// Upgrade NOTE: unity_Scale shader variable was removed; replaced 'unity_Scale.w' with '1.0'
// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'

#ifndef ADVCAR_INCLUDED
#define ADVCAR_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
 

#include "../Include/NssLighting.cginc"

#define PARABOLOID_OFFSET 2.0
 

half _InLeisure;
//鱼眼反射图
sampler2D _MirrorReflectionTex;

//路的灯光方向
half3 _RoadSpecularLightLocalDir;


half4x4 _LightMatrix; // transform from world space to light camera's projection space
half4x4 _LightCamMat;

//阴影图
sampler2D _FastShadowMap;


half2 _FastShadowUVScale;
half2 _FastShadowUVOffset;

half3 _NssLightColor = half3(1.0, 1.0, 1.0);;
//伪light probes
half3 _SHLightDir;
half3 _SHForwardColor;
half3 _SHBackwardColor;

half _AvatarLightProbesRatio;

//light brobes
half3 NssShadeSH(float4 WS_normal)
{
	#ifdef USE_BUILDIN_SH
		half3 shColor = SampleSH(WS_normal.xyz).rgb;
	#else
		WS_normal.rgb = normalize(WS_normal.rgb);
	 
		half factor = saturate(dot(WS_normal.rgb, _SHLightDir));
 
		half3 shColor = lerp(_SHBackwardColor, _SHForwardColor, factor);
	#endif
	return shColor;
}

//fake light probes
half3 NssAvatarShadeSH(float4 WS_normal)
{
	return NssShadeSH(WS_normal) * _AvatarLightProbesRatio;
}

//Get negative camera dir
half3 GetNegativeCameraForwardDir()
{
	return half3(UNITY_MATRIX_V[2].xyz);
}

//保护参数
half NssPow(half base,half power)
{
	return pow(max(0.001,base), power + 0.01);
}

inline float3 NssSafeNormalize(float3 inVec)
{
	float dp3 = max(0.001f, dot(inVec, inVec));
	return inVec * rsqrt(dp3);
}


//鱼眼反射, google Paraboloid reflection
half4 ParaboloidTransform( in half4 paraboloidPos)
{
#ifndef SHADER_API_GLES
	paraboloidPos.x = -paraboloidPos.x;
#endif
	paraboloidPos.z = -paraboloidPos.z;
	
	
	half len = length( paraboloidPos.xyz );
	paraboloidPos = paraboloidPos / len;

	paraboloidPos.z = paraboloidPos.z + 1.0;
	//multi 0.90 to reserve uv space
	paraboloidPos.xy = paraboloidPos.xy / paraboloidPos.z;

	//Finally we set the z value as the distance from the vertex to the origin of the paraboloid, scaled and biased by the near and far planes of the paraboloid 'camera'.
	//paraboloidPos.z = len/10000.0;
	paraboloidPos.z = len/50000.0;
	
	paraboloidPos.w = 1.0; 
	return paraboloidPos;
}
//鱼眼反射, google Paraboloid reflection
half2 GetParaboloidReflectionUV(half3 reflectionVector)
{

	
	reflectionVector.y = abs(reflectionVector.y);

 #ifndef SHADER_API_GLES
	half3 coord = half3(-reflectionVector.x, reflectionVector.z, reflectionVector.y);
#else
	half3 coord = half3(reflectionVector.x, -reflectionVector.z, reflectionVector.y);
#endif
	half z = coord.z;
	
	z += 1.0;
	
	coord.xy /= z;
	coord.xy = coord.xy * 0.5 + 0.5;
	
	return coord.xy;
}



half3 FetchReflectionColor(sampler2D reflectionMap, half2 coord)
{
	half3 color = tex2D(reflectionMap, coord).rgb; 
	 
	 
	return max(half3(0.0,0.0,0.0),color);
}


half3 FetchReflectionColor(sampler2D reflectionMap, half2 coord, half2 distort)
{

	half2 refuv = coord + distort;
	half3 color = tex2D(reflectionMap, refuv).rgb; 
	 
 
	return max(half3(0.0,0.0,0.0),color);
}

bool ParaboloidDiscard(half4 paraboloidHemisphere)
{
    //keep uv in circle 1 radius
	return paraboloidHemisphere.z  > 0.0;	
	 
	
}

