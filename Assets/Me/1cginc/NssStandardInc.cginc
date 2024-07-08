// Upgrade NOTE: replaced 'defined METALLICGLOSSMAP' with 'defined (METALLICGLOSSMAP)'
// Upgrade NOTE: replaced 'defined NORMALMAP' with 'defined (NORMALMAP)'

#ifndef NSS_STANDARD_INCLUDED
#define  NSS_STANDARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/ResForAssetBundles/0BaseCommon/Include/LegacyCommon.hlsl"
#include "NssLighting.cginc"
#include "../Shaders/NssFog.cginc"
#include "LocalReflection.cginc"

#include "QSM_COLORSPACE_CORE.cginc"
		   #include "QSM_BASE_MACRO.cginc"

sampler2D _ParamMap;
sampler2D _BaseMap;
sampler2D _BumpMap;
sampler2D _EmissionMap;
sampler2D _NormalMRMap;
sampler2D _OcclusionMap;
CBUFFER_START(UnityPerMaterial)

float4 _BaseMap_ST;
half4 _BaseColor;
half _EmissionScale;
half4 _EmissionColor;
half _Metallic;
half _Roughness;
half _AVGMetallic;
half _AVGRoughness;
half _Occlusion;
half _BumpScale;
half _Cutoff;


half4 _BaseColor2;
sampler2D _BaseMap2;
float4 _BaseMap2_ST;
half _Metallic2;
half _Roughness2;
half _AVGMetallic2;
half _AVGRoughness2;
sampler2D _NormalMRMap2;
half _BumpScale2;


half _OcclusionSeUV;
CBUFFER_END
#ifdef _PLANAR_REFLECTION_ON
sampler2D _MirrorReflectionTex;
#endif
sampler2D _LightmapSecend;
sampler2D _LightmapFirst;
half _LightmapLerp;
TEXTURECUBE(_SpecCube0First);SAMPLER( sampler_SpecCube0First);
TEXTURECUBE(_SpecCube0Second);SAMPLER( sampler_SpecCube0Second);



half3 Decode(half2 f, half bumpScale)
{
	f = f * 2 - 1;

	// https://twitter.com/Stubbesaurus/status/937994790553227264
	half3 n = half3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
	//half t = saturate(-n.z);
	//n.xy += n.xy >= 0 ? -t : t;
	n.xy *= bumpScale;
	return normalize(n);
}
half3 NssUnpackScaleNormalXY(half2 packednormal, half bumpScale)
{
	//// This do the trick
	half3 normal;
	normal.xy = (packednormal.xy * 2 - 1);
	// SM2.0: instruction count limitation
	// SM2.0: normal scaler is not supported
	normal.xy *= bumpScale;
	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	return normal;
}

half3 NssUnpackScaleNormal(half4 packednormal, half bumpScale)
{
#if defined(UNITY_NO_DXT5nm)
	half3 normal = packednormal.xyz * 2 - 1;
	normal.xy *= bumpScale;
	return normal;
#else
		// This do the trick
		packednormal.x *= packednormal.w;
		half3 normal;
		normal.xy = (packednormal.xy * 2 - 1);
		normal.xy *= bumpScale;
		normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
		return normal;
#endif
}



