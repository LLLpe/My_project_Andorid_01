
Shader "QF/Character/Low/Character_MHY_Common_Low"
{
    Properties
    {
		[KeywordEnum(Body,Face)] _ShaderEnum("Shader类型", int) = 0
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_Color("_Color", COLOR) = (1.00, 1.00, 1.00, 1.00)
		_Color2("_Color2", COLOR) = (1, 1, 1, 1)
		_Color3("_Color3", COLOR) = (1, 1, 1, 1)
		_Color4("_Color4", COLOR) = (1, 1, 1, 1)
		_Color5("_Color5", COLOR) = (1, 1, 1, 1)

		[NoScaleOffset]_LightMapTex("_LightMapTex", 2D) = "white" {}

		_DirLightDir("灯光方向",Vector) = (0.4783422,0.3420219,0.8088325,1)
		_FaceShadowToggle("_FaceShadowToggle", Float) = 0
		[NoScaleOffset]_FaceMapTex("_FaceMapTex", 2D) = "white" {}
		_FaceMapSoftness("_FaceMapSoftness", Range(0, 1)) = 0.0001
		//_FaceMapRotateOffset("_FaceMapRotateOffset", Float) = 0
		//_FaceShadowMapPow("Face Shadow Map Pow", range(0.001, 5.0)) = 1.0
		_FaceRotateRange("_FaceRotateRange", range(0.01, 1.0)) = 0.6

		_MTSpecToggle("_MTSpecToggle", Float) = 0
		[NoScaleOffset]_MTMap("_MTMap", 2D) = "white" {}
		_MTMapBrightness("_MTMapBrightness", Float) = 5
		_MTMapTileScale("_MTMapTileScale", Float) = 1
		_MTMapLightColor("_MTMapLightColor", COLOR) = (0.79617, 0.56394, 0.36523, 1.0)
		_MTMapDarkColor("_MTMapDarkColor", COLOR) = (0.29207, 0.20534, 0.31342, 1.0)

		_BlinnSpecToggle("_BlinnSpecToggle", Float) = 0
		[NoScaleOffset]_SpecularRamp("_SpecularRamp", 2D) = "white" {}
		_SpecularColor("_SpecularColor", COLOR) = (1, 1, 1, 1)
		_Shininess("_Shininess", Float) = 10
		_Shininess2("_Shininess2", Float) = 10
		_Shininess3("_Shininess3", Float) = 10
		_Shininess4("_Shininess4", Float) = 10
		_Shininess5("_Shininess5", Float) = 10
		_SpecMulti("_SpecMulti", Float) = 0.0
		_SpecMulti2("_SpecMulti2", Float) = 0.1
		_SpecMulti3("_SpecMulti3", Float) = 0.1
		_SpecMulti4("_SpecMulti4", Float) = 0.1
		_SpecMulti5("_SpecMulti5", Float) = 0.1

		_ShadowRampToggle("_ShadowRampToggle", Float) = 0
		[NoScaleOffset]_PackedShadowRampTex("_PackedShadowRampTex", 2D) = "white" {}
		_ShadowRampWidth("_ShadowRampWidth", Float) = 1
		_LightArea("_LightArea", Range(0, 1)) = 0.5
		//_LightYAngle("_LightYAngle", Range(-80, 80)) = 10.0
		_ShadowMultColor("_ShadowMultColor", COLOR) = (0.94731, 0.52712, 0.45641, 1.0)
		_ShadowMultColor2("_ShadowMultColor2", COLOR) = (0.53405, 0.35817, 0.34012, 1.0)
		_ShadowMultColor3("_ShadowMultColor3", COLOR) = (0.7816, 0.7816, 0.7816, 1.0)
		_ShadowMultColor4("_ShadowMultColor4", COLOR) = (0.78741, 0.44799, 0.52252, 1.0)
		_ShadowMultColor5("_ShadowMultColor5", COLOR) = (0.78741, 0.44799, 0.52252, 1.0)
		_UseShadowTransition("_UseShadowTransition", Float) = 0
		_ShadowTransitionRange("_ShadowTransitionRange", Float) = 0.01
		_ShadowTransitionRange2("_ShadowTransitionRange2", Float) = 0.01
		_ShadowTransitionRange3("_ShadowTransitionRange3", Float) = 0.01
		_ShadowTransitionRange4("_ShadowTransitionRange4", Float) = 0.01
		_ShadowTransitionRange5("_ShadowTransitionRange5", Float) = 0.01
		_ShadowTransitionSoftness("_ShadowTransitionSoftness", Float) = 0.5
		_ShadowTransitionSoftness2("_ShadowTransitionSoftness2", Float) = 0.5
		_ShadowTransitionSoftness3("_ShadowTransitionSoftness3", Float) = 0.5
		_ShadowTransitionSoftness4("_ShadowTransitionSoftness4", Float) = 0.5
		_ShadowTransitionSoftness5("_ShadowTransitionSoftness5", Float) = 0.5

		_EmissionToggle("_EmissionToggle", Float) = 0
		_EmissionColor("_EmissionColor", COLOR) = (1.00, 1.00, 1.00, 1.0)
		_EmissionMap("_EmissionMap", 2D) = "white" {}
		_EmissionScaler("_EmissionScaler", Float) = 1
		_EmissionScaler1("_EmissionScaler1", Float) = 1
		_EmissionScaler2("_EmissionScaler2", Float) = 1
		_EmissionScaler3("_EmissionScaler3", Float) = 1
		_EmissionScaler4("_EmissionScaler4", Float) = 1
		_EmissionScaler5("_EmissionScaler5", Float) = 1
		_EmissionShiningToggle("自发光闪烁", float) = 0
		_EmissionNoise("自发光Noise", 2D) = "white" {}
		_EmissionShiningMin("最低亮度", Range(0, 1)) = 0
		_EmissionShiningFreq("闪动频率", Range(0, 5)) = 1
		_EmissionNoiseIntensity("噪点扰动强度", Range(0, 1)) = 1
		_EmissionNoiseSpeed("噪点扰动速度", Range(0, 20)) = 3
		_EmissionNoiseTile("噪点扰动密度", Range(0, 20)) = 10

		_OutlineType("_OutlineType", Float) = 1
		_OutlineWidth("_OutlineWidth", Float) = 1
		[HDR]_OutlineColor("_OutlineColor", COLOR) = (0.10354, 0.08415, 0.16358, 1.00)
		_OutlineLerp("_OutlineLerp", Range(0, 1)) = 0.76
		_OutlineMask("OutlineMask", 2D) = "white" {}
		_OutLineMaskAlpha("Mask Alpha比例", Range(0, 1)) = 0
		_OutlineClip("OutlineClip", Range(0, 1)) = 0.0
		_OutlineFXMaskOn("OutlineFXMaskOn", Float) = 0
		[Enum(R, 0, RG, 1)]_OutlineFXMask("OutlineFXMask", Float) = 0.0
		_OutlineRamp("OutlineRamp", Float) = 0.0
		_OutlineAlphaMin("_OutlineAlphaMin", Float) = 0
		_OutlineAlphaMax("_OutlineAlphaMax", Float) = 0
		_OutlineZScale("_OutlineZScale", Range(0.5, 50.0)) = 1.0

		_FXMask("Mask", 2D) = "white" {}
		//_FXMaskRNoiseIntensity("MaskR受Noise影响强度", Range(0, 10)) = 0.0
		_FXMaskRIntensity("MaskR强度", Range(0, 50)) = 1.0
		_FXMaskRTilingAndOffset("MaskRTilingAndOffset", Vector) = (1, 1, 0, 0)
		_FXMaskRSpeedU("MaskR_U移动", Float) = 0.0
		_FXMaskRSpeedV("MaskR_V移动", Float) = 0.0
		_FXMaskGIntensity("MaskG强度", Range(0, 50)) = 1.0
		//_FXMaskGNoiseIntensity("MaskG受Noise影响强度", Range(0, 10)) = 0.0
		_FXMaskGTilingAndOffset("MaskGTilingAndOffset", Vector) = (1, 1, 0, 0)
		_FXMaskGSpeedU("MaskG_U移动", Float) = 0.0
		_FXMaskGSpeedV("MaskG_V移动", Float) = 0.0

		_FXLayer2Toggle("特效Layer2", Float) = 0.0
		_FXLayer2Map("特效Layer2", 2D) = "black" {}
		[HDR]_FXLayer2Color("Layer1Color", Color) = (1, 1, 1, 1)
		_FXLayer2MaskOn("FXLayer1MaskOn", Float) = 0
		[Enum(G, 0, RG, 1)]_FXLayer2Mask("Layer1Mask", Float) = 0.0
		_FXLayer2SpeedU("Layer1SpeedU", Float) = 0.0
		_FXLayer2SpeedV("Layer1SpeedV", Float) = 0.0
		_FXLayer2ScreenUV("Screen UV", Range(0.0, 1.0)) = 0.5

		_IsHDR("_IsHDR", float) = 0
		_ACES_A("_ACES_A（标准值2.51）", Range(0.0, 10.0)) = 1.94
		_ACES_B("_ACES_B（标准值0.03）", Range(0.0, 10.0)) = 0
		_ACES_C("_ACES_C（标准值2.43）", Range(0.0, 10.0)) = 1.5
		_ACES_D("_ACES_D（标准值0.59）", Range(0.0, 10.0)) = 0.59
		_ACES_E("_ACES_E（标准值0.14）", Range(0.0, 10.0)) = 0.14

	    _RimColorToggle("_RimColorToggle", Float) = 0
	    [NoScaleOffset] _RimMap("_RimMap",2D) = "Gray"{}
	    _RimColor("_RimColor" , color) = (1,1,1,1)
	    _RimArea("_RimArea", Range(0.1,5)) = 1
	    _RimHardness("_RimHardness", Range(0.1,1)) = 1

		//渲染状态
		[Space(5)]
		_SrcBlend("", Float) = 1
		_DstBlend("", Float) = 0
		_ZWrite("", Float) = 1
		_CullMode("", Float) = 0
		_BlendMode("", float) = 0
		_Cutoff("", float) = 0.5
		_ZTest("ZTest", Float) = 4
		_ZWrite2("", Float) = 1
    }

	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
	ENDHLSL

	SubShader
    {
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "Reflection" = "RenderReflectionOpaque"}
		LOD 100

		HLSLINCLUDE
		#include "../../../Include/QSM_COLORSPACE_CORE.cginc"
		#include "../../../Include/QSM_BASE_MACRO.cginc"
		#include "../../../Include/NssLighting.cginc"
		ENDHLSL

        Pass
        {
			Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]
			ZTest[_ZTest]
			Cull[_CullMode]

			HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma target 3.0

			#pragma shader_feature_local _ _SHADERENUM_FACE
			#pragma shader_feature_local _ _FACE_SHADOW
			#pragma shader_feature_local _ _METAL_SPEC
			#pragma shader_feature_local _ _BLINN_SPEC
			#pragma shader_feature_local _ _RAMP_SPEC
			#pragma shader_feature_local _ _RAMP_SHADOW
			#pragma shader_feature_local _ _SOFT_SHADOW
			#pragma shader_feature_local _ _EMISSION
			#pragma shader_feature_local _ _EMISSION_SHINE
			#pragma shader_feature_local _ _FX_LAYER2
			#pragma shader_feature_local _ _HARD_RIM
			#pragma shader_feature_local _ _HDR

			#include "../../../Common/QF_Special.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				half4 color : COLOR;
				half3 normal : NORMAL;
				half3 tangent : TANGENT;
            };

            struct v2f
            {
				float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				half4 color	: TEXCOORD1;
				half4 scrPos : TEXCOORD2;
				half3 wsNormal: TEXCOORD3;
				half3 wsTangent : TEXCOORD4;
				half3 wsBTangent : TEXCOORD5;
				float2 worldPos : TEXCOORD6;
				half3 wsViewDir : TEXCOORD7;
				half3 normal: TEXCOORD8;
				half3 tangent: TEXCOORD9;
				half4 screenUV : TEXCOORD10;
            };

			sampler2D _MainTex; 
			sampler2D _NormalMap;
			sampler2D _LightMapTex;
			sampler2D _FaceMapTex;
			sampler2D _CharacterAmbientSensorTex;
			sampler2D _MTMap;
			sampler2D _SpecularRamp;
			sampler2D _PackedShadowRampTex;
			sampler2D _EmissionMap;
			sampler2D _RimMap;
		CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
			half4 _NormalMap_ST;
			half4 _LightMapTex_ST;
			half4 _FaceMapTex_ST;
			half4 _CharacterAmbientSensorTex_ST;
			half4 _SpecularRamp_ST;
			half4 _MTMap_ST;
			half4 _PackedShadowRampTex_ST;
			half4 _EmissionMap_ST;

			half3 _DirLightDir;
			half4 _Color;
			half4 _Color2;
			half4 _Color3;
			half4 _Color4;
			half4 _Color5;

			half _MTMapBrightness;
			half _MTMapTileScale;
			half3 _MTMapLightColor;
			half3 _MTMapDarkColor;
			half3 _MTShadowMultiColor;
			half _MTShininess;
			half3 _MTSpecularColor;
			half _MTSpecularScale;
			half _MTSpecularAttenInShadow;
			half _MTUseSpecularRamp;
			half _MTSharpLayerOffset;
			half3 _MTSharpLayerColor;

			half4 _EmissionColor;
			half _EmissionScaler;
			half _EmissionScaler1;
			half _EmissionScaler2;
			half _EmissionScaler3;
			half _EmissionScaler4;
			half _EmissionScaler5;
			half _EmissionStrengthLerp;
			half _FaceMapSoftness;
			float3 _ShadowMultColor;
			float3 _ShadowMultColor2;
			float3 _ShadowMultColor3;
			float3 _ShadowMultColor4;
			float3 _ShadowMultColor5;
			half _LightArea;
			//half _LightYAngle;
			half _ShadowTransitionRange;
			half _ShadowTransitionRange2;
			half _ShadowTransitionRange3;
			half _ShadowTransitionRange4;
			half _ShadowTransitionRange5;
			half _ShadowTransitionSoftness;
			half _ShadowTransitionSoftness2;
			half _ShadowTransitionSoftness3;
			half _ShadowTransitionSoftness4;
			half _ShadowTransitionSoftness5;
			half _Shininess;
			half _Shininess2;
			half _Shininess3;
			half _Shininess4;
			half _Shininess5;
			half _SpecMulti;
			half _SpecMulti2;
			half _SpecMulti3;
			half _SpecMulti4;
			half _SpecMulti5;
			half4 _SpecularColor;
			//half _FaceMapRotateOffset;
			//half _FaceShadowMapPow;
			half _FaceRotateRange;
			half _UseShadowTransition;
			half _ShadowRampWidth;
			//half _UseVertexRampWidth;
            
	        half _RimArea;
	        half _RimHardness;
	        half3 _RimColor;

			half _ACES_A;
			half _ACES_B;
			half _ACES_C;
			half _ACES_D;
			half _ACES_E;
		CBUFFER_END

			half3 ACESToneMapping_V2(half3 color)
			{
				//color *= adapted_lum;
				color = (color * (_ACES_A * color + _ACES_B)) / (color * (_ACES_C * color + _ACES_D) + _ACES_E);
				return color;
			}


            v2f vert (appdata v)
            {
				float4 vertex = v.vertex;

				v2f o;
				o.vertex = TransformObjectToHClip(vertex);
				o.uv.xy = v.uv;
				o.uv.zw = v.uv;// v.uv2.xy;
				//o.scrPos = ComputeScreenPos(o.vertex);
				o.wsViewDir = normalize(lerp((GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz)), UNITY_MATRIX_V[2].xyz, unity_OrthoParams.w));
				o.wsNormal = TransformObjectToWorldNormal(v.normal);// normalize(mul(half4(v.normal, 0.0), UNITY_MATRIX_I_M).xyz); //normalize(mul(half4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.normal = v.normal.xyz;
				//o.tangent = OctahedronToUnitVector(v.uv1.xy);
				o.screenUV = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenUV.z);

				o.color = v.color;

                return o;
            }

			inline half GetFaceMap(half3 lightDir, float2 uv)
			{
				/*half sinOffset = sin(_FaceMapRotateOffset);
				half cosOffset = cos(_FaceMapRotateOffset);
				half2x2 rotationOffset = half2x2(cosOffset, -sinOffset, sinOffset, cosOffset);*/

				half2 F = normalize(unity_ObjectToWorld._12_22_32.xz);
				half2 R = normalize(unity_ObjectToWorld._13_23_33.xz);
				half2 L = normalize(lightDir.xz);// mul(rotationOffset, lightDir.xz));

				half FdotL = dot(F, L);
				half RdotL = dot(R, L);
				half isRight = step(0, RdotL);
				half isFront = step(0, FdotL);
				RdotL = -(acos(RdotL) / 3.1415926 - 0.5) * 2.0; //[1,-1]
				half FdotL2 = -(acos(FdotL) / 3.1415926 - 0.5) * 2.0; //[1,-1]
				RdotL = lerp(lerp(FdotL2 - 1, 1 - FdotL2, isRight), RdotL, isFront);

				RdotL *= _FaceRotateRange;

				RdotL = lerp(-RdotL, RdotL, isRight);
				half2 shadowUV = lerp(float2(-uv.x, uv.y), uv, isRight);
				half shadowData = tex2D(_FaceMapTex, shadowUV).r;
				//shadowData = pow(shadowData, _FaceShadowMapPow);
				half shadow = smoothstep(RdotL - _FaceMapSoftness, RdotL + _FaceMapSoftness, shadowData);
				return shadow;
			}

			half4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv.xy;

				//顶点色Alpha为黑时裁切
				/*half discardAlpha = lerp(1.0, i.color.w, _UseClipPlane);
				clip(discardAlpha - 0.01);*/

				half3 V = normalize(i.wsViewDir);
				/*half3 viewUp = UNITY_MATRIX_V[1].xyz;
				half3 viewRight = normalize(cross(V, viewUp));

				half2 F = normalize(unity_ObjectToWorld._12_22_32.xz);
				half2 R = normalize(unity_ObjectToWorld._13_23_33.xz);
				half3 sunDir = normalize(_SunDir);

				half sunInRight = step(0, dot(R, sunDir));
				half lightIsRight = step(0, dot(R, normalize(_DirLightDir)));*/
				//half3 lightDir = normalize(_DirLightDir);
				half3 lightDir = _DirLightDir;// lerp(_DirLightDir, half3(-_DirLightDir.x, _DirLightDir.y, _DirLightDir.z), abs(sunInRight - lightIsRight));

				lightDir = normalize(mul(lightDir, UNITY_MATRIX_V).xyz);

				half3 L = normalize(lightDir);

				/*half3 L = normalize(half3(lightDir.x, 0.0, lightDir.z));

				half radY = _LightYAngle / 180 * 3.1415926;
				float2 rotation = float2(cos(radY), sin(radY));
				float3x3 dirRotation = float3x3(rotation.x, -rotation.y, 0,
					rotation.y, rotation.x, 0,
					0, 0, 1
					);
				L = mul(dirRotation, L);	*/

				half3 N = normalize(i.wsNormal);
				//half3 L = normalize(_MainLightPosition.xyz);
				half3 H = normalize(V + L);
				half NdotL = dot(N, L);
				half NdotH = dot(N, H);
				half NdotV = dot(N, V);
				half HalfNdotL = NdotL * 0.5 + 0.5;

				half4 mainTex = tex2D(_MainTex, uv.xy);
				
				half4 lightMapTex = tex2D(_LightMapTex, uv); //tex2Dbias(_LightMapTex, half4(uv.x, uv.y, 0.0, -2));// tex2D(_LightMapTex, uv); //x:金属高光 y:AO z:高光Mask w:分段染色
				half specLayer = lightMapTex.r;
				half aoMask = lightMapTex.g;
				half specMask = lightMapTex.b;
				half rampLayer = lightMapTex.a;

				half tightsLayer = step(abs(rampLayer - 0.7), 0.015); //5
				half softLayer = (1.0 - tightsLayer) * step(abs(rampLayer - 0.3), 0.015);//4
				half metalLayer = (1.0 - softLayer) * step(abs(rampLayer - 0.5), 0.015); //3
				half skinLayer = (1.0 - metalLayer) * step(abs(rampLayer - 0.9), 0.015); //2
				half hardLayer = saturate(1.0 - (tightsLayer + softLayer + metalLayer + skinLayer));//1

				mainTex.xyz *= (_Color.xyz * hardLayer + _Color2.xyz * skinLayer + _Color3.xyz * metalLayer + _Color4.xyz * softLayer + _Color5 * tightsLayer);
				float3 shadowRamp = (_ShadowMultColor.xyz * hardLayer + _ShadowMultColor2.xyz * skinLayer + _ShadowMultColor3.xyz * metalLayer + _ShadowMultColor4.xyz * softLayer + _ShadowMultColor5.xyz * tightsLayer);

				bool alphaNotZero = mainTex.w > 0.01;
				half alpha = mainTex.w;

				half AO = lightMapTex.y;// ((_UseLightMapColorAO != 0.0) ? (lightMapTex.y) : (0.5));
				half faceShadow = 1.0;
				#ifdef _FACE_SHADOW
					faceShadow = GetFaceMap(L, uv);
				#endif

				AO = (AO * i.color.x);// ((_UseVertexColorAO != 0) ? (AO * i.color.x) : (AO));
				float rampNdotL = ((0.94999999 < AO) ? (1.0) : ((AO + NdotL * 0.4975 + 0.5) * 0.5)); //rampNdotL 二分光影
				rampNdotL = ((AO < 0.050000001) ? (0.0) : (rampNdotL));

				half darkScale = 0.0;
				half brightScale = 1.0;
				if (rampNdotL < _LightArea)
				{
					#ifdef _SOFT_SHADOW
						half2 RangeSoft = hardLayer * half2(_ShadowTransitionRange, _ShadowTransitionSoftness) + skinLayer * half2(_ShadowTransitionRange2, _ShadowTransitionSoftness2) 
								+ metalLayer * half2(_ShadowTransitionRange3, _ShadowTransitionSoftness3) + softLayer * half2(_ShadowTransitionRange4, _ShadowTransitionSoftness4) 
								+ tightsLayer * half2(_ShadowTransitionRange5, _ShadowTransitionSoftness5);

						half darkness = _LightArea - rampNdotL;
						darkness = (darkness / RangeSoft.x);
						bool isDark = (darkness >= 1.0);
						darkness = min(pow(darkness + 0.01, RangeSoft.y), 1.0);
						darkness = ((isDark) ? (1.0) : (darkness));
						darkScale = darkness;
					#else
						darkScale = 1.0;
					#endif
					brightScale = 0.0;
				}

				half brightArea = ((0.5 < specLayer) ? (min(faceShadow, brightScale)) : (brightScale));

				#ifdef _SOFT_SHADOW
					//shadowRamp = lerp(half3(1.0, 1.0, 1.0), shadowColor, darkScale);
				#endif

				#ifdef _FACE_SHADOW
					shadowRamp = lerp(shadowRamp, half3(1.0, 1.0, 1.0), faceShadow);
				#endif

				half3 diffuseColor = half3(0.0, 0.0, 0.0); //diffuseColor
				half3 specColor = half3(0.0, 0.0, 0.0); //specColor
				float rampU = 0.0;
				if (specLayer > 2.0)//金属高光，要改贴图
				{
					diffuseColor = mainTex.xyz;
					#ifdef _METAL_SPEC
						half3 normalVS = mul(UNITY_MATRIX_IT_MV, normalize(i.normal)).xyz;;
						normalVS.x = normalVS.y * _MTMapTileScale;
						half2 mtMapUV = normalVS.xz * 0.5 + half2(0.5, 0.5);
						half mtIntensity = saturate(tex2D(_MTMap, mtMapUV).x * _MTMapBrightness);

						diffuseColor *= mtIntensity * (_MTMapLightColor.xyz - _MTMapDarkColor.xyz) + _MTMapDarkColor.xyz;
					#endif

					diffuseColor = (brightArea != 1.0) ? (shadowRamp * diffuseColor.xyz) : (diffuseColor.xyz);
				}
				else
				{
					#ifdef _RAMP_SHADOW
						rampU = (rampNdotL < _LightArea) ? (1.0 - min(1.0, ((_LightArea - rampNdotL) / _LightArea) / (max(i.color.y * 2.0, 0.01) * _ShadowRampWidth))) : 1.0;
						half lmW = skinLayer * 2 + tightsLayer * 5 + metalLayer * 3 + softLayer * 4 + hardLayer * 1;
						float V1 = 1.0 - (((lmW - 1.0) * 0.1) + 0.05);
						shadowRamp = tex2D(_PackedShadowRampTex, float2(rampU, V1)).xyz; //tex2Dbias(_PackedShadowRampTex, half4(rampU, V1, 0.0, -2)).xyz;// tex2D(_PackedShadowRampTex, float2(rampU, V1)).xyz;
					#endif

						diffuseColor = lerp(shadowRamp * mainTex.xyz, mainTex.xyz, brightArea);
				}

				#ifdef _BLINN_SPEC
					half shininess = _Shininess * hardLayer + skinLayer * _Shininess2 + metalLayer * _Shininess3 + softLayer * _Shininess4 + tightsLayer * _Shininess5;
					half specMulti = _SpecMulti * hardLayer + skinLayer * _SpecMulti2 + metalLayer * _SpecMulti3 + softLayer * _SpecMulti4 + tightsLayer * _SpecMulti5;
					half spec = saturate(pow(max(NdotH, 0.001), shininess));
					#ifdef _RAMP_SPEC
						specColor = specMask * specMulti * tex2D(_SpecularRamp, half2(spec, 0.5)).xyz;
					#else
						specColor = specMask * spec * specMulti * _SpecularColor.xyz;
					#endif
				#endif
				
				half3 finalColor = specColor + diffuseColor;

		        #ifdef _HARD_RIM
		            half rimControl = tex2D(_RimMap , i.uv).r;
		            half rimControl_term = rimControl * 2 - 1 + lerp(0 , _RimArea , rimControl) + 1;//_LightMapIntensity
			        half fresnel_term = (1-NdotV) * HalfNdotL * rimControl_term;
			        half rimMask = pow(fresnel_term * _RimArea , _RimHardness * 300);
			        rimMask = saturate(rimMask);
		            finalColor = lerp(finalColor , _RimColor , rimMask);
		        #endif
		
				half3 emission = 0.0;
				#ifdef _EMISSION
					half3 emissionColor = tex2D(_EmissionMap, uv*_EmissionMap_ST.xy + _EmissionMap_ST.zw).rgb * _EmissionColor.xyz * _EmissionScaler;
					emission = emissionColor * (_EmissionScaler1 * hardLayer + _EmissionScaler2 * skinLayer + _EmissionScaler3 * metalLayer + _EmissionScaler4 * softLayer + _EmissionScaler5 * tightsLayer);
				#endif

				#if defined(_FX_LAYER2)
					float fTime = fmod(_Time.y, 3600.0f);
					//FX遮罩
					float2 maskRUV = (i.uv.zw * _FXMaskRTilingAndOffset.xy + _FXMaskRTilingAndOffset.zw);// +fxNoise * _FXMaskRNoiseIntensity;
					half maskR = saturate(tex2D(_FXMask, (maskRUV + float2(_FXMaskRSpeedU, _FXMaskRSpeedV) * fTime)).r * _FXMaskRIntensity);
					float2 maskGUV = (i.uv.zw * _FXMaskGTilingAndOffset.xy + _FXMaskGTilingAndOffset.zw);// +fxNoise * _FXMaskGNoiseIntensity;
					half maskG = saturate(tex2D(_FXMask, (maskGUV + float2(_FXMaskGSpeedU, _FXMaskGSpeedV) * fTime)).g * _FXMaskGIntensity);
					half4 fxMask = half4(maskR, maskG, 0.0, 0.0);
					emission += GetFXLayer2Color(i.uv.zw, fxMask, (i.screenUV.xy) / (i.screenUV.w), fTime);
				#endif

				#ifdef _EMISSION_SHINE
					emission *= GetEmissionShining(uv);
				#endif

				finalColor += emission;
				/*UNITY_BRANCH
				if (_InverseToneMapping < 0.1)
				{
					finalColor.rgb = ACESToneMapping_V2(finalColor.rgb);
				}*/

				#ifdef _HDR
					UNITY_BRANCH
					if (_InverseToneMapping < 0.1)
					{
						finalColor.rgb = ACESToneMapping_V2(finalColor.rgb);
					}

					return NSS_OUTPUT_COLOR_SPACE(half4(finalColor, alpha));
				#else
					return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalColor, alpha));
				#endif
            }
			ENDHLSL
        }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite2]
			ZTest LEqual
			Cull Front

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#define _OUTLINE
			#pragma shader_feature_local _ _EMISSION
			#pragma shader_feature_local _ _EMISSION_SHINE
			#pragma shader_feature_local _ _HDR

			#include "../../../Common/QF_Special.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				half4 color : COLOR;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				half4 color	: TEXCOORD1;
				half3 wsNormal: TEXCOORD2;
				half3 normal: TEXCOORD3;
				half3 viewN : TEXCOORD4;
			};

			sampler2D _MainTex; 
			sampler2D _LightMapTex;
			sampler2D _OutlineEmission;
			sampler2D _OutlineMask;
		CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
			half4 _LightMapTex_ST;
			half4 _OutlineEmission_ST;
			half4 _OutlineMask_ST;
			half4 _Color;
			half3 _Color2;
			half3 _Color3;
			half3 _Color4;
			half3 _Color5;

			float _OutlineType;//
			float _OutlineWidth;//
			half4 _OutlineColor;//
			half _OutlineLerp;
			half _OutlineClip;
			half _OutlineFXMaskOn;
			half _OutlineFXMask;
			half _OutlineRamp;
			half _OutlineAlphaMin;
			half _OutlineAlphaMax;
			half _OutLineMaskAlpha;
			half _OutlineZScale;

			half _ACES_A;
			half _ACES_B;
			half _ACES_C;
			half _ACES_D;
			half _ACES_E;
		CBUFFER_END

			half3 ACESToneMapping_V2(half3 color)
			{
				//color *= adapted_lum;
				color = (color * (_ACES_A * color + _ACES_B)) / (color * (_ACES_C * color + _ACES_D) + _ACES_E);
				return color;
			}

			inline	float GetOutlineWidthMultiplier(float positionVS_Z)
			{
				float cameraMulFix;
				if (unity_OrthoParams.w == 0)
				{
					// keep outline similar width on screen accoss all camera distance       
					cameraMulFix = abs(positionVS_Z);

					// can replace to a tonemap function if a smooth stop is needed
					cameraMulFix = saturate(cameraMulFix);

					// keep outline similar width on screen accoss all camera fov
					//https://answers.unity.com/questions/770838/how-can-i-extract-the-fov-information-from-the-pro.html
					float t = unity_CameraProjection._m11;
					float Rad2Deg = 180 / 3.1415;
					float fov = atan(1.0f / t) * 2.0 * Rad2Deg;
					cameraMulFix *= fov;
				}
				else
				{
					////////////////////////////////
					// Orthographic camera case
					////////////////////////////////
					float orthoSize = abs(unity_OrthoParams.y);
					orthoSize = saturate(orthoSize);
					cameraMulFix = orthoSize * 50;
				}

				return cameraMulFix * 0.00005; // mul a const to make return result = default normal expand amount WS
			}

			float3 OctahedronToUnitVector(float2 oct)
			{
				float3 unitVec = float3(oct, 1 - dot(float2(1, 1), abs(oct)));

				if (unitVec.z < 0)
				{
					unitVec.xy = (1 - abs(unitVec.yx)) * float2(unitVec.x >= 0 ? 1 : -1, unitVec.y >= 0 ? 1 : -1);
				}

				return normalize(unitVec);
			}

			v2f vert(appdata v)
			{
				float4 vertex = v.vertex;
				v2f o;
				if (_OutlineType == 0.0)
				{
					o.vertex = half4(0.0, 0.0, 0.0, 0.0);
				}
				else
				{
					o.uv.xy = v.uv;
					//o.uv.zw = v.uv1.xy;
					o.color = v.color;

					float3 tangent = OctahedronToUnitVector(v.uv2.xy);
					float3 binormal = cross(v.normal, v.tangent) * v.tangent.w;
					float3x3 T2O = float3x3(v.tangent.xyz, binormal.xyz, v.normal.xyz);
					T2O = transpose(T2O);
					tangent = mul(T2O, tangent);

					float4 viewSpacePos = mul(UNITY_MATRIX_MV, v.vertex);
					float3 fixedVerterxNormal = (_OutlineType == 1.0) ? v.normal : v.tangent;
					float3 vsNormal = mul(UNITY_MATRIX_IT_MV, fixedVerterxNormal);
					
					/*float3 wsNormal = TransformObjectToWorldNormal(fixedVerterxNormal, true);
					float outlineMultipier = GetOutlineWidthMultiplier(viewSpacePos.z);
					float3 posWorld = mul(UNITY_MATRIX_M, v.vertex).xyz + wsNormal * outlineMultipier * _OutlineWidth * v.color.z;
					o.vertex = TransformWorldToHClip(posWorld);*/

					float4 vsPos = mul(UNITY_MATRIX_MV, v.vertex);
					if (unity_OrthoParams.w == 0)
					{
						float s = abs(vsPos.z) / unity_CameraProjection[1][1];
						float width = pow(s, 0.5) *0.002;
						vsPos.xy += normalize(vsNormal).xy * _OutlineWidth * width * v.color.z;
					}
					else
					{
						float orthoSize = abs(unity_OrthoParams.y);
						orthoSize = saturate(orthoSize);
						float width = orthoSize * 0.0025;
						vsPos.xy += normalize(vsNormal).xy * _OutlineWidth * width * v.color.z;
					}
					o.vertex = mul(UNITY_MATRIX_P, vsPos);
					o.viewN = vsNormal;
				}

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv.xy;
				half4 mainTex = tex2D(_MainTex, uv.xy);

				half4 lightMapTex = tex2D(_LightMapTex, uv.xy); //x:金属高光 y:AO z:高光Mask w:分段染色
				half specLayer = lightMapTex.r;
				half aoMask = lightMapTex.g;
				half specMask = lightMapTex.b;
				half rampLayer = lightMapTex.a;

				half tightsLayer = step(abs(rampLayer - 0.7), 0.015); //5
				half softLayer = (1.0 - tightsLayer) * step(abs(rampLayer - 0.3), 0.015);//4
				half metalLayer = (1.0 - softLayer) * step(abs(rampLayer - 0.5), 0.015); //3
				half skinLayer = (1.0 - metalLayer) * step(abs(rampLayer - 1.0), 0.015); //2
				half hardLayer = saturate(1.0 - (tightsLayer + softLayer + metalLayer + skinLayer));//1

				mainTex.xyz *= (_Color.xyz * hardLayer + _Color2.xyz * skinLayer + _Color3.xyz * metalLayer + _Color4.xyz * softLayer + _Color5 * tightsLayer);

				float3 viewN = normalize(i.viewN);// mul(UNITY_MATRIX_IT_MV, i.viewN);
				viewN.z = abs(viewN.z * _OutlineZScale);
				viewN = normalize(viewN) * 0.5 + 0.5;
				half rampU = distance(viewN.xy, half2(0.5, 0.5));
				rampU = saturate(smoothstep(_OutlineAlphaMax, _OutlineAlphaMin, rampU));
				half edgeAlpha = rampU;

				float fTime = fmod(_Time.y, 3600.0f);
				float2 maskRUV = (uv * _FXMaskRTilingAndOffset.xy + _FXMaskRTilingAndOffset.zw);
				half maskR = saturate(tex2D(_FXMask, (maskRUV + float2(_FXMaskRSpeedU, _FXMaskRSpeedV) * fTime)).r * _FXMaskRIntensity);
				float2 maskGUV = (uv * _FXMaskGTilingAndOffset.xy + _FXMaskGTilingAndOffset.zw);
				half maskG = saturate(tex2D(_FXMask, (maskGUV + float2(_FXMaskGSpeedU, _FXMaskGSpeedV) * fTime)).g * _FXMaskGIntensity);
				half4 fxMask = lerp(half4(maskR, maskG, 0.0, 0.0), half4(1.0, 1.0, 0.0, 0.0), edgeAlpha);

				float2 maskUV = lerp(uv.xy, half2(rampU, 0.5), _OutlineRamp);
				float4 mask = tex2D(_OutlineMask, TRANSFORM_TEX(maskUV, _OutlineMask));
				half maskAlpha = Luminance_GrayScale(mask.rgb);
				maskAlpha *= lerp(1.0, lerp(fxMask.r, fxMask.r * fxMask.g, _OutlineFXMask), _OutlineFXMaskOn);

				half4 emissionColor = _OutlineColor;
				emissionColor.rgb *= mask.rgb;
				#ifdef _EMISSION_SHINE
					emissionColor *= GetEmissionShining(uv);
				#endif

				half alpha = saturate(lerp(1.0, maskAlpha, _OutLineMaskAlpha)) * emissionColor.a * edgeAlpha;
				clip(alpha - _OutlineClip);

				mainTex.xyz = lerp(mainTex.xyz, emissionColor.xyz, _OutlineLerp);

				#ifdef _HDR
					UNITY_BRANCH
					if (_InverseToneMapping < 0.1)
					{
						mainTex.rgb = ACESToneMapping_V2(mainTex.rgb);
					}

					return NSS_OUTPUT_COLOR_SPACE(half4(mainTex.xyz, alpha));
				#else
					return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(mainTex.xyz, alpha));
				#endif
			}
			ENDHLSL
		}
    }

	Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	CustomEditor "QF_CharacterMHYCommonShaderGUI"
}
