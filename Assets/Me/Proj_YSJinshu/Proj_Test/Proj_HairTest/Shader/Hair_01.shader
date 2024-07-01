Shader "QF/Character/High/Hair_01" 
{
	Properties
	{
		_MainTex ("头发纹理 (RGB) Alpha (A)", 2D) = "white" {}
		
		_SpecularTex ("Specular (R) Spec Shift (G) Fresnel (B)", 2D) = "gray" {}
		_SpecularMask2("SpecularMask2" , 2D) = "white" {}
		_SkinMap ("SkinMask(R)", 2D) = "black" {}	 
		_RampMap ("Ramp Map", 2D) = "black" {}
		_RampSpecularMap ("Ramp Specular Map", 2D) = "black" {}
		
		_Color ("头发色彩", Color) = (1,1,1,1.0)

		_SpecularPow ("高光强度[0,1]", Float) = 0.7
		_PrimaryShift ( "高光偏移[-0.5,0.5]", Float) = 0.0
		

		_FrsnelMap("Frsnel Map (RGB)", 2D) = "black" {}
		_FrsnelPower ("Frsnel Power", Float) = 1.0
		
		
		 _Ambient ("Ambient[0,0.2]", Float) = 0.0
		 _ShadowSoft ("ShadowSoft[0,1]", Float) = 0.0
		
		[HDR]_Brightness ("明暗颜色", Color) = (1.0,1.0,1.0,1)
		_BrightnessLerp ("明暗[0,1.0]", Range(0,1)) = 1.0
		_BrightnessMap("BrightnessMap",2D) = "white" {}
		_BrightnessNoiseMap("BrightnessNoiseMap",2D) = "black" {}
		_BrightnessNoise("BrightnessNoise", Range(0,1)) = 1.0
		[HDR]_BrightnessEdge("BrightnessEdge", Color) = (0,0,0,1)
		_BrightnessEdgePow("BrightnessEdgePow", Range(0,8)) = 2.0
		_BrightnessTimeSpeed("BrightnessTimeSpeed", Vector) = (0,0,0,1)
	}
	
	HLSLINCLUDE
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	 //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

	ENDHLSL

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Reflection" = "RenderReflectionOpaque"}

		LOD 150
			
		
		// HLSLINCLUDE
		// #include "../../1cginc/QSM_COLORSPACE_CORE.cginc"
		//    #include "../../1cginc/QSM_BASE_MACRO.cginc"
		// ENDHLSL
		
		Pass
		{
			Cull Off
			
			Fog {Mode Off}
		    Tags {"LightMode" = "UniversalForward"}
			HLSLPROGRAM
		 
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma glsl
			// #pragma shader_feature_local _ DISSOLVE_ON
			// #pragma shader_feature_local _ DISSOLVE_INVERSE
			// #pragma shader_feature_local _ DISSOLVE_BRIGHTNESS
			// #pragma shader_feature_local _ DISSOLVE_BRIGHTNESS_SCREENUV
			// #include "../../AdvCarCommon.cginc"
			//#pragma multi_compile_fwdbase
			 
			//////#pragma multi_compile _ ENABLE_WHITE_MODE

			sampler2D _MainTex, _SpecularTex, _SkinMap;
CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
			half4 _SpecularTex_ST;
			half4 _Color;
			half _SpecularPow;
			half _PrimaryShift;
			half _FrsnelPower;
			uniform half _Ambient;
			uniform half _ShadowSoft;
			// half _DissolveProgress;
			// half _DissolveOffset;
			// float4 _DissolveMap_ST;
			// half _DissolveEdgeWidth;
			// half3 _DissolveEdgeColor;
			// half _DissolveEdgeColorIntensity;
			// half3 _DissolveFresnelColorOut;
			// half3 _DissolveFresnelColorIn;
			// half _DissolveFresnelPow;
			// half3 _DissolveFresnelColorEdge;
			// half _DissolveFresnelEdgePow;
			half3 _Brightness;
			half _BrightnessLerp;
			float4 _BrightnessMap_ST;
			float4 _BrightnessNoiseMap_ST;
			half _BrightnessNoise;
			half3 _BrightnessEdge;
			half _BrightnessEdgePow;
			float4 _BrightnessTimeSpeed;
CBUFFER_END
			uniform sampler2D _SpecularMask2;
			uniform sampler2D _RampMap;
			uniform sampler2D _RampSpecularMap;
		 

			sampler2D _FrsnelMap;
			
			//sampler2D _DissolveMap;
			//Edge
			//Color
		 
			sampler2D _BrightnessMap;
			sampler2D _BrightnessNoiseMap;

			struct appdata
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
			};

			struct VSOut
			{
				float4 pos : SV_POSITION;
				float4 uv  : TEXCOORD0;
				// #ifdef DISSOLVE_ON
				// float4 dissolveUV :TEXCOORD8;
				// float2 dissolveNoiseUV :TEXCOORD9;
				half3 TS_normal : TEXCOORD1;
				half3 TS_binormal : TEXCOORD2;
				half3 TS_lightDir : TEXCOORD3;
				half3 TS_viewDir : TEXCOORD4;
				half2 normalVS_uv: TEXCOORD5;
				
				float4 shadowPos : TEXCOORD6;
		 
			};

            // void MainLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out float ShadowAtten)
            //     {
            //     #if defined(SHADERGRAPH_PREVIEW)
            //         Direction = float3(0.5, 0.5, 0);
            //         Color = 1;
            //         ShadowAtten = 1;
            //     #else
            //         float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);

            //         Light mainLight = GetMainLight(shadowCoord);
            //         Direction = mainLight.direction;
            //         Color = mainLight.color;

            //         #if !defined(_MAIN_LIGHT_SHADOWS) || defined(_RECEIVE_SHADOWS_OFF)
            //             ShadowAtten = 1.0h;
            //         #else
            //             ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
            //             float shadowStrength = GetMainLightShadowStrength();
            //             ShadowAtten = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture,
            //             sampler_MainLightShadowmapTexture),
            //             shadowSamplingData, shadowStrength, false);
            //         #endif
            //     #endif
            //     }
			VSOut vert(appdata v)
			{
				VSOut o = (VSOut)0;
				
				v.normal = normalize(v.normal);
	
				o.pos = TransformObjectToHClip(v.vertex);
		 
				o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord.xy,_SpecularTex);
				o.TS_normal = v.normal;
				o.TS_binormal = normalize(cross( v.normal, v.tangent));
				
		
				half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normal).xyz;;
				o.normalVS_uv = normalVS.xy * 0.5 + 0.5;
				
				float3 worldPos = TransformObjectToWorld(v.vertex);
				//o.shadowPos = UnityMulPos(_SGameShadowMatrix, worldPos);
				 
                float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
                Light mainLight = GetMainLight(shadowCoord);
				o.TS_lightDir = mul(UNITY_MATRIX_I_M, half4(GetMainLight(), 0));
				o.TS_viewDir = (TransformWorldToObject(GetCameraPositionWS()) - v.vertex.xyz);

				return o; 
			}
			
			half StrandSpecular ( half3 T, half3 V, half3 L)
			{
				half3 H = normalize (  V +  L);
				float dotTH = dot ( T, H );
				return dotTH;
			}
			
			half4 frag(VSOut i) : COLOR
			{
			 
				i.TS_lightDir = normalize(i.TS_lightDir);
				i.TS_viewDir = normalize(i.TS_viewDir);
 
				half NdotL = dot(i.TS_normal,i.TS_lightDir);

				half absNdotL = abs(NdotL);
				//half shadow = CalcShadow(i.shadowPos, lerp(0.003, 0.001, absNdotL), lerp(80.0, 1000.0, absNdotL) ,_ShadowSoft); 

				half light = min(NdotL,shadow);
				
				half NdotL_0to1 = light * 0.5 + 0.5;
				
				NdotL_0to1 = max(NdotL_0to1,_Ambient);

				half skin = tex2D(_SkinMap, i.uv.xy).r;
				half2 rampUVSkin = half2(NdotL_0to1, 1.0);
				half2 rampUVCloth = half2(NdotL_0to1, 0.0);
				half3 rampColor = lerp(tex2D(_RampMap, rampUVCloth), tex2D(_RampMap, rampUVSkin), skin);
				 
				half3 diffuseRamp = rampColor  * _NssLightColor;
				
				 
				half3 DF = tex2D(_MainTex,i.uv.xy).rgb;
				DF = DF * diffuseRamp * _Color;
	
			    half3 specMask = tex2D(_SpecularTex, i.uv.zw).rgb;
				half specularIntensity = specMask.r;
				half specShift = specMask.g;
				half fresnelMask = specMask.b;
			
				if(dot(i.TS_normal,i.TS_viewDir) < 0)
				{
					i.TS_normal = -i.TS_normal;
				}
			
				half shiftTex = _PrimaryShift + specShift - .5;
				  
				half3 t1 = ShiftTangent (  i.TS_binormal, i.TS_normal, shiftTex );

				half spec =  StrandSpecular(t1, i.TS_viewDir, i.TS_lightDir);

				half3 sepcRamp = specularIntensity * _SpecularPow * max(0.0,NdotL) * (tex2D(_RampSpecularMap, half2(spec,0.5)) - 0.5);
				
				half specMask2 = tex2D(_SpecularMask2 , i.uv.xy).r;
				
				sepcRamp =  specMask2 * sepcRamp;
				
	
	
				half3 frsnelMapColor = tex2D(_FrsnelMap, i.normalVS_uv).rgb * _FrsnelPower * fresnelMask;

				
				half4 result = half4(( DF +  sepcRamp  + frsnelMapColor),1.0);
	
	 

                return result;	

			}
			ENDHLSL
		}
	}
	Fallback "Diffuse"
	// CustomEditor "CharacterMaterialInspector"
}
