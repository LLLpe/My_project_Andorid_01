Shader "QF/NssFX/NssFX_ASE/FX_ASE_PixelFlow_Paxton_code"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BaseMap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Pix1Map("Pix1Map", 2D) = "black" {}
		_Pix2Map("Pix2Map", 2D) = "black" {}
		_SquareMap("SquareMap", 2D) = "white" {}
		_PixTilling("PixTilling", Int) = 6
		_seed1("seed1", Vector) = (0,0,0,0)
		_seed2("seed2", Vector) = (0,2.4,0,0)
		_Speed("Speed", Vector) = (0,0,0,0)
		_ReflectMap("ReflectMap", 2D) = "black" {}
		_FresnelMap("FresnelMap", 2D) = "black" {}
		_Matcap("Matcap", 2D) = "black" {}
		_ReflectIntensity("ReflectIntensity", Range( 0 , 1)) = 1
		_FrsnelIntensity("FrsnelIntensity", Range( 0 , 1)) = 1
		_FresnelPower("FresnelPower", Range( 0.1 , 16)) = 1
		_Light("Light", Float) = 1
		_Dissolve("Dissolve", Range( -1 , 1)) = 0.001407384
		_DissolveTail("DissolveTail", Range( 0 , 4)) = 2.143974
		_DissolvePower("DissolvePower", Range( 0.1 , 10)) = 2.143974
		_DissolveIntensity("DissolveIntensity", Range( 0.1 , 20)) = 2.143974
		_DissolveBalance("DissolveBalance", Range( -1 , 1)) = 0
		_RootAlpha("RootAlpha", Range( 0 , 1)) = 1
		_MidCol("MidCol", Color) = (0.6320754,0.6320754,0.6320754,0)
		_MidAlpha("MidAlpha", Range( 0 , 1)) = 0
		_TailCol("TailCol", Color) = (0.427451,0.9803922,0.9803922,0)
		[HDR]_ShadowCol("ShadowCol", Color) = (0.6320754,0.6320754,0.6320754,0)
		_ShadowDissolve("ShadowDissolve", Range( 0 , 5)) = 2.381026
		_ShadowBalancee("ShadowBalancee", Range( -1 , 1)) = 1
		_ShadowAlpha("ShadowAlpha", Range( 0 , 1)) = 1
		_EdgeScale("EdgeScale", Range( 0 , 1)) = 0.1
		[HDR]_EdgeCol("EdgeCol", Color) = (0.4978195,0.741802,0.9339623,0)
		_EdgeAlpha("EdgeAlpha", Range( 0 , 1)) = 1
		_SparkTex("SparkTex", 2D) = "white" {}
		[HDR]_StarCol("StarCol", Color) = (1,1,1,0)
		_StarIntensity("StarIntensity", Range( 0 , 50)) = 1
		_StarPower("StarPower", Range( 0 , 20)) = 1
		_StarTillingSpeed("StarTillingSpeed", Vector) = (1,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		HLSLINCLUDE
		// #define GAMMA_TEXTURE
		// #include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		// #include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"
		// #include "../../AdvCarCommon.cginc"	
		ENDHLSL
		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		Pass
		{
			Name "SFXShader"

			HLSLPROGRAM

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"



			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 tangent : TANGENT;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 posCS : SV_POSITION;
				float3 posWS : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 color : COLOR;
				float4 tangentWS : TEXCOORD2;
				float4 normalWS : TEXCOORD3;
				float4 binormalWS : TEXCOORD4;
			};

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _BaseMap;
			sampler2D _SquareMap;
			sampler2D _Matcap;
			sampler2D _NormalMap;
			sampler2D _FresnelMap;
			sampler2D _SparkTex;
			sampler2D _ReflectMap;


			
			CBUFFER_START( UnityPerMaterial )
			float4 _StarTillingSpeed;
			float4 _EdgeCol;
			float4 _MidCol;
			float4 _NormalMap_ST;
			float4 _BaseMap_ST;
			float4 _ShadowCol;
			float4 _StarCol;
			float4 _SquareMap_ST;
			float4 _TailCol;
			float4 _Pix2Map_ST;
			float4 _Pix1Map_ST;
			float2 _seed1;
			float2 _Speed;
			float2 _seed2;
			float _StarIntensity;
			float _FresnelPower;
			float _StarPower;
			float _FrsnelIntensity;
			float _ReflectIntensity;
			float _Light;
			float _DissolveTail;
			float _EdgeScale;
			float _DissolveBalance;
			float _DissolveIntensity;
			float _RootAlpha;
			float _DissolvePower;
			float _ShadowDissolve;
			float _ShadowBalancee;
			float _Dissolve;
			int _PixTilling;
			float _ShadowAlpha;
			float _EdgeAlpha;
			float _MidAlpha;
			CBUFFER_END


			v2f vert(appdata v )
			{
				v2f o;

				o.tangentWS.xyz = TransformObjectToWorldDir(v.tangent.xyz);
				o.normalWS.xyz = TransformObjectToWorldNormal(v.ase_normal);
				o.binormalWS.xyz = normalize(cross( o.normalWS, o.tangentWS ) *  v.tangent.w);
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.tangentWS.w = 0;
				o.normalWS.w = 0;
				o.binormalWS.w = 0;

				o.uv.xy = v.uv.xy;
				o.uv.zw = v.uv1.xy;
				o.color = v.color;
				
				o.posCS = TransformObjectToHClip(v.vertex);
				o.posWS = mul(UNITY_MATRIX_M, v.vertex).xyz;
				return o;
			}

			real4 frag(v2f i ) : SV_Target
			{

				float2 FlowSpeed = ( _Speed * _Time.x  );
				
				float2 uv2_Pix1Map = i.uv.zw * _Pix1Map_ST.xy + _Pix1Map_ST.zw  ;	
				float3 TestCol = tex2D(_Pix1Map , uv2_Pix1Map + FlowSpeed);

				float var_Pix1Map = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed ) * _PixTilling ) ) / _PixTilling ) + float2( 0,0.01 ) + ( _seed1 * _Time.x  ) ) ).r - _Dissolve );
				var_Pix1Map = clamp( var_Pix1Map , 0.0 , 1.0 );
				float2 uv2_Pix2Map = i.uv.zw * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _Time.x ;
				float4 var_Pix2Map = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed + uv2_Pix2Map ) * _PixTilling ) ) / _PixTilling ) + ( _seed2 * mulTime109 ) ) );
				float pixStepColor = step( var_Pix1Map , var_Pix2Map.r );

				float gradient_x = abs( pow( i.uv.x , 1.8 ) );
				gradient_x = pow( gradient_x , _DissolvePower );
				float MaskShadow00 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * gradient_x ) ) , 0.0 , 1.0 );
				float MaskShadow = clamp( ( _ShadowAlpha * ( ( pixStepColor * i.color.r ) * ( 1.0 - MaskShadow00 ) ) ) , 0.0 , 1.0 );

				float3 var_basecolor = (tex2D( _BaseMap, i.uv.xy )).rgb;
				float rootAlpha = clamp( ( i.color.g * _RootAlpha ) , 0.0 , 1.0 );

				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * gradient_x ) , _DissolveTail);
				float clampResult523 = clamp( ( var_Pix2Map.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );

				float2 uv2_SquareMap = i.uv.zw * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 var_squareMap = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed ) * _PixTilling ) );
				float pixStepSquareColor = pixStepColor * step( clampResult523 , var_squareMap.r );
				
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep(  var_squareMap.r , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * i.color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMask = clampResult487 * pixStepSquareColor;
				float MaskPxl = clamp( ( ( i.color.r * pixStepSquareColor ) - EdgeMask ) , 0.0 , 1.0 );

				float3 EdgeCol = clamp( ( EdgeMask * (_EdgeCol).rgb ) , float3( 0,0,0 ) , float3( 6.0, 6.0, 6.0 ) );

				float3 var_normalMap = UnpackNormalScale( tex2D( _NormalMap, i.uv.xy ), 1.0f );
				float3 normalWS = i.normalWS.xyz;
				float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
				float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
				float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );

				normalWS = normalize( float3(dot(tanToWorld0,var_normalMap), dot(tanToWorld1,var_normalMap), dot(tanToWorld2,var_normalMap)) );

				//MatCap
				float3 normalVS = normalize( mul( UNITY_MATRIX_V, float4( normalWS , 0.0 ) ).xyz );
				float2 MatCapUV = ((normalVS).xy*0.5 + 0.5) ;
				float3 MatCapCol = (tex2D( _Matcap, MatCapUV )).rgb;
				float3 normalizeResult340 = normalize( mul( UNITY_MATRIX_V, float4( normalWS , 0.0 ) ).xyz );

				//Fresnal
				float3 Fresnel = clamp( pow( ( _FrsnelIntensity * (tex2D( _FresnelMap, MatCapUV )).rgb ) , _FresnelPower ) , float3( 0,0,0 ) , float3( 1,1,0 ) );

				//Star
				float mulTime267 = _Time.x * ( (_StarTillingSpeed).zw * 0.01 ).x;
				float2 temp_cast_9 = (mulTime267).xx;
				float2 texCoord259 = i.uv.xy * (_StarTillingSpeed).xy + temp_cast_9;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - i.posWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 saferPower253 = abs( ( (tex2D( _SparkTex, texCoord259 )).rgb * (tex2D( _SparkTex, ( ( texCoord259 + ( ( (ase_worldViewDir).xy / 20.0 ) + ( (normalWS).xy / 20.0 ) ) ) * 1.5 ) )).rgb * _StarIntensity ) );
				float3 SparkCol = clamp( ( (_StarCol).rgb * pow( saferPower253 , _StarPower ) ) , float3( 0,0,0 ) , float3( 20,20,20 ) );

				float3 ReflectCol338 = ( (tex2D( _ReflectMap, MatCapUV )).rgb * _ReflectIntensity );

				float MaskMid = clamp( ( ( 1.0 - max( i.color.r , i.color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float3 MidCol = ( (_MidCol).rgb * MaskMid * (tex2D( _BaseMap, i.uv.xy )).rgb );

				float3 LightCol463 = ( MatCapCol + Fresnel + SparkCol + ReflectCol338 );
				float Alpha = clamp( ( MaskShadow + rootAlpha + MaskPxl + MaskMid + EdgeMask ) , 0.0 , 1.0 );
				float4 finalColor = (float4((( _Light * ( max( ( MaskShadow * (_ShadowCol).rgb * var_basecolor ) , ( ( rootAlpha * var_basecolor ) + ( var_basecolor * MaskPxl * (_TailCol).rgb ) ) ) + EdgeCol + LightCol463 + MidCol ) )).xyz , Alpha));
				

				float4 c = 1;
				c.xyz = TestCol;
				return finalColor;
			}
			ENDHLSL
		}
	}

}