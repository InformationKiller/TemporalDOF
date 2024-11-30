#version 330 compatibility

uniform sampler2D tex;
uniform int renderStage;

in vec4 color;
in vec2 uv;

/* DRAWBUFFERS:0 */
void main()
{
    gl_FragData[0] = texture(tex, uv) * color;
    if (renderStage != MC_RENDER_STAGE_SUN && renderStage != MC_RENDER_STAGE_MOON)
    {
        gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(1.0 / 2.2));
    }
}