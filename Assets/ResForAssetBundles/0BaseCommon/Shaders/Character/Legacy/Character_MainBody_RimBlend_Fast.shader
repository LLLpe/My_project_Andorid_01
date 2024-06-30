// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Character/Legacy/Character_MainBody_RimBlend_Fast" 
{

	Properties 
	{
	 _MainTex ("Diffue Map", 2D) = "white" {}
	 _SARMap ("Spec(R) Gloss(G) Reflect(B)", 2D) = "white" {}
	 _SAEMap ("SkinMask(R) Alpha(G) Emis(B)", 2D) = "black" {}
	 _ReflectMap ("Reflect Map", 2D) = "black" {}
	 _RampMap ("Ramp Map", 2D) = "black" {}
	 _ReflectPower ("Reflect Power[0,1]", Float) = 1
	}



	HLSLINCLUDE
	 #include "../../AdvCarCommon.cginc"		
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"		
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

	ENDHLSL
	 

	SubShader 
	{
		LOD 150
		Tags 
		{			
			"Queue" = "Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent" 
			"Reflection" = "RenderReflectionTransparentBlend"
		}
	
		
		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
		ENDHLSL
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			Fog {Mode Off}
			Lighting Off
			Tags {"LightMode" = "UniversalForward"}
			HLSLPROGRAM
			#pragma glsl		
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest	
			#pragma multi_compile _ USE_BUILDIN_SH
			#pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA  // ����NssFog

			 
			uniform sampler2D _MainTex;
			uniform sampler2D _SARMap;
			uniform sampler2D _SAEMap;
		 
			uniform sampler2D _ReflectMap;
 
			uniform sampler2D _RampMap;
		 
CBUFFER_START(UnityPerMaterial)
			uniform half _ReflectPower;
CBUFFER_END
			 

			 
			
			struct VertexInput 
			{
				float4 vertex : POSITION;
                half3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
			};
			
			struct VertexOutput 
			{
				float4 pos : SV_POSITION;
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				float2 texcoord :TEXCOORD0;
				half3 lightDir :TEXCOORD1;
				half3 normal: TEXCOORD2;
				half3 normalVS_uv: TEXCOORD3;
			#endif
				half3 vlight: TEXCOORD4;
			 
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				NSS_FOG_COORDS(5)
			#endif
			};
			
			
			
			  VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0; 

				o.pos = TransformObjectToHClip(v.vertex);
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				o.texcoord = v.texcoord.xy;

				o.lightDir = GetNegativeCameraForwardDir();;

				half4 normal = half4(v.normal,0);
				half3 normalVS = mul(UNITY_MATRIX_IT_MV, normal).xyz;
				o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
 
				o.normal = mul(UNITY_MATRIX_M, normal);
 
			#endif
				o.vlight =   NssAvatarShadeSH(half4(mul(UNITY_MATRIX_M,half4(v.normal, 0.0)).xyz, 1.0));
				
				
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				NSS_TRANSFER_FOG_MS(o, v.vertex, _WorldSpaceCameraPos);
			#endif
				return o;
			} 
			
			
		 
			
			half4 frag (VertexOutput i) : COLOR
			{
				#ifdef ENABLE_WHITE_MODE
					return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(i.vlight,1.0));
				#else // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				 
				#ifdef DISABLE_CHARACTER_LIGHTPROBES
					i.vlight = 1.0; 
				#endif
				
			
				half2 uv = i.texcoord;
				i.lightDir  = normalize(i.lightDir);
				half3 lightDir = i.lightDir;
		
				half3 N = normalize(i.normal);

				half3 ViewN =  i.normalVS_uv;
			 
	 
				half4 mainTexColor = tex2D(_MainTex, uv);
				half3 sarMask = tex2D(_SARMap,uv).rgb;
				half3 saeMask = tex2D(_SAEMap,uv).rgb;

				half NdotL = dot(N, lightDir); // -1 ~ 1

				half light_0to1 = NdotL * 0.5 + 0.5; 

				half2 rampUVSkin = half2(light_0to1, 1.0);
				half2 rampUVCloth = half2(light_0to1, 0.0);
				half3 reflectMapColor = tex2D(_ReflectMap, ViewN).rgb;

				half3 rampColor = lerp(tex2D(_RampMap, rampUVCloth), tex2D(_RampMap, rampUVSkin), saeMask.r);
				 

				half3 baseLight =  i.vlight * rampColor ;
				
				
				half3 baseColor = mainTexColor.rgb *  baseLight ;

				#ifdef DISABLE_CHARACTER_REFLECTION
				half3 reflectColor = 0;
				#else
				half3 reflectColor =  sarMask.b * reflectMapColor * _ReflectPower;
				#endif

				half3 finalColor = baseColor.rgb + reflectColor;
				
				return NSS_CALC_FOG(i, NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor,saeMask.g)));
				
				#endif
             }
             
              ENDHLSL
          }
      }
    Fallback "QF/Character/Legacy/Character_MainBody_RimBlend_Simple" 
 }
