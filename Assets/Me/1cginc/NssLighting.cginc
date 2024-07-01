#ifndef NSS_LIGHTING_INCLUDED
#define  NSS_LIGHTING_INCLUDED

#include "QSM_COLORSPACE_CORE.cginc"
		   #include "QSM_BASE_MACRO.cginc"
#include "NssShadowInc.cginc"

half3 _SunDir;
half3 _SunColor;
half _DynamicShadowStrength = 0.5;


//静态阴影依赖光照方向
#include "NssStaticShadowInc.cginc"
#define SHADOWS_SOFT

struct DirLight
{
	half3 color;
	half3 dir;
	half diffuse;
	half specular;
};

struct BakedInput
{
	half3 lightMapColor;
	real  shadowMaskValue;
};


#define SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED
half SampleBakedOcclusion(BakedInput bakeData, float4 ScreenPos, float3 worldPos)
{
	real shadow = 1.0f;
	//_SHADOWMASK used for prefab dynamic loading prefab 动态加载
#if defined(LIGHTMAP_ON)&& defined (SHADOWS_SHADOWMASK)
	shadow = bakeData.shadowMaskValue;
#endif

#if defined(_MAIN_LIGHT_SHADOWS)&&!defined(_SHADOWMASK)
  #ifndef SHADOWS_IF_OFF_TEST
	UNITY_BRANCH
	if (shadow > 1 - _MainLightShadowParams.r)
  #endif
	{
		real shadowValue = 1.0f;
		float4 ShadowCoord;
	
		//transfer coord
		#ifdef UNITY_NO_SCREENSPACE_SHADOWS
			ShadowCoord = UnityMulPos(_MainLightWorldToShadow[0], float4(worldPos, 1.0f));
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
					shadowValue = SAMPLE_SHADOW(_MainLightShadowmapTexture, ShadowCoord);//gl3.0 has built-in PCF
			#endif
			#else
					shadowValue = SAMPLE_SHADOW(_MainLightShadowmapTexture, ShadowCoord);
			#endif	
							//blend dynamic static shadow
			#ifdef UNITY_NO_SCREENSPACE_SHADOWS
					shadow = min(shadow, 1-_MainLightShadowParams.r + shadowValue * _MainLightShadowParams.r);
			#else
					shadow = min(shadow, shadowValue);
			#endif
			}
	
	}
#endif

	return shadow;
}


#define SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED
half SampleBakedOcclusionWithDynamic(BakedInput bakeData, float4 ScreenPos, float3 worldPos, out half dynamicShadow)
{
	real shadow = 1.0f;
	dynamicShadow = 1.0;
	//_SHADOWMASK used for prefab dynamic loading prefab 动态加载
#if defined(LIGHTMAP_ON)&& defined (SHADOWS_SHADOWMASK)
	shadow = bakeData.shadowMaskValue;
	dynamicShadow = bakeData.shadowMaskValue;
#endif

#if defined(_MAIN_LIGHT_SHADOWS)
  #ifndef SHADOWS_IF_OFF_TEST
	UNITY_BRANCH
	if (shadow > 1 - _MainLightShadowParams.r)
  #endif
	{
		real shadowValue = 1.0f;
		float4 ShadowCoord;
	
		//transfer coord
		#ifdef UNITY_NO_SCREENSPACE_SHADOWS
			ShadowCoord = UnityMulPos(_MainLightWorldToShadow[0] , float4(worldPos, 1.0f));
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
					shadowValue = SAMPLE_SHADOW(_MainLightShadowmapTexture, ShadowCoord);//gl3.0 has built-in PCF
			#endif
			#else
					shadowValue = SAMPLE_SHADOW(_MainLightShadowmapTexture, ShadowCoord);
			#endif	
			
			//blend dynamic static shadow
			#ifdef UNITY_NO_SCREENSPACE_SHADOWS
			        dynamicShadow = min(shadow, 1-_MainLightShadowParams.r + lerp(1, shadowValue, _DynamicShadowStrength) *  _MainLightShadowParams.r);
					shadow = min(shadow, 1-_MainLightShadowParams.r + shadowValue * _MainLightShadowParams.r);
					
			#else
			        dynamicShadow = min(shadow, lerp(1, shadowValue, _DynamicShadowStrength));
					shadow = min(shadow, shadowValue);
			#endif
			}
	
	}
#endif

	return shadow;
}

#ifdef MORE_HALF
DirLight CreateLight(BakedInput bakeData, half4 ScreenPos, float3 worldPos)
#else
DirLight CreateLight(BakedInput bakeData, half4 ScreenPos, float3 worldPos)
#endif
{
	DirLight light;

	//light.dir = _MainLightPosition.xyz;

	light.dir = _SunDir;

	light.specular = SampleBakedOcclusionWithDynamic(bakeData, ScreenPos, worldPos, light.diffuse);
	
	//light.color = _MainLightColor.rgb * atten;
#if LIGHTMAP_SHADOW_MIXING
	light.color = 0;
#else
	light.color = _SunColor;
#endif
	return light;
}

#ifdef STATIC_SHADOW
#ifdef MORE_HALF
DirLight CreateStaticShadowLight(half3 ndcPos)
#else
DirLight CreateStaticShadowLight(float3 ndcPos)
#endif
{
	DirLight light;

	light.dir = _SunDir;

	half atten = 1 - CalcShadowByNDC(ndcPos);
	light.color = _SunColor * atten;
    light.diffuse = 1;
    light.specular = 1;
    
	return light;
}
#endif

#endif
