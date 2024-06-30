// Upgrade NOTE: replaced '_Object2World' with 'UNITY_MATRIX_M'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Character/Legacy/Character_MainBody_RimBlend_Simple" 
{

	Properties 
	{
	 _MainTex ("Diffue Map", 2D) = "white" {}
 
	 _SAEMap ("SkinMask(R) Alpha(G) Emis(B)", 2D) = "black" {}
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
		LOD 100
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
			Cull Off
			Fog {Mode Off}
			Lighting Off
			Tags {"LightMode" = "UniversalForward"}
			HLSLPROGRAM
			#pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA  // 启用NssFog
			#pragma glsl		
			//#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdbase 
			#pragma fragmentoption ARB_precision_hint_fastest	

			#pragma multi_compile _ USE_BUILDIN_SH
			 
			uniform sampler2D _MainTex;
	 
			uniform sampler2D _SAEMap;
		 
		 

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
				 
				//half3 normal: TEXCOORD3; // [Samsung Gamedev] Not used in frag
			#endif

				half3 vlight: TEXCOORD5;

			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these 
				NSS_FOG_COORDS(6)
			#endif
			};
			
			
			
			  VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0; 
			 
				v.normal = normalize(v.normal);
				
				o.pos = TransformObjectToHClip(v.vertex);
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				o.texcoord = v.texcoord.xy;
			#endif
			
				o.vlight = NssAvatarShadeSH(half4(mul(UNITY_MATRIX_M,half4(v.normal, 0.0)).xyz, 1.0)); // [Samsung Gamedev]
				
			#ifndef ENABLE_WHITE_MODE // [Samsung Gamedev] Only in !ENABLE_WHITE_MODE will use these
				NSS_TRANSFER_FOG_MS(o, v.vertex, _WorldSpaceCameraPos);
			#endif
				return o;
			} 
			
			
		 
			
			half4 frag (VertexOutput i) : COLOR
			{
				#ifdef ENABLE_WHITE_MODE
					return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(i.vlight,1.0));
				#else
				 
				#ifdef DISABLE_CHARACTER_LIGHTPROBES
					i.vlight = 1.0; 
				#endif
				
			
				half2 uv = i.texcoord;
				 

				half4 mainTexColor = tex2D(_MainTex, uv);
			 
				half3 saeMask = tex2D(_SAEMap,uv).rgb;
			
			 
			 
			   
				
				half3 finalColor = mainTexColor.rgb * i.vlight ;
				  
				
				return NSS_CALC_FOG(i, NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor,saeMask.g)));
				
				#endif
             }
             
              ENDHLSL
          }
      }
    Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	  //Fallback "Legacy Shaders/DiffuseX"
 }
