#define APERTURE 8 // Diameter [1 2 3 4 5 6 7 8 9 10]
#define HEX

bool compareMat4(mat4 a, mat4 b)
{
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            if (abs(a[i][j] - b[i][j]) > 0.00001)
            {
                return false;
            }
        }
    }
    return true;
}

bool compareVec3(vec3 a, vec3 b)
{
    return distance(a, b) < 0.00001;
}

float random(float seed)
{
    return fract(sin(seed * 0.012989) * 43758.5453123);
}

vec2 randomPointCircle(float seed)
{
    float hexSize = 1.0;
    float angle = random(seed) * 6.28318530718;
    float r = hexSize * sqrt(random(seed * 2.0));

    return vec2(r * cos(angle), r * sin(angle)) * 0.005 * APERTURE;
}

vec2 randomPointHex(float seed)
{
    float hexSize = 1.0;
    float angle = random(seed) * 6.28318530718;
    float r = hexSize * sqrt(random(seed * 2.0));

    vec2 point = vec2(r * cos(angle), r * sin(angle));
    vec2 q = abs(point);
    q = q.x <= hexSize && q.y <= hexSize * sqrt(3.0) / 2.0 && q.y + q.x * sqrt(3.0) <= hexSize * sqrt(3.0) ? point : point * sqrt(3.0) / 2.0;

    return q * 0.005 * APERTURE;
}

vec2 randomPoint(float seed)
{
#ifdef HEX
    return randomPointHex(seed);
#else
    return randomPointCircle(seed);
#endif
}

mat4 perspectiveMatrix(vec3 v, float zNear, float zFar)
{
    float tanHalfFovx = abs(v.x / v.z);
    float tanHalfFovy = abs(v.y / v.z);

    mat4 result = mat4(0.0);
    result[0][0] = 1.0 / tanHalfFovx;
    result[1][1] = 1.0 / tanHalfFovy;
    result[2][2] = -(zFar + zNear) / (zFar - zNear);
    result[2][3] = -1.0;
    result[3][2] = -(2.0 * zFar * zNear) / (zFar - zNear);
    
    return result;
}

mat4 computeTransformMatrix(vec3 src[4], vec3 dst[4]) {
    vec2 srcCenter = (src[0].xy + src[1].xy + src[2].xy + src[3].xy) / 4.0;
    float srcWidth = distance(src[0], src[1]);
    float srcHeight = distance(src[0], src[3]);

    vec2 dstCenter = (dst[0].xy + dst[1].xy + dst[2].xy + dst[3].xy) / 4.0;
    float dstWidth = distance(dst[0], dst[1]);
    float dstHeight = distance(dst[0], dst[3]);

    float scaleX = dstWidth / srcWidth;
    float scaleY = dstHeight / srcHeight;

    vec2 translation = dstCenter - srcCenter;

    mat4 scaleMatrix = mat4(1.0);
    scaleMatrix[0][0] = scaleX;
    scaleMatrix[1][1] = scaleY;

    mat4 translationMatrix = mat4(1.0);
    translationMatrix[3].xy = translation;

    return scaleMatrix * translationMatrix;
}

// PUBLIC ==========================================================================

bool shouldClear(mat4 pm, mat4 m, mat4 pp, mat4 p, vec3 pc, vec3 c)
{
    return !compareMat4(pm, m) || !compareMat4(pp, p) || !compareVec3(pc, c);
}

mat4 modelViewOffset(int frame)
{
    vec2 offset = randomPoint(frame);
    return mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        -offset.x, -offset.y, 0.0, 1.0
    );
}

mat4 projection(int frame, float depth, float zNear, float zFar, mat4 projinv)
{
    vec4 focus = projinv * vec4(0.0, 0.0, depth * 2.0 - 1.0, 1.0);
    focus /= focus.w;

    vec3 corners[4] = vec3[4](
        vec3(-1.0, -1.0, 0.0),
        vec3(1.0, -1.0, 0.0),
        vec3(1.0, 1.0, 0.0),
        vec3(-1.0, 1.0, 0.0)
    );

    vec3 shiftedCorners[4];
    for (int i = 0; i < 4; i++) {
        vec4 cam = projinv * vec4(corners[i], 1.0);
        cam /= cam.w;
        shiftedCorners[i] = (modelViewOffset(frame) * vec4(-focus.z / dot(vec3(0.0, 0.0, -1.0), normalize(cam.xyz)) * normalize(cam.xyz), 1.0)).xyz;
    }

    vec3 biggestFov = shiftedCorners[0];
    for (int i = 1; i < 4; i++) {
        if (length(shiftedCorners[i].xy) > length(biggestFov.xy)) {
            biggestFov = shiftedCorners[i];
        }
    }

    mat4 projectionMatrix = perspectiveMatrix(biggestFov, zNear, zFar);

    for (int i = 0; i < 4; i++) {
        vec4 p = projectionMatrix * vec4(shiftedCorners[i], 1.0);
        shiftedCorners[i] = p.xyz / p.w;
    }

    return computeTransformMatrix(shiftedCorners, corners) * projectionMatrix;
}