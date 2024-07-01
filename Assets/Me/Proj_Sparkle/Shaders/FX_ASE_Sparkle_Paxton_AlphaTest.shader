// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QF/AlphaTest"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_DiffueMap("Diffue Map", 2D) = "black" {}
		_Alphaweight("Alphatest", Range( 0 , 1)) = 1
		_Tint("Tint", Color) = (1,1,1,0)
		_sarMask("sarMask", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_ReflectMap("ReflectMap", 2D) = "black" {}
		_StarryMap("StarryMap", 2D) = "black" {}
		_SparkleMap("SparkleMap", 2D) = "black" {}
		_ShiningMask("ShiningMask", 2D) = "white" {}
		_ColorMap("ColorMap", 2D) = "white" {}
		_SpecularGloss("SpecularGloss", Range( 0.01 , 100)) = 100
		_SpecularPower("SpecularPower", Float) = 1
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		_ReflectPower("Reflect Power", Range( 0 , 1)) = 1
		_SparkHue("外层闪点饱和度", Range( 0 , 1)) = 0
		[HDR]_SparkleColor("外层闪点颜色", Color) = (1,1,1,0)
		_SparkIntenrity("外层闪点Intenrity", Range( 0 , 3)) = 1
		_SprkleSpeed01("SprkleSpeed01", Range( -1 , 1)) = 0.1
		_SprkleAmount("SprkleAmount", Range( 0 , 2)) = 0.8352941
		_SprkleVornojScale("外层闪点消融扭曲比例", Float) = 1
		_SprkleVornojOffset("外层闪点消融速度", Float) = 1
		_SprkleVornojStrength("外层闪点消融扭曲强度", Float) = 21.9
		_SparkSpec("外层闪点高光区域", Range( 0.02 , 50)) = 1
		_Height1("内层闪点01高度", Range( -15 , 15)) = 0
		_Starry1Intensity("内层闪点01强度", Range( 0 , 1)) = 1
		[HDR]_Starry1Color("内层闪点01Color", Color) = (1,1,1,0)
		_Starry1Tilling("内层闪点01Tilling", Float) = 20
		_Starry1Speed("内层闪点01闪烁速度", Float) = 1
		_Starry1Spec("内层闪点01高光区域", Range( 0.02 , 50)) = 1
		_Height02("内层闪点02高度", Range( -15 , 15)) = -1
		_Starry2Intensity("Starry2Intensity", Range( 0 , 1)) = 1
		[HDR]_Starry2Color("Starry2Color", Color) = (1,1,1,0)
		_Starry2Tilling("Starry2Tilling", Float) = 20
		_Starry2Speed("Starry2Speed", Float) = 1
		_Starry2Spec("Starry2Spec", Range( 0.02 , 50)) = 1
		_StarryPower("StarryPower", Float) = 20
		_StarryHue("StarryHue", Range( 0 , 1)) = 0
		_SkyTex("星空", 2D) = "black" {}
		_xingkongIntensity("星空颜色强度", Range( 0 , 5)) = 0
		_Height3("Height3", Range( -15 , 15)) = 0
		_xingkongHue("星空饱和度", Range( 0 , 1)) = 0
		_Tilling1("Tilling 1", Vector) = (1,1,0,0)
		_FCol("FCol", Color) = (1,1,1,0)
		[ASEEnd]_FresnaelPower("FresnaelPower", Range( 0.1 , 10)) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _FCol;
			float4 _SparkleMap_ST;
			float4 _Starry2Color;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float4 _SkyTex_ST;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _NormalMap_ST;
			float4 _Tint;
			float4 _SpecularColor;
			float2 _Tilling1;
			float _Height3;
			float _xingkongHue;
			float _SprkleAmount;
			float _SparkHue;
			float _xingkongIntensity;
			float _SparkSpec;
			float _SparkIntenrity;
			float _SprkleSpeed01;
			float _FresnaelPower;
			float _SprkleVornojScale;
			float _Starry2Spec;
			float _SprkleVornojStrength;
			float _ReflectPower;
			float _SpecularGloss;
			float _SpecularPower;
			float _Starry1Speed;
			float _Height1;
			float _Starry1Tilling;
			float _SprkleVornojOffset;
			float _StarryPower;
			float _Starry1Spec;
			float _Starry2Speed;
			float _Height02;
			float _Starry2Tilling;
			float _Starry2Intensity;
			float _StarryHue;
			float _Starry1Intensity;
			float _Alphaweight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffueMap;
			sampler2D _ReflectMap;
			sampler2D _NormalMap;
			sampler2D _sarMask;
			sampler2D _StarryMap;
			sampler2D _ColorMap;
			sampler2D _SparkleMap;
			sampler2D _ShiningMask;
			sampler2D _SkyTex;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_DiffueMap = IN.ase_texcoord3.xy * _DiffueMap_ST.xy + _DiffueMap_ST.zw;
				float4 tex2DNode308 = tex2D( _DiffueMap, uv_DiffueMap );
				float2 uv_NormalMap = IN.ase_texcoord3.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 tex2DNode365 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f );
				float3 NormalTangent366 = tex2DNode365;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal325 = NormalTangent366;
				float3 worldNormal325 = normalize( float3(dot(tanToWorld0,tanNormal325), dot(tanToWorld1,tanNormal325), dot(tanToWorld2,tanNormal325)) );
				float3 NDirWS314 = worldNormal325;
				float3 normalizeResult347 = normalize( mul( UNITY_MATRIX_V, float4( NDirWS314 , 0.0 ) ).xyz );
				float3 temp_output_344_0 = ( (normalizeResult347*0.5 + 0.5) + float3( 0,0,0 ) );
				float4 ReflectCol349 = ( tex2D( _ReflectMap, temp_output_344_0.xy ) * _ReflectPower );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 normalizeResult323 = normalize( ( ase_worldViewDir + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult321 = dot( normalizeResult323 , worldNormal325 );
				float2 uv_sarMask = IN.ase_texcoord3.xy * _sarMask_ST.xy + _sarMask_ST.zw;
				float4 tex2DNode367 = tex2D( _sarMask, uv_sarMask );
				float sarMask_g369 = tex2DNode367.g;
				float sarMask_r368 = tex2DNode367.r;
				float4 SpecularColor333 = ( pow( saturate( dotResult321 ) , ( _SpecularGloss * sarMask_g369 ) ) * _SpecularPower * _SpecularColor * sarMask_r368 );
				float mulTime237 = _TimeParameters.x * 0.01;
				float temp_output_238_0 = ( mulTime237 * _Starry1Speed );
				float2 texCoord370 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = SafeNormalize( ase_tanViewDir );
				float2 NoiseOffset446 = ( texCoord370 + ( _Height1 * (ase_tanViewDir).xy * 0.01 ) );
				float4 saferPower244 = abs( ( tex2Dlod( _StarryMap, float4( ( ( temp_output_238_0 + NoiseOffset446 ) * _Starry1Tilling ), 0, 0.0) ) + 0.2 ) );
				float4 temp_cast_3 = (_StarryPower).xxxx;
				float2 appendResult620 = (float2(( temp_output_238_0 * -1.0 ) , ( temp_output_238_0 * -1.1353 )));
				float4 saferPower245 = abs( ( 0.2 + tex2Dlod( _StarryMap, float4( ( _Starry1Tilling * ( float3( appendResult620 ,  0.0 ) + float3( NoiseOffset446 ,  0.0 ) + ( NormalTangent366 * 0.05 ) ) ).xy, 0, 0.0) ) ) );
				float4 temp_cast_7 = (_StarryPower).xxxx;
				float3 normalizeResult427 = normalize( NDirWS314 );
				float dotResult425 = dot( normalizeResult427 , ase_worldViewDir );
				float HalfNdotV431 = (dotResult425*0.5 + 0.5);
				float Thichness434 = HalfNdotV431;
				float saferPower455 = abs( Thichness434 );
				float4 StarryCol298 = ( ( pow( saferPower244 , temp_cast_3 ) * pow( saferPower245 , temp_cast_7 ) * _Starry1Color * _Starry1Intensity ) * pow( saferPower455 , _Starry1Spec ) );
				float mulTime698 = _TimeParameters.x * 0.01;
				float temp_output_697_0 = ( mulTime698 * _Starry2Speed );
				float2 NoiseOffset2711 = ( texCoord370 + ( _Height02 * (ase_tanViewDir).xy * 0.01 ) + 0.5 );
				float StarryLightOffset721 = 0.2;
				float4 saferPower681 = abs( ( tex2Dlod( _StarryMap, float4( ( ( temp_output_697_0 + NoiseOffset2711 ) * _Starry2Tilling ), 0, 0.0) ) + StarryLightOffset721 ) );
				float StarryPower722 = _StarryPower;
				float4 temp_cast_8 = (StarryPower722).xxxx;
				float2 appendResult706 = (float2(( temp_output_697_0 * -1.0 ) , ( temp_output_697_0 * -1.1353 )));
				float4 saferPower680 = abs( ( StarryLightOffset721 + tex2Dlod( _StarryMap, float4( ( _Starry2Tilling * ( float3( appendResult706 ,  0.0 ) + float3( NoiseOffset2711 ,  0.0 ) + ( NormalTangent366 * 0.05 ) ) ).xy, 0, 0.0) ) ) );
				float4 temp_cast_12 = (StarryPower722).xxxx;
				float saferPower683 = abs( Thichness434 );
				float4 StarryCol2692 = ( ( pow( saferPower681 , temp_cast_8 ) * pow( saferPower680 , temp_cast_12 ) * _Starry2Color * _Starry2Intensity ) * pow( saferPower683 , _Starry2Spec ) );
				float4 temp_cast_13 = (1.0).xxxx;
				float2 texCoord463 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode461 = tex2D( _ColorMap, texCoord463 );
				float4 lerpResult464 = lerp( temp_cast_13 , tex2DNode461 , _StarryHue);
				float4 temp_cast_14 = (8.0).xxxx;
				float2 texCoord575 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 center45_g2 = float2( 0.5,0.5 );
				float2 delta6_g2 = ( texCoord575 - center45_g2 );
				float angle10_g2 = ( length( delta6_g2 ) * _SprkleVornojStrength );
				float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
				float2 break40_g2 = center45_g2;
				float mulTime578 = _TimeParameters.x * 0.1;
				float2 temp_cast_15 = (( mulTime578 * _SprkleVornojOffset )).xx;
				float2 break41_g2 = temp_cast_15;
				float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
				float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
				float simplePerlin2D800 = snoise( appendResult44_g2*_SprkleVornojScale );
				simplePerlin2D800 = simplePerlin2D800*0.5 + 0.5;
				float4 temp_cast_16 = (simplePerlin2D800).xxxx;
				float2 uv_SparkleMap = IN.ase_texcoord3.xy * _SparkleMap_ST.xy + _SparkleMap_ST.zw;
				float mulTime560 = _TimeParameters.x * 0.1;
				float2 appendResult558 = (float2(0.0 , ( mulTime560 * _SprkleSpeed01 )));
				float4 temp_cast_17 = (6.0).xxxx;
				float saferPower616 = abs( Thichness434 );
				float4 SparkleCol504 = ( step( temp_cast_16 , ( _SprkleAmount * pow( tex2Dlod( _SparkleMap, float4( ( uv_SparkleMap + appendResult558 ), 0, 0.0) ) , temp_cast_17 ) ) ) * _SparkIntenrity * pow( saferPower616 , _SparkSpec ) * _SparkleColor );
				float4 temp_cast_18 = (1.0).xxxx;
				float4 lerpResult736 = lerp( temp_cast_18 , tex2DNode461 , _SparkHue);
				float4 temp_cast_19 = (8.0).xxxx;
				float2 uv_ShiningMask = IN.ase_texcoord3.xy * _ShiningMask_ST.xy + _ShiningMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShiningMask, uv_ShiningMask );
				float4 temp_cast_20 = (1.0).xxxx;
				float4 lerpResult793 = lerp( temp_cast_20 , tex2DNode461 , _xingkongHue);
				float4 temp_cast_21 = (8.0).xxxx;
				float2 uv_SkyTex = IN.ase_texcoord3.xy * _SkyTex_ST.xy + _SkyTex_ST.zw;
				float4 xingkong777 = ( pow( ( lerpResult793 + 0.2 ) , temp_cast_21 ) * tex2D( _SkyTex, ( ( uv_SkyTex + ( _Height3 * (ase_tanViewDir).xy * 0.01 ) ) * _Tilling1.x ) ) * _xingkongIntensity );
				float fresnelNdotV807 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode807 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV807, _FresnaelPower ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( tex2DNode308 * _Tint ) + ReflectCol349 + SpecularColor333 + ( ( ( ( StarryCol298 + StarryCol2692 ) * pow( ( lerpResult464 + 0.2 ) , temp_cast_14 ) ) + ( SparkleCol504 * pow( ( lerpResult736 + 0.2 ) , temp_cast_19 ) ) ) * tex2DNode556 ) + ( xingkong777 * tex2DNode556 ) + saturate( ( fresnelNode807 * _FCol ) ) ).rgb;
				float Alpha = tex2DNode308.a;
				float AlphaClipThreshold = _Alphaweight;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _FCol;
			float4 _SparkleMap_ST;
			float4 _Starry2Color;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float4 _SkyTex_ST;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _NormalMap_ST;
			float4 _Tint;
			float4 _SpecularColor;
			float2 _Tilling1;
			float _Height3;
			float _xingkongHue;
			float _SprkleAmount;
			float _SparkHue;
			float _xingkongIntensity;
			float _SparkSpec;
			float _SparkIntenrity;
			float _SprkleSpeed01;
			float _FresnaelPower;
			float _SprkleVornojScale;
			float _Starry2Spec;
			float _SprkleVornojStrength;
			float _ReflectPower;
			float _SpecularGloss;
			float _SpecularPower;
			float _Starry1Speed;
			float _Height1;
			float _Starry1Tilling;
			float _SprkleVornojOffset;
			float _StarryPower;
			float _Starry1Spec;
			float _Starry2Speed;
			float _Height02;
			float _Starry2Tilling;
			float _Starry2Intensity;
			float _StarryHue;
			float _Starry1Intensity;
			float _Alphaweight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffueMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_DiffueMap = IN.ase_texcoord2.xy * _DiffueMap_ST.xy + _DiffueMap_ST.zw;
				float4 tex2DNode308 = tex2D( _DiffueMap, uv_DiffueMap );
				

				float Alpha = tex2DNode308.a;
				float AlphaClipThreshold = _Alphaweight;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _FCol;
			float4 _SparkleMap_ST;
			float4 _Starry2Color;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float4 _SkyTex_ST;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _NormalMap_ST;
			float4 _Tint;
			float4 _SpecularColor;
			float2 _Tilling1;
			float _Height3;
			float _xingkongHue;
			float _SprkleAmount;
			float _SparkHue;
			float _xingkongIntensity;
			float _SparkSpec;
			float _SparkIntenrity;
			float _SprkleSpeed01;
			float _FresnaelPower;
			float _SprkleVornojScale;
			float _Starry2Spec;
			float _SprkleVornojStrength;
			float _ReflectPower;
			float _SpecularGloss;
			float _SpecularPower;
			float _Starry1Speed;
			float _Height1;
			float _Starry1Tilling;
			float _SprkleVornojOffset;
			float _StarryPower;
			float _Starry1Spec;
			float _Starry2Speed;
			float _Height02;
			float _Starry2Tilling;
			float _Starry2Intensity;
			float _StarryHue;
			float _Starry1Intensity;
			float _Alphaweight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffueMap;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_DiffueMap = IN.ase_texcoord.xy * _DiffueMap_ST.xy + _DiffueMap_ST.zw;
				float4 tex2DNode308 = tex2D( _DiffueMap, uv_DiffueMap );
				

				surfaceDescription.Alpha = tex2DNode308.a;
				surfaceDescription.AlphaClipThreshold = _Alphaweight;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _FCol;
			float4 _SparkleMap_ST;
			float4 _Starry2Color;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float4 _SkyTex_ST;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _NormalMap_ST;
			float4 _Tint;
			float4 _SpecularColor;
			float2 _Tilling1;
			float _Height3;
			float _xingkongHue;
			float _SprkleAmount;
			float _SparkHue;
			float _xingkongIntensity;
			float _SparkSpec;
			float _SparkIntenrity;
			float _SprkleSpeed01;
			float _FresnaelPower;
			float _SprkleVornojScale;
			float _Starry2Spec;
			float _SprkleVornojStrength;
			float _ReflectPower;
			float _SpecularGloss;
			float _SpecularPower;
			float _Starry1Speed;
			float _Height1;
			float _Starry1Tilling;
			float _SprkleVornojOffset;
			float _StarryPower;
			float _Starry1Spec;
			float _Starry2Speed;
			float _Height02;
			float _Starry2Tilling;
			float _Starry2Intensity;
			float _StarryHue;
			float _Starry1Intensity;
			float _Alphaweight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffueMap;


			
			float4 _SelectionID;


			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_DiffueMap = IN.ase_texcoord.xy * _DiffueMap_ST.xy + _DiffueMap_ST.zw;
				float4 tex2DNode308 = tex2D( _DiffueMap, uv_DiffueMap );
				

				surfaceDescription.Alpha = tex2DNode308.a;
				surfaceDescription.AlphaClipThreshold = _Alphaweight;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _FCol;
			float4 _SparkleMap_ST;
			float4 _Starry2Color;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float4 _SkyTex_ST;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _NormalMap_ST;
			float4 _Tint;
			float4 _SpecularColor;
			float2 _Tilling1;
			float _Height3;
			float _xingkongHue;
			float _SprkleAmount;
			float _SparkHue;
			float _xingkongIntensity;
			float _SparkSpec;
			float _SparkIntenrity;
			float _SprkleSpeed01;
			float _FresnaelPower;
			float _SprkleVornojScale;
			float _Starry2Spec;
			float _SprkleVornojStrength;
			float _ReflectPower;
			float _SpecularGloss;
			float _SpecularPower;
			float _Starry1Speed;
			float _Height1;
			float _Starry1Tilling;
			float _SprkleVornojOffset;
			float _StarryPower;
			float _Starry1Spec;
			float _Starry2Speed;
			float _Height02;
			float _Starry2Tilling;
			float _Starry2Intensity;
			float _StarryHue;
			float _Starry1Intensity;
			float _Alphaweight;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffueMap;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_DiffueMap = IN.ase_texcoord1.xy * _DiffueMap_ST.xy + _DiffueMap_ST.zw;
				float4 tex2DNode308 = tex2D( _DiffueMap, uv_DiffueMap );
				

				surfaceDescription.Alpha = tex2DNode308.a;
				surfaceDescription.AlphaClipThreshold = _Alphaweight;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;748;-9690.606,305.6093;Inherit;False;814.6475;537.4528;Normal;4;365;366;221;228;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;747;-7471.323,1721.283;Inherit;False;3226.023;3152.732;StarryColAll;18;711;446;729;671;670;440;669;370;717;720;668;718;716;713;712;676;615;765;StarryCol;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;746;-7509.381,324.8647;Inherit;False;2507.689;1199.531;SparkleColor;3;472;471;581;SparkleColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;745;-9669.827,3512.628;Inherit;False;1790.535;923.4119;SpecularColor;24;313;319;321;322;323;334;335;325;324;314;328;331;326;312;327;329;330;332;315;316;317;318;320;333;SpecularColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;615;-7384.187,2340.457;Inherit;False;2929.586;1142.796;StarryCol1;41;673;241;240;672;620;675;623;437;436;622;239;237;238;438;288;445;234;298;439;456;294;469;257;454;452;248;455;296;244;245;297;246;283;722;721;723;843;845;842;844;846;StarryCol1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;614;-4134.247,3609.132;Inherit;False;1701.077;1088.437;SparkleColAll;25;743;764;556;739;737;741;735;466;461;463;588;727;740;738;736;733;731;732;299;742;734;464;465;613;612;SparkleColAll;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;587;-7485.509,-406.0535;Inherit;False;1597.035;663.2364;TwirlMask;8;573;574;575;577;578;579;580;800;TwirlMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;337;-9682.95,2877.877;Inherit;False;1781.21;507.1108;ReflectMap;10;364;360;356;355;349;348;347;346;345;344;ReflectMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;338;-9677.702,2075.249;Inherit;False;1165.792;688.3389;Fresnel;6;363;362;361;359;354;353;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;389;-9705.618,1118.383;Inherit;False;2091.478;863.4287;RandomMap;18;371;379;388;387;386;378;380;385;372;376;377;375;374;381;383;384;382;373;RandomMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;422;-9662.356,4584.52;Inherit;False;1346.887;575.667;Thichness;7;434;431;427;426;425;424;423;Thichness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;471;-5831.09,519.5297;Inherit;False;728.1446;829.0439;LightDieValue;7;505;504;611;616;617;618;749;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;472;-7480.39,569.5578;Inherit;False;1587.962;614.7743;NoiseMask1;12;522;519;478;521;506;486;558;559;560;557;561;805;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;590;-9682.313,-318.7812;Inherit;False;1302.086;449.1232;reflectDir;12;602;601;600;599;598;597;596;595;594;593;592;591;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;676;-7359.511,3605.066;Inherit;False;2929.586;1142.796;StarryCol2;34;710;709;708;707;706;705;703;702;701;700;699;698;697;696;695;694;692;691;690;689;686;685;684;683;682;681;680;679;678;677;724;725;726;730;StarryCol2;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;753;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;754;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;755;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;756;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;757;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;758;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;759;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;760;-262.613,2720.567;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;579;-7226.842,44.84953;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;578;-7430.842,7.516117;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-5500.934,585.5201;Inherit;False;4;4;0;COLOR;1,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;677;-6463.558,3774.63;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;680;-5458.757,4263.956;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;681;-5458.279,3932.487;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;682;-5681.578,3932.948;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;691;-6241.823,4308.228;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;695;-6462.813,4373.967;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;696;-6268.631,3772.493;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;697;-7044.469,4062.612;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;700;-6722.357,4526.629;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;706;-6705.012,4336.172;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;707;-6900.892,4347.971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;708;-6877.9,4185.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;709;-7118.741,4199.79;Inherit;False;Constant;_Float15;Float 15;28;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;710;-7121.127,4348.703;Inherit;False;Constant;_Float23;Float 23;28;0;Create;True;0;0;0;False;0;False;-1.1353;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;698;-7269.18,3971.971;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;678;-5078.413,4151.885;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;724;-5650.215,4098.117;Inherit;False;722;StarryPower;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;725;-6013.215,4067.098;Inherit;False;721;StarryLightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;694;-6732.998,4043.453;Inherit;False;711;NoiseOffset2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;705;-6957.069,4530.548;Inherit;False;366;NormalTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;703;-6927.333,4637.851;Inherit;False;Constant;_Float19;Float 19;17;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;679;-5682.437,4263.775;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0.2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;683;-4966.82,4517.573;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;-5179.175,4513.042;Inherit;False;434;Thichness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;686;-4800.529,4356.733;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;726;-6462.397,4030.002;Inherit;False;723;StarryTilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;730;-6466,4106.412;Inherit;False;Property;_Starry2Tilling;Starry2Tilling;40;0;Create;True;0;0;0;False;0;False;20;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;699;-7279.137,4106.612;Inherit;False;Property;_Starry2Speed;Starry2Speed;41;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;560;-7434.986,912.9036;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;-7209.314,953.6575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;521;-6984.355,644.2978;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;685;-5267.414,4606.706;Inherit;False;Property;_Starry2Spec;Starry2Spec;42;0;Create;True;0;0;0;False;0;False;1;0.1;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;684;-5546.541,4353.958;Inherit;False;Property;_Starry2Color;Starry2Color;39;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.7204026,0.9526433,0.9748427,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;506;-6122.634,740.4598;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;612;-3063.24,3724.917;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;613;-3249.24,3680.917;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-3671.646,3799.675;Inherit;False;Constant;_aa;aa;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;464;-3495.762,3935.967;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;734;-3312.845,4157.155;Inherit;False;Constant;_Float32;Float 32;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;742;-2981.165,4112.331;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;732;-3473.47,4066.191;Inherit;False;Constant;_Float31;Float 31;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;731;-3315.583,4001.407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;733;-3158.803,3946.234;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;727;-3535.9,3739.916;Inherit;False;692;StarryCol2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;466;-3840.028,4108.867;Inherit;False;Property;_StarryHue;StarryHue;44;0;Create;True;0;0;0;False;0;False;0;0.551;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;743;-2837.533,3821.166;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;310;-2940.109,3174.552;Inherit;False;349;ReflectCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-2948.448,3278.884;Inherit;False;333;SpecularColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;423;-9455.632,4781.223;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;424;-9125.126,4726.925;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;425;-9268.485,4726.161;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;427;-9452.612,4675.777;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;426;-9639.468,4682.083;Inherit;False;314;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;-8890.21,4720.215;Inherit;False;HalfNdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;434;-8562.081,4716.288;Inherit;False;Thichness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;313;-8737.15,3779.643;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;319;-9505.993,4213.667;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;321;-8873.829,3748.629;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;322;-9216.827,3652.628;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;323;-9084.827,3651.628;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;334;-9464.958,3713.371;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;325;-9405.827,3911.629;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;324;-9619.827,3907.629;Inherit;False;366;NormalTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-9133.415,3906.384;Inherit;False;NDirWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-8918.162,3909.629;Inherit;False;Property;_SpecularGloss;SpecularGloss;12;0;Create;True;0;0;0;False;0;False;100;8;0.01;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-8819.636,4001.344;Inherit;False;369;sarMask_g;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;-8641.593,3952.419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;312;-8507.828,3809.629;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-8259.162,3811.629;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-8496.79,3903.197;Inherit;False;Property;_SpecularPower;SpecularPower;13;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;332;-8498.281,3973.95;Inherit;False;Property;_SpecularColor;SpecularColor;14;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;315;-9164.287,4175.606;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;-8947.378,4181.04;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;317;-8810.378,4183.04;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;318;-8612.61,4231.933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;-8488.004,4229.11;Inherit;False;HLambet;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;335;-9452.827,3562.628;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;330;-8464.13,4146.603;Inherit;False;368;sarMask_r;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;333;-8107.292,3806.839;Inherit;True;SpecularColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;367;-10244.37,3643.008;Inherit;True;Property;_sarMask;sarMask;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-9912.49,3643.445;Inherit;False;sarMask_r;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;369;-9914.922,3714.452;Inherit;False;sarMask_g;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;602;-8585.213,-198.6428;Inherit;False;ViewDirxy;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-9245.386,-254.3521;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;593;-9120.603,-250.5734;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;595;-8961.085,-203.5714;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;591;-8734.176,-196.624;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;-8766.946,-275.677;Inherit;False;ReflectDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;764;-2640.462,3934.858;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;692;-4658.271,4351.912;Inherit;False;StarryCol2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-3531.535,3658.465;Inherit;False;298;StarryCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;702;-6038.953,4282.375;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;701;-6043.026,3749.058;Inherit;True;Property;_TextureSample4;Texture Sample 4;7;0;Create;True;0;0;0;False;0;False;-1;None;a26bfdd73e091e949a32a0c695ec59e6;True;1;False;black;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;461;-3860.181,3906.009;Inherit;True;Property;_ColorMap;ColorMap;10;0;Create;True;0;0;0;False;0;False;-1;None;e4b38866534f2ca44a2e09b37542955a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;774;-2848.751,5119.105;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;599;-9637.029,-271.9392;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;596;-9401.604,-137.9614;Inherit;False;Constant;_Float41;Float 41;12;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;598;-9375.966,-62.95251;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;601;-9645.966,-118.2466;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.WorldNormalVector;600;-9636.966,-41.28571;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;597;-9231.637,-64.61916;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;365;-9640.606,355.6091;Inherit;True;Property;_NormalMap;NormalMap;5;0;Create;True;0;0;0;False;0;False;-1;None;7ef7fd4114f08bf419334b8753f4225a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;221;-9359.192,664.062;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-9116.963,360.3181;Inherit;False;NormalTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-9103.959,660.3983;Inherit;False;NDirWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;689;-5583.282,4537.006;Inherit;False;Property;_Starry2Intensity;Starry2Intensity;38;0;Create;True;0;0;0;False;0;False;1;0.596;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;770;-5058.106,5492.391;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;771;-5372.105,5579.059;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;769;-5326.105,5381.726;Inherit;False;World;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;767;-5498.329,5386.361;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;787;-4725.852,5492.076;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;772;-4876.108,5487.055;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;786;-5016.518,5600.745;Inherit;False;Property;_Offset;Offset;50;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;784;-3400.811,5032.847;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;780;-3563.022,5031.473;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;736;-3504.838,4337.957;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;738;-3317.921,4379.143;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;740;-3171.921,4372.477;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;735;-3746.007,4331.819;Inherit;False;Constant;_Float20;Float 20;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-3502.587,4478.478;Inherit;False;Constant;_Float21;Float 21;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-3327.921,4517.146;Inherit;False;Constant;_Float33;Float 33;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;793;-3440.181,4735.442;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;794;-3254.598,4735.299;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;795;-3108.598,4735.965;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;796;-3694.684,4700.641;Inherit;False;Constant;_Float3;Float 3;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;797;-3441.264,4849.967;Inherit;False;Constant;_Float4;Float 4;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;798;-3270.598,4851.299;Inherit;False;Constant;_Float5;Float 5;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;785;-3602.144,5122.852;Inherit;False;Property;_Tilling1;Tilling 1;49;0;Create;True;0;0;0;False;0;False;1,1;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;478;-6650.385,883.0982;Inherit;False;Constant;_Float22;Float 22;6;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;573;-7032.174,-173.8173;Inherit;True;Twirl;-1;;2;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;800;-6600.016,-159.8089;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;486;-6503.442,770.3563;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;805;-6328.953,609.6767;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;558;-7075.317,801.3247;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;557;-7412.199,789.9569;Inherit;False;Constant;_Float36;Float 36;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;504;-5323.187,579.6403;Inherit;False;SparkleCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;588;-3254.9,4250.412;Inherit;False;504;SparkleCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-2493.544,2985.865;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;305;-2887.986,2983.428;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;744;-3382.551,3214.157;Inherit;False;Property;_Tint;Tint;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.899371,0.899371,0.899371,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;814;-2956.77,2699.861;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;809;-3103.479,2699.817;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;811;-3343.611,2716.415;Inherit;False;Property;_FCol;FCol;51;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6099442,0.6840961,0.7547169,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;790;-3815.447,5051.831;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;816;-4043.49,5267.227;Inherit;False;URP Tangent To World Normal;-1;;3;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;791;-4050.109,5141.793;Inherit;False;Constant;_Float2;Float 2;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;789;-4044.976,5069.303;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;792;-4272.229,4989.555;Inherit;False;Property;_Height3;Height3;47;0;Create;True;0;0;0;False;0;False;0;-3;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;788;-4268.053,5068.919;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;519;-6828.298,614.4667;Inherit;True;Property;_SparkleMap;SparkleMap;8;0;Create;True;0;0;0;False;0;False;-1;None;55856094a7b022c46b054315c536643a;True;2;False;black;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;741;-3853.104,4407.523;Inherit;False;Property;_SparkHue;外层闪点饱和度;18;0;Create;False;0;0;0;False;0;False;0;0.14;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;-7490.965,1031.819;Inherit;False;Property;_SprkleSpeed01;SprkleSpeed01;21;0;Create;True;0;0;0;False;0;False;0.1;-0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;581;-6605.632,494.9564;Inherit;False;Property;_SprkleAmount;SprkleAmount;22;0;Create;True;0;0;0;False;0;False;0.8352941;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;580;-7432.172,88.18298;Inherit;False;Property;_SprkleVornojOffset;外层闪点消融速度;24;0;Create;False;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;577;-7430.264,-85.47833;Inherit;False;Property;_SprkleVornojStrength;外层闪点消融扭曲强度;25;0;Create;False;0;0;0;False;0;False;21.9;13.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;574;-6972.411,99.91129;Inherit;False;Property;_SprkleVornojScale;外层闪点消融扭曲比例;23;0;Create;False;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;775;-3240.976,5242.815;Inherit;False;Property;_xingkongIntensity;星空颜色强度;46;0;Create;False;0;0;0;False;0;False;0;0.03;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;799;-3826.448,4775.678;Inherit;False;Property;_xingkongHue;星空饱和度;48;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;611;-5799.547,964.6833;Inherit;False;Property;_SparkIntenrity;外层闪点Intenrity;20;0;Create;False;0;0;0;False;0;False;1;0.95;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;-5819.055,1108.072;Inherit;False;434;Thichness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;616;-5617.11,1106.665;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-9212.289,1167.958;Inherit;False;Constant;_Float16;Float 16;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;297;-5707.11,2999.167;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0.2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;244;-5482.953,2667.878;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;455;-5044.826,3255.633;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-4841.204,3097.459;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-6487.485,3109.359;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-7069.142,2798.004;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;237;-7316.548,2739.343;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;-6747.03,3262.021;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-6952.005,3373.242;Inherit;False;Constant;_Float18;Float 18;17;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;675;-6985.008,3285.537;Inherit;False;366;NormalTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;620;-6729.685,3071.565;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;672;-6925.565,3083.364;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-6902.573,2921.123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-7143.415,2935.182;Inherit;False;Constant;_Float13;Float 13;28;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;-7145.8,3084.095;Inherit;False;Constant;_Float11;Float 11;28;0;Create;True;0;0;0;False;0;False;-1.1353;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-6303.398,2759.439;Inherit;False;StarryTilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;298;-4698.944,3092.637;Inherit;False;StarryCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-6266.496,3047.62;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-8276.658,3160.955;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;349;-8119.608,3156.143;Inherit;False;ReflectCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;-9193.208,2293.871;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;354;-9009.602,2295.717;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-8819.46,2291.346;Inherit;True;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-9572.196,2230.883;Inherit;False;Property;_FrsnelIntensity;FrsnelIntensity;28;0;Create;True;0;0;0;False;0;False;1;0.321;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;359;-9574.433,2400.396;Inherit;True;Property;_FresnelMap;FresnelMap;4;0;Create;True;0;0;0;False;0;False;-1;None;357516955bc394d489bf350347f0cf95;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;364;-8595.469,3235.798;Inherit;False;Property;_ReflectPower;Reflect Power;15;0;Create;True;0;0;0;False;0;False;1;0.148;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;360;-8603.279,3017.608;Inherit;True;Property;_ReflectMap;ReflectMap;6;0;Create;True;0;0;0;False;0;False;-1;None;329a792ec57d56b42b61b6c449e42c32;True;0;False;black;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;345;-9007.188,2951.754;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-9404.386,2949.996;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;347;-9174.47,2949.349;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;356;-9621.694,3026.549;Inherit;False;314;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-9238.712,2505.728;Inherit;False;Property;_Float8;Float 8;29;0;Create;True;0;0;0;False;0;False;0.1;1.4;0.1;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;355;-9574.831,2931.991;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-8763.166,3017.617;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-5257.18,3251.102;Inherit;False;434;Thichness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;722;-5442.792,2877.489;Inherit;False;StarryPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;721;-5858.569,2845.829;Inherit;False;StarryLightOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;-6488.231,2510.021;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-6293.303,2507.884;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;-5706.251,2668.339;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;245;-5451.015,2972.654;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;437;-6070.292,3018.434;Inherit;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;469;-6177.256,2859.514;Inherit;False;Constant;_StarryLightOffset;StarryLightOffset;46;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-5103.085,2887.277;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;712;-5642.367,1866.829;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;-5822.671,1992.345;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;711;-5448.468,1866.328;Inherit;False;NoiseOffset2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;717;-6253.146,2065.493;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;436;-6067.699,2484.449;Inherit;True;Property;_StarryMap;StarryMap;7;0;Create;True;0;0;0;False;0;False;-1;None;a26bfdd73e091e949a32a0c695ec59e6;True;1;False;black;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;445;-6732.526,2803.986;Inherit;False;446;NoiseOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;718;-6013.802,2062.416;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;844;-7298.67,2515.347;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;842;-7102.667,2422.013;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;843;-7102.669,2523.347;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;846;-6958.668,2466.014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;845;-6808.403,2537.415;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;834;-8223.139,2729.908;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;840;-8065.138,2361.242;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;838;-8131.805,2533.908;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;839;-7995.806,2509.241;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;831;-7851.142,2345.908;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;832;-7817.808,2510.575;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;833;-7933.14,2726.574;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;837;-8231.809,2359.909;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;841;-7690.474,2489.909;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;835;-8448.475,2675.242;Inherit;False;Constant;_Vector1;Vector 1;52;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;819;-8448.077,2523.975;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;836;-8443.813,2355.909;Inherit;False;Constant;_Vector2;Vector 2;52;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;847;-7878.635,2184.55;Inherit;False;Derive Tangent Basis;-1;;4;fee816718ad753c4f9b25822c0d67438;0;1;5;FLOAT2;0,0;False;2;FLOAT3x3;0;FLOAT3x3;6
