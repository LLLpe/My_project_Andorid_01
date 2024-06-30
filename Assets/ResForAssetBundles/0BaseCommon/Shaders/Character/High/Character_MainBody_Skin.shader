// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Character/High/Character_MainBody_Skin" 
{
	Properties 
	{
		_BaseColor("Base Color", Color) = (1.0,1.0,1.0,1.0)
		_BaseColorIntensity("Intensity", Range(0.0, 2.0)) = 1.0
		_MainTex ("Diffue Map", 2D) = "white" {}

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
		_SrcBlend("", Float) = 1
		_DstBlend("", Float) = 0
		_ZWrite("", Float) = 1
		_CullMode("", Float) = 0
		_BlendMode("", float) = 0
		_Cutoff("", float) = 0.5
		_ZTest("ZTest", Float) = 4
	}

	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

	ENDHLSL


	SubShader
	{
		LOD 100
		Tags { "Queue" = "Geometry+100"  "RenderType" = "Opaque" "Reflection" = "RenderReflectionOpaque"}

		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
		ENDHLSL

		Blend[_SrcBlend][_DstBlend]
		ZWrite[_ZWrite]
		ZTest[_ZTest]
		Cull[_CullMode]

		Pass
		{
			Fog {Mode Off}
			Lighting Off
			Tags {"LightMode" = "UniversalForward"}
			HLSLPROGRAM
			#include "../../AdvCarCommon.cginc"	
			#include "../../../Common/QF_Special.cginc"
			#pragma glsl			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature_local __ _ADV_DISSOLVE_ON
			#pragma shader_feature_local __ _DISSOLVE_SPHERE_ON
			#pragma shader_feature_local __ _CLIP_ON
			#pragma shader_feature_local __ _CUTOUT
			#pragma shader_feature_local __ FRESNEL
			#pragma shader_feature_local __ FRESNEL_ALPHA
			#pragma shader_feature_local __ INVERT_FRESNEL

			//#pragma multi_compile_fwdbase 
			#pragma fragmentoption ARB_precision_hint_fastest


CBUFFER_START(UnityPerMaterial)
			half4 _BaseColor;
			half _BaseColorIntensity;
			half _DissolveAdd;
			half _DissolveAlphaToggle;
			half _FresnelTightness;
			half _ColorInsideIntensity;
			half _ColorOutsideIntensity;
			half4 _FresnelColorInside;
			half4 _FresnelColorOutside;
			half _Cutoff;
CBUFFER_END	
			uniform sampler2D _MainTex;

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
				
				half4 shadowPos : TEXCOORD7;
				half4 uv1 : TEXCOORD8;
				half3 localPos : TEXCOORD9;
				#ifdef FRESNEL
				half4 color : TEXCOORD10;
				#endif
			};
			
			
			VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0; 

				#ifdef _ADV_DISSOLVE_ON
				o.uv1.xy = v.texcoord3;
				o.localPos = v.vertex;
				#endif

				v.normal = normalize(v.normal);
				
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = v.texcoord;

				o.WS_viewDir =(GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz)); 
				//https://en.wikibooks.org/wiki/Cg_Programming/Unity/Lighting_of_Bumpy_Surfaces
				o.WS_tangent = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
				o.WS_normal = normalize(mul(half4(v.normal, 0.0), UNITY_MATRIX_I_M).xyz);
				o.WS_binormal = normalize(cross(o.WS_normal, o.WS_tangent) * v.tangent.w); // tangent.w is specific to Unity
 
				#ifdef FRESNEL
				o.color = v.color;
				#endif
				return o;
			} 
			

			half4 frag (VertexOutput i) : COLOR
			{
				half2 uv = i.texcoord.xy;
				
			
				#ifdef _CUTOUT
					clip(_BaseColor.a - _Cutoff);
				#endif

				half4 mainTexColor = tex2D(_MainTex, uv) * _BaseColor;
				mainTexColor.rgb *= _BaseColorIntensity;


				half4 result = mainTexColor;

				half disScale = 1.0;
				#ifdef _ADV_DISSOLVE_ON
				disScale = 0.0;
				#ifdef _DISSOLVE_SPHERE_ON
				half4 haloColor = GetHaloColor3(i.uv1.xy, i.localPos.xyz, disScale);
				#else
				half4 haloColor = GetHaloColor(i.uv1.xy, disScale);
				#endif
				result.rgb = lerp(lerp(result.rgb, haloColor.rgb, haloColor.a * _FinalPower), result.rgb + haloColor.a * _FinalPower * haloColor.rgb, _DissolveAdd);

				half disAlpha = saturate(1.0 - disScale);
				#ifdef _CLIP_ON
				clip(disAlpha - _Cutoff);
				#endif
				result.a *= lerp(1.0, disAlpha, _DissolveAlphaToggle);
				#endif

				#ifdef FRESNEL
				half4 insideColor = _FresnelColorInside * _ColorInsideIntensity;
				half4 outsideColor = _FresnelColorOutside * _ColorOutsideIntensity;
				half phong = 1.0 - saturate(abs(dot(normalize(i.WS_binormal.xyz), normalize(i.WS_viewDir))));
				#ifdef INVERT_FRESNEL
				phong = 1.0 - phong;
				insideColor = _FresnelColorOutside * _ColorOutsideIntensity;
				outsideColor = _FresnelColorInside * _ColorInsideIntensity;
				#endif
				half fresnel = saturate(pow(phong, _FresnelTightness));
				half4 fresnelColor = lerp(half4(insideColor.rgb * insideColor.a, insideColor.a), half4(outsideColor.rgb * outsideColor.a, outsideColor.a), fresnel) * fresnel;
				result.rgb += fresnelColor.rgb * disScale;
				#ifdef FRESNEL_ALPHA
				result.a *= fresnelColor.a * fresnel * i.color.a;
				#endif
				#endif

				return NSS_OUTPUT_COLOR_SPACE_CHARACTER(result);	
			}
             
			ENDHLSL
		}
	}
	Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	
	CustomEditor "QF_MainBodyShaderGUI"
 }
