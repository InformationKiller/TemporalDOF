#version 330 compatibility

#include "tdof.glsl"

uniform isampler2D colortex4gbuffer;

uniform int frameCounter;
uniform float centerDepthSmooth;
uniform float near;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

out vec4 color;
out vec2 uv;

void main()
{
    gl_Position = gbufferProjection * gl_ModelViewMatrix * gl_Vertex;

    if (texelFetch(colortex4gbuffer, ivec2(0, 0), 0)[0] != frameCounter)
    {
        vec4 cam = gbufferProjectionInverse * vec4(0.0, 0.0, 1.0, 1.0);
        float far = -cam.z / cam.w;
        gl_Position = projection(frameCounter, centerDepthSmooth, near, far, gbufferProjectionInverse) * modelViewOffset(frameCounter) * gl_ModelViewMatrix * gl_Vertex;
    }

    color = gl_Color;
    uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}