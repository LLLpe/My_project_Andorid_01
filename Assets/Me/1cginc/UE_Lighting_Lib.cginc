#ifndef NSS_LIGHTING_BASE
#define NSS_LIGHTING_BASE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define MAX_VISIBLE_LIGHTS 16
#define HALF_MIN 6.103515625e-5 
#ifdef _PLANAR_REFLECTION_ON
sampler2D _MirrorReflectionTex;
#endif
half3 _SunDir;
half3 _SunColor;
half3 _NssLightColor = half3(1.0, 1.0, 1.0);
half _AverageBrightness;
half3 _SecondLightDir;

//float4 _AdditionalLightsPosition[MAX_VISIBLE_LIGHTS];
//half4 _AdditionalLightsColor[MAX_VISIBLE_LIGHTS];
//half4 _AdditionalLightsAttenuation[MAX_VISIBLE_LIGHTS];
//half4 _AdditionalLightsSpotDir[MAX_VISIBLE_LIGHTS];
//float4x4 _WorldToAdditionalLights[MAX_VISIBLE_LIGHTS];
//float4 _AdditionalLightsIndices[2];
//float _AdditionalLightsCount;
TEXTURE2D_FLOAT (_LightTexture0);SAMPLER (sampler_LightTexture0);
TEXTURE2D_FLOAT (_LightTextureB0);SAMPLER (sampler_LightTextureB0);

#if _ENABLETOD
TEXTURECUBE(_SpecCube0First);SAMPLER( sampler_SpecCube0First);
TEXTURECUBE(_SpecCube0Second);SAMPLER( sampler_SpecCube0Second);
half _LightmapLerp;
#endif

half3 GetMainLightDir()
{
	return _SunDir;
}

half3 GetMainLightColor()
{
	return _SunColor;
}

half3 GetSecondLightDir()
{
	return _SecondLightDir;
}

half GetAverageBrightness()
{
	return _AverageBrightness;
}


half GetIndirectDiffuseWithUnitySH(half4 normal)
{
	half3 L0L1;
	L0L1.r = dot(unity_SHAr, normal);
	L0L1.g = dot(unity_SHAg, normal);
	L0L1.b = dot(unity_SHAb, normal);

	half3 L2X1, L2X2;
	half4 vB = normal.xyzz * normal.yzzx;
	L2X1.r = dot(unity_SHBr, vB);
	L2X1.g = dot(unity_SHBg, vB);
	L2X1.b = dot(unity_SHBb, vB);

	// Final (5th) quadratic (L2) polynomial
	half vC = normal.x*normal.x - normal.y*normal.y;
	L2X2 = unity_SHC.rgb * vC;

	return L0L1 + L2X1 + L2X2;
}

#ifdef _CUSTOM_CUBEMAP
float3 _SH_0;
float3 _SH_1;
float3 _SH_2;
float3 _SH_3;
float3 _SH_4;
float3 _SH_5;
float3 _SH_6;
float3 _SH_7;
float3 _SH_8;

half _hdrMax;

#define SHBasic0(normal) 0.2821
#define SHBasic1(normal) (-0.4886) * normal.y
#define SHBasic2(normal) 0.4886 * normal.z
#define SHBasic3(normal) (-0.4886) * normal.x
#define SHBasic4(normal) 1.09254 * normal.x * normal.y
#define SHBasic5(normal) (-1.09254) * normal.z * normal.y
#define SHBasic6(normal) (0.94617 * normal.z * normal.z - 0.31539)
#define SHBasic7(normal) (-1.09254) * normal.z * normal.x
#define SHBasic8(normal) 0.54627 * (normal.x * normal.x - normal.y * normal.y)

