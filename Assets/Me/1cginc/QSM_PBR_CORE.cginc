#ifndef QSM_PBR_CORE
#define QSM_PBR_CORE

#include "QSM_COLORSPACE_CORE.cginc"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/ResForAssetBundles/0BaseCommon/Include/LegacyCommon.hlsl"
		   #include "QSM_BASE_MACRO.cginc"

	//===================================================================================================
	// Pre Common Function
	//===================================================================================================

	inline half NssPow4 (half x)
	{
		return x*x*x*x;
	}

	inline half2 NssPow4 (half2 x)
	{
		return x*x*x*x;
	}

	inline half3 NssPow4 (half3 x)
	{
		return x*x*x*x;
	}

	inline half4 NssPow4 (half4 x)
	{
		return x*x*x*x;
	}
		

	//===================================================================================================
	//核心Shading Model部分
	//===================================================================================================
	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
	float D_GGX_USER_DEFINE(float Roughness, float NoH)
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float d = NoH * NoH * a2 - NoH * NoH + 1;	// ( (NoH * a2 - NoH) * NoH + 1 写法会导致编译器NaN)2 mad
		return a2 / (max(PI * d * d , 0.001));					// 4 mul, 1 rcp
	}


	float Vis_Implicit()
	{
		return 0.25f;
	}

	//改进[Schlick 1994] ：pow5改pow4，节省一次mul instruction
	// [GDC 2014] Physically Based Shading in Unity 
	// Fresnel approximation with 4.0 power
	half3 F_Schlick_Fast(half HdotV, half3 F0)
	{
		return F0 + (1 - F0) * NssPow4(1 - HdotV);
	}

		
	half3 Diffuse_Lambert(half3 DiffuseColor)
	{
		return DiffuseColor;
	}

	//===================================================================================================
	// common function
	//===================================================================================================
	
	float Square(float x)
	{
		return x * x;
	}
	
	float2 Square(float2 x)
	{
		return x * x;
	}
	
	float3 Square(float3 x)
	{
		return x * x;
	}
	
	float4 Square(float4 x)
	{
		return x * x;
	}

	
	
	// Pow5 uses the same amount of instructions as generic pow(), but has 2 advantages:
	// 1) better instruction pipelining
	// 2) no need to worry about NaNs
	inline half NssPow5 (half x)
	{
		return x*x * x*x * x;
	}

	inline half2 NssPow5 (half2 x)
	{
		return x*x * x*x * x;
	}

	inline half3 NssPow5 (half3 x)
	{
		return x*x * x*x * x;
	}

	inline half4 NssPow5 (half4 x)
	{
		return x*x * x*x * x;
	}
	


	//===================================================================================================
	// BRDF
	//===================================================================================================
	
	

	
	// [Burley 2012, "Physically-Based Shading at Disney"]
	float3 Diffuse_Burley_Disney(float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH)
	{
		float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
		float FdV = 1 + (FD90 - 1) * NssPow5(1 - NoV);
		float FdL = 1 + (FD90 - 1) * NssPow5(1 - NoL);
		return DiffuseColor * ((1 / PI) * FdV * FdL);
	}
	
	// [Gotanda 2012, "Beyond a Simple Physically Based Blinn-Phong Model in Real-Time"]
	float3 Diffuse_OrenNayar(float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH)
	{
		float a = Roughness * Roughness;
		float s = a;// / ( 1.29 + 0.5 * a );
		float s2 = s * s;
		float VoL = 2 * VoH * VoH - 1;		// double angle identity
		float Cosri = VoL - NoV * NoL;
		float C1 = 1 - 0.5 * s2 / (s2 + 0.33);
		float C2 = 0.45 * s2 / (s2 + 0.09) * Cosri * (Cosri >= 0 ? 1 / (max(NoL, NoV)): 1);
		return DiffuseColor / PI * (C1 + C2) * (1 + Roughness * 0.5);
	}
	
	// [Gotanda 2014, "Designing Reflectance Models for New Consoles"]
	float3 Diffuse_Gotanda(float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH)
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float F0 = 0.04;
		float VoL = 2 * VoH * VoH - 1;		// double angle identity
		float Cosri = VoL - NoV * NoL;
		#if 1
			float a2_13 = a2 + 1.36053;
			float Fr = (1 - (0.542026 * a2 + 0.303573 * a) / a2_13) * (1 - pow(1 - NoV, 5 - 4 * a2) / a2_13) * ((-0.733996 * a2 * a + 1.50912 * a2 - 1.16402 * a) * pow(1 - NoV, 1 + 1 / (39 * a2 * a2 + 1)) + 1);
			//float Fr = ( 1 - 0.36 * a ) * ( 1 - pow( 1 - NoV, 5 - 4*a2 ) / a2_13 ) * ( -2.5 * Roughness * ( 1 - NoV ) + 1 );
			float Lm = (max(1 - 2 * a, 0) * (1 - NssPow5(1 - NoL)) + min(2 * a, 1)) * (1 - 0.5 * a * (NoL - 1)) * NoL;
			float Vd = (a2 / ((a2 + 0.09) * (1.31072 + 0.995584 * NoV))) * (1 - pow(1 - NoL, (1 - 0.3726732 * NoV * NoV) / (0.188566 + 0.38841 * NoV)));
			float Bp = Cosri < 0 ? 1.4 * NoV * NoL * Cosri: Cosri;
			float Lr = (21.0 / 20.0) * (1 - F0) * (Fr * Lm + Vd + Bp);
			return DiffuseColor / PI * Lr;
		#else
			float a2_13 = a2 + 1.36053;
			float Fr = (1 - (0.542026 * a2 + 0.303573 * a) / a2_13) * (1 - pow(1 - NoV, 5 - 4 * a2) / a2_13) * ((-0.733996 * a2 * a + 1.50912 * a2 - 1.16402 * a) * pow(1 - NoV, 1 + rcp(39 * a2 * a2 + 1)) + 1);
			float Lm = (max(1 - 2 * a, 0) * (1 - NssPow5(1 - NoL)) + min(2 * a, 1)) * (1 - 0.5 * a + 0.5 * a * NoL);
			float Vd = (a2 / ((a2 + 0.09) * (1.31072 + 0.995584 * NoV))) * (1 - pow(1 - NoL, (1 - 0.3726732 * NoV * NoV) / (0.188566 + 0.38841 * NoV)));
			float Bp = Cosri < 0 ? 1.4 * NoV * Cosri: Cosri / max(NoL, 1e-8);
			float Lr = (21.0 / 20.0) * (1 - F0) * (Fr * Lm + Vd + Bp);
			return DiffuseColor / PI * Lr;
		#endif
	}
	
	#define MaterialFloat half
	// Clamp the base, so it's never <= 0.0f (INF/NaN).
	MaterialFloat ClampedPow(MaterialFloat X, MaterialFloat Y)
	{
		return pow(max(abs(X), 0.000001f), Y);
	}
	
	/**
	* Use this function to compute the pow() in the specular computation.
	* This allows to change the implementation depending on platform or it easily can be replaced by some approxmation.
	*/
	MaterialFloat PhongShadingPow(MaterialFloat X, MaterialFloat Y)
	{
		// The following clamping is done to prevent NaN being the result of the specular power computation.
		// Clamping has a minor performance cost.
		
		// In HLSL pow(a, b) is implemented as exp2(log2(a) * b).
		
		// For a=0 this becomes exp2(-inf * 0) = exp2(NaN) = NaN.
		
		// As seen in #TTP 160394 "QA Regression: PS3: Some maps have black pixelated artifacting."
		// this can cause severe image artifacts (problem was caused by specular power of 0, lightshafts propagated this to other pixels).
		// The problem appeared on PlayStation 3 but can also happen on similar PC NVidia hardware.
		
		// In order to avoid platform differences and rarely occuring image atrifacts we clamp the base.
		
		// Note: Clamping the exponent seemed to fix the issue mentioned TTP but we decided to fix the root and accept the
		// minor performance cost.
		
		return ClampedPow(X, Y);
	}
	
	// [Blinn 1977, "Models of light reflection for computer synthesized pictures"]
	float D_Blinn(float Roughness, float NoH)
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float n = 2 / a2 - 2;
		return(n + 2) / (2 * PI) * PhongShadingPow(NoH, n);		// 1 mad, 1 exp, 1 mul, 1 log
	}
	
	
	
	
	// [Beckmann 1963, "The scattering of electromagnetic waves from rough surfaces"]
	float D_Beckmann(float Roughness, float NoH)
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float NoH2 = NoH * NoH;
		return exp((NoH2 - 1) / (a2 * NoH2)) / (PI * a2 * NoH2 * NoH2 );
	}
	

	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
	float D_GGX_USER_DEFINE_( float a2, float NoH )
	{
		float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
		return a2 / ( PI*d*d + 0.0001);					// 4 mul, 1 rcp
	}


	// [reference : SIGGRAPH 2010 , COD : OP1]
	half D_NssBlinn_EX(half Roughness, half NoH)
	{
		return pow(NoH, pow(8192, 1 - Roughness));
	}
	
	half D_NssBlinn(half Roughness, half NoH)
	{
		half n =  1- Roughness * Roughness;
		return 0.0397 * pow(NoH, n); // 0.0397 = 1 / 8PI
	}
	
	// [Brian Karis. 2014. Physically Based Shading on Mobile.]
	// Blinn approximated with a radially symmetric Phong lobe
	// https://www.unrealengine.com/zh-CN/blog/physically-based-shading-on-mobile?sessionInvalidated=true
	// float D_Approx( half Roughness, half RoL )
	// {
	// 	float a = Roughness * Roughness;
	// 	float a2 = a * a;
	// 	float rcp_a2 = rcp(a2);
	// 	// 0.5 / ln(2), 0.275 / ln(2)
	// 	float c = 0.72134752 * rcp_a2 + 0.39674113;
	// 	return rcp_a2 * exp2( c * RoL - c );
	// }
	
	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
	float D_GGX_USER_DEFINE_UE4_NSS(float Roughness, float NoH)
	{
		float a2 = Roughness * Roughness;
		//float a2 = a * a;
		float d = (NoH * a2 - NoH) * NoH + 1;	// 2 mad
		return a2 / (PI * d * d + 1e-7f);					// 4 mul, 1 rcp
	}
	
	
	//------------------------[UE4  MoblieGGX.ush]-----------------------------------------
	
	// Note: comment out to assume fp32 computations
	#ifndef MOBILE_GGX_USE_FP16
		#define MOBILE_GGX_USE_FP16 1
	#endif
	
	#define MEDIUMP_FLT_MAX    65504.0
	#define MEDIUMP_FLT_MIN    0.00006103515625
	
	#if MOBILE_GGX_USE_FP16
		#define saturateMediump(x) min(x, MEDIUMP_FLT_MAX)
	#else
		#define saturateMediump(x) (x)
	#endif
	
	// Taken from https://gist.github.com/romainguy/a2e9208f14cae37c579448be99f78f25
	// Modified by Epic Games, Inc. To account for premultiplied light color and code style rules.
	
	half D_GGX_USER_DEFINE_UE4_NSS_MOBILE(half Roughness, half NoH, half3 H, half3 N)
	{
		// Walter et al. 2007, "Microfacet Models for Refraction through Rough Surfaces"
		
		// In mediump, there are two problems computing 1.0 - NoH^2
		// 1) 1.0 - NoH^2 suffers floating point cancellation when NoH^2 is close to 1 (highlights)
		// 2) NoH doesn't have enough precision around 1.0
		// Both problem can be real by computing 1-NoH^2 in highp and providing NoH in highp as well
		
		// However, we can do better using Lagrange's identity:
		//      ||a x b||^2 = ||a||^2 ||b||^2 - (a . b)^2
		// since N and H are unit vectors: ||N x H||^2 = 1.0 - NoH^2
		// This computes 1.0 - NoH^2 directly (which is close to zero in the highlights and has
		// enough precision).
		// Overall this yields better performance, keeping all computations in mediump
		
		// 用1.0 - NoH ^ 2代替 cross(N, H)，精度足够，更省性能
		
		#if MOBILE_GGX_USE_FP16
			float3 NxH = cross(N, H);
			float OneMinusNoHSqr = dot(NxH, NxH);
		#else
			float OneMinusNoHSqr = 1.0 - NoH * NoH;
		#endif
		
		half a = Roughness * Roughness;
		float n = NoH * a;
		float p = a / (OneMinusNoHSqr + n * n);
		float d = p * p;
		return saturateMediump(d);
	}
	
	//-----------------------------------------------------
	
	// Anisotropic GGX
	// [Burley 2012, "Physically-Based Shading at Disney"]
	float D_GGX_USER_DEFINEaniso(float RoughnessX, float RoughnessY, float NoH, float3 H, float3 X, float3 Y)
	{
		float ax = RoughnessX * RoughnessX;
		float ay = RoughnessY * RoughnessY;
		float XoH = dot(X, H);
		float YoH = dot(Y, H);
		float d = XoH * XoH / (ax * ax) + YoH * YoH / (ay * ay) + NoH * NoH;
		return 1.0f / (PI * ax * ay * d * d);
	}

	
	// [Neumann et al. 1999, "Compact metallic reflectance models"]
	float Vis_Neumann(float NoV, float NoL)
	{
		return 1.0f / (4 * max(NoL, NoV));
	}
	
	// [Kelemen 2001, "A microfacet based coupled specular-matte brdf model with importance sampling"]
	float Vis_Kelemen(float VoH)
	{
		// constant to prevent NaN
		return 1.0f / (4 * VoH * VoH + 1e-5);
	}
	
	// Tuned to match behavior of Vis_Smith
	// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
	float Vis_Schlick(float Roughness, float NoV, float NoL)
	{
		float k = Square(Roughness) * 0.5;
		float Vis_SchlickV = NoV * (1 - k) + k;
		float Vis_SchlickL = NoL * (1 - k) + k;
		
		//分母加一个小值，防止除0
		return 0.25f / (Vis_SchlickV * Vis_SchlickL + 0.0001);
	}
	
	
	
	float GeometrySchlickGGX(real NdotV, real roughness)
	{
		float r = (roughness + 1.0);
		float k = (r * r) / 8.0;
		
		float nom = NdotV;
		float denom = NdotV * (1.0 - k) + k;
		
		return nom / denom;
	}
	
	// Tuned to match behavior of Vis_Smith
	// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
	float G_Schlick(real3 N, real3 V, real3 L, real roughness)
	{
		float NdotV = max(dot(N, V), 0.0);
		float NdotL = max(dot(N, L), 0.0);
		float ggx2 = GeometrySchlickGGX(NdotV, roughness);
		float ggx1 = GeometrySchlickGGX(NdotL, roughness);
		
		return ggx1 * ggx2;
	}
	
	
	
	
	// Smith term for GGX
	// [Smith 1967, "Geometrical shadowing of a random rough surface"]
	float Vis_Smith(float Roughness, float NoV, float NoL)
	{
		float a = Square(Roughness);
		float a2 = a * a;
		
		float Vis_SmithV = NoV + sqrt(NoV * (NoV - NoV * a2) + a2);
		float Vis_SmithL = NoL + sqrt(NoL * (NoL - NoL * a2) + a2);
		return 1.0f / (Vis_SmithV * Vis_SmithL);
	}
	
	// Appoximation of joint Smith term for GGX
	// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
	float Vis_SmithJointApprox(float Roughness, float NoV, float NoL)
	{
		float a = Square(Roughness);
		float Vis_SmithV = NoL * (NoV * (1 - a) + a);
		float Vis_SmithL = NoV * (NoL * (1 - a) + a);
		// Note: will generate NaNs with Roughness = 0.  MinRoughness is used to prevent this
		return 0.5f * 1 / (Vis_SmithV + Vis_SmithL);
	}
	
	half3 F_None(half3 SpecularColor)
	{
		return SpecularColor;
	}
	
	// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
	//half3 F_Schlick(half3 SpecularColor, half VoH)
	//{
	//	half Fc = NssPow5(1 - VoH);					// 1 sub, 3 mul
	//	//return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
	//	
	//	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	//	return saturate(50.0 * SpecularColor.g) * Fc + (1 - Fc) * SpecularColor;
	//}
	
	// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
	half3 F_Schlick_(half HdotV, half3 F0)
	{
		return F0 + (1 - F0) * NssPow5(1 - HdotV);
	}
	


	// [SIGGRPAPH 2015. Renaldas Zioma. Optimizing PBR for Mobile]
	//https://community.arm.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-20-66/siggraph2015_2D00_mmg_2D00_renaldas_2D00_slides.pdf
	half3 F_FastApprox(half LdotH, half3 F0)
	{
		return F0 / (LdotH + 0.001);
	}

	
	float3 F_Fresnel(float3 SpecularColor, float VoH)
	{
		float3 SpecularColorSqrt = sqrt(clamp(float3(0, 0, 0), float3(0.99, 0.99, 0.99), SpecularColor));
		float3 n = (1 + SpecularColorSqrt) / (1 - SpecularColorSqrt);
		float3 g = sqrt(n * n + VoH * VoH - 1);
		return 0.5f * Square((g - VoH) / (g + VoH)) * (1 + Square(((g + VoH) * VoH - 1) / ((g - VoH) * VoH + 1)));
	}
	
	
	
	float D_InvBlinn(float Roughness, float NoH)
	{
		float m = Roughness * Roughness;
		float m2 = m * m;
		float A = 4;
		float Cos2h = NoH * NoH;
		float Sin2h = 1 - Cos2h;
		//return rcp( PI * (1 + A*m2) ) * ( 1 + A * ClampedPow( Sin2h, 1 / m2 - 1 ) );
		return 1 / (PI * (1 + A * m2)) * (1 + A * exp(-Cos2h / m2));
	}
	
	float D_InvBeckmann(float Roughness, float NoH)
	{
		float m = Roughness * Roughness;
		float m2 = m * m;
		float A = 4;
		float Cos2h = NoH * NoH;
		float Sin2h = 1 - Cos2h;
		float Sin4h = Sin2h * Sin2h;
		return 1.0f / (PI * (1 + A * m2) * Sin4h) * (Sin4h + A * exp(-Cos2h / (m2 * Sin2h)));
	}
	
	float D_InvGGX(float Roughness, float NoH)
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float A = 4;
		float d = (NoH - a2 * NoH) * NoH + a2;
		return 1.0f / (PI * (1 + A * a2)) * (1 + 4 * a2 * a2 / (d * d));
	}
	
	float Vis_Cloth(float NoV, float NoL)
	{
		return 1.0f / (4 * (NoL + NoV - NoL * NoV));
	}
	
	
	// Octahedron Normal Vectors
	// [Cigolle 2014, "A Survey of Efficient Representations for Independent Unit Vectors"]
	//						Mean	Max
	// oct		8:8			0.33709 0.94424
	// snorm	8:8:8		0.17015 0.38588
	// oct		10:10		0.08380 0.23467
	// snorm	10:10:10	0.04228 0.09598
	// oct		12:12		0.02091 0.05874
	
	float2 UnitVectorToOctahedron(float3 N)
	{
		N.xy /= dot(1, abs(N));
		if (N.z <= 0)
		{
			N.xy = (1 - abs(N.yx)) * (N.xy >= 0 ? float2(1, 1): float2(-1, -1));
		}
		return N.xy;
	}
	
	float3 OctahedronToUnitVector(float2 Oct)
	{
		float3 N = float3(Oct, 1 - dot(1, abs(Oct)));
		if(N.z < 0)
		{
			N.xy = (1 - abs(N.yx)) * (N.xy >= 0 ? float2(1, 1): float2(-1, -1));
		}
		return normalize(N);
	}
	
	//---------------------------------------------------------------------------
	// [SIGGRAPH 2013.Lazarov D. Getting More Physical in Call of Duty Black Ops II [J]]
	// @ g - gloss-range（0,1）
	// @ NoV - NdotV
	// @ rf0 - F0
	float3 EnvironmentBRDF(float g, float NoV, float3 rf0)
	{
		float4 t = float4(1 / 0.96, 0.475, (0.0275 - 0.25 * 0.04) / 0.96, 0.25);
		t *= float4(g, g, g, g);
		t += float4(0, 0, (0.015 - 0.75 * 0.04) / 0.96, 0.75);
		float a0 = t.x * min(t.y, exp2(-9.28 * NoV)) + t.z; float a1 = t.w;
		return saturate(a0 + rf0 * (a1 - a0));
	}
	
	//https://knarkowicz.wordpress.com/2014/12/27/analytical-dfg-term-for-ibl/
	float3 LazarovGGXEnvBRDF(float3 specularColor, float gloss, float ndotv)
	{
		float4 p0 = float4(0.5745, 1.548, -0.02397, 1.301);
		float4 p1 = float4(0.5753, -0.2511, -0.02066, 0.4755);
		
		float4 t = gloss * p0 + p1;
		
		float bias = saturate(t.x * min(t.y, exp2(-7.672 * ndotv)) + t.z);
		float delta = saturate(t.w);
		float scale = delta - bias;
		
		bias *= saturate(50.0 * specularColor.y);
		return specularColor * scale + bias;
	}
	
	
	//https://knarkowicz.wordpress.com/2014/12/27/analytical-dfg-term-for-ibl/
	float3 EnvDFGPolynomial(float3 specularColor, float gloss, float ndotv)
	{
		float x = gloss;
		float y = ndotv;
		
		float b1 = -0.1688;
		float b2 = 1.895;
		float b3 = 0.9903;
		float b4 = -4.853;
		float b5 = 8.404;
		float b6 = -5.069;
		float bias = saturate(min(b1 * x + b2 * x * x, b3 + b4 * y + b5 * y * y + b6 * y * y * y));
		
		float d0 = 0.6045;
		float d1 = 1.699;
		float d2 = -0.5228;
		float d3 = -3.603;
		float d4 = 1.404;
		float d5 = 0.1939;
		float d6 = 2.661;
		float delta = saturate(d0 + d1 * x + d2 * y + d3 * x * x + d4 * x * y + d5 * y * y + d6 * x * x * x);
		float scale = delta - bias;
		
		bias *= saturate(50.0 * specularColor.y);
		return specularColor * scale ;
	}
	
	
	//[Brian Karis. 2014. Physically Based Shading on Mobile.]
	// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
	half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
	{
		
		const half4 c0 = {- 1, -0.0275, -0.572, 0.022};
		
		const half4 c1 = {1, 0.0425, 1.04, -0.04};
		
		half4 r = Roughness * c0 + c1;
		
		half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
		
		half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
		
		return SpecularColor * AB.x + AB.y;
	}


	//[Brian Karis. 2014. Physically Based Shading on Mobile.]
	// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
	half3 EnvBRDFApprox_Improve(half3 SpecularColor, half Roughness, half NoV, half edgeFactor)
	{		
		const half4 c0 = {- 1, -0.0275, -0.572, 0.022};		
		const half4 c1 = {1, 0.0425, 1.04, -0.04};		
		half4 r = Roughness * c0 + c1;		
		half a004 = min(r.x * r.x, exp2(-9.28 * NoV * edgeFactor)) * r.x + r.y;		
		half2 AB = half2(-1.04, 1.04) * a004 + r.zw;		
		return SpecularColor * AB.x + AB.y;
	}
		

		
	//[Brian Karis. 2014. Physically Based Shading on Mobile.]
	// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
	half EnvBRDFApproxNonmetal( half Roughness, half NoV )
	{
		// Same as EnvBRDFApprox( 0.04, Roughness, NoV )
		const half2 c0 = { -1, -0.0275 };
		const half2 c1 = { 1, 0.0425 };
		half2 r = Roughness * c0 + c1;
		return min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
	}


	half3 NssEnvBRDFApprox(float3 F0, float paintFresnel)
	{
		return paintFresnel * F0 * 5.0f ;
	}

	// [SIGGRPAPH 2015. Renaldas Zioma. Optimizing PBR for Mobile]
	//https://community.arm.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-20-66/siggraph2015_2D00_mmg_2D00_renaldas_2D00_slides.pdf
	half3 EnvBRDFApprox_Fast(half3 SpecularColor, half Roughness, half NoV)
	{
		half c = saturate(1 - max(Roughness,NoV));
		half c3 = c * c * c;
		return c3 + SpecularColor;
	}


	//[SIGGRAPH 2016. Brinck W, Maximov A, Jiang Y. Technical Art of Uncharted 4]
	float ApplyMicroShadow(float ao, float3 N, float3 L, float shadow)
	{
		float aperture = 2.0 * ao * ao;
		float microShadow = saturate(abs(dot(L, N)) + aperture - 1.0);
		return shadow * microShadow;
	}
	
	//[SIGGRAPH 2016. Brinck W, Maximov A, Jiang Y. Technical Art of Uncharted 4]
	float3 ApplyLightWrap(float3 lightWrapColor, float3 normalWS, float3 vertexNormalWS, float3 lightDirWS)
	{
		float lightWrapDistance = 0.1;
		float3 wrapLight = lightWrapDistance * lightWrapColor;
		float NdotL = dot(normalWS, lightDirWS);
		NdotL = lerp(max(wrapLight.r, max(wrapLight.g, wrapLight.b)), 1.0, NdotL);
		
		float wrapForwardNdotL = max(NdotL, dot(vertexNormalWS, lightDirWS));
		float3 wrapForward = lerp(wrapLight, float3(1.0, 1.0, 1.0), wrapForwardNdotL);
		float3 wrapRecede = lerp(-wrapLight, float3(1.0, 1.0, 1.0), NdotL);
		float3 wrapLighting = saturate(lerp(wrapRecede, wrapForward, lightWrapColor));
		
		return wrapLighting;
	}
	



	
	//----------------------------------------------------------------------------
	
	// Generalized-Trowbridge-Reitz distribution
	// Distribución Generalized-Trowbridge-Reitz
	float DGTR1(float alpha, float dotNH)
	{
		float a2 = alpha * alpha;
		float cos2th = dotNH * dotNH;
		float den = (1.0 + (a2 - 1.0) * cos2th);
		
		return(a2 - 1.0) / (PI * log(a2) * den);
	}
	
	float DGTR2(float alpha, float dotNH)
	{
		float a2 = alpha * alpha;
		float cos2th = dotNH * dotNH;
		float den = (1.0 + (a2 - 1.0) * cos2th);
		
		return a2 / (PI * den * den);
	}	
	
	
	//--------------ToneMapping begin------------------------------------------
	float3 ACESToneMapping(float3 color, float adapted_lum)
	{
		const float A = 2.51f;
		const float B = 0.03f;
		const float C = 2.43f;
		const float D = 0.59f;
		const float E = 0.14f;
		
		color *= adapted_lum;
		return(color * (A * color + B)) / (color * (C * color + D) + E);
	}
	
	float3 ReinhardToneMap(real3 color)
	{
		color.rgb *= 1.8;
		float luminance = color.r * 0.2126 + color.g * 0.72152 + color.b * 0.0722;
		return saturate(color.rgb / (1.0 + luminance));
	}
	
	float3 ReinhardToneMapping_V2(float3 color, float adapted_lum)
	{
		const float MIDDLE_GREY = 1;
		color *= MIDDLE_GREY / adapted_lum;
		return color / (1.0f + color);
	}
	
	float3 CEToneMapping(float3 color, float adapted_lum)
	{
		return 1 - exp(-adapted_lum * color);
	}
	
	
	//------------Uncharted2ToneMapping------------
	float3 F(float3 x)
	{
		const float A = 0.22f;
		const float B = 0.30f;
		const float C = 0.10f;
		const float D = 0.20f;
		const float E = 0.01f;
		const float F = 0.30f;
		
		return((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
	}
	
	float3 Uncharted2ToneMapping(float3 color, float adapted_lum)
	{
		const float WHITE = 11.2f;
		return F(1.6f * adapted_lum * color) / F(WHITE);
	}
	
	//uniform half _Adapted_lum;
	uniform half _ACES_A;
	uniform half _ACES_B;
	uniform half _ACES_C;
	uniform half _ACES_D;
	uniform half _ACES_E;
	
	
	//--------------ToneMapping begin------------------------------------------
	half3 ACESToneMapping_V2(half3 color)
	{
		// const half A = 2.51f;
		// const half B = 0.03f;
		// const half C = 2.43f;
		// const half D = 0.59f;
		// const half E = 0.14f;
		
		//color *= adapted_lum;
		return(color * (_ACES_A * color + _ACES_B)) / (color * (_ACES_C * color + _ACES_D) + _ACES_E);
	}
	
	half3 ACESToneMapping_V3(half3 color)
	{
		const half A = 3.8f;
		const half B = 0.03f;
		const half C = 1.5f;
		const half D = 0.59f;
		const half E = 0.14f;
		
		//color *= adapted_lum;
		return(color * (A * color + B)) / (color * (C * color + D) + E);
	}
	
	
	// [Header(for ACES Tone Mapping)]
	// [Toggle] _NEED_ACES_1("是否开启ACES ToneMapping", float) = 1
	// //_Adapted_lum("adapted_lum（调色系数）", Range(0.1, 10.0)) = 1.0
	// _ACES_A("_ACES_A（标准值2.51）", Range(0.0, 10.0)) = 3.8
	// _ACES_B("_ACES_B（标准值0.03）", Range(0.0, 10.0)) = 0.03
	// _ACES_C("_ACES_C（标准值2.43）", Range(0.0, 10.0)) = 1.5
	// _ACES_D("_ACES_D（标准值0.59）", Range(0.0, 10.0)) = 0.59
	// _ACES_E("_ACES_E（标准值0.14）", Range(0.0, 10.0)) = 0.14
	
	//--------------------------------------------------
	
	
	float3 ToneMapLogarithmic(float3 x, float max_lum)
	{
		return log10(1 + x) / log10(1 + max_lum);
	}
	
	// static float3 ToneMapExponential(float x, const TMPostProcessor::Constants& constants)
	// {
	//     return 1 - exp(-x);
	// }
		
	// static float ToneMapDragoLogarithmic(float x, const TMPostProcessor::Constants& constants)
	// {
	//     float y = std::log10f(1 + x);
	//     y /= std::log10f(1 + constants.WhiteLevel);
	//     y /= std::log10f(2 + 8 * ((x ) * std::log10f(constants.Bias) / std::log10f(0.5f)));
	//     return y;
	// }
		
			
			
	//--------------ToneMapping end--------------------------------------------
			
	
	
	//------------------------------------------------------------------------------

	half3 fromRGBMGamma(half4 c)
	{
		//c.a *= 6.0;
		//return c.rgb * lerp(c.a, toLinearFast1(c.a), IS_LINEAR);
		//7 instructions
		///

		//combined 6.0 * toLinear
		half4 IGL; //.xyz: modified versions of IS_GAMMA_LINEAR, .w: c.a*c.a
		IGL = half4(
			19.35486, // 3.22581 * 6.0,
			-87.468483312, //-3.22581 * 0.7532 * 36.0,
			-171.964060128, //-3.22581 * 0.2468 * 216.0,
			c.a
			) *
			half4(
				0.5,0.5,0.5,
				c.a
				) +
			half4(
				-3.6774, //-0.6129 * 6.0,
				43.73410608, // 1.6129 * 0.7532 * 36.0,
				85.98176352, // 1.6129 * 0.2468 * 216.0,
				0.0
				);
		//return c.aaa;//
		return c.rgb * dot(IGL.xyz, half3(c.a, IGL.w, c.a * IGL.w));
		//4 instructions
		///
	}

		
	half3 fromRGBM(half4 c)
	{
		//c.a *= 6.0;
		//return c.rgb * lerp(c.a, toLinearFast1(c.a), IS_LINEAR);
		//7 instructions
		///
		
		//combined 6.0 * toLinear
		half4 IGL; //.xyz: modified versions of IS_GAMMA_LINEAR, .w: c.a*c.a
		IGL = half4(
			19.35486, // 3.22581 * 6.0,
			- 87.468483312, //-3.22581 * 0.7532 * 36.0,
			- 171.964060128, //-3.22581 * 0.2468 * 216.0,
			c.a
		) *
		half4(
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			c.a
		) +
		half4(
			- 3.6774, //-0.6129 * 6.0,
			43.73410608, // 1.6129 * 0.7532 * 36.0,
			85.98176352, // 1.6129 * 0.2468 * 216.0,
			0.0
		);
		return c.rgb * dot(IGL.xyz, half3(c.a, IGL.w, c.a * IGL.w));
		//4 instructions
		///
	}
	

	float3 fromRGBM_NSS(float4 c)
	{
		//c.a *= 6.0;
		//return c.rgb * lerp(c.a, toLinearFast1(c.a), IS_LINEAR);
		//7 instructions
		///
		
		//combined 6.0 * toLinear
		float4 IGL; //.xyz: modified versions of IS_GAMMA_LINEAR, .w: c.a*c.a
		IGL = float4(
			19.35486, // 3.22581 * 6.0,
			- 87.468483312, //-3.22581 * 0.7532 * 36.0,
			- 171.964060128, //-3.22581 * 0.2468 * 216.0,
			0.2
		) *
		float4(
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			0.2
		) +
		float4(
			- 3.6774, //-0.6129 * 6.0,
			43.73410608, // 1.6129 * 0.7532 * 36.0,
			85.98176352, // 1.6129 * 0.2468 * 216.0,
			0.0
		);
		return c.rgb * dot(IGL.xyz, float3(c.a, IGL.w, c.a * IGL.w));
		//4 instructions
		///
	}

	
	
	float3 diffCubeLookup(samplerCUBE diffCube, float3 worldNormal)
	{
		float4 diff = texCUBE(diffCube, worldNormal);
		return fromRGBM(diff);
	}
	
	float3 specCubeLookup(samplerCUBE specCube, float3 worldRefl)
	{
		float4 spec = texCUBE(specCube, worldRefl);
		return fromRGBM(spec);
	}
	
	half3 glossCubeLookup(samplerCUBE specCube, half3 worldRefl, half glossLod)
	{
		//#ifdef MARMO_BIAS_GLOSS
		//half4 lookup = half4(worldRefl,glossLod);
		//half4 spec = texCUBEbias(specCube, lookup);
		//#else
		half4 lookup = half4(worldRefl, glossLod);
		half4 spec = texCUBElod(specCube, lookup);
		//#endif
		return fromRGBM(spec);
	}

	half3 glossCubeLookup_Linear(samplerCUBE specCube, half3 worldRefl, half glossLod)
	{
		//#ifdef MARMO_BIAS_GLOSS
		//half4 lookup = half4(worldRefl,glossLod);
		//half4 spec = texCUBEbias(specCube, lookup);
		//#else
		half4 lookup = half4(worldRefl, glossLod);
		half4 spec = texCUBElod(specCube, lookup);
		spec.rgb = LinearToGamma_Fast(spec.rgb);
		//#endif
		return GammaToLinear_Fast(fromRGBMGamma(spec));
	}

	
	half3 glossCubeLookup_LDR(samplerCUBE specCube, half3 worldRefl, half glossLod)
	{
		//#ifdef MARMO_BIAS_GLOSS
		//half4 lookup = half4(worldRefl,glossLod);
		//half4 spec = texCUBEbias(specCube, lookup);
		//#else
		half4 lookup = half4(worldRefl, glossLod);
		half4 spec = texCUBElod(specCube, lookup);
		//#endif
		return spec;
	}
		
	half3 glossCubeLookup_Nss(samplerCUBE specCube, half3 worldRefl)
	{
		//#ifdef MARMO_BIAS_GLOSS
		//half4 lookup = half4(worldRefl,glossLod);
		//half4 spec = texCUBEbias(specCube, lookup);
		//#else
		//float4 lookup = float4(worldRefl, glossLod);
		half4 spec = texCUBE(specCube,worldRefl);
		//#endif
		return fromRGBM(spec);
	}
	
	half3 glossCubeLookupStandard(TEXTURECUBE_PARAM(specCube,samplerspecCube), half4 specCube_HDR,  half3 worldRefl, half glossLod)
	{	
	    half4 lookup = half4(worldRefl, glossLod);
		half4 spec = SAMPLE_TEXTURECUBE_LOD(specCube, samplerspecCube, worldRefl, glossLod);		
		return DecodeHDREnvironment(spec, specCube_HDR);
	}	
	
	//converts linear, HDR color to RGBM encoded data, ready for screen output
	float4 HDRtoRGBM(float4 color)
	{
		float toLinear = 2.2;
		float toGamma = 1.0 / 2.2;
		color.rgb = pow(color.rgb, toGamma); //RGBM gamma compression is 1/2.2
		color *= 1.0 / 6.0;
		float m = max(max(color.r, color.g), color.b);
		m = saturate(m);
		m = ceil(m * 255.0) / 255.0;
		
		if (m > 0.0)
		{
			float inv_m = 1.0 / m;
			color.rgb = saturate(color.rgb * inv_m);
			color.a = m;
		}
		else
		{
			color = half4(0.0, 0.0, 0.0, 0.0);
		}
		return color;
	}
	
	
	//returns fresnel*specIntensity in proper color space
	//E: View Direction
	float fastFresnel(float3 N, float3 E, float specIntensity, float fresnel)
	{
		//fresnel math performed in gamma space
		float factor = saturate(dot(N, E));
		factor = 1.0 - factor;
		factor *= (0.5 * factor) + 0.5;
		factor = (factor * 0.85) + 0.15;
		factor = lerp(1.0, factor, fresnel);
		factor = specIntensity * factor;
		factor = lerp(factor, factor * factor, 1);
		return factor;
	}
	
	
	
	
	
	
	
	uniform float3		_SH0;
	uniform float3		_SH1;
	uniform float3		_SH2;
	uniform float3		_SH3;
	uniform float3		_SH4;
	uniform float3		_SH5;
	uniform float3		_SH6;
	uniform float3		_SH7;
	uniform float3		_SH8;
	
	
	uniform float3		_SH01;
	uniform float3		_SH11;
	uniform float3		_SH21;
	uniform float3		_SH31;
	uniform float3		_SH41;
	uniform float3		_SH51;
	uniform float3		_SH61;
	uniform float3		_SH71;
	uniform float3		_SH81;
	
	
	
	float3 SHLookup(float3 dir)
	{
		//l = 0 band (constant)
		float3 result = _SH0.xyz;
		
		//l = 1 band
		result += _SH1.xyz * dir.y;
		result += _SH2.xyz * dir.z;
		result += _SH3.xyz * dir.x;
		
		//l = 2 band
		float3 swz = dir.yyz * dir.xzx;
		result += _SH4.xyz * swz.x;
		result += _SH5.xyz * swz.y;
		result += _SH7.xyz * swz.z;
		float3 sqr = dir * dir;
		result += _SH6.xyz * (3.0 * sqr.z - 1.0);
		result += _SH8.xyz * (sqr.x - sqr.y);
		
		return abs(result);
	}
	
	void SHLookup(float3 dir, out float3 band0, out float3 band1, out float3 band2)
	{
		//l = 0 band (constant)
		band0 = _SH0.xyz;
		
		//l = 1 band
		band1 = _SH1.xyz * dir.y;
		band1 += _SH2.xyz * dir.z;
		band1 += _SH3.xyz * dir.x;
		
		//l = 2 band
		float3 swz = dir.yyz * dir.xzx;
		band2 = _SH4.xyz * swz.x;
		band2 += _SH5.xyz * swz.y;
		band2 += _SH7.xyz * swz.z;
		float3 sqr = dir * dir;
		band2 += _SH6.xyz * (3.0 * sqr.z - 1.0);
		band2 += _SH8.xyz * (sqr.x - sqr.y);
	}
	
	
	float3 SHLookup1(float3 dir)
	{
		//l = 0 band (constant)
		float3 result = _SH01.xyz;
		
		//l = 1 band
		result += _SH11.xyz * dir.y;
		result += _SH21.xyz * dir.z;
		result += _SH31.xyz * dir.x;
		
		//l = 2 band
		float3 swz = dir.yyz * dir.xzx;
		result += _SH41.xyz * swz.x;
		result += _SH51.xyz * swz.y;
		result += _SH71.xyz * swz.z;
		float3 sqr = dir * dir;
		result += _SH61.xyz * (3.0 * sqr.z - 1.0);
		result += _SH81.xyz * (sqr.x - sqr.y);
		
		return abs(result);
	}
	void SHLookup1(float3 dir, out float3 band0, out float3 band1, out float3 band2)
	{
		//l = 0 band (constant)
		band0 = _SH01.xyz;
		
		//l = 1 band
		band1 = _SH11.xyz * dir.y;
		band1 += _SH21.xyz * dir.z;
		band1 += _SH31.xyz * dir.x;
		
		//l = 2 band
		float3 swz = dir.yyz * dir.xzx;
		band2 = _SH41.xyz * swz.x;
		band2 += _SH51.xyz * swz.y;
		band2 += _SH71.xyz * swz.z;
		float3 sqr = dir * dir;
		band2 += _SH61.xyz * (3.0 * sqr.z - 1.0);
		band2 += _SH81.xyz * (sqr.x - sqr.y);
	}
	
	
	float3 SHLookupUnity(float3 dir)
	{
		return SampleSH(dir);
	}
	
	void SHLookupUnity(float3 dir, out float3 band0, out float3 band1, out float3 band2)
	{
		//constant term
		band0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
		
		// Linear term
		band1.r = dot(unity_SHAr.xyz, dir.xyz);
		band1.g = dot(unity_SHAg.xyz, dir.xyz);
		band1.b = dot(unity_SHAb.xyz, dir.xyz);
		
		// 4 of the quadratic polynomials
		half4 vB = dir.xyzz * dir.yzzx;
		band2.r = dot(unity_SHBr, vB);
		band2.g = dot(unity_SHBg, vB);
		band2.b = dot(unity_SHBb, vB);
		
		// Final quadratic polynomial
		float vC = dir.x * dir.x - dir.y * dir.y;
		band2 += unity_SHC.rgb * vC;
	}
	
	float3 SHConvolve(float3 band0, float3 band1, float3 band2, float3 weight)
	{
		float3 conv1 = lerp(float3(1.0, 1.0, 1.0), float3(0.6667, 0.6667, 0.6667), weight);
		float3 conv2 = lerp(float3(1.0, 1.0, 1.0), float3(0.25, 0.25, 0.25), weight);
		conv1 = lerp(conv1, conv1 * conv1, weight);
		conv2 = lerp(conv2, conv2 * conv2, weight);
		return abs(band0 + band1 * conv1 + band2 * conv2);
	}

	//------------------------------------------------------------------------------
	
	
//---------------------------------Specular AA-------------------


// Return modified perceptualSmoothness based on provided variance (get from GeometricNormalVariance + TextureNormalVariance)
half NormalFiltering(half roughness, float variance, float threshold)
{
    // Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)
    half squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold)); // threshold can be really low, square the value for easier control

    return sqrt(squaredRoughness);
}

// Specular antialiasing for geometry-induced normal (and NDF) variations: Tokuyoshi / Kaplanyan et al.'s method.
half GeometricNormalVariance(half3 geometricNormalWS, half screenSpaceVariance)
{
    half3 deltaU = ddx(geometricNormalWS);
    half3 deltaV = ddy(geometricNormalWS);

    return screenSpaceVariance * (dot(deltaU, deltaU) + dot(deltaV, deltaV));
}

// Return modified perceptualSmoothness
half GeometricNormalFiltering(half roughness, half3 geometricNormalWS, half screenSpaceVariance, half threshold)
{
    half variance = GeometricNormalVariance(geometricNormalWS, screenSpaceVariance);
    return NormalFiltering(roughness, variance, threshold);
}
	
	
	
#endif


