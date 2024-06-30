// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Simple/Simple_Diffuse_NoVertexColor" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque"  "Reflection" = "RenderReflectionOpaque"}
		LOD 10
				
		
		HLSLINCLUDE
		#include "../../Include/QSM_COLORSPACE_CORE.cginc"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
		   #include "../../Include/QSM_BASE_MACRO.cginc"
		ENDHLSL
		
		pass
		{
          Tags { "LightMode" = "UniversalForward" }
			Cull Back
			
			Fog {Mode Off}
			HLSLPROGRAM		
			#include "../AdvCarCommon.cginc"	
			
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdbase
			#pragma exclude_renderers xbox360 flash	
	

			sampler2D _MainTex;	
CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;			
CBUFFER_END
			struct appdata 
			{
		 
			    float4 vertex : POSITION;
			    float4 texcoord : TEXCOORD0;
			};
			
			struct VSOut
			{
	 
				float4 pos		: SV_POSITION;
				float2 uv		: TEXCOORD0;

			};
			
			VSOut vert(appdata v)
			{
				VSOut o;
	
				o.pos = TransformObjectToHClip(v.vertex);
	
				o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				
			 
				return o;
			}
			
			half4 frag(VSOut i) : COLOR
			{					
 
				half3 diffuseCol = tex2D(_MainTex,  i.uv).rgb;			
				half4 finalColor = half4(diffuseCol, 1) ; 
				
				return NSS_OUTPUT_COLOR_SPACE(finalColor);
			}

			ENDHLSL
		} 
	}
	 Fallback "QF/Simple/Diffuse_Write_Depth"
}