half3 GetSHLightintIrradiance(float3 normal, half3x3 rotation)
{
	normal = mul(rotation, normal);
	half3 SH = half3(0, 0, 0);

	

#ifdef _TWOSIDE_LIGHTING
	SH += _SH_0 * SHBasic0(normal);
	SH += _SH_1 * SHBasic1(normal);
	SH += _SH_2 * SHBasic2(normal);
	SH += _SH_3 * SHBasic3(normal);
	
	SH += _SH_0 * SHBasic0(-normal);
	SH += _SH_1 * SHBasic1(-normal);
	SH += _SH_2 * SHBasic2(-normal);
	SH += _SH_3 * SHBasic3(-normal);

#else
	SH += _SH_0 * SHBasic0(normal);
	SH += _SH_1 * SHBasic1(normal);
	SH += _SH_2 * SHBasic2(normal);
	SH += _SH_3 * SHBasic3(normal);
	SH += _SH_4 * SHBasic4(normal);
	SH += _SH_5 * SHBasic5(normal);
	SH += _SH_6 * SHBasic6(normal);
	SH += _SH_7 * SHBasic7(normal);
	SH += _SH_8 * SHBasic8(normal);
#endif


	return SH;
}


half3 GetIndirectDiffuseCustom(half3 worldNormal, half3x3 rotation, samplerCUBE customReflectionCube)
{

	half3 rotateNormal = mul(rotation, worldNormal);


	half4 rgbm = texCUBElod(customReflectionCube, half4(rotateNormal, 0));
#ifdef SHADER_API_MOBILE
	const half4 unity_rgbm_hdr = half4(34.49, 2.2, 0, 0);
#else
	const half4 unity_rgbm_hdr = half4(1, 1, 0, 0);
#endif
	half3 hdr = DecodeHDREnvironment(rgbm, unity_rgbm_hdr);

	return clamp(hdr, 0, _hdrMax);

}


half3 GetIndirectSpecularCustom(half3 worldViewDir, half3 worldTangent, half3 worldNormal, half roughness, half3x3 rotation, samplerCUBE customReflectionCube)
{

	half3 reflectDir = reflect(-worldViewDir, worldNormal);

	reflectDir = mul(rotation, reflectDir);

#ifdef _SUPER_HIGH
	float CubemapMaxMip = 7.0;
	float LevelFrom1x1 = 1 - 1.2 * log2(max(roughness, 0.001));
	float mip = CubemapMaxMip - 1 - LevelFrom1x1;
#else
	float mip = 6 * roughness;
#endif

#ifdef SHADER_API_MOBILE
	const half4 unity_RGBM_HDR = half4(34.49, 2.2, 0, 0);
	half4 rgbm = texCUBElod(customReflectionCube, half4(reflectDir, mip));
	half3 hdr = rgbm.xyz * unity_RGBM_HDR.x *pow(rgbm.w, unity_RGBM_HDR.y);
#else
	half3 hdr = texCUBElod(customReflectionCube, half4(reflectDir, mip)).xyz;
#endif

	return clamp(hdr, 0, _hdrMax);
}
#endif

half3 GetIndirectSpecularFull(half3 worldViewDir, half3 worldTangent, half3 worldNormal, half roughness)
{
	float CubemapMaxMip = 7.0;
	float LevelFrom1x1 = 1 - 1.2 * log2(max(roughness, 0.001));
	float mip = CubemapMaxMip - 1 - LevelFrom1x1;

	//mip = CubemapMaxMip * roughness*(1.7 - 0.7*roughness);
	float3 reflectDir = reflect(normalize(-worldViewDir), normalize(worldNormal));

#if !_ENABLETOD
	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDir, mip);
	return DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR);
#else
	half4 rgbmFirst = SAMPLE_TEXTURECUBE_LOD(_SpecCube0First, sampler_SpecCube0First, reflectDir, mip);
	half3 colorFirst = DecodeHDREnvironment(rgbmFirst, unity_SpecCube0_HDR);
	half4 rgbmSecond = SAMPLE_TEXTURECUBE_LOD(_SpecCube0Second, sampler_SpecCube0Second, reflectDir, mip);
	half3 colorSecond = DecodeHDREnvironment(rgbmSecond, unity_SpecCube0_HDR);
	return lerp(rgbmFirst, rgbmSecond, _LightmapLerp);
#endif
}

