#version 330 compatibility

/*
const int colortex4Format = R32I;
const bool colortex4Clear = false;
const float centerDepthHalflife = 0.001f;
*/

#include "tdof.glsl"

uniform int frameCounter;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferProjection;
uniform vec3 previousCameraPosition;
uniform vec3 cameraPosition;
uniform float centerDepthSmooth; // Only fragment shaders can enable centerDepthSmooth. FUNNY.

uniform isampler2D colortex4;

/* DRAWBUFFERS:4 */
layout (location = 0) out int beginFrame;

void main()
{
    if (shouldClear(gbufferPreviousModelView, gbufferModelView, gbufferPreviousProjection, gbufferProjection, previousCameraPosition, cameraPosition) || frameCounter == 0)
        beginFrame = frameCounter;
    else
        beginFrame = texelFetch(colortex4, ivec2(0, 0), 0)[0];
}