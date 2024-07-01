Shader "QF/NssFX/NssFX_ASE/FX_ASE_FireHair_Paxton_code"
{
	Properties
	{
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainTexCol("MainTexCol", Color) = (0,0,0,0)
        [Space(20)]
		[NoScaleOffset]_MaskMap("Mask", 2D) = "white" {}
		_DissolveMap("DissolveMap", 2D) = "white" {}
		_Maindissolve("消融强度", Range( 0 , 2)) = 0.9
		_DissolveHard("边缘硬度", Range( 0 , 0.4)) = 0.3
		_Buring("燃烧强度", Range( 0 , 1)) = 0.22
        [Space(20)]
		_Noisetex("颜色扰动", 2D) = "white" {}
		_NoiseContrast("扰动对比度", Range( 0 , 0.5)) = 0.02941176
		_ColNoiseIntensity("ColNoiseIntensity", Range( 0 , 1)) = 1

        [Space(20)]
		_NoiseMap("位移扰动", 2D) = "white" {}
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


		HLSLINCLUDE
		#define GAMMA_TEXTURE
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"

		ENDHLSL


		

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend Off
			Cull Off
			ZWrite On
			ZTest LEqual


			HLSLPROGRAM


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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
			};

			sampler2D _NoiseMap;
			sampler2D _MainTex;
			sampler2D _Noisetex;
			sampler2D _MaskMap;
			sampler2D _DissolveMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseMap_ST;
			float4 _DissolveMap_ST;
			float4 _MainTexCol;
			float4 _Noisetex_ST;
			float _NoiseContrast;
			float _Buring;
			float _VertexOffsetFactor4;
			float _ColorEdgeIntensity;
			float _VertexOffsetTimeZoomer;
			float _NormalOffset;
			float _Maindissolve;
			float _DissolveHard;
			float _VertexOffsetScrollSpeed;
			float _ColNoiseIntensity;
			float _Flare;
			CBUFFER_END


			v2f vert(appdata v )
			{
				v2f o;
				float2 uv_NoiseMap = v.ase_texcoord.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _NoiseMap, float4( ( uv_NoiseMap + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) *  v.color.r );
				
				float3 PosOS528 = ( v.vertex.xyz + VertexOffset4367 );
				float3 customSurfaceDepth487 = PosOS528;
				float customEye487 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth487 )).z;
				o.ase_texcoord1.z = customEye487;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.vertex;
				o.ase_color = v.color;
				
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				vertexValue = VertexOffset4367;

				//***********
				v.vertex.xyz += vertexValue;
				//***********

				o.vertex = TransformObjectToHClip(v.vertex);

				return o;
			}

			half4 frag(v2f i ) : SV_Target
			{

				float2 texCoord601 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_Noisetex = i.ase_texcoord1.xy * _Noisetex_ST.xy ;
				float4 Var_Mask = tex2D( _MaskMap, i.ase_texcoord1.xy );
				float MaskA282 = Var_Mask.a; //******参与Noise扰动的Mask
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( _Noisetex_ST.zw * _TimeParameters.x ) ) ).r - _NoiseContrast ) ) * 1.0 * MaskA282 );
				float4 MainCol248 = ( tex2D( _MainTex, ( texCoord601 + ( _ColNoiseIntensity * Noise94 ) ) ) * _MainTexCol );

				//Alpha
				float2 uv_DissolveMap = i.ase_texcoord1.xy * _DissolveMap_ST.xy ;
				float MaskR81 = Var_Mask.r; //头发Alpha
				float MaskG80 = Var_Mask.g; //头发消融Alpha
				float lerpResult462 = lerp( MaskR81 , MaskG80 , _Buring);
				float MaskB276 = Var_Mask.b; //
				float lerpResult589 = lerp( lerpResult462 , 1.0 , MaskB276);
				float BurnedTerm566 = lerpResult589;
				float saferPower440 = abs( BurnedTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( BurnedTerm566 , 0.3 ) , _Flare);
				float clampResult588 = clamp( ( tex2D( _DissolveMap, ( ( float2( 0,0 ) + uv_DissolveMap ) + ( _DissolveMap_ST.zw * _TimeParameters.x ) ) ).r * lerpResult541 ) , 0.0 , 1.0 );
				float clampResult587 = clamp( temp_output_440_0 , 0.0 , 1.0 );
				float temp_output_442_0 = ( clampResult588 + clampResult587 );
				float lerpResult593 = lerp( step( _Maindissolve , temp_output_442_0 ) , MaskR81 , MaskB276);
				// float lerpResult593 = lerp( smoothstep( _Maindissolve , _Maindissolve + (0.5 - _DissolveHard ) , temp_output_442_0 ) , MaskR81 , MaskB276);

				float Alpha = lerpResult593;
				float AlphaClipThreshold = 0.5;

				clip(Alpha - AlphaClipThreshold);

				float4 c = 1;
				c.xyz = MainCol248.rgb ;

				

				return NSS_OUTPUT_COLOR_SPACE(c);
			}
			ENDHLSL
		}
	}
	Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	
}