//deprecated, use GetIndirectSpecularFull as Instead
half3 GetIndirectSpecular(half3 worldViewDir, half3 normal, half roughness)
{
	float CubemapMaxMip = 7.0;
	float LevelFrom1x1 = 1 - 1.2 * log2(max(roughness, 0.001));
	float mip =  CubemapMaxMip - 1 - LevelFrom1x1;

	//mip = CubemapMaxMip * roughness*(1.7 - 0.7*roughness);
	float3 reflectDir = reflect(normalize(-worldViewDir), normalize(normal));

#if !_ENABLETOD
	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDir, mip);
	return DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR);
#else
	half4 rgbmFirst = SAMPLE_TEXTURECUBE_LOD(_SpecCube0First, sampler_SpecCube0First, reflectDir, mip);
	half3 colorFirst = DecodeHDREnvironment(rgbmFirst, unity_SpecCube0_HDR);
	half4 rgbmSecond = SAMPLE_TEXTURECUBE_LOD(_SpecCube0Second, sampler_SpecCube0Second, reflectDir, mip);
	half3 colorSecond = DecodeHDREnvironment(rgbmSecond, unity_SpecCube0_HDR);
	return lerp(rgbmFirst, rgbmSecond, _LightmapLerp);
#endif
}
half3 GetIndirectSpecularWithCorrection(half3 worldViewDir, half3 normal, half roughness, float3 posWorld)
{
	const int CubemapMaxMip = 7.0;
	half LevelFrom1x1 = 1 - 1.2 * log2(max(roughness, 0.001));
	half mip = CubemapMaxMip - 1 - LevelFrom1x1;

	half3 reflectDir = reflect(-worldViewDir, normal);

#if CORRECT_BOX
	reflectDir = LocalCorrectBox(normalize(reflectDir), _BoxMin, _BoxMax, posWorld, _LocalCubePos);
#endif

#if CORRECT_CYLINDER
	reflectDir = LocalCorrectCylinder(normalize(reflectDir), posWorld, _GeometryCenter, _Radius, _LocalCubePos);
#endif
#if !_ENABLETOD
	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDir, mip);
	return DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR);
#else
	half4 rgbmFirst = SAMPLE_TEXTURECUBE_LOD(_SpecCube0First, sampler_SpecCube0First, reflectDir, mip);
	half3 colorFirst = DecodeHDREnvironment(rgbmFirst, unity_SpecCube0_HDR);
	half4 rgbmSecond = SAMPLE_TEXTURECUBE_LOD(_SpecCube0Second, sampler_SpecCube0Second, reflectDir, mip);
	half3 colorSecond = DecodeHDREnvironment(rgbmSecond, unity_SpecCube0_HDR);
	return lerp(rgbmFirst, rgbmSecond, _LightmapLerp);
#endif
}
half3 GetIndirectSpecularWithCorrectionAndPlanarReflection(half3 worldViewDir, half3 normal, half roughness, float3 posWorld,float2 screenpos)
{
	const int CubemapMaxMip = 7.0;
	half LevelFrom1x1 = 1 - 1.2 * log2(max(roughness, 0.001));
	half mip = CubemapMaxMip - 1 - LevelFrom1x1;

	half3 reflectDir = reflect(-worldViewDir, normal);

#if CORRECT_BOX
	reflectDir = LocalCorrectBox(normalize(reflectDir), _BoxMin, _BoxMax, posWorld, _LocalCubePos);
#endif

#if CORRECT_CYLINDER
	reflectDir = LocalCorrectCylinder(normalize(reflectDir), posWorld, _GeometryCenter, _Radius, _LocalCubePos);
#endif
#ifdef _PLANAR_REFLECTION_ON
	float3 reflect = tex2D(_MirrorReflectionTex, screenpos).rgb;
	return reflect;
#else
#if !_ENABLETOD
	half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDir, mip);
	return DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR);