half3 WorldSpaceLightDir( in half3 worldPos )
{
#ifndef USING_LIGHT_MULTI_COMPILE
	return _MainLightPosition.xyz - worldPos * _MainLightPosition.w;
#else
	#ifndef USING_DIRECTIONAL_LIGHT
	return _MainLightPosition.xyz - worldPos;
	#else
	return _MainLightPosition.xyz;
	#endif
#endif
}
 

half3 GetOutputDir(half3 inVec)
{
	half3 outVec = (inVec + 1.0) * 0.5;
	return outVec;
}

 
//海底雾效
half _FogHorizontalNearDistance;
half _FogHorizontalFarDistance;

half _FogSeaLevel;
half _FogSeaHorizontalNearDistance;
half _FogSeaHorizontalFarDistance;

half _FogMulpiler;


sampler2D _FogTexture;

//#pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA
#include "./NssFog.cginc"

//计算到摄像机的距离
float3 CalcCamDist(half4 vertex)
{
// #if defined(NSS_FOG_NORMAL) || defined(NSS_FOG_SEA)
//     return half3(0, 0, 0);
// #else
	float4 worldPos = UnityMulPos(UNITY_MATRIX_M,vertex);
	float3 viewPos = TransformWorldToView(vertex);
	float camHorizontalDist =  -viewPos.z;
	
	float wholeDistance = _FogHorizontalFarDistance - _FogHorizontalNearDistance;
	float factorHorizontal = _FogMulpiler * (camHorizontalDist - _FogHorizontalNearDistance) / wholeDistance;
	
	float wholeSeaDistance = _FogSeaHorizontalFarDistance - _FogSeaHorizontalNearDistance;
	float factorSeaHorizontal = _FogMulpiler * (camHorizontalDist - _FogSeaHorizontalNearDistance) / wholeSeaDistance;

	return float3(factorSeaHorizontal, factorHorizontal, worldPos.y);
//#endif
}

//雾效		
half4 NssFog(float3 factor,half4 finalColor)
{	 
#if defined(NSS_FOG_NORMAL) || defined(NSS_FOG_SEA)
    return finalColor;
#else
	float isLand = step(_FogSeaLevel , factor.z);
	float factorHorizontal = lerp(factor.x, factor.y, isLand);
	
	half4 fogColor = tex2D(_FogTexture, float2(factorHorizontal, isLand));
	
	finalColor.rgb = lerp(finalColor.rgb ,fogColor.rgb, fogColor.a);  
	
	return finalColor;
    // return half4(0, 0, 0, 0);
#endif
}


void WriteTangentSpaceData (appdata_full v, out half3 ts0, out half3 ts1, out half3 ts2) {
	TANGENT_SPACE_ROTATION;
	ts0 = mul(rotation, UNITY_MATRIX_M[0].xyz * 1.0);
	ts1 = mul(rotation, UNITY_MATRIX_M[1].xyz * 1.0);
	ts2 = mul(rotation, UNITY_MATRIX_M[2].xyz * 1.0);				
}

half2 EthansFakeReflection (half4 vtx) {
	half3 worldSpace = UnityMulPos(UNITY_MATRIX_M, vtx).xyz;
	worldSpace = (-_WorldSpaceCameraPos * 0.6 + worldSpace) * 0.07;
	return worldSpace.xz;
}


sampler2D _ReflectionTex;





uniform float4x4 _SGameShadowMatrix;
TEXTURE2D_FLOAT (_SGameShadowTexture);SAMPLER (sampler_SGameShadowTexture);
TEXTURE2D_SHADOW(_SGameShadowDepthTexture);SAMPLER_CMP(sampler_SGameShadowDepthTexture);
float _IsUseDepthRT;



half CalcShadow_DepthRT(half4 shadowPos, half bias, half fade, half _ShadowSoft)
{
	half3 coord = shadowPos.xyz / shadowPos.w;
#ifdef SHADER_API_GLES3
	coord = coord * 0.5 + 0.5;
#else
	coord.xy = coord.xy * 0.5 + 0.5;
#endif
	UNITY_BRANCH
		if (coord.x < 0 || coord.x >1 || coord.y > 1 || coord.y < 0)
			return 1.0;

	coord.z = saturate(coord.z);
#if UNITY_REVERSED_Z
	coord.z = coord.z + bias;// z forward towards camera
#else
	coord.z = coord.z + lerp(-bias, bias, _UseGlesReservedZ);
#endif
	half shadow = SAMPLE_TEXTURE2D_SHADOW(_SGameShadowDepthTexture , sampler_SGameShadowDepthTexture ,  coord);

	return  1 - fade + shadow * fade;
}

