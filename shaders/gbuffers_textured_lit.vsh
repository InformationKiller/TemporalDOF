#version 330 compatibility

#include "tdof.glsl"

uniform isampler2D colortex4gbuffer;

uniform int frameCounter;
uniform float centerDepthSmooth;
uniform float near;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform int renderStage;

out vec4 color;
out vec2 uv;
out vec2 lm;

void main()
{
    gl_Position = gbufferProjection * gl_ModelViewMatrix * gl_Vertex;

    if (texelFetch(colortex4gbuffer, ivec2(0, 0), 0)[0] != frameCounter)
    {
        vec4 cam = gbufferProjectionInverse * vec4(0.0, 0.0, 1.0, 1.0);
        float far = -cam.z / cam.w;
        gl_Position = projection(frameCounter, centerDepthSmooth, near, far, gbufferProjectionInverse) * modelViewOffset(frameCounter) * gl_ModelViewMatrix * gl_Vertex;
    }

    if (renderStage == MC_RENDER_STAGE_HAND_SOLID || renderStage == MC_RENDER_STAGE_HAND_TRANSLUCENT)
    {
        gl_Position.z *= MC_HAND_DEPTH;
    }

    color = gl_Color;
    uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lm = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}