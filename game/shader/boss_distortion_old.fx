// BOSS背景扭曲特效
// 适用于luastg+

// 由PostEffect过程捕获到的纹理
texture2D ScreenTexture:POSTEFFECTTEXTURE;  // 纹理
sampler2D ScreenTextureSampler = sampler_state {  // 采样器
    texture = <ScreenTexture>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = MIN_MAG_LINEAR_MIP_POINT;
};

// 自动设置的参数
float4 screen : SCREENSIZE;  // 屏幕缓冲区大小

// 外部参数
float centerX < string binding = "centerX"; > = 100.0f;  // 指定效果的中心坐标X
float centerY < string binding = "centerY"; > = 100.0f;  // 指定效果的中心坐标Y
float effectSize < string binding = "size"; > = 50.0f;  // 指定效果的影响大小
float effectArg < string binding = "arg"; > = 15.f;  // 变形系数
float4 effectColor < string binding = "color"; > = float4(163/255.f, 73/255.f, 164/255.f, 1.f);  // 指定效果的中心颜色
float effectColorSize < string binding = "colorsize"; > = 80.0f;  // 指定颜色的扩散大小

float Resampler(float input)
{
    // X^P * (1-X) + X^2
    return lerp(pow(input, (1 + effectArg)), input, input);
}

float4 PS_MainPass(float4 position:POSITION, float2 uv:TEXCOORD0):COLOR
{
    float2 screenSize = float2(screen.z - screen.x, screen.w - screen.y);
    float2 uvReal = uv * screenSize;  // 屏幕上真实位置
    float2 center = float2(centerX, centerY);
    float2 delta = uvReal - center;  // 计算效果中心到纹理采样点的向量
    float deltaLen = length(delta);
    delta = normalize(delta);
    
    // 若命中效果范围
    float newLen;
    if (deltaLen <= effectSize)
        newLen = effectSize * Resampler(deltaLen / effectSize);
    else
        newLen = deltaLen;
    
    // 对纹理进行采样
    float4 texColor = tex2D(ScreenTextureSampler, (center + delta * newLen) / screenSize);
    
    // 着色
    if(deltaLen <= effectColorSize)
        texColor = lerp(texColor, effectColor, 1 - deltaLen / effectColorSize);
 
    return texColor;
}

technique Main
{
    pass MainPass
    {
        PixelShader = compile ps_3_0 PS_MainPass();
    }
}