//阴影计算
half getShadowDepth(half2 uv)
{
	half4 c = SAMPLE_TEXTURE2D(_SGameShadowTexture,sampler_SGameShadowTexture, uv);
	return DecodeFloatRGBA(c);
}

half sampleShadow(half3 coord, half fade)
{
	half shadowDepth = getShadowDepth(coord.xy);
	half shadowValue = 2 - exp((coord.z - shadowDepth) * fade);
	return clamp(shadowValue, -1.0, 1);
}


half CalcShadow(half4 shadowPos, half bias, half fade, half _ShadowSoft)
{
	//UNITY_BRANCH
    //if (_IsUseDepthRT > 0.01)
    //{
    //	return CalcShadow_DepthRT(shadowPos, bias, fade, _ShadowSoft);
    //}


	half3 coord = shadowPos.xyz / shadowPos.w;
#if !defined(SHADER_API_D3D9) && !defined(SHADER_API_D3D11) && !defined(SHADER_API_D3D11_9X)
	coord = coord * 0.5 + 0.5;
#else
	coord.xy = coord.xy * 0.5 + 0.5;
#endif
	UNITY_BRANCH
		if (coord.x < 0 || coord.x >1 || coord.y > 1 || coord.y < 0)
			return 1.0;

	coord.z = saturate(coord.z);

#if UNITY_REVERSED_Z
	coord.z = 1.0 - coord.z;
#else
	coord.z = lerp(coord.z, 1.0 - coord.z, _UseGlesReservedZ);
#endif

	coord.z = coord.z - bias;


	half texelSize = _ShadowSoft * 0.0009765625;

	half shadow = sampleShadow(coord, fade);

	half3 coordAdd = coord;
	coordAdd.xy += half2(texelSize, texelSize);
	shadow += sampleShadow(coordAdd, fade);


	return shadow * 0.5;
}


half GetShadow(half2 uv, float currentZ)
{
	float shadowZ = getShadowDepth(uv);
	half shadow = shadowZ < currentZ ? 0.5 : 1;
	return shadow;
}

half CalcSoftShadow(half4 shadowPos, half bias, half fade, half _ShadowSoft)
{
	//UNITY_BRANCH
	//if (_IsUseDepthRT > 0.01)
	//{
	//	return CalcShadow_DepthRT(shadowPos, bias, fade, _ShadowSoft);
	//}

	half3 coord = shadowPos.xyz / shadowPos.w;
#if !defined(SHADER_API_D3D9) && !defined(SHADER_API_D3D11) && !defined(SHADER_API_D3D11_9X)
	coord = coord * 0.5 + 0.5;
#else
	coord.xy = coord.xy * 0.5 + 0.5;
#endif

	coord.z = saturate(coord.z);

#if UNITY_REVERSED_Z
	coord.z = 1.0 - coord.z;
#else
	coord.z = lerp(coord.z, 1.0 - coord.z, _UseGlesReservedZ);
#endif

	coord.z = coord.z - bias;

	half shadow = 0;
	half texelSize = _ShadowSoft / 512.0;

#ifdef LOD1
	shadow = GetShadow(coord.xy, coord.z);
	return shadow;
#else
#if 0
	//jitter
	offset = fmod(offset * 512, 2);
	shadow += GetShadow(coord.xy + (half2(-1.5, -1.5) + offset) * texelSize, coord.z);
	shadow += GetShadow(coord.xy + (half2(-0.5, 0.5) + offset) * texelSize, coord.z);
	shadow += GetShadow(coord.xy + (half2(-1.5, 0.5) + offset) * texelSize, coord.z);
	shadow += GetShadow(coord.xy + (half2(-0.5, 1.5) + offset) * texelSize, coord.z);
#else
#if 1
#if 0
	//2x2 box filter
	shadow += GetShadow(coord.xy + half2(-texelSize, texelSize), coord.z);
	shadow += GetShadow(coord.xy + half2(texelSize, texelSize), coord.z);
	shadow += GetShadow(coord.xy + half2(-texelSize, -texelSize), coord.z);
	shadow += GetShadow(coord.xy + half2(texelSize, -texelSize), coord.z);
#else
	//poisson sampling
	float2 poissonDisk[4] = {
	float2(-0.94201624, -0.39906216),
	float2(0.94558609, -0.76890725),
	float2(-0.094184101, -0.92938870),
	float2(0.34495938, 0.29387760)
	};
	for (int i = 0; i < 4; i++)
	{
		shadow += GetShadow(coord.xy + poissonDisk[i] * texelSize, coord.z);
	}
#endif
#else
	//3x3 kernel 
	for (int i = -1; i <= 1; i++)
	{
		for (int j = -1; j <= 1; j++)
		{
			shadow += GetShadow(coord.xy + half2(i * texelSize, j * texelSize), coord.z);
		}
	}
#endif		
#endif					
#endif

	return shadow * 0.25;
}

