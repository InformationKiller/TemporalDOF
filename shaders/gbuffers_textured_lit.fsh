#version 330 compatibility

uniform sampler2D tex;
uniform sampler2D lightmap;

in vec4 color;
in vec2 uv;
in vec2 lm;

/* DRAWBUFFERS:0 */
void main()
{
    gl_FragData[0] = texture(tex, uv) * texture(lightmap, lm) * color;
    gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(1.0 / 2.2));
}