#else
	half4 rgbmFirst = SAMPLE_TEXTURECUBE_LOD(_SpecCube0First, sampler_SpecCube0First, reflectDir, mip);
	half3 colorFirst = DecodeHDREnvironment(rgbmFirst, unity_SpecCube0_HDR);
	half4 rgbmSecond = SAMPLE_TEXTURECUBE_LOD(_SpecCube0Second, sampler_SpecCube0Second, reflectDir, mip);
	half3 colorSecond = DecodeHDREnvironment(rgbmSecond, unity_SpecCube0_HDR);
	return lerp(rgbmFirst, rgbmSecond, _LightmapLerp);
#endif


#endif
}
struct BakedInput
{
	half3 lightMapColor;
	real  shadowMaskValue;
};

//用于shadowmask和lightcolor合并的材质
half3 GetIndirectDiffuseWithLS(BakedInput bakeData, half3 SHLight, float2 lightmapuv)
{
	half3 indirectdiffuse = 0;
#if UNITY_SHOULD_SAMPLE_SH
	indirectdiffuse = SHLight;
#elif  defined(LIGHTMAP_ON)

	half3 bakedColor = bakeData.lightMapColor;

#if defined (DIRLIGHTMAP_COMBINED)
	real4 bakedDirTex = SAMPLE_TEXTURE2D(unity_LightmapInd,samplerunity_Lightmap, data.lightmapUV.xy);
	bakedColor = DecodeDirectionalLightmap(bakedColor, bakedDirTex, normalize(s.normalWorld));
#endif

	indirectdiffuse = bakedColor / PI;
#endif
	return indirectdiffuse;
}

half GetDirectOcclusionWithLS(BakedInput bakeData, float4 ScreenPos, float3 worldPos)
{
	real shadow = 1.0f;
	//_SHADOWMASK used for prefab dynamic loading prefab 动态加载
#if defined (SHADOWS_SHADOWMASK)||defined(_SHADOWMASK)
	shadow = bakeData.shadowMaskValue;
#endif

#if defined(_MAIN_LIGHT_SHADOWS)&&!defined(_SHADOWMASK)
#ifndef SHADOWS_IF_OFF_TEST
	UNITY_BRANCH
		if (shadow > _MainLightShadowParams.r)
#endif
		{
			real shadowValue = 1.0f;
			float4 ShadowCoord;

			//transfer coord
#ifdef UNITY_NO_SCREENSPACE_SHADOWS
			ShadowCoord = mul(_MainLightWorldToShadow[0], float4(worldPos, 1.0f));
#else
			ShadowCoord = ScreenPos;
#endif
			//blur
			ShadowCoord.xyz = ShadowCoord.xyz / ShadowCoord.w;
			ShadowCoord.w = 1.0f;
#ifndef SHADOWS_IF_OFF_TEST
			UNITY_BRANCH
				if (ShadowCoord.z >= 0 && ShadowCoord.z < 1)
#endif
				{
#ifdef SHADOWS_SOFT	
#if defined(UNITY_NO_SCREENSPACE_SHADOWS) && defined(SHADER_SUPER_HIGH)
					shadowValue = NssSampleShadowmap_PCF3x3(ShadowCoord, 0);
#else
					shadowValue = SAMPLE_TEXTURE2D_SHADOW(_MainLightShadowmapTexture , sampler_MainLightShadowmapTexture ,  ShadowCoord);//gl3.0 has built-in PCF
#endif
#else
					shadowValue = SAMPLE_TEXTURE2D_SHADOW(_MainLightShadowmapTexture , sampler_MainLightShadowmapTexture ,  ShadowCoord);
#endif	
					//blend dynamic static shadow
#ifdef UNITY_NO_SCREENSPACE_SHADOWS
					shadow = min(shadow, _MainLightShadowParams.r + shadowValue * (1 - _MainLightShadowParams.r));
#else
					shadow = min(shadow, shadowValue);
#endif
				}

		}
#endif

	return shadow;
}