struct VertexInput
{
	half4 color     :COLOR;
	float4 vertex   : POSITION;
#ifdef MORE_HALF
	half3 normal    : NORMAL;
	half4 tangent : TANGENT;
	float2 uv0      : TEXCOORD0;
	half2 uv1      : TEXCOORD1;
	half2 uv2      : TEXCOORD2;
#else
	float3 normal    : NORMAL;
	float4 tangent : TANGENT;
	float2 uv0      : TEXCOORD0;
	float2 uv1      : TEXCOORD1;
	float2 uv2      : TEXCOORD2;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutputForwardBase
{
	float4 pos : SV_POSITION;
	half4 color : COLOR;
#ifdef MORE_HALF
	float4 tex                            : TEXCOORD0;
	half4 eyeVec                         : TEXCOORD1;
#else
	float4 tex                            : TEXCOORD0;
	float4 eyeVec                         : TEXCOORD1;
#endif
#ifdef MORE_HALF
	half4 tangentToWorldAndPackedData[3] : TEXCOORD2;
#else
	float4 tangentToWorldAndPackedData[3] : TEXCOORD2;
#endif
	half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV
#ifdef MORE_HALF
	half4 _ShadowCoord : TEXCOORD6;
#else
	float4 _ShadowCoord : TEXCOORD6;
#endif	
	NSS_FOG_COORDS(7)
	float3 posWorld                 : TEXCOORD8;
#ifdef _SECOND_LAYER
	float2 tex2	: TEXCOORD9;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct FragmentCommonData
{
	half3 diffColor, specColor;
	half oneMinusReflectivity, roughness;
#ifdef MORE_HALF
	half3 normalWorld;
	half3 eyeVec;
#else
	float3 normalWorld;
	float3 eyeVec;
#endif	
	half alpha;
	float3 posWorld;
	half occlusion;
	half3 reflectDir;
};

struct GIInput
{
	float3 worldPos;
	half3 worldViewDir;
	half3 ambient;

#ifdef _PLANAR_REFLECTION_ON
	half2 screenProjCoord;
#endif

#ifdef MORE_HALF
	half4 lightmapUV;
	half4 probeHDR[2];
#else
	float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV
	// HDR cubemap properties, use to decompress HDR texture
	float4 probeHDR[2];
#endif
};

#define ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)


float4 TexCoords(VertexInput v)
{
	float4 texcoord;
	texcoord.xy = v.uv0; // Always source from uv0
	//texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
	texcoord.zw = v.uv2;	// lmz modify
	return texcoord;
}

half3 NssShadeSH9(half4 normal)
{
	return SampleSH(normal.xyz);
}


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


inline half3 DiffuseAndSpecularFromMetallic1(half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
#ifdef _NO_METALLIC
    specColor = ColorSpaceDielectricSpec.rgb;
    oneMinusReflectivity = ColorSpaceDielectricSpec.a;
	return albedo * oneMinusReflectivity;
#endif

	specColor = lerp(ColorSpaceDielectricSpec.rgb, albedo, metallic);
	//oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);


	// We'll need oneMinusReflectivity, so
	//   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
	// store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
	//   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
	//                  = alpha - metallic * alpha
	half oneMinusDielectricSpec = ColorSpaceDielectricSpec.a;
	oneMinusReflectivity = oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;


	return albedo * oneMinusReflectivity;
}

inline float GGXTerm1(float NdotH, float roughness)
{
	float a2 = roughness * roughness;
	float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad

	return INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
											// therefore epsilon is smaller than what can be represented by half
}

inline half GGXTerm2(half roughness, half nh)
{
	half a = roughness * roughness;
	half a2 = a * a;
	half d = (nh * a2 - nh) * nh + 1.00001h;		// 2 mad
	return a2 / (d * d + 1e-7);					// 4 mul, 1 rcp
}


#ifdef MORE_HALF
inline half3 SafeNormalize(half3 inVec)
{
	half dp3 = max(0.001f, dot(inVec, inVec));
	return inVec * rsqrt(dp3);
}
#endif

inline half4 Pow4(half4 x)
{
	return x * x*x*x;
}


// approximage Schlick with ^4 instead of ^5
inline half3 FresnelLerpFast(half3 F0, half3 F90, half cosA)
{
	half t = Pow4(1 - cosA);
	return lerp(F0, F90, t);
}


half4 BRDF2_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
#ifdef MORE_HALF
	half3 normal, half3 viewDir,
#else
    float3 normal, float3 viewDir,
#endif
	DirLight light, UnityIndirect gi, half4 fastPBR)
{

#ifdef MORE_HALF
    half3 halfDir = SafeNormalize(half3(light.dir) + viewDir);
#else
	float3 halfDir = SafeNormalize(float3(light.dir) + viewDir);
#endif

#ifdef _SHADING_IN_VS
	half nl = fastPBR.z;
#else
	half nl = saturate(dot(normal, light.dir));
#endif

#ifdef MORE_HALF
	half nh = saturate(dot(normal, halfDir));
#else
    float nh = saturate(dot(normal, halfDir));
#endif


    half nv = saturate(dot(normal, viewDir));

#ifdef MORE_HALF
	half lh = saturate(dot(light.dir, halfDir));
#else
	float lh = saturate(dot(light.dir, halfDir));
#endif

    // Specular term
    half perceptualRoughness = 1-smoothness;
    half roughness = perceptualRoughness * perceptualRoughness;

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155
    half a = roughness;


#ifdef MORE_HALF
	half a2 = a * a;

	half d = nh * nh * (a2 - 1.f) + 1.00001f;

	half specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);

