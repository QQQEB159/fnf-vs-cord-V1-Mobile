//SHADERTOY PORT FIX
#pragma header

uniform float iTime;
uniform sampler2D iChannel1;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

vec2 fragCoord;
//SHADERTOY PORT FIX

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43.5453);
}

float smoothNoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    return mix(mix(noise(i), noise(i + vec2(1.0, 0.0)), f.x * f.x * (3.0 - 2.0 * f.x)),
               mix(noise(i + vec2(0.0, 1.0)), noise(i + vec2(1.0, 1.0)), f.x * f.x * (3.0 - 2.0 * f.x)),
               f.y * f.y * (3.0 - 2.0 * f.y));
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    mat2 rot = mat2(1.0, 0.0, 0.0, 1.0);
    for (int i = 0; i < 5; i++, a *= 0.5, p = rot * p + vec2(100.0, 100.0))
        v += a * smoothNoise(p);
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 iResolution = openfl_TextureSize;
    fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    
    vec2 uv = (fragCoord.xy / iResolution.xy - 0.3) * vec2(iResolution.x / iResolution.y, -1.5);
    float flame = smoothstep(0.2, 1.0, uv.y + fbm(uv * vec2(100.0, 100.0) + vec2(0.0, iTime * 0.5)) * 0.5);
    fragColor = vec4(mix(vec3(0.0), vec3(0.3), flame), 1.0);  // Inverted colors
}
