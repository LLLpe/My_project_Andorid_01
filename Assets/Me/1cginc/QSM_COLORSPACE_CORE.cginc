#ifndef QSM_COLORSPACE_CORE
#define QSM_COLORSPACE_CORE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
#include "QSM_COLORSPACE_BASIC.cginc"


//==============【other function】============
half3 DecodeSpecCubeLOD(half3 reflectVector, half mip)
{
	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
	return DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR).rgb;
}

//==============【实际使用】============
// 默认使用 optimized版本
half4 GammaToLinear_float4_Actual(half4 value)
{
	return GammaToLinear_float4(value);
}

half3 LinearToGamma_float3_Actual(half3 value)
{
	return LinearToGamma(value);
}

half4 LinearToGamma_float4_Actual(half4 value)
{
	return half4(LinearToGamma_float3_Actual(value.rgb), value.a);
}

half4 LinearToGamma_float4_Blit(half4 value)
{
	return half4(LinearToGamma_Fast(value.rgb), value.a);
}

half4 GammaToLinear_float_Blit(half4 value)
{
	return GammaToLinear_float4_Fast(value);
}

//==============【应用】============
half4 tex2D_LinearToGamma_float4(sampler2D textureData, float2 uv)
{
	half4 texColor = tex2D(textureData, uv);
	return LinearToGamma_float4_Actual(texColor);
}

half4 tex2D_GammaToLinear_float4(sampler2D textureData, float2 uv)
{
	half4 texColor = tex2D(textureData, uv);
	return GammaToLinear_float4(texColor);
}

half3 DecodeLightmap_LinearToGamma(real4 color)
{
	half3 res = DecodeLightmap(color);
	return LinearToGamma_float3_Actual(res);
}

half4 texCube_LinearToGamma_float4(samplerCUBE textureData, float3 uvw)
{
	half4 value = texCUBE(textureData, uvw);
	return LinearToGamma_float4_Actual(value);
}

half4 texCubelod_LinearToGamma_float4(samplerCUBE textureData, float4 xyzw)
{
	half4 value = texCUBElod(textureData, xyzw);
	return LinearToGamma_float4_Actual(value);
}

half4 texCubeBias_LinearToGamma_float4(samplerCUBE textureData, float4 xyzw)
{
	half4 value = texCUBEbias(textureData, xyzw);
	return LinearToGamma_float4_Actual(value);
}

half3 DecodeSpecCubeLOD_LinearToGamma(half3 reflectVector, half mip)
{
	return LinearToGamma_float3_Actual(DecodeSpecCubeLOD(reflectVector, mip));
}
half _InverseToneMappingIntensity;
half3 InverseBloomAndTonemappingApproximate(half3 x)
{
	half3 result;

	// reverse tonemapping
	/*const float A = 1.38389819279849;
	const float B = -1.21317281599074;
	const float C = 0.846698393516273;
	const float D = 0;
	result = clamp((C * pow((A - D) / (saturate(x) - D) - 1, 1 / B)), 0, 3);*/
	const half A = 1.384;
	const half B = -1.213;
	const half C = 0.847;
	result = clamp((C * pow(A / saturate(x) - 1, 1 / B)), 0, 3);

	// reverse bloom
	result = result * _InverseToneMappingIntensity;

	return result;
}

//使用多项式拟合以及乘加优化
half3 InverseBloomAndTonemappingPolynomialApproximate(half3 x)
{
    //Y = a + b·X + c·X2 + d·X3 + e·X4 + f·X5
	const half a = -0.00164086073460323;
    const half b = 1.40206294284724;
    const half c = -4.31323162167694;
    const half d = 14.1046455959537;
    const half e = -18.0415158599774;
    const half f = 8.82081029715001;
        
    half3 o = f * x + e;
          o = o * x + d;
          o = o * x + c;
          o = o * x + b;
          o = o * x + a;
	return clamp(o,0, 3) * _InverseToneMappingIntensity;
}

float _DebugInverseToneMapping;
float _InverseToneMapping;
// output
// 使用说明：
//	1. shader定义SHADER_CALC_GAMMA宏（一般老资源才需要，标记shader为gamma计算空间），新资源默认为linear计算空间，不需定义此宏
//	2. 特效定义shaderfeature NSS_FRAMEBUFFER_GAMMA，[Toggle(NSS_FRAMEBUFFER_GAMMA)]_EnableFxUI("UI effect", Float) = 0 如果是UI特效则材质编辑器中勾选它
//	3. NSS_OUTPUT_COLOR_SPACE用在fragment shader return语句
//  4. EFFECT_ANLAYZE_ENV 特效MRT分析环境，EFFECT_ANLAYZE_KEEPGAMMA老特效gamma路径
//  5. TURN_OFF_LINEAR_CORRECT 关闭补偿校正
#ifdef SOURCEALPHA_ONE_ADDITIVE					
	#define BLEND_CORRECT(result) half4(saturate(result.rgb * sqrt(result.a + 1.0/max(result.rgb, 0.01))), result.a)					