Node;AmplifyShaderEditor.InverseViewProjectionMatrixNode;829;-8490.479,2195.906;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ColorNode;749;-5454.868,1142.607;Inherit;False;Property;_SparkleColor;外层闪点颜色;19;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;2.242347,5.992157,4.368036,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;248;-5571.214,3089.35;Inherit;False;Property;_Starry1Color;内层闪点01Color;33;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.7644871,0.9294407,0.9685534,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;257;-5653.206,2891.027;Inherit;False;Property;_StarryPower;StarryPower;43;0;Create;True;0;0;0;False;0;False;20;10.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-6484.933,2801.349;Inherit;False;Property;_Starry1Tilling;内层闪点01Tilling;34;0;Create;False;0;0;0;False;0;False;20;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-7303.812,2842.004;Inherit;False;Property;_Starry1Speed;内层闪点01闪烁速度;35;0;Create;False;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-5345.42,3344.764;Inherit;False;Property;_Starry1Spec;内层闪点01高光区域;36;0;Create;False;0;0;0;False;0;False;1;27.2;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;-5567.956,3264.859;Inherit;False;Property;_Starry1Intensity;内层闪点01强度;32;0;Create;False;0;0;0;False;0;False;1;0.989;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;716;-6015.883,2162.402;Inherit;False;Constant;_Float24;Float 24;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;729;-5814.026,2157.098;Inherit;False;Constant;_Float30;Float 30;68;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;-5819.722,1205.033;Inherit;False;Property;_SparkSpec;外层闪点高光区域;26;0;Create;False;0;0;0;False;0;False;1;2.2;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-6293.075,1953.6;Inherit;False;Property;_Height02;内层闪点02高度;37;0;Create;False;0;0;0;False;0;False;-1;-5;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;386;-9490.609,1690.515;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;388;-9508.35,1796.428;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;371;-9655.743,1519.845;Inherit;False;Property;_RandomMapTillingSpeed;RandomMapTillingSpeed;16;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;-8051.327,1345.281;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;-9263.35,1754.428;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;377;-8276.005,1653.594;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;379;-9276.705,1520.734;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-8508.514,1584.911;Inherit;False;Constant;_Float17;Float 17;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;-8595.685,1867.112;Inherit;False;Property;_RandomWeight;RandomWeight;17;0;Create;True;0;0;0;False;0;False;0;0.474;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;382;-9220.667,1251.523;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-9418.061,1386.897;Inherit;False;Property;_VertexWeight;VertexWeight;27;0;Create;True;0;0;0;False;0;False;0;0.091;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;374;-8997.701,1247.124;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-8674.019,1200.05;Inherit;False;Property;_Height;Height;30;0;Create;True;0;0;0;False;0;False;1.640666;-1;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;381;-9415.965,1229.669;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;668;-6780.344,1780.298;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-6564.505,1765.331;Inherit;False;NoiseOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;380;-8603.984,1670.425;Inherit;True;Property;_RandomMap;RandomMap;11;0;Create;True;0;0;0;False;0;False;-1;None;db59a147e05cbd94993ee81b8097c979;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.InverseOpNode;830;-8053.142,2149.241;Inherit;False;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SwizzleNode;670;-7195.858,1975.262;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;-6914.264,1987.797;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.InverseTranspMVMatrixNode;821;-8492.475,2017.909;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.InverseViewMatrixNode;822;-8492.479,2101.907;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;385;-7869.599,1341.578;Inherit;False;CrystalHeight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;765;-7417.111,1886.849;Inherit;False;Property;_Height1;内层闪点01高度;31;0;Create;False;0;0;0;False;0;False;0;-3;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;671;-7186.325,2070.767;Inherit;False;Constant;_Float9;Float 9;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;815;-3689.413,2634.917;Inherit;False;Property;_FresnaelPower;FresnaelPower;52;0;Create;True;0;0;0;False;0;False;5;2.97;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;378;-8832.352,1697.663;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;773;-3255.064,5003.75;Inherit;True;Property;_SkyTex;星空;45;0;Create;False;0;0;0;False;0;False;-1;None;884ba83408ef6404fad7da1a386ff172;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;556;-2919.166,4232.106;Inherit;True;Property;_ShiningMask;ShiningMask;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;777;-2640.31,5114.813;Inherit;False;xingkong;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;848;-2195.277,3630.173;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;778;-2444.838,3668.807;Inherit;False;777;xingkong;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;807;-3360.311,2546.302;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;463;-4083.62,3932.398;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;779;-3817.202,4926.114;Inherit;False;0;773;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;370;-7415.009,1772.331;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;522;-7431.802,636.3474;Inherit;False;0;519;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;575;-7430.266,-208.145;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;440;-7407.943,1976.18;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;751;-1923.155,3260.121;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;True;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SamplerNode;308;-3419.598,2964.642;Inherit;True;Property;_DiffueMap;Diffue Map;0;0;Create;True;0;0;0;False;0;False;-1;None;28e5211da70604145a23909dac70588f;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;766;-2297.509,3228.968;Inherit;False;Property;_Alphaweight;Alphatest;1;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;752;-1934.567,3004.988;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;QF/AlphaTest;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;638412318563925137;Forward Only;0;0;Cast Shadows;0;638412315392944719;  Use Shadow Threshold;0;0;Receive Shadows;0;638412315401366939;GPU Instancing;0;638412315406847438;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;638412320374492683;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
WireConnection;579;0;578;0
WireConnection;579;1;580;0
WireConnection;505;0;506;0
WireConnection;505;1;611;0
WireConnection;505;2;616;0
WireConnection;505;3;749;0
WireConnection;677;0;697;0
WireConnection;677;1;694;0
WireConnection;680;0;679;0
WireConnection;680;1;724;0
WireConnection;681;0;682;0
WireConnection;681;1;724;0
WireConnection;682;0;701;0
WireConnection;682;1;725;0
WireConnection;691;0;730;0
WireConnection;691;1;695;0
WireConnection;695;0;706;0
WireConnection;695;1;694;0
WireConnection;695;2;700;0
WireConnection;696;0;677;0
WireConnection;696;1;730;0
WireConnection;697;0;698;0
WireConnection;697;1;699;0
WireConnection;700;0;705;0
WireConnection;700;1;703;0
WireConnection;706;0;708;0
WireConnection;706;1;707;0
WireConnection;707;0;697;0
WireConnection;707;1;710;0
WireConnection;708;0;697;0
WireConnection;708;1;709;0
WireConnection;678;0;681;0
WireConnection;678;1;680;0
WireConnection;678;2;684;0
WireConnection;678;3;689;0
WireConnection;679;0;725;0
WireConnection;679;1;702;0
WireConnection;683;0;690;0
WireConnection;683;1;685;0
WireConnection;686;0;678;0
WireConnection;686;1;683;0
WireConnection;559;0;560;0
WireConnection;559;1;561;0
WireConnection;521;0;522;0
WireConnection;521;1;558;0
WireConnection;506;0;800;0
WireConnection;506;1;805;0
WireConnection;612;0;613;0
WireConnection;612;1;733;0
WireConnection;613;0;299;0
WireConnection;613;1;727;0
WireConnection;464;0;465;0
WireConnection;464;1;461;0
WireConnection;464;2;466;0
WireConnection;742;0;588;0
WireConnection;742;1;740;0
WireConnection;731;0;464;0
WireConnection;731;1;732;0
WireConnection;733;0;731;0
WireConnection;733;1;734;0
WireConnection;743;0;612;0
WireConnection;743;1;742;0
WireConnection;424;0;425;0
WireConnection;425;0;427;0
WireConnection;425;1;423;0
WireConnection;427;0;426;0
WireConnection;431;0;424;0
WireConnection;434;0;431;0
WireConnection;313;0;321;0
WireConnection;321;0;323;0
WireConnection;321;1;325;0
WireConnection;322;0;335;0
WireConnection;322;1;334;0
WireConnection;323;0;322;0
WireConnection;325;0;324;0
WireConnection;314;0;325;0
WireConnection;326;0;328;0
WireConnection;326;1;331;0
WireConnection;312;0;313;0
WireConnection;312;1;326;0
WireConnection;327;0;312;0
WireConnection;327;1;329;0
WireConnection;327;2;332;0
WireConnection;327;3;330;0
WireConnection;315;0;325;0
WireConnection;315;1;319;0
WireConnection;316;0;315;0
WireConnection;317;0;316;0
WireConnection;318;0;317;0
WireConnection;320;0;318;0
WireConnection;333;0;327;0
WireConnection;368;0;367;1
WireConnection;369;0;367;2
WireConnection;602;0;591;0
WireConnection;592;0;599;0
WireConnection;592;1;596;0
WireConnection;593;0;592;0
WireConnection;595;0;593;0
WireConnection;595;1;597;0
WireConnection;591;0;595;0
WireConnection;594;0;595;0
WireConnection;764;0;743;0
WireConnection;764;1;556;0
WireConnection;692;0;686;0
WireConnection;702;1;691;0
WireConnection;701;1;696;0
WireConnection;461;1;463;0
WireConnection;774;0;795;0
WireConnection;774;1;773;0
WireConnection;774;2;775;0
WireConnection;598;0;601;0
WireConnection;598;1;600;0
WireConnection;597;0;598;0
WireConnection;221;0;365;0
WireConnection;366;0;365;0
WireConnection;228;0;221;0
WireConnection;770;0;769;0
WireConnection;770;1;771;0
WireConnection;769;0;767;0
WireConnection;787;0;772;0
WireConnection;787;1;786;0
WireConnection;772;0;770;0
WireConnection;784;0;780;0
WireConnection;784;1;785;1
WireConnection;780;0;779;0
WireConnection;780;1;790;0
WireConnection;736;0;735;0
WireConnection;736;1;461;0
WireConnection;736;2;741;0
WireConnection;738;0;736;0
WireConnection;738;1;737;0
WireConnection;740;0;738;0
WireConnection;740;1;739;0
WireConnection;793;0;796;0
WireConnection;793;1;461;0
WireConnection;793;2;799;0
WireConnection;794;0;793;0
WireConnection;794;1;797;0
WireConnection;795;0;794;0
WireConnection;795;1;798;0
WireConnection;573;1;575;0
WireConnection;573;3;577;0
WireConnection;573;4;579;0
WireConnection;800;0;573;0
WireConnection;800;1;574;0
WireConnection;486;0;519;0
WireConnection;486;1;478;0
WireConnection;805;0;581;0
WireConnection;805;1;486;0
WireConnection;558;0;557;0
WireConnection;558;1;559;0
WireConnection;504;0;505;0
WireConnection;304;0;305;0
WireConnection;304;1;310;0
WireConnection;304;2;311;0
WireConnection;304;3;764;0
WireConnection;304;4;848;0
WireConnection;304;5;814;0
WireConnection;305;0;308;0
WireConnection;305;1;744;0
WireConnection;814;0;809;0
WireConnection;809;0;807;0
WireConnection;809;1;811;0
WireConnection;790;0;792;0
WireConnection;790;1;789;0
WireConnection;790;2;791;0
WireConnection;789;0;788;0
WireConnection;519;1;521;0
WireConnection;616;0;617;0
WireConnection;616;1;618;0
WireConnection;297;0;469;0
WireConnection;297;1;437;0
WireConnection;244;0;296;0
WireConnection;244;1;257;0
WireConnection;455;0;456;0
WireConnection;455;1;452;0
WireConnection;454;0;246;0
WireConnection;454;1;455;0
WireConnection;288;0;620;0
WireConnection;288;1;445;0
WireConnection;288;2;622;0
WireConnection;238;0;237;0
WireConnection;238;1;239;0
WireConnection;622;0;675;0
WireConnection;622;1;623;0
WireConnection;620;0;240;0
WireConnection;620;1;672;0
WireConnection;672;0;238;0
WireConnection;672;1;673;0
WireConnection;240;0;238;0
WireConnection;240;1;241;0
WireConnection;723;0;234;0
WireConnection;298;0;454;0
WireConnection;439;0;234;0
WireConnection;439;1;288;0
WireConnection;348;0;360;0
WireConnection;348;1;364;0
WireConnection;349;0;348;0
WireConnection;353;0;363;0
WireConnection;353;1;359;0
WireConnection;354;0;353;0
WireConnection;354;1;362;0
WireConnection;361;0;354;0
WireConnection;359;1;344;0
WireConnection;360;1;344;0
WireConnection;345;0;347;0
WireConnection;346;0;355;0
WireConnection;346;1;356;0
WireConnection;347;0;346;0
WireConnection;344;0;345;0
WireConnection;722;0;257;0
WireConnection;721;0;469;0
WireConnection;283;0;238;0
WireConnection;283;1;445;0
WireConnection;438;0;283;0
WireConnection;438;1;234;0
WireConnection;296;0;436;0
WireConnection;296;1;469;0
WireConnection;245;0;297;0
WireConnection;245;1;257;0
WireConnection;437;1;439;0
WireConnection;246;0;244;0
WireConnection;246;1;245;0
WireConnection;246;2;248;0
WireConnection;246;3;294;0
WireConnection;712;0;370;0
WireConnection;712;1;713;0
WireConnection;712;2;729;0
WireConnection;713;0;720;0
WireConnection;713;1;718;0
WireConnection;713;2;716;0
WireConnection;711;0;712;0
WireConnection;436;1;438;0
WireConnection;718;0;717;0
WireConnection;844;0;841;0
WireConnection;842;0;844;0
WireConnection;843;0;844;1
WireConnection;846;0;842;0
WireConnection;846;1;843;0
WireConnection;845;0;846;0
WireConnection;845;1;844;2
WireConnection;834;0;835;0
WireConnection;840;0;837;0
WireConnection;838;0;837;0
WireConnection;838;1;835;0
WireConnection;839;0;838;0
WireConnection;831;0;840;0
WireConnection;831;1;819;0
WireConnection;832;0;839;0
WireConnection;832;1;819;0
WireConnection;833;0;834;0
WireConnection;833;1;819;0
WireConnection;837;0;836;0
WireConnection;837;1;835;0
WireConnection;841;0;831;0
WireConnection;841;1;832;0
WireConnection;841;2;833;0
WireConnection;386;0;371;0
WireConnection;372;0;384;0
WireConnection;372;1;374;0
WireConnection;372;2;377;0
WireConnection;387;0;386;0
WireConnection;387;1;388;0
WireConnection;377;0;375;0
WireConnection;377;1;380;0
WireConnection;377;2;376;0
WireConnection;379;0;371;0
WireConnection;382;0;381;1
WireConnection;374;0;373;0
WireConnection;374;1;382;0
WireConnection;374;2;383;0
WireConnection;668;0;370;0
WireConnection;668;1;669;0
WireConnection;446;0;668;0
WireConnection;380;1;378;0
WireConnection;670;0;440;0
WireConnection;669;0;765;0
WireConnection;669;1;670;0
WireConnection;669;2;671;0
WireConnection;385;0;372;0
WireConnection;378;0;379;0
WireConnection;378;1;387;0
WireConnection;773;1;784;0
WireConnection;777;0;774;0
WireConnection;848;0;778;0
WireConnection;848;1;556;0
WireConnection;807;3;815;0
WireConnection;752;2;304;0
WireConnection;752;3;308;4
WireConnection;752;4;766;0
ASEEND*/
//CHKSM=1FC4E81D207FF0C20A561D75FBFB2A9B2489C145