half CalcShadow2(half4 shadowPos, half NdotL)
{
	//旧版材质阴影是-1, 取ramp图最左, PBR版改成0, 取ramp图中间
	half absNdotL = abs(NdotL);
	return max(CalcShadow(shadowPos, lerp(0.003, 0.001, absNdotL), lerp(80.0, 1000.0, absNdotL) , 0.5), 0.0); 
}

			
half Remap(float value, float low1, float high1, float low2, float high2)
{
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}



//魔法套装溶解
half4 Dissolve(half4 srcColor, 
			half3 _Brightness, 
			half _BrightnessLerp,
			float2 uv,
			half _Dissolve,
			sampler2D _DissolveMap,
			//Edge
			half _DissolveEdgeWidth,
			//Color
			half3 _DissolveEdgeColor,
			half _DissolveEdgeColorIntensity,
			half3 _DissolveFresnelColorOut,
			half3 _DissolveFresnelColorIn,
			half3 WS_TexNormal,
			half3 WS_viewDir,
			half _DissolveFresnelPow,
			half3 _DissolveFresnelColorEdge, 
			half _DissolveFresnelEdgePow
			)
{
#ifdef DISSOLVE_ON
	half alpha = tex2D(_DissolveMap, uv).r;
	alpha -= _Dissolve;

	#ifdef DISSOLVE_BRIGHTNESS
		if(alpha < 0.0)
		{
			return half4(lerp(srcColor.rgb, _Brightness, _BrightnessLerp), srcColor.a);
		} 
	#else
		clip(alpha);
	#endif
	
	float NdotV = NssPow(saturate(dot(WS_TexNormal, WS_viewDir)), _DissolveFresnelPow);
	srcColor.rgb *= lerp(_DissolveFresnelColorOut * 2.0,_DissolveFresnelColorIn, NdotV);
	srcColor.rgb += _DissolveFresnelColorEdge * NssPow(1.0 - NdotV, _DissolveFresnelEdgePow);
	alpha *= 5.0;
	half edgeGradient = saturate(alpha) * (1.0 / _DissolveEdgeWidth);
		
	half invertGradient = saturate(1 - edgeGradient);
	invertGradient *= invertGradient;


	half3 finalColor = lerp(srcColor.rgb, _DissolveEdgeColor * _DissolveEdgeColorIntensity, invertGradient);

	return half4(finalColor, srcColor.a);
#else
	return srcColor;
#endif
}

#ifdef CAR_FLATTEN			
		float4 _Scale;
		float4 _ScaleRootPosDelta;
		float3 _FlattenTintColor;
		float4x4 _World2CarModel;
		float4x4 _CarModel2World;	

		float4 NSSVertScaledPos(float4 vertex)
		{
			float4 worldPos = UnityMulPos(UNITY_MATRIX_M, vertex);
			float4 carModel = UnityMulPos(_World2CarModel, worldPos);
			carModel.xyz +=
				float3((_Scale.x - 1) * (carModel.x - _ScaleRootPosDelta.x),
				(_Scale.y - 1) * (carModel.y - _ScaleRootPosDelta.y),
					(_Scale.z - 1) * (carModel.z - _ScaleRootPosDelta.z));
			worldPos = UnityMulPos(_CarModel2World, carModel);
			return UnityMulPos(UNITY_MATRIX_VP, worldPos);
		}

		
    #define NSS_CAR_CLIP_POS NSSVertScaledPos
#else

    #define NSS_CAR_CLIP_POS TransformObjectToHClip
#endif    

#endif