//int GetAdditionalLightsCount()
//{
//	// TODO: we need to expose in SRP api an ability for the pipeline cap the amount of lights
//	// in the culling. This way we could do the loop branch with an uniform
//	// This would be helpful to support baking exceeding lights in SH as well
//	return _AdditionalLightsCount;// min(_AdditionalLightsCount.x, unity_LightData.y);
//}
//
//int GetPerObjectLightIndex(uint index)
//{
//	return _AdditionalLightsIndices[index / 4][index % 4];
//}
//
//float DistanceAttenuation(float distanceSqr, half2 distanceAttenuation)
//{
//	// Reconstruct the light range from the Unity shader arguments
//	float lightRangeSqr = rcp(distanceAttenuation.x);
//
//	// Calculate the distance attenuation to approximate the built-in Unity curve
//	float normalizedDist = sqrt(distanceSqr / lightRangeSqr);
//	return saturate(rcp(1 + 25 * distanceSqr / lightRangeSqr) * saturate((1 - normalizedDist) * 5.0));
//}
//half AngleAttenuation(half3 spotDirection, half3 lightDirection, half2 spotAttenuation)
//{
//	// Spot Attenuation with a linear falloff can be defined as
//	// (SdotL - cosOuterAngle) / (cosInnerAngle - cosOuterAngle)
//	// This can be rewritten as
//	// invAngleRange = 1.0 / (cosInnerAngle - cosOuterAngle)
//	// SdotL * invAngleRange + (-cosOuterAngle * invAngleRange)
//	// SdotL * spotAttenuation.x + spotAttenuation.y
//
//	// If we precompute the terms in a MAD instruction
//	half SdotL = dot(spotDirection, lightDirection);
//	half atten = saturate(SdotL * spotAttenuation.x + spotAttenuation.y);
//	return atten * atten;
//}
//inline real UnitySpotCookie(float4 LightCoord)
//{
//	return tex2D(_LightTexture0, LightCoord.xy / LightCoord.w + 0.5).w;
//}
//inline real UnitySpotAttenuate(float3 LightCoord)
//{
//	return tex2D(_LightTextureB0, dot(LightCoord, LightCoord).xx).r;
//}
//
//// Fills a light struct given a perObjectLightIndex
//ShadingCustomInput GetAdditionalPerObjectLight(int perObjectLightIndex, float3 positionWS)
//{
//	// Abstraction over Light input constants
//	float4 lightPositionWS = _AdditionalLightsPosition[perObjectLightIndex];
//	half3 color = _AdditionalLightsColor[perObjectLightIndex].rgb;
//	half4 distanceAndSpotAttenuation = _AdditionalLightsAttenuation[perObjectLightIndex];
//	float4x4 worldToLight = _WorldToAdditionalLights[perObjectLightIndex];
//	// Directional lights store direction in lightPosition.xyz and have .w set to 0.0.
//	// This way the following code will work for both directional and punctual lights.
//	float3 lightVector = lightPositionWS.xyz - positionWS * lightPositionWS.w;
//	float distanceSqr = max(dot(lightVector, lightVector), HALF_MIN);
//#if 1
//	half3 lightDirection = half3(normalize(lightVector));
//	float4 lightCoord = mul(worldToLight, float4(positionWS, 1));
//	half attenuation = distanceAndSpotAttenuation.z == 0 ? UnitySpotAttenuate(lightCoord.xyz) : (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
//#else
//	half3 lightDirection = half3(lightVector * rsqrt(distanceSqr));
//	half4 spotDirection = _AdditionalLightsSpotDir[perObjectLightIndex];
//	half attenuation = DistanceAttenuation(distanceSqr, distanceAndSpotAttenuation.xy) * AngleAttenuation(spotDirection.xyz, lightDirection, distanceAndSpotAttenuation.zw);
//#endif
//	ShadingCustomInput LightInput;
//
//	LightInput.directMainLightDir = lightDirection;
//	LightInput.directMainLightColor = color * attenuation;
//	LightInput.indirectDiffuseColor = 0;
//	LightInput.indirectSpecularColor = 0;
//
//	return LightInput;
//}
//
//ShadingCustomInput GetAdditionalLight(uint i, float3 positionWS)
//{
//	int perObjectLightIndex = GetPerObjectLightIndex(i);
//	return GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
//}



#endif