	specularTerm = specularTerm - 1e-4f;


	specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#else
    float a2 = a*a;

    float d = nh * nh * (a2 - 1.f) + 1.00001f;

    float specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);

    specularTerm = specularTerm - 1e-4f;


    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif


    half surfaceReduction = (0.6-0.08*perceptualRoughness);

    surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));

	half lerpFactor = Pow4(1 - nv);

#ifdef _SHADING_IN_VS
	lerpFactor = fastPBR.y;
#endif

#if defined(_SECOND_LAYER) && !defined(LOW_QUALITY) && !defined(MID_QUALITY)
#if defined(_NMR_CONST) && defined(_NMR2_CONST)
	surfaceReduction = fastPBR.x;
#endif
#else
#ifdef _NMR_CONST
	surfaceReduction = fastPBR.x;
#endif	
#endif

	half3 IndirectSpecular = surfaceReduction * lerp(specColor, grazingTerm, lerpFactor) *  gi.specular;

#ifdef _DIRECT_SPEC_ON
    half3 color =   (diffColor * light.diffuse + specularTerm * specColor * light.specular) * light.color * nl
                    + gi.diffuse * diffColor
                + IndirectSpecular;
#else  
	half3 color = diffColor * light.color * nl * light.specular
		+ gi.diffuse * diffColor
		+ IndirectSpecular;
#endif

	return half4(color, 1);
}


// ----------------------------------------------------------------------------
// GlossyEnvironment - Function to integrate the specular lighting with default sky or reflection probes
// ----------------------------------------------------------------------------
struct GlossyEnvironmentData
{
	// - Deferred case have one cubemap
	// - Forward case can have two blended cubemap (unusual should be deprecated).

	// Surface properties use for cubemap integration
	half    roughness; // CAUTION: This is perceptualRoughness but because of compatibility this name can't be change :(
	half3   reflUVW;
};

GlossyEnvironmentData GlossyEnvironmentSetup(half Smoothness, half3 reflectDir, float3 posWorld)
{
	GlossyEnvironmentData g;

	g.roughness /* perceptualRoughness */ = 1-Smoothness;
	g.reflUVW = reflectDir; 


#if CORRECT_BOX
	g.reflUVW = LocalCorrectBox(normalize(reflectDir), _BoxMin, _BoxMax, posWorld, _LocalCubePos);
#endif

#if CORRECT_CYLINDER
	g.reflUVW = LocalCorrectCylinder(normalize(reflectDir), posWorld, _GeometryCenter, _Radius, _LocalCubePos);
#endif

	return g;
}

// ----------------------------------------------------------------------------
half perceptualRoughnessToMipmapLevel(half perceptualRoughness)
{
	half LOD_STEPS = 6;
	return perceptualRoughness * LOD_STEPS;
}
// ----------------------------------------------------------------------------
half3 GlossyEnvironment(TEXTURECUBE_PARAM(tex,samplertex), half4 hdr, GlossyEnvironmentData glossIn)
{
	half perceptualRoughness = glossIn.roughness /* perceptualRoughness */;


	// MM: came up with a surprisingly close approximation to what the #if 0'ed out code above does.
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);


	half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
	half3 R = glossIn.reflUVW;

	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(tex, samplertex, R, mip);

	return DecodeHDREnvironment(rgbm, hdr);
}

