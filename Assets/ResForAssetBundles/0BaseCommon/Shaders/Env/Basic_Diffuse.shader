// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'TransformObjectToHClip(*)'

Shader "QF/Env/Basic_Diffuse" {
	Properties {
		//_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque"  "Reflection" = "RenderReflectionOpaque"}
		LOD 100
				
		pass
		{
          Tags { "LightMode" = "UniversalForward" }
			Cull Back
			Fog {Mode Off}
			HLSLPROGRAM		
			#include "../AdvCarCommon.cginc"	
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"	
			#include "../NssLightmap.cginc"
			//#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ LIGHTMAP_ON  
			#pragma exclude_renderers xbox360 flash	
 
			#pragma shader_feature_local _ LIGHTMAP_ON_AA 
            #pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA  // ����NssFog

			//#pragma multi_compile _ ENABLE_PARABOLOID
			//////#pragma multi_compile _ ENABLE_WHITE_MODE
			//////#pragma multi_compile _ DISABLE_LIGHTMAPS_DIFFUSE
			 

			sampler2D _MainTex;
CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
CBUFFER_END
			//half4 _Color;
			

		
			
			struct appdata 
			{
				half4 color : COLOR;
			    float4 vertex : POSITION;
			    float2 texcoord : TEXCOORD0;
			    float2 texcoord1 : TEXCOORD1;
			};
			
			struct VSOut
			{
				half4 color : COLOR;
				float4 pos		: SV_POSITION;
				float4 uv		: TEXCOORD0;
		//	#ifdef ENABLE_PARABOLOID
		//		float paraboloidHemisphere : TEXCOORD1;
		//	#endif
		        NSS_FOG_COORDS(2)
			};
			
			
			
			
			VSOut vert(appdata v)
			{
				VSOut o;
		//	#ifdef ENABLE_PARABOLOID
		//		o.pos = mul(UNITY_MATRIX_MV, v.vertex);	
		//		o.paraboloidHemisphere = o.pos.z;
		//		o.pos = ParaboloidTransform(o.pos);
				
		//	#else
				o.pos = TransformObjectToHClip(v.vertex);
		//	#endif	
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);

				NSS_TRANSFER_FOG_MS(o, v.vertex, _WorldSpaceCameraPos);
				
			#ifdef LIGHTMAP_ON
				o.uv.zw = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;
			#else
				o.uv.zw = v.texcoord1;
			#endif
				
				
			
				o.color = v.color;
			
				
				return o;
			}
			
			
			
			
			
			half4 frag(VSOut i) : COLOR
			{							
		//     #ifdef ENABLE_PARABOLOID
		//		if (ParaboloidDiscard(i.paraboloidHemisphere))
		//			 discard;
		//	#endif	
			
				float2 uv0 = i.uv.xy;
				float2 uv1 = i.uv.zw;
				
			
							
				half3 diffuseCol = tex2D(_MainTex, uv0);
		
		 
			
				

			 
				half3 lightMapCol = NssLightmap_Diffuse(uv1);
				#ifdef ENABLE_WHITE_MODE
					return half4(lightMapCol,1.0);
				#endif
				 

				half3 color = diffuseCol * lightMapCol;				
				half4 finalColor = half4(color, 1) * i.color; 
				
				
				
				finalColor = NSS_CALC_FOG(i, finalColor );
				
				return saturate(finalColor);
			}
			
			
			

			ENDHLSL
		} 
	}
	Fallback "QF/Env/0_Low/Basic_Diffuse_Low"
}
