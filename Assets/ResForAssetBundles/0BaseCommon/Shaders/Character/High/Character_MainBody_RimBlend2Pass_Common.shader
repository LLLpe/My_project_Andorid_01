// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Character/Character_MainBody_RimBlend2Pass_Common" 
{

	Properties 
	{
		_BaseColor("Base Color", Color) = (1.0,1.0,1.0,1.0)
		_BaseColorIntensity("Intensity", Range(0.0, 2.0)) = 1.0
		_MainTex ("Diffue Map", 2D) = "white" {}
		_SARMap ("Spec(R) Gloss(G) Reflect(B)", 2D) = "white" {}
		_SAEMap ("SkinMask(R) Alpha(G) Emis(B)", 2D) = "black" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_ReflectMap ("Reflect Map", 2D) = "black" {}
		_RampMap ("Ramp Map", 2D) = "black" {}
		_FrsnelMap("Frsnel Map (RGB)", 2D) = "black" {}
		_FxMap("Fx Map",2D) = "black" {}	 
		_ReflectPower ("Reflect Power[0,1]", Float) = 1.0	 
		_FrsnelPower ("Frsnel Power[0,1]", Float) = 1.0	 
		_SpecularColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecularGloss ("Specular Gloss[1,100]", Float) = 100.0
		_SpecularPower ("Specular Power[0,1]", Float) = 1.0
	 
	// _EmissionPower ("Emission Power[0,1]", Float) = 0.0
	 
		_Ambient ("Ambient[0,0.2]", Float) = 0.0
		_Bump ("Bump[0,1]", Float) = 0.3 
		_FxColor("FxColor",Color) = (1.0,1.0,1.0,1.0)
		_FxUSpeed("FxUSpeed",Float) = 1.0
		_FxVSpeed("FxVSpeed",Float) = 1.0

		_BackColorToggle("背面颜色", Float) = 0.0
		_BackColor("Back Color", Color) = (1, 1, 1, 1)
		_BackMainTex("Diffue Map", 2D) = "white" {}

		_EmissionOn("自发光", float) = 0
		[NoScaleOffset]_EmssionMap("自发光贴图", 2D) = "white" { }
		_EmissionNoise("自发光Noise", 2D) = "white" {}
		[HDR]_EmissionColor("EmssionColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_EmissionShiningToggle("自发光闪烁", float) = 0
		_EmissionShiningMin("最低亮度", Range(0, 1)) = 0
		_EmissionShiningFreq("闪动频率", Range(0, 5)) = 1
		_EmissionNoiseIntensity("噪点扰动强度", Range(0, 1)) = 1
		_EmissionNoiseSpeed("噪点扰动速度", Range(0, 20)) = 3
		_EmissionNoiseTile("噪点扰动密度", Range(0, 20)) = 10

		//闪光
		_GlitterToggle("闪光", Float) = 0
		_GlitterMask("Glitter mask", 2D) = "white" {}
		_GlitterMap("Glitter map", 2D) = "white" {}
		[HDR]_GlitterColor("Glitter color", Color) = (1,1,1,1)
		_GlitterPower("Glitter power (0 - 50)", Range(0, 50)) = 2
		_GlitterContrast("Glitter contrast (1 - 3)", Range(1, 3)) = 1.5
		_GlitterySpeed("Glittery speed (0 - 1)", Range(0, 1)) = 0.5
		_GlitteryDotMaskSscale("Glittery & mask dots scale", Range(0.1, 8)) = 2.5
		_GlitterIntensity("Glitter Intensity", Range(0, 1)) = 0.05
		_MaskAdjust("Mask adjust (0.5 - 1.5)", Range(0.5, 1.5)) = 1
		Specularglitter("Specular glitter", 2D) = "white" {}
		Specularpower("Specular power (0 - 5)", Range(0, 5)) = 1.5
		Specularcontrast("Specular contrast (1 - 3)", Range(1, 3)) = 1
		SpecularIntensity("Specular Intensity (0 - 5)", Range(0, 5)) = 1

		//溶解变身
		_AdvDissolve("溶解", Float) = 0
		_DissolveAdd("Add", Float) = 0
		_FinalPower("Final Power", Range(0, 10)) = 2
		_DissolveSphereToggle("相对位置溶解", float) = 0
		_StartPosition("溶解相对位置", Vector) = (0, 1, 0)
		_DissolveAlphaToggle("Enable", Float) = 1
		[NoScaleOffset]_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		_DissolveTiling("Dissolve Tiling", Float) = 1
		_ClipOffset("Clip Offset", Float) = 0
		_MaskThickness("Mask Thickness", Float) = 1
		_MaskDistance("Mask Distance", Float) = 1
		[NoScaleOffset]_MaskTexture("Mask Texture", 2D) = "white" {}
		[HDR]_RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
		_Ramp("Ramp", 2D) = "white" {}
		_NoiseDistortionPower("Noise Distortion Power", Range(0, 10)) = 1
		[NoScaleOffset]_Noise01("Noise 01", 2D) = "white" {}
		_Noise01Tiling("Noise 01 Tiling", Float) = 1
		_Noise01ScrollSpeed("Noise 01 Scroll Speed", Float) = 0.25

		_ClipToggle("裁切", float) = 0

		_FresnelToggle("Enable", Float) = 0
		_InvertFresnel("Enable", Float) = 0
		_FresnelAlphaToggle("Enable", Float) = 1
		_FresnelTightness("Fresnel Tightness", Range(0.0, 10.0)) = 4.0
		_ColorInsideIntensity("ColorInsideIntensity", Range(0.0, 10.0)) = 1
		_ColorOutsideIntensity("ColorInsideIntensity", Range(0.0, 10.0)) = 1
		[HDR] _FresnelColorInside("Color Inside", COLOR) = (1,1,1,1)
		[HDR] _FresnelColorOutside("Color Outside", COLOR) = (1,1,1,1)

		//渲染状态
		[Space(5)]
		_ZWrite("", Float) = 0
		_Cutoff("", float) = 0.5
	}

	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

	ENDHLSL

	SubShader
	{
		LOD 150
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"Reflection" = "RenderReflectionTransparentBlend"
		}

		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
		#include "../../AdvCarCommon.cginc"	
		#include "../../../Common/QF_Special.cginc"

CBUFFER_START(UnityPerMaterial)
		half _BaseColorIntensity;
		half4 _BaseColor;
		half4 _BackColor;
		half4 _FxMap_ST;
		uniform half _ReflectPower;
		uniform half _FrsnelPower;
		uniform half4 _SpecularColor;
		uniform half _SpecularGloss;
		uniform half _SpecularPower;
		uniform half _Ambient;
		uniform half _Bump;
		uniform half3 _FxColor;
		uniform half _FxUSpeed;
		uniform half _FxVSpeed;
		half _DissolveAdd;
		half _DissolveAlphaToggle;
		half _FresnelTightness;
		half _ColorInsideIntensity;
		half _ColorOutsideIntensity;
		half4 _FresnelColorInside;
		half4 _FresnelColorOutside;
		half _Cutoff;

		half4 _EmissionColor;
CBUFFER_END
		uniform sampler2D _MainTex;
		uniform sampler2D _SARMap;
		uniform sampler2D _SAEMap;
		uniform sampler2D _NormalMap;
		uniform sampler2D _ReflectMap;

		uniform sampler2D _RampMap;

		uniform sampler2D _FrsnelMap;
		uniform sampler2D _FxMap;

		uniform sampler2D _EmssionMap;
		//uniform half _EmissionPower;

		uniform sampler2D _GlitterMask;
		uniform sampler2D _BackMainTex;

		#ifdef FRESNEL
		#endif

		struct VertexInput
		{
			float4 vertex : POSITION;
			half3 normal : NORMAL;
			#ifdef FRESNEL
			half4 color : COLOR;
			#endif
			float2 texcoord : TEXCOORD0;
			float2 texcoord2 : TEXCOORD1;
			float2 texcoord3 : TEXCOORD2;
			half4 tangent : TANGENT;
		};

		struct VertexOutput
		{
			float4 pos : SV_POSITION;
			float4 texcoord :TEXCOORD0;
			half3 WS_lightDir :TEXCOORD1;
			half3 WS_viewDir : TEXCOORD2;
			half3 normalVS_uv: TEXCOORD3;

			half3 WS_normal : TEXCOORD4;
			half3 WS_tangent: TEXCOORD5;
			half3 WS_binormal: TEXCOORD6;
			//half4 shadowPos : TEXCOORD7;
			half4 uv1 : TEXCOORD7;
			half3 localPos : TEXCOORD8;
			#ifdef FRESNEL
			half4 color : TEXCOORD9;
			#endif
		};



		VertexOutput vert(VertexInput v)
		{
			VertexOutput o = (VertexOutput)0;

			#ifdef _ADV_DISSOLVE_ON
			o.uv1.xy = v.texcoord3;
			o.localPos = v.vertex;
			#endif

			o.pos = TransformObjectToHClip(v.vertex);
			o.texcoord.xy = v.texcoord;
			o.texcoord.zw = TRANSFORM_TEX(v.texcoord2,_FxMap) + half2(_FxUSpeed,_FxVSpeed) * _Time.y;


			o.WS_lightDir = _MainLightPosition.xyz;
			o.WS_viewDir =(GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz));



			half4 worldPos = UnityMulPos(UNITY_MATRIX_M, v.vertex);
			//o.shadowPos = UnityMulPos(_SGameShadowMatrix, worldPos);




			half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normal).xyz;;
			o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;


			//https://en.wikibooks.org/wiki/Cg_Programming/Unity/Lighting_of_Bumpy_Surfaces
			o.WS_tangent = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
			o.WS_normal = normalize(mul(half4(v.normal, 0.0), UNITY_MATRIX_I_M).xyz);
			o.WS_binormal = normalize(cross(o.WS_normal, o.WS_tangent) * v.tangent.w); // tangent.w is specific to Unity

			#ifdef FRESNEL
			o.color = v.color;
			#endif
			return o;
		}

		half4 frag(VertexOutput i, real facing : VFACE) : COLOR
		{
			half2 uv = i.texcoord.xy;
			half2 uv_fx = i.texcoord.zw;
			i.WS_lightDir = normalize(i.WS_lightDir);
			i.WS_viewDir = normalize(i.WS_viewDir);


			#ifdef DISABLE_CHARACTER_NORMAL
			half3 TS_TexNormal = half3(0.0,0.0,1.0);
			#else
			half3 TS_TexNormal = UnpackNormal(tex2D(_NormalMap,uv));
			#endif


			half3x3 tangent2World = half3x3(i.WS_tangent,i.WS_binormal ,i.WS_normal);

			half3 WS_TexNormal = normalize(mul(TS_TexNormal,tangent2World));
			half3 H = normalize(i.WS_lightDir + i.WS_viewDir);

			half3 ViewN = i.normalVS_uv;
			ViewN.xy += TS_TexNormal.xy * _Bump;

			half4 mainColor = tex2D(_MainTex, uv) * _BaseColor;
#ifdef _BACKCOLOR
			half isFront = step(0, facing);
			mainColor = lerp(tex2D(_BackMainTex, uv) * _BackColor, mainColor, isFront);
#endif
			half4 mainTexColor = mainColor * _BaseColorIntensity;
			half3 sarMask = tex2D(_SARMap,uv).rgb;
			half3 saeMask = tex2D(_SAEMap,uv).rgb;

			half NdotL = dot(WS_TexNormal,i.WS_lightDir); // -1 ~ 1
			half absNdotL = abs(NdotL);
			//half shadow = CalcShadow(i.shadowPos, lerp(0.003, 0.001, absNdotL), lerp(80.0, 1000.0, absNdotL) , 0.5); 

			half light = NdotL;
			half HdotN = saturate(dot(H,WS_TexNormal));
			half light_0to1 = light * 0.5 + 0.5;
			light_0to1 = max(light_0to1,_Ambient);
			half2 rampUV = half2(light_0to1, saeMask.r);
			half3 frsnelMapColor = tex2D(_FrsnelMap,ViewN).rgb;
			half3 reflectMapColor = tex2D(_ReflectMap, ViewN).rgb;

			half3 rampColor = tex2D(_RampMap, rampUV);

			half3 fxColor = tex2D(_FxMap,uv_fx) * _FxColor  * saeMask.b;


			#ifdef DISABLE_CHARACTER_RAMP
				rampColor = light;
			#endif


			half3 baseLight = rampColor * _NssLightColor;


			half3 baseColor = mainTexColor.rgb * baseLight;
			#ifdef DISABLE_CHARACTER_SPECULAR
			half3 specularColor = 0;
			#else
			half3 specularColor = sarMask.r * NssPow(HdotN, sarMask.g * _SpecularGloss) * _SpecularPower * _SpecularColor.rgb;
			#endif

			#ifdef DISABLE_CHARACTER_REFLECTION
			half3 reflectColor = 0;
			#else
			half3 reflectColor = sarMask.b * reflectMapColor * _ReflectPower;
			#endif

			#ifdef DISABLE_CHARACTER_FRESNEL
			half3 frsnelColor = 0;
			#else
			half3 frsnelColor = frsnelMapColor * _FrsnelPower;
			#endif

			#ifndef SHADER_API_MOBILE
			half3 finalColor = baseColor.rgb + specularColor + reflectColor + frsnelColor + fxColor;
			#else
				#if defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)
					half3 finalColor = baseColor.rgb + specularColor + reflectColor + frsnelColor + fxColor;
				#else
					half3 finalColor = baseColor.rgb + specularColor + reflectColor;
				#endif
			#endif

			#ifdef _MASKGLITTER
			half3 glitterMask = tex2D(_GlitterMask, uv).rgb;
			finalColor += glitterMask.r * GetGlitter(uv.xy, mul(tangent2World, i.WS_viewDir).xyz);
			#endif

			half alpha = saeMask.g * _BaseColor.a;

			#ifdef _EMISSION
				//half3 emissionColor = lerp(_EmssionColor.xyz, _EmssionColor2.xyz, abs(sin(fmod(_Time.y, 3600.0f) * _EmissionLoopSpeed)) * _EmissionLoop);
				half3 emissionColor = _EmissionColor.xyz;
				#ifdef _EMISSION_SHINE
					emissionColor *= GetEmissionShining(uv.xy);
				#endif
					finalColor.rgb += tex2D(_EmssionMap, uv.xy).xyz * emissionColor;
			#endif

			half disScale = 1.0;
			#ifdef _ADV_DISSOLVE_ON
			disScale = 0.0;
			#ifdef _DISSOLVE_SPHERE_ON
			half4 haloColor = GetHaloColor3(i.uv1.xy, i.localPos.xyz, disScale);
			#else
			half4 haloColor = GetHaloColor(i.uv1.xy, disScale);
			#endif
			finalColor.rgb = lerp(lerp(finalColor.rgb, haloColor.rgb, haloColor.a * _FinalPower), finalColor.rgb + haloColor.a * _FinalPower * haloColor.rgb, _DissolveAdd);
			half disAlpha = saturate(1.0 - disScale);
			#ifdef _CLIP_ON
			clip(disAlpha - _Cutoff);
			#endif
			alpha *= lerp(1.0, disAlpha, _DissolveAlphaToggle);
			#endif

			#ifdef FRESNEL
			half4 insideColor = _FresnelColorInside * _ColorInsideIntensity;
			half4 outsideColor = _FresnelColorOutside * _ColorOutsideIntensity;
			half phong = 1.0 - saturate(abs(dot(normalize(WS_TexNormal), normalize(i.WS_viewDir))));
			#ifdef INVERT_FRESNEL
			phong = 1.0 - phong;
			insideColor = _FresnelColorOutside * _ColorOutsideIntensity;
			outsideColor = _FresnelColorInside * _ColorInsideIntensity;
			#endif
			half fresnel = saturate(pow(phong, _FresnelTightness));
			half4 fresnelColor = lerp(half4(insideColor.rgb * insideColor.a, insideColor.a), half4(outsideColor.rgb * outsideColor.a, outsideColor.a), fresnel) * fresnel;
			finalColor.rgb += fresnelColor.rgb * disScale;
			#ifdef FRESNEL_ALPHA
			alpha *= fresnelColor.a * fresnel * i.color.a;
			#endif
			#endif

			return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor, alpha));
		}
		ENDHLSL

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite[_ZWrite]
			Cull Front
			Fog {Mode Off}
			Lighting Off
			Tags {"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma glsl			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature_local __ _ADV_DISSOLVE_ON
			#pragma shader_feature_local __ _DISSOLVE_SPHERE_ON
			#pragma shader_feature_local __ _CLIP_ON
			#pragma shader_feature_local __ _MASKGLITTER
			#pragma shader_feature_local __ FRESNEL
			#pragma shader_feature_local __ FRESNEL_ALPHA
			#pragma shader_feature_local __ INVERT_FRESNEL
			#pragma shader_feature_local __ _BACKCOLOR
			#pragma shader_feature_local __ _EMISSION
			#pragma shader_feature_local __ _EMISSION_SHINE
			//#pragma multi_compile_fwdbase 
			#pragma fragmentoption ARB_precision_hint_fastest		 
			ENDHLSL
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			Fog{ Mode Off }
			Lighting Off
			Tags{ "LightMode" = "SRPDefaultUnlit" }

			HLSLPROGRAM
			#pragma glsl			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature_local __ _ADV_DISSOLVE_ON
			#pragma shader_feature_local __ _DISSOLVE_SPHERE_ON
			#pragma shader_feature_local __ _CLIP_ON
			#pragma shader_feature_local __ _MASKGLITTER
			#pragma shader_feature_local __ FRESNEL
			#pragma shader_feature_local __ FRESNEL_ALPHA
			#pragma shader_feature_local __ INVERT_FRESNEL
			#pragma shader_feature_local __ _BACKCOLOR
			#pragma shader_feature_local __ _EMISSION
			#pragma shader_feature_local __ _EMISSION_SHINE
			//#pragma multi_compile_fwdbase 
			#pragma fragmentoption ARB_precision_hint_fastest	
			ENDHLSL
		}
	}
    Fallback "QF/Character/Legacy/Character_MainBody_RimBlend_Fast" 
	CustomEditor "QF_MainBody2PassShaderGUI"
 }
