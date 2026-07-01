// THANK YOU VIRTU I LOVE YOU (no homo)

#pragma header

uniform vec3 filling = vec3(0.0, 0.0, 0.0);
uniform vec3 outline = vec3(1.0, 1.0, 1.0);
uniform float threshold = 0.1;

void main()
{
    vec4 color = texture2D(bitmap, openfl_TextureCoordv);

    float average = (color.r + color.g + color.b) / 3.0;

    color.rgb = outline;

    if (average > threshold) {
        color.rgb = filling;
    }

    if (color.a > 0.0)
    {
        gl_FragColor = color;
    }
}