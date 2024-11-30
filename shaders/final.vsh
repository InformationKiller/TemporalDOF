#version 330 compatibility

out vec2 uv;

void main()
{
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}