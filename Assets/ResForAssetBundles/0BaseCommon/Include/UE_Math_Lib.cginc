#ifndef NSS_MATH_FUNC
#define NSS_MATH_FUNC

#include "QSM_COLORSPACE_CORE.cginc"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
		   #include "QSM_BASE_MACRO.cginc"

//===================================================================================================
//Math Functions
// 注意不要添加不必要的模型函数
//===================================================================================================


inline half NssPow4(half x)
{
	return x * x*x*x;
}

inline half NssPow5(half x)
{
	return x * x * x * x * x;
}


//保护参数
half NssPow(half base, half power)
{
	return pow(max(0.001, base), power + 0.01);
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
		-87.468483312, //-3.22581 * 0.7532 * 36.0,
		-171.964060128, //-3.22581 * 0.2468 * 216.0,
		c.a
		) *
		half4(
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			c.a
			) +
		half4(
			-3.6774, //-0.6129 * 6.0,
			43.73410608, // 1.6129 * 0.7532 * 36.0,
			85.98176352, // 1.6129 * 0.2468 * 216.0,
			0.0
			);
	return c.rgb * dot(IGL.xyz, half3(c.a, IGL.w, c.a * IGL.w));
	//4 instructions
	///
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


//===================================================================================================
// PBR Shading Functions
// 注意不要添加不必要的模型函数
//===================================================================================================

#define PI 3.14159265358979323846f

half Diffuse_Lambert(half LdotN)
{
	return LdotN;
}

float Diffuse_Disney(float Roughness, half NdotV, half NdotL, half LdotH)
{
	half fd90 = 0.5 + 2 * LdotH * LdotH * Roughness;
	// Two schlick fresnel term
	half lightScatter = (1 + (fd90 - 1) * NssPow5(1 - NdotL));
	half viewScatter = (1 + (fd90 - 1) * NssPow5(1 - NdotV));

	return lightScatter * viewScatter * NdotL;
}



//改进[Schlick 1994] ：pow5改pow4，节省一次mul instruction
// [GDC 2014] Physically Based Shading in Unity 
// Fresnel approximation with 4.0 power
half3 F_Schlick_Fast(half HdotV, half3 F0)
{
	return F0 + (1 - F0) * NssPow4(1 - HdotV);
}

// Ashikhmin 2007, "Distribution-based BRDFs"
half D_Velvet(half roughness, half NoH)
{
	half a2 = NssPow4(roughness);
	half cos2h = NoH * NoH;
	half sin2h = max(1.0 - cos2h, 0.0078125); // 2^(-14/2), so sin2h^2 > 0 in fp16
	half sin4h = sin2h * sin2h;
	half cot2 = -cos2h / (a2 * sin2h);
	return 0.25 / ((4.0 * a2 + 1.0) * sin4h) * (4.0 * exp(cot2) + sin4h);
}

half G1_EPIC_NOTE(half NdotV, half roughness)
{
	//reduction
	half r = (roughness + 1.0);
	half k = (r * r) * 0.125;

	half denom = NdotV * (1.0 - k) + k;

	return NdotV / (denom + 0.00001);
}

//s2013-pbs-epic-note
half V_Smith_EPIC_NOTE(float NdotL, float NdotV, float roughness)
{
	half ggx2 = G1_EPIC_NOTE(NdotV, roughness);
	half ggx1 = G1_EPIC_NOTE(NdotL, roughness);

	return ggx1 * ggx2;
}


//[Burley 2012, "Physically-Based Shading at Disney"]
half D_GGX_Anisotropic(half at, half ab, half NoH, half TOH,  half bOH)
{
	half d = TOH * TOH / (at*at) + bOH * bOH / (ab*ab) + NoH * NoH;
	return 1 / (at*ab * d*d);
}


// Note: comment out to assume fp32 computations
#ifndef MOBILE_GGX_USE_FP16
#define MOBILE_GGX_USE_FP16 1
#endif

#define MEDIUMP_FLT_MAX    65504.0
#define MEDIUMP_FLT_MIN    0.00006103515625


// Taken from https://gist.github.com/romainguy/a2e9208f14cae37c579448be99f78f25
// Modified by Epic Games, Inc. To account for premultiplied light color and code style rules.

half D_GGX_Mobile(half Roughness, half NoH, half3 H, half3 N)
{
	float OneMinusNoHSqr = 1.0 - NoH * NoH;

	half a = Roughness * Roughness;
	float n = NoH * a;
	float p = a / (OneMinusNoHSqr + n * n);
	float d = min(p * p, 2048.0);
	return d;// / PI;//UE moble的除PI发生在CPU
}

