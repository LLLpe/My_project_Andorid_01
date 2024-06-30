// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Character/Character_MainBody_RimBlend2Pass" 
{

	Properties 
	{
	[Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 0
	 
	_FrontColor("Front Color", Color) = (1, 1, 1, 1)
	_BackColor("Back Color", Color) = (1, 1, 1, 1)
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
			"IgnoreProjector"="True"
			"RenderType"="Transparent" 
			"Reflection" = "RenderReflectionTransparentBlend"
		}
	
		
		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
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
			#include "../../AdvCarCommon.cginc"	
			#pragma glsl			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdbase 
			#pragma fragmentoption ARB_precision_hint_fastest	
		 
			////#pragma multi_compile _ DISABLE_CHARACTER_RAMP
			////#pragma multi_compile _ DISABLE_CHARACTER_REFLECTION
			////#pragma multi_compile _ DISABLE_CHARACTER_FRESNEL
			////#pragma multi_compile _ DISABLE_CHARACTER_SPECULAR
			////#pragma multi_compile _ DISABLE_CHARACTER_EMISSION
			////#pragma multi_compile _ DISABLE_CHARACTER_NORMAL
		 
			 
			uniform sampler2D _MainTex;
			uniform sampler2D _SARMap;
			uniform sampler2D _SAEMap;
			uniform sampler2D _NormalMap;
			uniform sampler2D _ReflectMap;
 
			uniform sampler2D _RampMap;
 
			uniform sampler2D _FrsnelMap;
			uniform sampler2D _FxMap;
			CBUFFER_START(UnityPerMaterial)
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
			uniform half4 _FrontColor;
			uniform half4 _BackColor;
			CBUFFER_END
	 
			//uniform half _EmissionPower;
 
			 
		 
	 
 
			
			 
 
			
			
			struct VertexInput 
			{
				float4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
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
				 

			};
			
			
			
			  VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0; 
				
				
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = v.texcoord;
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord2,_FxMap) + half2(_FxUSpeed,_FxVSpeed) * _Time.y;
				
				
				o.WS_lightDir = _MainLightPosition.xyz;
				o.WS_viewDir =(GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz)); 
			
 
		 
				half4 worldPos = UnityMulPos(UNITY_MATRIX_M,v.vertex);
				//o.shadowPos = UnityMulPos(_SGameShadowMatrix, worldPos);
				 
			
				
 
				half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normal).xyz;;
				o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
 
				
					//https://en.wikibooks.org/wiki/Cg_Programming/Unity/Lighting_of_Bumpy_Surfaces
				o.WS_tangent = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
				o.WS_normal = normalize(mul(half4(v.normal, 0.0), UNITY_MATRIX_I_M).xyz);
				o.WS_binormal = normalize(cross(o.WS_normal, o.WS_tangent) * v.tangent.w); // tangent.w is specific to Unity
 
				return o;
			} 
			
			
	 
			
			
			half4 frag (VertexOutput i, real facing : VFACE) : COLOR
			{
				half4 mainColor = lerp(_BackColor, _FrontColor, step(0, facing));

				half2 uv = i.texcoord.xy;
				half2 uv_fx = i.texcoord.zw;
				i.WS_lightDir  = normalize(i.WS_lightDir);
				i.WS_viewDir = normalize(i.WS_viewDir);
				
			 
				#ifdef DISABLE_CHARACTER_NORMAL
				half3 TS_TexNormal = half3(0.0,0.0,1.0);
				#else
				half3 TS_TexNormal = UnpackNormal(tex2D(_NormalMap,uv));
				#endif
				
	 
				half3x3 tangent2World = half3x3(i.WS_tangent,i.WS_binormal ,i.WS_normal);
		 
				half3 WS_TexNormal = normalize(mul(TS_TexNormal,tangent2World));
		 	     
				
				
				half3 H = normalize (i.WS_lightDir +  i.WS_viewDir);	
	 
				half3 ViewN =  i.normalVS_uv;
				ViewN.xy += TS_TexNormal.xy * _Bump;
	 
				half4 mainTexColor = tex2D(_MainTex, uv) * mainColor;
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
		 
				//return half4(reflectMapColor,1);
			 
				half3 rampColor =  tex2D(_RampMap, rampUV);
				
				half3 fxColor = tex2D(_FxMap,uv_fx) * _FxColor  * saeMask.b;
			 
				
				#ifdef DISABLE_CHARACTER_RAMP
				rampColor = light;
				
				#endif
	 
				//#ifdef DISABLE_CHARACTER_EMISSION
				//half emision = 0;
				//#else
			//	half emision = saeMask.b * _EmissionPower;
			//	#endif
				 
				
	 
				half3 baseLight = rampColor  * _NssLightColor;
			   
				
				half3 baseColor = mainTexColor.rgb * baseLight ;
				#ifdef DISABLE_CHARACTER_SPECULAR
				half3 specularColor = 0;
				#else
				half3 specularColor = sarMask.r * NssPow(HdotN, sarMask.g * _SpecularGloss) * _SpecularPower * _SpecularColor.rgb;
				#endif
 
				#ifdef DISABLE_CHARACTER_REFLECTION
				half3 reflectColor = 0;
				#else
				half3 reflectColor =  sarMask.b * reflectMapColor * _ReflectPower;
				#endif
			 
				#ifdef DISABLE_CHARACTER_FRESNEL
				half3 frsnelColor = 0;
				#else
				half3 frsnelColor = frsnelMapColor * _FrsnelPower;
				#endif
		 
				
				
				 
				 
				#ifndef SHADER_API_MOBILE
				half3 finalColor = baseColor.rgb + specularColor  + reflectColor + frsnelColor + fxColor;
				#else
					#if defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)
						half3 finalColor = baseColor.rgb + specularColor  + reflectColor + frsnelColor + fxColor;
					#else
						half3 finalColor = baseColor.rgb + specularColor  + reflectColor;
					#endif
				#endif
				
				 
				
				return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor,saeMask.g));
             }
             
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
#include "../../AdvCarCommon.cginc"	
#pragma glsl			
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
			  //#pragma multi_compile_fwdbase 
