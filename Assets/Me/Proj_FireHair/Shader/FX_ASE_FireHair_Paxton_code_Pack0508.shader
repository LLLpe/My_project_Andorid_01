Shader "QF/NssFX/NssFX_ASE/FX_ASE_FireHair_Paxton_code"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainTexCol("MainTexCol", Color) = (0,0,0,0)
		_DissolveMap("DissolveMap", 2D) = "white" {}
		_MainTex01U_Speed("MainTex01U移动", Float) = 0
		_MainTex01_V_Speed("MainTex01V移动", Float) = -0.5
		_Maindissolve("Maindissolve", Range( 0 , 2)) = 0.7741094
		_Buring("Buring", Range( 0 , 1)) = 0.4041814
		_Noisetex("Noise图", 2D) = "white" {}
		_mainspeedU2("Noise图U移动", Float) = 0
		_mainspeedV2("Noise图V移动", Float) = 0
		_NoiseContrast("扰动对比度", Range( 0 , 0.5)) = 0.02941176
		_ColNoiseIntensity("ColNoiseIntensity", Range( 0 , 1)) = 1
		_MaskRG("MaskRG", 2D) = "white" {}
		_NoiseMap("NoiseMap", 2D) = "white" {}
		_VertexOffsetTimeZoomer("VertexOffsetTimeZoomer", Float) = 0
		_VertexOffsetScrollSpeed("VertexOffsetScrollSpeed", Float) = 0
		_VertexOffsetFactor4("VertexOffsetFactor4", Float) = 0
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_ColorEdgeIntensity("ColorEdgeIntensity", Range( 0 , 1)) = 1
		_NormalOffset("NormalOffset", Range( -10 , 10)) = 0.01
		_Flare("尾焰", Range( 0 , 1)) = 0
		[Toggle]_OneMinusR("One Minus R", Float) = 0

	}

	SubShader
	{
		
		LOD 100

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque"  }
		// Cull Off
		// AlphaToMask Off


		HLSLINCLUDE
		#define GAMMA_TEXTURE
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"
		// #include "../../AdvCarCommon.cginc"	

		ENDHLSL


		// Blend SrcAlpha OneMinusSrcAlpha
		// Cull Off
		// ZWrite On
		// ZTest LEqual
		

		
		Pass
		{
			// Name "Forward"
			// Tags { "LightMode"="UniversalForwardOnly" }

			Blend Off
			// AlphaToMask Off
			Cull Off
			// ColorMask RGBA
			ZWrite On
			ZTest LEqual
			// Offset 0 , 0

			// Name "SFXShader"

			HLSLPROGRAM

			// #define ASE_SRP_VERSION -1
			// #define REQUIRE_DEPTH_TEXTURE 1


			// #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			// #define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			// #endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				// UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				// #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				// float3 worldPos : TEXCOORD0;
				// #endif
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				// UNITY_VERTEX_INPUT_INSTANCE_ID
				// UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _NoiseMap;
			sampler2D _MainTex;
			sampler2D _Noisetex;
			sampler2D _MaskRG;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _DissolveMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseMap_ST;
			float4 _DissolveMap_ST;
			float4 _Color0;
			float4 _MainTexCol;
			float4 _Noisetex_ST;
			float4 _MaskRG_ST;
			float _OneMinusR;
			float _mainspeedU2;
			float _mainspeedV2;
			float _NoiseContrast;
			float _Buring;
			float _VertexOffsetFactor4;
			float _ColorEdgeIntensity;
			float _VertexOffsetTimeZoomer;
			float _NormalOffset;
			float _Maindissolve;
			float _VertexOffsetScrollSpeed;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _ColNoiseIntensity;
			float _Flare;
			CBUFFER_END


			v2f vert(appdata v )
			{
				v2f o;
				// UNITY_SETUP_INSTANCE_ID(v);
				// UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				// UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 uv_NoiseMap = v.ase_texcoord.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _NoiseMap, float4( ( uv_NoiseMap + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.color.r ) ):( v.color.r )) );
				
				float3 PosOS528 = ( v.vertex.xyz + VertexOffset4367 );
				float3 customSurfaceDepth487 = PosOS528;
				float customEye487 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth487 )).z;
				o.ase_texcoord1.z = customEye487;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.vertex;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				vertexValue = VertexOffset4367;

				//***********
				v.vertex.xyz += vertexValue;
				//***********

				o.vertex = TransformObjectToHClip(v.vertex);

				// #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				// o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
				// #endif
				return o;
			}

			half4 frag(v2f i ) : SV_Target
			{
				// UNITY_SETUP_INSTANCE_ID(i);
				// UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				half4 finalColor;
				// #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				// float3 WorldPosition = i.worldPos;
				// #endif
				float2 texCoord601 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_Noisetex = i.ase_texcoord1.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float2 uv_MaskRG = i.ase_texcoord1.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float4 Var_Mask = tex2D( _MaskRG, uv_MaskRG );
				float MaskA282 = Var_Mask.a; //******参与Noise扰动的Mask
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - _NoiseContrast ) ) * 1.0 * MaskA282 );
				float4 MainCol248 = ( tex2D( _MainTex, ( texCoord601 + ( _ColNoiseIntensity * Noise94 ) ) ) * _MainTexCol );
				float4 EdgeColor497 = ( _ColorEdgeIntensity * _Color0 );
				float3 objToViewDir514 = mul( UNITY_MATRIX_IT_MV, float4( i.ase_normal, 0 ) ).xyz;
				float3 appendResult515 = (float3(objToViewDir514));
				float2 uv_NoiseMap = i.ase_texcoord1.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2D( _NoiseMap, ( uv_NoiseMap + mulTime359 ) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - i.ase_color.r ) ):( i.ase_color.r )) );
				float3 PosOS528 = ( i.ase_texcoord2.xyz + VertexOffset4367 );
				float3 objToView509 = mul( UNITY_MATRIX_MV, float4( PosOS528, 1 ) ).xyz;
				float3 appendResult505 = (float3(objToView509));
				float3 temp_output_507_0 = ( ( _NormalOffset * appendResult515 ) + appendResult505 );
				float4 appendResult504 = (float4(temp_output_507_0 , 1.0));
				float4 computeScreenPos512 = ComputeScreenPos( mul( UNITY_MATRIX_P, appendResult504 ) );
				computeScreenPos512 = computeScreenPos512 / computeScreenPos512.w;
				computeScreenPos512.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos512.z : computeScreenPos512.z* 0.5 + 0.5;
				float eyeDepth488 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( computeScreenPos512.xy ),_ZBufferParams);
				float customEye487 = i.ase_texcoord1.z;
				float EdgeMask501 = saturate( ( eyeDepth488 - customEye487 ) );
				// float4 lerpResult502 = lerp( MainCol248 , EdgeColor497 , EdgeMask501);
				float4 lerpResult502 = lerp( MainCol248 , EdgeColor497 , 0);
				float2 uv_DissolveMap = i.ase_texcoord1.xy * _DissolveMap_ST.xy + _DissolveMap_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float MaskR81 = Var_Mask.r; //头发Alpha
				float MaskG80 = Var_Mask.g; //头发消融Alpha
				float lerpResult462 = lerp( MaskR81 , MaskG80 , _Buring);
				float MaskB276 = Var_Mask.b; //
				float lerpResult589 = lerp( lerpResult462 , 1.0 , MaskB276);
				float BurnedTerm566 = lerpResult589;
				float saferPower440 = abs( BurnedTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( BurnedTerm566 , 0.3 ) , _Flare);
				float clampResult588 = clamp( ( tex2D( _DissolveMap, ( ( float2( 0,0 ) + uv_DissolveMap ) + ( appendResult99 * _TimeParameters.x ) ) ).r * lerpResult541 ) , 0.0 , 1.0 );
				float clampResult587 = clamp( temp_output_440_0 , 0.0 , 1.0 );
				float temp_output_442_0 = ( clampResult588 + clampResult587 );
				float lerpResult593 = lerp( step( _Maindissolve , temp_output_442_0 ) , MaskR81 , MaskB276);
				float Alpha01254 = lerpResult593;

				float4 c = 1;
				c.xyz = lerpResult502.rgb ;

				float Alpha = Alpha01254;
				float AlphaClipThreshold = 0.5;

				clip(Alpha - AlphaClipThreshold);
				

				return NSS_OUTPUT_COLOR_SPACE(c);
				// return c;
			}
			ENDHLSL
		}
	}
	// CustomEditor "ASEMaterialInspector"
	Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	
}