//------------------------[UE4  GGX_Standard]-----------------------------------------

half GGX_Mobile(half Roughness, half NoH, half3 H, half3 N)
{
	half  D = D_GGX_Mobile(Roughness, NoH, H, N);
	return D * (Roughness*0.25 + 0.25);
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
half Vis_SmithJointApprox(half a2, half NoV, half NoL)
{
	half a = sqrt(a2);
	half Vis_SmithV = NoL * (NoV * (1 - a) + a);
	half Vis_SmithL = NoV * (NoL * (1 - a) + a);
	return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

 half Vis_SmithJointAniso_Approx(float NdotL, float NdotV, float at, float ab)
{

	float lambdaV = NdotL * (NdotV * (1 - at) + at);
	float lambdaL = NdotV * (NdotL * (1 - ab) + ab);


	return 0.5h / (lambdaV + lambdaL + 1e-5h);

}

// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointAniso(float ax, float ay, float NoV, float NoL, float XoV, float XoL, float YoV, float YoL)
{
	float Vis_SmithV = NoL * length(float3(ax * XoV, ay * YoV, NoV));
	float Vis_SmithL = NoV * length(float3(ax * XoL, ay * YoL, NoL));
	return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

half3 SpecularGGX(half Roughness, half3 SpecularColor, half NoH, half NoV, half VoH, half NoL)
{
	half a2 = pow(Roughness, 4);

	// Generalized microfacet specular
	half D = D_GGX(a2, NoH);
	half Vis = Vis_SmithJointApprox(a2, NoV, NoL);
	half3 F = F_Schlick(SpecularColor, VoH);

	return (D * Vis) * F;
}


//------------------------[UE4  GGX_Anisotropi]-----------------------------------------
half3 GGX_Mobile_Anisotropic(half at, half ab, half NoH, half ToH, half boH, half NoL, half NoV, half3 F0, half VoH)
{
	half  D = D_GGX_Anisotropic(at, ab, NoH, ToH, boH);
	half  V = Vis_SmithJointAniso_Approx(NoL, NoV, at, ab);
	half3 F = F_Schlick_Fast(VoH, F0);

	return D * V * F;
}
//------------------------[UE4  GGX_Cloth]-----------------------------------------

half3 GGX_Mobile_Cloth(half roughness, half NoH, half NoV, half3 F0)
{
	half  D = D_Velvet(roughness, NoH);
	half3 F = F_Schlick_Fast(NoV, F0);

	return D * F;
}

//half2 EnvBRDFApproxLazarov(half Roughness, half NoV)
//{
//	// [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
//	// Adaptation to fit our G term.
//	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
//	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
//	half4 r = Roughness * c0 + c1;
//	half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
//	half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
//	return AB;
//}


//[Brian Karis. 2014. Physically Based Shading on Mobile.]
	// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
{

	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };

	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };

	half4 r = Roughness * c0 + c1;

	half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;

	half2 AB = half2(-1.04, 1.04) * a004 + r.zw;

	return SpecularColor * AB.x + AB.y;
}


////[Brian Karis. 2014. Physically Based Shading on Mobile.]
//// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
//half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
//{
//	half2 AB = EnvBRDFApproxLazarov(Roughness, NoV);
//
//	// Anything less than 2% is physically impossible and is instead considered to be shadowing
//	// Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
//	float F90 = saturate(50.0 * SpecularColor.g);
//
//	return SpecularColor * AB.x + F90 * AB.y;
//}


// Octahedron Normal Vectors
// [Cigolle 2014, "A Survey of Efficient Representations for Independent Unit Vectors"]
//						Mean	Max
// oct		8:8			0.33709 0.94424
// snorm	8:8:8		0.17015 0.38588
// oct		10:10		0.08380 0.23467
// snorm	10:10:10	0.04228 0.09598
// oct		12:12		0.02091 0.05874

half2 UnitVectorToOctahedron(half3 N)
{
	N.xy /= dot(1, abs(N));
	if (N.z <= 0)
	{
		N.xy = (1 - abs(N.yx)) * (N.xy >= 0 ? half2(1, 1) : half2(-1, -1));
	}
	return N.xy;
}

half3 OctahedronToUnitVector(half2 Oct)
{
	half3 N = half3(Oct, 1 - dot(1, abs(Oct)));
	if (N.z < 0)
	{
		N.xy = (1 - abs(N.yx)) * (N.xy >= 0 ? half2(1, 1) : half2(-1, -1));
	}
	return normalize(N);
}
#endif


