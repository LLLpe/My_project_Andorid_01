#ifndef QSM_COLORSPACE_BASIC
#define QSM_COLORSPACE_BASIC

// 去除warning: pow(f, e) will not work for negative f, use abs(f) or conditionally handle negative
#pragma warning (disable : 3571)

// todo 去除其他地方使用的 转化实现，统一使用本文件实现


//=======【Exact version】=======
inline half GammaToLinear_Exact(half value)
{
	if (value <= 0.04045F)
		return value / 12.92F;
	else if(value < 1.0F)
		return pow((value + 0.055F) / 1.055F, 2.4F);
	else
		return pow(value, 2.2F);
}
	
	
inline half LinearToGamma_Exact(half value)
{
	if (value <= 0.0F)
		return 0.0F;
	else if(value <= 0.0031308F)
		return 12.92F * value;
	else if(value < 1.0F)
		return 1.055F * pow(value, 0.4166667F) - 0.055F;
	else
		return pow(value, 0.45454545F);
}

inline half3 GammaToLinear_float3_Exact(half3 value)
{
	return half3(GammaToLinear_Exact(value.r), GammaToLinear_Exact(value.g), GammaToLinear_Exact(value.b));
}

inline half3 LinearToGamma_float3_Exact(half3 value)
{
	return half3(LinearToGamma_Exact(value.r), LinearToGamma_Exact(value.g), LinearToGamma_Exact(value.b));
}

half4 GammaToLinear_float4_Exact(half4 value)
{
	return half4(GammaToLinear_float3_Exact(value.rgb), value.a);
}

half4 LinearToGamma_float4_Exact(half4 value)
{
	return half4(LinearToGamma_float3_Exact(value.rgb), value.a);
}
	
	
//=======【Optimized version】======= 推荐使用

// Approximate version from http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
half3 GammaToLinear(half3 value)
{
	return value * (value * (value * 0.305306011h + 0.682171111h) + 0.012522878h);
}
	
half4 GammaToLinear_float4(half4 value)
{
	return half4(value.rgb * (value.rgb * (value.rgb * 0.305306011h + 0.682171111h) + 0.012522878h), value.a);
}	
	
// An almost-perfect approximation from http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
half3 LinearToGamma(half3 linRGB)
{
	half3 S1 = sqrt(linRGB);
	half3 S2 = sqrt(S1);
	half3 S3 = sqrt(S2);
	half3 value = 0.585122381 * S1 + 0.783140355 * S2 - 0.368262736 * S3;
	return value;
}

half4 LinearToGamma_float4(half4 linRGB)
{
	half3 S1 = sqrt(linRGB.rgb);
	half3 S2 = sqrt(S1);
	half3 S3 = sqrt(S2);
	half3 value = 0.585122381 * S1 + 0.783140355 * S2 - 0.368262736 * S3;
	return half4(value, linRGB.a);
}

half3 LinearToGamma_22(half3 linRGB)
{
	half3 value =pow(linRGB, 0.4545454545);
	return value;
}
	
// ============= 【2.2 version】==============
half4 GammaToLinear_float4_22(half4 GammaColor)
{
	return half4(pow(GammaColor.rgb, 2.2), GammaColor.a);
}
	
//==============【Simple version】============
	
//------float version-----
	
half3 GammaToLinear_Fast(half3 GammaColor)
{
	return GammaColor * GammaColor;
}
	
half4 GammaToLinear_float4_Fast(half4 GammaColor)
{
	return half4(GammaColor.rgb * GammaColor.rgb, GammaColor.a);
}
	
half3 LinearToGamma_Fast(half3 linearColor)
{	
	linearColor = max(linearColor, half3(0.0001h, 0.0001h, 0.0001h));
	return sqrt(linearColor);
}

half3 LinearToGamma_Fast_EX(half3 linearColor)
{	
	linearColor = max(linearColor, half3(0.h, 0.h, 0.h));
	// An almost-perfect approximation from http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
	return max(1.055h * pow(linearColor, 0.416666667h) - 0.055h, 0.h);
}		
	
half4 LinearToGamma_float4_Fast(half4 linearColor)
{
	return half4(sqrt(linearColor.rgb), linearColor.a);
}
	
#endif