#elif ONE_ONE_ADDITIVE			
	#define BLEND_CORRECT(result)  half4(saturate(result.rgb * sqrt(1.0 + 1.0/max(result.rgb, 0.01))), result.a)					
#else//source:source_alpha  dest: 1 - source_alpha
	#define BLEND_CORRECT(result) result
#endif	

float _IsFramebufferGamma;
half4 NSS_OUTPUT_COLOR_SPACE(half4 input)
{

	half4 output = 0;
#ifdef SHADER_CALC_GAMMA
	if (_IsFramebufferGamma > 0.001)
		output =  input;
	else
	{

		//linear space下和gamma space下的blend差异补偿
		output = GammaToLinear_float4_Fast(BLEND_CORRECT(input));
	}
#else

	UNITY_BRANCH
	if (_IsFramebufferGamma > 0.001)
		output = half4(LinearToGamma_Fast(input.rgb), input.a);
	else
		output = input;
#endif

	return output;
}

half4 NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4 input)
{
	half4 output = NSS_OUTPUT_COLOR_SPACE(input);

	UNITY_BRANCH
	if (_InverseToneMapping > 0.1)
	{
		//output.rgb = lerp(InverseBloomAndTonemappingApproximate(output.rgb), 1, _DebugInverseToneMapping);
		output.rgb = InverseBloomAndTonemappingPolynomialApproximate(output.rgb);
	}

	return output;
}

half4 NSS_OUTPUT_COLOR_SPACE_FX(half4 input)
{
#ifdef SHADER_CALC_GAMMA
	input = saturate(input);
	if (_IsFramebufferGamma > 0.001)
		return input;
	else
	{
		//linear space下和gamma space下的blend差异补偿
		return GammaToLinear_float4_Fast(BLEND_CORRECT(input));
	}
#else
	UNITY_BRANCH
	if (_IsFramebufferGamma > 0.001)
		return half4(LinearToGamma_Fast(input.rgb), input.a);
	else
		return input;
#endif
}

// tex2D -> NSS_TEX2D_COLORSPACE/NSS_TEX2D_LINEAR_TO_GAMMA/NSS_TEX2D_GAMMA_TO_LINEAR
#ifdef GAMMA_TEXTURE
	#define NSS_TEX2D_COLORSPACE(textureData, uv) NSS_TEX2D_GAMMA_TO_LINEAR(textureData, uv)
#else
	#define NSS_TEX2D_COLORSPACE(textureData, uv) tex2D(textureData, uv)
#endif

#define NSS_TEX2D_LINEAR_TO_GAMMA(textureData, uv) tex2D_LinearToGamma_float4(textureData, uv)

#define NSS_TEX2D_GAMMA_TO_LINEAR(textureData, uv) tex2D_GammaToLinear_float4(textureData, uv)

// lightmap -> NSS_DECODE_LIGHTMAP_COLORSPACE
#ifdef SHADER_CALC_GAMMA
	#define NSS_DECODE_LIGHTMAP_COLORSPACE(data) DecodeLightmap_LinearToGamma(data)
#else
	#define NSS_DECODE_LIGHTMAP_COLORSPACE(data) DecodeLightmap(data)
#endif

// texCUBE -> NSS_TEXCUBE_COLORSPACE
#ifdef SHADER_CALC_GAMMA
	#define NSS_TEXCUBE_COLORSPACE(textureData, uv) texCube_LinearToGamma_float4(textureData, uv)
#else
	#define NSS_TEXCUBE_COLORSPACE(textureData, uv) texCUBE(textureData, uv)
#endif

// texCUBElod -> NSS_TEXCUBELOD_COLORSPACE
#ifdef SHADER_CALC_GAMMA
	#define NSS_TEXCUBELOD_COLORSPACE(textureData, xyzw) texCubelod_LinearToGamma_float4(textureData, xyzw)
#else
	#define NSS_TEXCUBELOD_COLORSPACE(textureData, xyzw) texCUBElod(textureData, xyzw)
#endif

// texCUBEbias -> NSS_TEXCUBEBIAS_COLORSPACE
#ifdef SHADER_CALC_GAMMA
#define NSS_TEXCUBEBIAS_COLORSPACE(textureData, xyzw) texCubeBias_LinearToGamma_float4(textureData, xyzw)
#else
#define NSS_TEXCUBEBIAS_COLORSPACE(textureData, xyzw) texCUBEbias(textureData, xyzw)
#endif

// UNITY_SAMPLE_TEXCUBE_LOD unity_SpecCube0 and decode -> NSS_DECODE_TEXCUBE_LOD_COLORSPACE
#ifdef SHADER_CALC_GAMMA
	#define NSS_DECODE_SPEC_CUBE_LOD_COLORSPACE(reflectVector, mip) DecodeSpecCubeLOD_LinearToGamma(reflectVector, mip)
#else
	#define NSS_DECODE_SPEC_CUBE_LOD_COLORSPACE(reflectVector, mip) DecodeSpecCubeLOD(reflectVector, mip)
#endif

	
#endif
