#version 330 compatibility

uniform sampler2D colortex1;

in vec2 uv;

void main()
{
    gl_FragData[0] = texture(colortex1, uv);
    gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(2.2));
}