#version 330 compatibility

uniform int renderStage;

in vec4 color;

/* DRAWBUFFERS:0 */
void main()
{
    gl_FragData[0] = color;
    gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(1.0 / 2.2));
}