#pragma fragmentoption ARB_precision_hint_fastest	

			  ////#pragma multi_compile _ DISABLE_CHARACTER_RAMP
			  ////#pragma multi_compile _ DISABLE_CHARACTER_REFLECTION
			  ////#pragma multi_compile _ DISABLE_CHARACTER_FRESNEL
			  ////#pragma multi_compile _ DISABLE_CHARACTER_SPECULAR
			  ////#pragma multi_compile _ DISABLE_CHARACTER_EMISSION
			  ////#pragma multi_compile _ DISABLE_CHARACTER_NORMAL


			  uniform sampler2D _MainTex;
		  uniform sampler2D _SARMap;
		  uniform sampler2D _SAEMap;
		  uniform sampler2D _NormalMap;
		  uniform sampler2D _ReflectMap;

		  uniform sampler2D _RampMap;

		  uniform sampler2D _FrsnelMap;
		  uniform sampler2D _FxMap;
CBUFFER_START(UnityPerMaterial)
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
CBUFFER_END


		  //uniform half _EmissionPower;










		  struct VertexInput
		  {
			  float4 vertex : POSITION;
			  half3 normal : NORMAL;
			  float2 texcoord : TEXCOORD0;
			  float2 texcoord2 : TEXCOORD1;
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


		  };



		  VertexOutput vert(VertexInput v)
		  {
			  VertexOutput o = (VertexOutput)0;


			  o.pos = TransformObjectToHClip(v.vertex);
			  o.texcoord.xy = v.texcoord;
			  o.texcoord.zw = TRANSFORM_TEX(v.texcoord2,_FxMap) + half2(_FxUSpeed,_FxVSpeed) * _Time.y;


			  o.WS_lightDir = GetNegativeCameraForwardDir();;
			  o.WS_viewDir =(GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz));



			  half4 worldPos = UnityMulPos(UNITY_MATRIX_M, v.vertex);
			  //o.shadowPos = UnityMulPos(_SGameShadowMatrix, worldPos);




			  half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normal).xyz;;
			  o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;


			  //https://en.wikibooks.org/wiki/Cg_Programming/Unity/Lighting_of_Bumpy_Surfaces
			  o.WS_tangent = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
			  o.WS_normal = normalize(mul(half4(v.normal, 0.0), UNITY_MATRIX_I_M).xyz);
			  o.WS_binormal = normalize(cross(o.WS_normal, o.WS_tangent) * v.tangent.w); // tangent.w is specific to Unity

			  return o;
		  }





		  half4 frag(VertexOutput i) : COLOR
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

			  half4 mainTexColor = tex2D(_MainTex, uv);
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

			  //return half4(reflectMapColor,1);

			  half3 rampColor = tex2D(_RampMap, rampUV);

			  half3 fxColor = tex2D(_FxMap,uv_fx) * _FxColor  * saeMask.b;


#ifdef DISABLE_CHARACTER_RAMP
			  rampColor = light;

#endif

			  //#ifdef DISABLE_CHARACTER_EMISSION
			  //half emision = 0;
			  //#else
			  //	half emision = saeMask.b * _EmissionPower;
			  //	#endif



			  half3 baseLight = rampColor  * _NssLightColor;


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



			  return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor,saeMask.g));
		  }

			  ENDHLSL
		  }
      }
    Fallback "QF/Character/Legacy/Character_MainBody_RimBlend_Fast" 
 }
