// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Env/0_Low/Basic_Diffuse_Low" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque"  "Reflection" = "RenderReflectionOpaque"}
		LOD 10
				
		
		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
		   #include "../../../Include/QSM_BASE_MACRO.cginc"
		ENDHLSL
		
		pass
		{
          Tags { "LightMode" = "UniversalForward" }
			Cull Back
			
			Fog {Mode Off}
			HLSLPROGRAM		
			#include "../../AdvCarCommon.cginc"	
			//#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdbase
			#pragma exclude_renderers xbox360 flash	
		//	#pragma multi_compile _ ENABLE_PARABOLOID
			//////#pragma multi_compile _ DISABLE_VERTEX_COLOR 
			#pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA  // ����NssFog

			sampler2D _MainTex;	
CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;			
CBUFFER_END
			struct appdata 
			{
				half4 color : COLOR;
			    float4 vertex : POSITION;
			    float4 texcoord : TEXCOORD0;
			};
			
			struct VSOut
			{
				half4 color : COLOR;
				float4 pos		: SV_POSITION;
				float2 uv		: TEXCOORD0;
		//	#ifdef ENABLE_PARABOLOID
		//		half paraboloidHemisphere : TEXCOORD1;
		//	#endif
				NSS_FOG_COORDS(2)
			};
			
			VSOut vert(appdata v)
			{
				VSOut o;
		//	#ifdef ENABLE_PARABOLOID
		//		o.pos = float4(TransformWorldToView(v.vertex), 1.0);
		//		o.paraboloidHemisphere = o.pos.z;
		//		o.pos = ParaboloidTransform(o.pos);
				
		//	#else
				o.pos = TransformObjectToHClip(v.vertex);
		//	#endif	
				
				NSS_TRANSFER_FOG_MS(o, v.vertex, _WorldSpaceCameraPos);
				o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				
			
				o.color = v.color;
		
				return o;
			}
			
			half4 frag(VSOut i) : COLOR
			{					
			//#ifdef ENABLE_PARABOLOID				
			//	if (ParaboloidDiscard(i.paraboloidHemisphere))
			//		discard;
			//#endif	
				float2 uv0 = i.uv.xy;

				half3 diffuseCol = tex2D(_MainTex, uv0).rgb;			
				half4 finalColor = half4(diffuseCol, 1)  * i.color; 
				
				return NSS_CALC_FOG(i, NSS_OUTPUT_COLOR_SPACE(finalColor));
			}

			ENDHLSL
		} 
	}
}
