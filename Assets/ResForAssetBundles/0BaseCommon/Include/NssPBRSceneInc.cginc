// Upgrade NOTE: replaced 'defined METALLICGLOSSMAP' with 'defined (METALLICGLOSSMAP)'
// Upgrade NOTE: replaced 'defined NORMALMAP' with 'defined (NORMALMAP)'

#ifndef NSS_PBRSCENE_INCLUDED
#define  NSS_PBRSCENE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
#include "../Shaders/NssPBRFog.cginc"
#include "LocalReflection.cginc"
//#include "NssLighting.cginc"

//#include "../QSM_COLORSPACE_CORE.cginc"

sampler2D _ParamMap;
sampler2D _BaseMap;
sampler2D _BumpMap;
sampler2D _EmissionMap;
sampler2D _NormalMRMap;
sampler2D _OcclusionMap;

float4 _BaseMap_ST;

half4 _BaseColor;
half _EmissionScale;
half4 _EmissionColor;
half _Metallic;
half _Roughness;
half _Occlusion;
half _BumpScale;
half _Cutoff;

#if _ENABLETOD
sampler2D _LightmapSecend;
sampler2D _LightmapFirst;
//half _LightmapLerp;
#endif



half3 NssUnpackScaleNormalXY(half2 packednormal, half bumpScale)
{
	// This do the trick
	half3 normal;
	normal.xy = (packednormal.xy * 2 - 1);
	// SM2.0: instruction count limitation
	// SM2.0: normal scaler is not supported
	normal.xy *= bumpScale;
	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	return normal;
}

struct VertexInput
{
	half4 color     :COLOR;
	float4 vertex   : POSITION;
	half3 normal    : NORMAL;
	float4 tangent : TANGENT;
	float2 uv0      : TEXCOORD0;
	float2 uv1      : TEXCOORD1;
	float2 uv2      : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutputForwardBase
{
	float4 pos : SV_POSITION;
	half4 color : COLOR;
	float4 tex                            : TEXCOORD0;
	float4 eyeVec                         : TEXCOORD1;
	float4 tangentToWorldAndPackedData[3] : TEXCOORD2;
	half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV
	float4 _ShadowCoord : TEXCOORD6;
	NSS_FOG_COORDS(7)
	float3 posWorld                 : TEXCOORD8;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

half3 Emission(float2 uv)
{
#ifdef _EMISSION
	return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb * _EmissionScale;
#endif
	return 0;
}
half3 NssShadeSH9(half4 normal)
{
	return SampleSH(normal.xyz);
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

float3 PerPixelWNormal(half3 normalTangent, float4 tangentToWorld[3])
{
	half3 tangent = tangentToWorld[0].xyz;
	half3 binormal = tangentToWorld[1].xyz;
	half3 normal = tangentToWorld[2].xyz;
	
	float3 normalWorld = normalize(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
	return normalWorld;
}

inline BakedInput BakeInputSetup(float2 shadowCoord)
{
	BakedInput bakeInput;
	
#if !_ENABLETOD
	half4 bakedColorTex = SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, shadowCoord);
	bakeInput.lightMapColor = 5.0f * bakedColorTex.rgb;
	//bakeInput.lightMapColor = (unity_Lightmap_HDR.x * pow(bakedColorTex.a, unity_Lightmap_HDR.y)) * bakedColorTex.rgb;
	//bakeInput.lightMapColor = DecodeLightmap(bakeInput.lightMapColor);
#else//下面应该也是类似问题
	half4 lightmapFirst = tex2D(_LightmapFirst, shadowCoord);
	half4 lightmapSecend = tex2D(_LightmapSecend, shadowCoord);

	bakeInput.lightMapColor = 5.0f * lerp(lightmapFirst.rgb, lightmapSecend.rgb, _LightmapLerp);
#endif
#if !_ENABLETOD
	bakeInput.shadowMaskValue = bakedColorTex.a;
#else
	bakeInput.shadowMaskValue = lerp(lightmapFirst.a, lightmapSecend.a, _LightmapLerp);
#endif


	return bakeInput;
}

#ifdef NSS_LOD_FADE_CROSSFADE
    UNITY_INSTANCING_BUFFER_START(NssLodInstancingProps)
        UNITY_DEFINE_INSTANCED_PROP(float, _NssLODFadeArray)
    UNITY_INSTANCING_BUFFER_END(NssLodInstancingProps)

    #ifndef NSS_APPLY_DITHER_CROSSFADE
        #define NSS_APPLY_DITHER_CROSSFADE(vpos) NssApplyDitherCrossFade(vpos)
        sampler2D _DitherMaskLOD2D;
        void NssApplyDitherCrossFade(float2 vpos)
        {
            vpos /= 4; // the dither mask texture is 4x4
            half fade = UNITY_ACCESS_INSTANCED_PROP(NssLodInstancingProps, _NssLODFadeArray); // quantized lod fade by 16 levels
            
            vpos.y = frac(vpos.y) * 0.0625 + clamp(1 - fade, 0.0001,1-0.0624999); /* 1/16 */ 
            clip(tex2D(_DitherMaskLOD2D, vpos).a - 0.5);
        }
        
        #define NSS_APPLY_DITHER_CROSSFADE_CLIPVALUE(vpos) NssApplyDitherCrossFadeValue(vpos)

        half NssApplyDitherCrossFadeValue(float2 vpos)
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

#endif

