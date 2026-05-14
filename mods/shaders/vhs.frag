
#pragma header

#define INTERLACING_RATE 5.0
#define INTERLACING_SEVERITY 0.0001
#define TRACKING_HEIGHT 0.0
#define TRACKING_SEVERITY 0.015
#define TRACKING_SPEED 0.2
#define SHIMMER_SPEED 30.0
#define RGB_MASK_SIZE 5.0

uniform float iTime;

void main()
{

    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;

    vec2 uv = openfl_TextureCoordv;
    
    // x wigglies (sampling error)
    uv.x -= sin(uv.y * 300.0 + iTime * INTERLACING_RATE) * INTERLACING_SEVERITY;
    
    float scan = mod(fragCoord.y, 3.0);
  
    // Convert our xy coordinates into a linear index we can use in
    // the next step
    // periodically offset y by 1 pixel to get that shimmer
    float yOffset = floor(sin(iTime * SHIMMER_SPEED));
    float pix = (fragCoord.y + yOffset) * openfl_TextureSize.x + fragCoord.x;
    pix = floor(pix);
    
    // Simulate pixel layout by using a repeating RGB mask
    vec4 colMask = vec4(mod(pix, RGB_MASK_SIZE), mod((pix + 1.0), RGB_MASK_SIZE), mod((pix + 2.0), RGB_MASK_SIZE), 1.0);
    colMask = colMask / (RGB_MASK_SIZE - 1.0) + 0.1;

    // Tracking
    float t = -iTime * TRACKING_SPEED;
    float fractionalTime = (t - floor(t)) * 1.3 - TRACKING_HEIGHT;
    if(fractionalTime + TRACKING_HEIGHT >= uv.y && fractionalTime <= uv.y)

    {
        uv.x -= fractionalTime * TRACKING_SEVERITY;
    }
    
    gl_FragColor = flixel_texture2D(bitmap, uv) * colMask * scan;
}
