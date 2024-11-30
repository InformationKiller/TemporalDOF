#version 330 compatibility

/*
const int colortex0Format = RGBA16;
const int colortex1Format = RGB32F;
const bool colortex1Clear = false;
*/

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform isampler2D colortex4;

uniform int frameCounter;

in vec2 uv;

/* DRAWBUFFERS:1 */
void main()
{
    int begin = texelFetch(colortex4, ivec2(0, 0), 0)[0];
    int curr = frameCounter + 1;
    float delta = float(curr - begin);

    gl_FragData[0] = 1.0 / delta * texture(colortex0, uv) + (delta - 1.0) / delta * texture(colortex1, uv);
}