inline half3 GI_IndirectSpecular(GIInput data, half occlusion, GlossyEnvironmentData glossIn)
{
	half4 specular = half4(0,0,0,1);
    
#ifdef _PLANAR_REFLECTION_ON
	specular = tex2D(_MirrorReflectionTex, data.screenProjCoord).rgba;
#if !_ENABLETOD
	half3 env0 = GlossyEnvironment(TEXTURECUBE_ARGS(unity_SpecCube0,samplerunity_SpecCube0), data.probeHDR[0], glossIn);
#else
	half3 env0First = GlossyEnvironment(TEXTURECUBE_ARGS(_SpecCube0First,sampler_SpecCube0First), data.probeHDR[0], glossIn);
	half3 env0Second = GlossyEnvironment(TEXTURECUBE_ARGS(_SpecCube0Second,sampler_SpecCube0Second), data.probeHDR[0], glossIn);
	half3 env0 = lerp(env0First, env0Second, _LightmapLerp);

#endif
	//reyyi : 仿照UE根据粗糙度混合Reflection probe和平面反射的结果以接近对齐中低配无平面反射效果，根据美术需求取平方以加强粗糙占比，经验公式
	specular.rgb = lerp(env0,specular.rgb,(1 - glossIn.roughness) * (1 - glossIn.roughness) * specular.a);
#else
#if !_ENABLETOD
	half3 env0 = GlossyEnvironment(TEXTURECUBE_ARGS(unity_SpecCube0,samplerunity_SpecCube0), data.probeHDR[0], glossIn);
#else
	half3 env0First = GlossyEnvironment(TEXTURECUBE_ARGS(_SpecCube0First,sampler_SpecCube0First), data.probeHDR[0], glossIn);
	half3 env0Second = GlossyEnvironment(TEXTURECUBE_ARGS(_SpecCube0Second,sampler_SpecCube0Second), data.probeHDR[0], glossIn);
	half3 env0 = lerp(env0First, env0Second, _LightmapLerp);

#endif
	specular.rgb = env0;
#endif

	return specular.rgb * occlusion;
}

//No planar reflection
inline half3 GI_IndirectSpecular_Low(GIInput data, half occlusion, GlossyEnvironmentData glossIn)
{
	half3 env0 = GlossyEnvironment(TEXTURECUBE_ARGS(unity_SpecCube0,samplerunity_SpecCube0), data.probeHDR[0], glossIn);

	half3 specular = env0;

	return specular * occlusion;
}

#ifdef MORE_HALF
half3 Emission(half2 uv)
#else
half3 Emission(float2 uv)
#endif
{
#ifdef _EMISSION
	return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb * _EmissionScale;
#endif
	return 0;
}




UnityIndirect CreateIndirectLight(GIInput data, BakedInput bakeData, half occlusion, VertexOutputForwardBase i, FragmentCommonData s)
{
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

#if UNITY_SHOULD_SAMPLE_SH
	indirectLight.diffuse = i.ambientOrLightmapUV.rgb;

#elif  defined(STATIC_SHADOW_SH)
    indirectLight.diffuse = i.ambientOrLightmapUV.rgb;

#elif  defined(LIGHTMAP_ON)
	half3 bakedColor = bakeData.lightMapColor;

	#if defined (DIRLIGHTMAP_COMBINED)
		real4 bakedDirTex = SAMPLE_TEXTURE2D(unity_LightmapInd, samplerunity_Lightmap, data.lightmapUV.xy);
		bakedColor = DecodeDirectionalLightmap(bakedColor, bakedDirTex, normalize(s.normalWorld));
	#endif

	indirectLight.diffuse = bakedColor;
#endif
	GlossyEnvironmentData glossIn = GlossyEnvironmentSetup(1 - s.roughness, s.reflectDir, s.posWorld);
	indirectLight.specular = GI_IndirectSpecular(data, occlusion, glossIn);
    indirectLight.diffuse *= occlusion;
	return indirectLight;
}



inline half4 VertexGIForward(VertexInput v, float3 posWorld, half3 normalWorld)
{
	half4 ambientOrLightmapUV = 0;
#ifdef STATIC_SHADOW_SH
    ambientOrLightmapUV.rgb = max(half3(0, 0, 0), StaticSingleSH9(half4(normalWorld, 1.0)));
#elif defined(LIGHTMAP_ON)
	ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	ambientOrLightmapUV.zw = 0;
#elif UNITY_SHOULD_SAMPLE_SH
	ambientOrLightmapUV.rgb = max(half3(0, 0, 0), NssShadeSH9(half4(normalWorld, 1.0)));
#endif
	return ambientOrLightmapUV;
}

#ifdef MORE_HALF
half3 PerPixelWNormal(half3 normalTangent, half4 tangentToWorld[3])
#else
float3 PerPixelWNormal(half3 normalTangent, float4 tangentToWorld[3])
#endif
{
	half3 tangent = tangentToWorld[0].xyz;
	half3 binormal = tangentToWorld[1].xyz;
	half3 normal = tangentToWorld[2].xyz;

#ifdef MORE_HALF
	half3 normalWorld = normalize(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
#else
	float3 normalWorld = normalize(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
#endif	
	return normalWorld;
}

#ifdef MORE_HALF
inline BakedInput BakeInputSetup(half2 shadowCoord)
#else
inline BakedInput BakeInputSetup(float2 shadowCoord)
#endif
{
	BakedInput bakeInput;
	
#if !_ENABLETOD
	half4 bakedColorTex = SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, shadowCoord);
	bakeInput.lightMapColor = 5.0f  * bakedColorTex.rgb;
	 //bakeInput.lightMapColor = (unity_Lightmap_HDR.x * pow(bakedColorTex.a, unity_Lightmap_HDR.y)) * bakedColorTex.rgb;
#else
	half4 lightmapFirst =  tex2D(_LightmapFirst, shadowCoord);
	half4 lightmapSecend = tex2D(_LightmapSecend, shadowCoord);

	bakeInput.lightMapColor =  5.0f * lerp(lightmapFirst.rgb, lightmapSecend.rgb, _LightmapLerp);
#endif
#if !_ENABLETOD
	bakeInput.shadowMaskValue = bakedColorTex.a;
#else
	bakeInput.shadowMaskValue = lerp(lightmapFirst.a, lightmapSecend.a, _LightmapLerp);
#endif

	return bakeInput;
}

#ifdef MORE_HALF
inline FragmentCommonData NormalAndMetallicSetup(half4 i_tex, half2 i_tex2, half3 i_eyeVec, float3 i_posWorld, half bumpScale, half4 i_color, half4 tangentToWorld[3])
#else
inline FragmentCommonData NormalAndMetallicSetup(float4 i_tex, float2 i_tex2, float3 i_eyeVec, float3 i_posWorld, half bumpScale, half4 i_color, float4 tangentToWorld[3])
#endif
{
	FragmentCommonData o = (FragmentCommonData)0;

	half4 baseColor = _BaseColor;
	half metallic = _Metallic;
	half roughness = _Roughness;

#ifdef _SECOND_LAYER
	baseColor = lerp(_BaseColor2, baseColor, i_color.a);
#if !defined(LOW_QUALITY) && !defined(MID_QUALITY)
	metallic = lerp(_Metallic2, metallic, i_color.a);
	roughness = lerp(_Roughness2, roughness, i_color.a);
#endif
#endif

	half occlusion = 1;
	
	#ifdef _OCCLUSIONMAP
		half2 occlusionUV = _OcclusionSeUV == 1 ? i_tex.zw : i_tex.xy;
		 occlusion = 1 - ((1 - saturate(tex2D(_OcclusionMap, occlusionUV).x))*_Occlusion);
	#elif defined(UV2_AS_OCCLUSION)
	     occlusion = 1 - ((1 - saturate(i_tex.w)) * _Occlusion);
	#endif
	
	half2 metallicRoughness = half2(metallic, roughness);
#if defined(_SECOND_LAYER) && !defined(LOW_QUALITY) && !defined(MID_QUALITY)
	#if  defined(NORMALMAP) && defined(NORMALMAP2)
		half4 normalMR = tex2D(_NormalMRMap, i_tex.xy);
		half4 normalMR2 = tex2D(_NormalMRMap2, i_tex2.xy);
		metallicRoughness = lerp(normalMR2.wz, normalMR.wz, i_color.a);
		#ifndef LOW_QUALITY
		half3 normalTangent = NssUnpackScaleNormalXY(normalMR.xy, bumpScale);
		o.normalWorld = PerPixelWNormal(normalTangent, tangentToWorld);
		half3 normalTangent2 = NssUnpackScaleNormalXY(normalMR2.xy, _BumpScale2);
		o.normalWorld = lerp(PerPixelWNormal(normalTangent2, tangentToWorld), o.normalWorld, i_color.a);
		#else
		o.normalWorld = normalize(tangentToWorld[2]);
		#endif
	#elif defined(NORMALMAP)
		half4 normalMR = tex2D(_NormalMRMap, i_tex.xy);
		metallicRoughness = lerp(metallicRoughness, normalMR.wz, i_color.a);
		#ifndef LOW_QUALITY
		half3 normalTangent = NssUnpackScaleNormalXY(normalMR.xy, bumpScale);
		o.normalWorld = PerPixelWNormal(normalTangent, tangentToWorld);
		o.normalWorld = lerp(normalize(tangentToWorld[2]), o.normalWorld, i_color.a);
		#else
		o.normalWorld = normalize(tangentToWorld[2]);
		#endif 
	#elif defined(NORMALMAP2)
		half4 normalMR2 = tex2D(_NormalMRMap2, i_tex2.xy);
		metallicRoughness = lerp(normalMR2.wz, metallicRoughness, i_color.a);
		#ifndef LOW_QUALITY
		half3 normalTangent = NssUnpackScaleNormalXY(normalMR2.xy, _BumpScale2);
		o.normalWorld = PerPixelWNormal(normalTangent, tangentToWorld);
		o.normalWorld = lerp(o.normalWorld, normalize(tangentToWorld[2]), i_color.a);
		#else
		o.normalWorld = normalize(tangentToWorld[2]);
		#endif
	#else
		o.normalWorld = normalize(tangentToWorld[0]);
	#endif
#else
#if  defined (NORMALMAP)
	half4 normalMR = tex2D(_NormalMRMap, i_tex.xy);

	metallicRoughness = normalMR.wz;

	#ifndef LOW_QUALITY
	half3 normalTangent = NssUnpackScaleNormalXY(normalMR.xy, bumpScale);
	o.normalWorld = PerPixelWNormal(normalTangent, tangentToWorld);
	#else
	o.normalWorld = normalize(tangentToWorld[2]);
	#endif
#else
	o.normalWorld = normalize(tangentToWorld[0]);
#endif
#endif

	#if defined(_SECOND_LAYER) && (!defined(LOW_QUALITY)) && (!defined(MID_QUALITY))
		#if defined(_NMR_CONST) || defined(_NMR2_CONST)
			metallic = metallicRoughness.x;
			roughness = metallicRoughness.y;
			#if defined(_NMR_CONST) && defined(_NMR2_CONST)
			metallic  = lerp(_AVGMetallic2, _AVGMetallic, i_color.a);
			roughness = lerp(_AVGRoughness2, _AVGRoughness, i_color.a);
			#elif defined(_NMR_CONST)
			metallic = lerp(metallic, _AVGMetallic, i_color.a);
			roughness = lerp(roughness, _AVGRoughness, i_color.a);
			#elif defined(_NMR2_CONST)
			metallic = lerp(_AVGMetallic2, metallic, i_color.a);
			roughness = lerp(_AVGRoughness2, roughness, i_color.a);
			#endif
		#else
			metallic = metallicRoughness.x;
			roughness = metallicRoughness.y;
		#endif
	#else
		#ifdef _NMR_CONST
		metallic = _AVGMetallic;
		roughness = _AVGRoughness;
		#else
		metallic = metallicRoughness.x;
		roughness = metallicRoughness.y;
		#endif
	#endif

	half oneMinusReflectivity;
	half3 specColor;

	half4 albedo = tex2D(_BaseMap, i_tex.xy);
#ifdef _SECOND_LAYER
	albedo = lerp(tex2D(_BaseMap2, i_tex2.xy), albedo, i_color.a);
#endif

	half3 diffColor = DiffuseAndSpecularFromMetallic1(albedo.rgb * baseColor.rgb * i_color.rgb, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

	
	o.diffColor = diffColor;
	o.specColor = specColor;
	o.oneMinusReflectivity = oneMinusReflectivity;
	o.roughness = roughness;
	o.occlusion = occlusion;
#if defined( _ENABLE_ALPHABLEND) || defined(_ENABLE_ALPHAPREMULTIPLY) || defined(_ENABLE_ALPHATEST)	
	o.alpha = albedo.a * baseColor.a * i_color.a;
#endif
	
#if _ENABLE_ALPHAPREMULTIPLY
	o.diffColor *= o.alpha;
	o.alpha = 1 - oneMinusReflectivity + o.alpha * oneMinusReflectivity;
#endif
	o.eyeVec = normalize(i_eyeVec);
	o.posWorld = i_posWorld;
	return o;
}

#ifdef MORE_HALF
inline FragmentCommonData FragmentSetupTangent(inout half4 i_tex, half2 i_tex2, half3 i_eyeVec, half4 tangentToWorld[3], float3 i_posWorld, half bumpScale, half4 i_color)
#else
inline FragmentCommonData FragmentSetupTangent(inout float4 i_tex, float2 i_tex2, float3 i_eyeVec, float4 tangentToWorld[3], float3 i_posWorld, half bumpScale, half4 i_color)
#endif
{
	FragmentCommonData o = NormalAndMetallicSetup(i_tex, i_tex2, i_eyeVec, i_posWorld, bumpScale, i_color, tangentToWorld);
	return o;
}


#ifdef NSS_LOD_FADE_CROSSFADE
    UNITY_INSTANCING_BUFFER_START(NssLodInstancingProps)
        UNITY_DEFINE_INSTANCED_PROP(float, _NssLODFadeArray)
    UNITY_INSTANCING_BUFFER_END(NssLodInstancingProps)

    #ifndef NSS_APPLY_DITHER_CROSSFADE
        #define NSS_APPLY_DITHER_CROSSFADE(vpos) NssApplyDitherCrossFade(vpos)
        sampler2D _DitherMaskLOD2D;
        void NssApplyDitherCrossFade(half2 vpos)
        {
            vpos /= 4; // the dither mask texture is 4x4
            half fade = UNITY_ACCESS_INSTANCED_PROP(NssLodInstancingProps, _NssLODFadeArray); // quantized lod fade by 16 levels
            
            vpos.y = frac(vpos.y) * 0.0625 + clamp(1 - fade, 0.0001,1-0.0624999); /* 1/16 */ 
            clip(tex2D(_DitherMaskLOD2D, vpos).a - 0.5);
        }
        
        #define NSS_APPLY_DITHER_CROSSFADE_CLIPVALUE(vpos) NssApplyDitherCrossFadeValue(vpos)

        half NssApplyDitherCrossFadeValue(half2 vpos)
        {
            vpos /= 4; // the dither mask texture is 4x4
            half fade = UNITY_ACCESS_INSTANCED_PROP(NssLodInstancingProps, _NssLODFadeArray); // quantized lod fade by 16 levels
            
            vpos.y = frac(vpos.y) * 0.0625 + clamp(1 - fade, 0.0001,1-0.0624999); /* 1/16 */ 
            return step(tex2D(_DitherMaskLOD2D, vpos).a,0.5);
        } 
        
    #endif

#else
    #define NSS_APPLY_DITHER_CROSSFADE(vpos)
    #define NSS_APPLY_DITHER_CROSSFADE_CLIPVALUE(vpos) 0
#endif



#ifdef LOD_FADE_CROSSFADE
    #define UNITY_APPLY_DITHER_CROSSFADE_CLIPVALUE(vpos)  UnityApplyDitherCrossFadeValue(vpos)
  //  sampler2D unity_DitherMask;

#else
    #define UNITY_APPLY_DITHER_CROSSFADE_CLIPVALUE(vpos)  0
#endif


#endif

