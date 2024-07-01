// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QF/NssFX/NssFX_ASE/FX_ASE_Sparkle_Paxton_pack240124"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_DiffueMap("Diffue Map", 2D) = "white" {}
		_Alphaweight("Alpha权重", Range( 0 , 1)) = 1
		_Tint("Tint", Color) = (1,1,1,0)
		_sarMask("sarMask", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_ReflectMap("ReflectMap", 2D) = "black" {}
		_SparkleMap("SparkleMap", 2D) = "black" {}
		_StarryMap("StarryMap", 2D) = "black" {}
		_ShiningMask("ShiningMask", 2D) = "white" {}
		_ColorMap("ColorMap", 2D) = "white" {}
		_SpecularGloss("SpecularGloss", Range( 0.01 , 100)) = 100
		_SpecularPower("SpecularPower", Float) = 1
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		_ReflectPower("Reflect Power", Range( 0 , 1)) = 1
		_SparkIntenrity("外层闪点强度", Range( 0 , 10)) = 1
		[HDR]_SparkleColor("外层闪点颜色", Color) = (1,1,1,0)
		_SparkHue("外层闪点饱和度", Range( 0 , 1)) = 0
		_SparkleTilling("外层闪点Tilling", Float) = 1
		_SparkleOffsetSpeed("外层闪点偏移闪烁速度[0,1]", Float) = 0.5
		_GlitterPower("GlitterPower", Float) = 1
		_GlitterContrast("GlitterContrast", Float) = 1
		_SparkleWeight("外层闪点消融权重", Range( 0 , 1)) = 1
		_SprkleShinSpeed("外层闪点消融闪烁速度", Float) = 1
		_SprkleVornojStrength("外层闪点消融扭曲强度", Float) = 21.9
		_SparkSpec("外层闪点高光区域", Range( 0.02 , 50)) = 1
		_Starry1Intensity("内层闪点强度", Range( 0 , 1)) = 1
		[HDR]_Starry1Color("内层闪点颜色", Color) = (1,1,1,0)
		_Starry1Tilling("内层闪点Tilling", Float) = 20
		_StarryFlowSpeed("内层闪点流动速度", Range( 0 , 1)) = 1
		_SparkshinFreq("内层闪点01转动闪烁频率", Range( 0 , 1)) = 1
		_Height1("内层闪点01高度", Range( -15 , 15)) = 0
		_Starry1Spec("内层闪点高光区域", Range( 0.02 , 50)) = 1
		_StarryPower("StarryPower", Float) = 20
		_StarryHue("StarryHue", Range( 0 , 1)) = 0
		_SkyTex("星空", 2D) = "black" {}
		_xingkongIntensity("星空颜色强度", Range( 0 , 1)) = 0
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

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" "IgnoreProjector"="True" }

		Cull Off
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
			Name "ExtraPrePass"
			

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
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
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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
			sampler2D _ShiningMask;
			sampler2D _SparkleMap;
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
			

			VertexOutput VertexFunction( VertexInput v  )
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

			half4 frag ( VertexOutput IN  ) : SV_Target
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
				float temp_output_238_0 = ( mulTime237 * _StarryFlowSpeed );
				float2 texCoord370 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = SafeNormalize( ase_tanViewDir );
				float2 NoiseOffset446 = ( texCoord370 + ( _Height1 * (ase_tanViewDir).xy * 0.01 ) );
				float4 saferPower244 = abs( ( tex2Dlod( _StarryMap, float4( ( ( temp_output_238_0 + NoiseOffset446 ) * _Starry1Tilling ), 0, 0.0) ) + 0.2 ) );
				float4 temp_cast_3 = (_StarryPower).xxxx;
				float2 appendResult620 = (float2(( temp_output_238_0 * -1.0 ) , ( temp_output_238_0 * -1.1353 )));
				ase_tanViewDir = normalize(ase_tanViewDir);
				float4 saferPower245 = abs( ( 0.2 + tex2Dlod( _StarryMap, float4( ( _Starry1Tilling * ( float3( appendResult620 ,  0.0 ) + float3( NoiseOffset446 ,  0.0 ) + ( 0.05 * _SparkshinFreq * ase_tanViewDir ) ) ).xy, 0, 0.0) ) ) );
				float4 temp_cast_7 = (_StarryPower).xxxx;
				float3 normalizeResult427 = normalize( NDirWS314 );
				float dotResult425 = dot( normalizeResult427 , ase_worldViewDir );
				float HalfNdotV431 = (dotResult425*0.5 + 0.5);
				float Thichness434 = HalfNdotV431;
				float saferPower455 = abs( Thichness434 );
				float4 StarryCol298 = ( ( pow( saferPower244 , temp_cast_3 ) * pow( saferPower245 , temp_cast_7 ) * _Starry1Color * _Starry1Intensity ) * pow( saferPower455 , _Starry1Spec ) );
				float4 temp_cast_8 = (1.0).xxxx;
				float2 texCoord463 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode461 = tex2D( _ColorMap, texCoord463 );
				float4 lerpResult464 = lerp( temp_cast_8 , tex2DNode461 , _StarryHue);
				float4 temp_cast_9 = (8.0).xxxx;
				float2 uv_ShiningMask = IN.ase_texcoord3.xy * _ShiningMask_ST.xy + _ShiningMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShiningMask, uv_ShiningMask );
				float2 texCoord575 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 center45_g5 = float2( 0.5,0.5 );
				float2 delta6_g5 = ( texCoord575 - center45_g5 );
				float angle10_g5 = ( length( delta6_g5 ) * _SprkleVornojStrength );
				float x23_g5 = ( ( cos( angle10_g5 ) * delta6_g5.x ) - ( sin( angle10_g5 ) * delta6_g5.y ) );
				float2 break40_g5 = center45_g5;
				float mulTime578 = _TimeParameters.x * 0.1;
				float2 temp_cast_10 = (( mulTime578 * _SprkleShinSpeed )).xx;
				float2 break41_g5 = temp_cast_10;
				float y35_g5 = ( ( sin( angle10_g5 ) * delta6_g5.x ) + ( cos( angle10_g5 ) * delta6_g5.y ) );
				float2 appendResult44_g5 = (float2(( x23_g5 + break40_g5.x + break41_g5.x ) , ( break40_g5.y + break41_g5.y + y35_g5 )));
				float simplePerlin2D800 = snoise( appendResult44_g5*( _SprkleVornojStrength * 3.74 ) );
				simplePerlin2D800 = simplePerlin2D800*0.5 + 0.5;
				float saferPower941 = abs( simplePerlin2D800 );
				float lerpResult948 = lerp( 1.0 , pow( saferPower941 , 2.0 ) , _SparkleWeight);
				float2 texCoord910 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float GlitterSpeed898 = _SparkleOffsetSpeed;
				float4 GlitterColor905 = tex2Dlod( _SparkleMap, float4( ( ( float3( texCoord910 ,  0.0 ) + ( ase_worldViewDir * 0.05 * GlitterSpeed898 ) ) * ( ( GlitterSpeed898 / 2.0 ) + 1.0 ) * _SparkleTilling ).xy, 0, 0.0) );
				float2 texCoord884 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uvCenter890 = float2( 0.5,0.5 );
				float2 break881 = ( ( texCoord884 + ( (ase_tanViewDir).xy * -0.05 * GlitterSpeed898 ) ) - uvCenter890 );
				float cosAngle892 = cos( 3.14 );
				float temp_output_899_0 = sin( 3.14 );
				float FusinAngle897 = ( temp_output_899_0 * -1.0 );
				float sinAngle893 = temp_output_899_0;
				float2 appendResult872 = (float2(( ( break881.x * cosAngle892 ) + ( break881.y * FusinAngle897 ) ) , ( ( break881.x * sinAngle893 ) + ( break881.y * cosAngle892 ) )));
				float4 GlitterColor2880 = tex2Dlod( _SparkleMap, float4( ( ( appendResult872 + uvCenter890 ) * ( 1.0 - ( GlitterSpeed898 / 3.14 ) ) * _SparkleTilling ), 0, 0.0) );
				float3 temp_cast_13 = (_GlitterContrast).xxx;
				float3 lerpResult916 = lerp( pow( (( _GlitterPower * GlitterColor905 * GlitterColor2880 )).rgb , temp_cast_13 ) , float3( 0,0,0 ) , ( 1.0 - GlitterColor2880 ).rgb);
				float3 Glitter_new922 = lerpResult916;
				float saferPower616 = abs( Thichness434 );
				float4 SparkleCol504 = ( float4( ( lerpResult948 * ( Glitter_new922 * pow( saferPower616 , _SparkSpec ) ) ) , 0.0 ) * _SparkIntenrity * _SparkleColor );
				float4 temp_cast_16 = (1.0).xxxx;
				float4 lerpResult736 = lerp( temp_cast_16 , tex2DNode461 , _SparkHue);
				float4 temp_cast_17 = (8.0).xxxx;
				float4 temp_cast_18 = (1.0).xxxx;
				float4 lerpResult793 = lerp( temp_cast_18 , tex2DNode461 , _xingkongHue);
				float4 temp_cast_19 = (8.0).xxxx;
				float2 uv_SkyTex = IN.ase_texcoord3.xy * _SkyTex_ST.xy + _SkyTex_ST.zw;
				float4 xingkong777 = ( pow( ( lerpResult793 + 0.2 ) , temp_cast_19 ) * tex2D( _SkyTex, ( ( uv_SkyTex + ( _Height3 * (ase_tanViewDir).xy * 0.01 ) ) * _Tilling1.x ) ) * _xingkongIntensity );
				float fresnelNdotV807 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode807 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV807, _FresnaelPower ) );
				
				float lerpResult849 = lerp( 1.0 , tex2DNode308.a , _Alphaweight);
				

				float3 Color = ( ( tex2DNode308 * _Tint ) + ReflectCol349 + SpecularColor333 + ( ( StarryCol298 * pow( ( lerpResult464 + 0.2 ) , temp_cast_9 ) * tex2DNode556 ) + ( SparkleCol504 * pow( ( lerpResult736 + 0.2 ) , temp_cast_17 ) ) ) + ( xingkong777 * tex2DNode556 ) + saturate( ( fresnelNode807 * _FCol ) ) ).rgb;
				float Alpha = lerpResult849;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask A

			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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

			

			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

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

				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = float3( 0.5, 0.5, 0.5 );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

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

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DiffueMap_ST;
			float4 _Tint;
			float4 _NormalMap_ST;
			float4 _FCol;
			float4 _ShiningMask_ST;
			float4 _sarMask_ST;
			float4 _SpecularColor;
			float4 _SkyTex_ST;
			float4 _SparkleColor;
			float4 _Starry1Color;
			float2 _Tilling1;
			float _GlitterContrast;
			float _SparkSpec;
			float _SparkIntenrity;
			float _xingkongHue;
			float _SparkleTilling;
			float _Height3;
			float _xingkongIntensity;
			float _FresnaelPower;
			float _SparkHue;
			float _SparkleOffsetSpeed;
			float _SprkleVornojStrength;
			float _SparkleWeight;
			float _SprkleShinSpeed;
			float _StarryHue;
			float _Starry1Spec;
			float _Starry1Intensity;
			float _SparkshinFreq;
			float _StarryPower;
			float _Starry1Tilling;
			float _Height1;
			float _StarryFlowSpeed;
			float _SpecularPower;
			float _SpecularGloss;
			float _ReflectPower;
			float _GlitterPower;
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

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

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
Node;AmplifyShaderEditor.CommentaryNode;746;-7509.381,324.8647;Inherit;False;2507.689;1199.531;SparkleColor;2;472;471;SparkleColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;745;-9669.827,3512.628;Inherit;False;1790.535;923.4119;SpecularColor;24;313;319;321;322;323;334;335;325;324;314;328;331;326;312;327;329;330;332;315;316;317;318;320;333;SpecularColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;615;-7369.262,2353.25;Inherit;False;2929.586;1142.796;StarryCol1;44;673;241;240;672;620;675;623;437;436;622;239;237;238;438;288;445;234;298;439;456;294;469;257;454;452;248;455;296;244;245;297;246;283;722;721;723;843;845;842;844;846;857;860;930;StarryCol1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;614;-4134.247,3609.132;Inherit;False;1701.077;1088.437;SparkleColAll;25;743;556;739;737;741;735;466;461;463;588;727;740;738;736;733;731;732;299;742;734;464;465;613;612;861;SparkleColAll;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;587;-7485.509,-406.0535;Inherit;False;1597.035;663.2364;TwirlMask;10;573;575;577;578;579;580;800;934;941;948;TwirlMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;337;-9682.95,2877.877;Inherit;False;1781.21;507.1108;ReflectMap;10;364;360;356;355;349;348;347;346;345;344;ReflectMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;338;-9677.702,2075.249;Inherit;False;1165.792;688.3389;Fresnel;6;363;362;361;359;354;353;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;389;-9705.618,1118.383;Inherit;False;2091.478;863.4287;RandomMap;18;371;379;388;387;386;378;380;385;372;376;377;375;374;381;383;384;382;373;RandomMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;422;-9662.356,4584.52;Inherit;False;1346.887;575.667;Thichness;7;434;431;427;426;425;424;423;Thichness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;471;-5831.09,519.5297;Inherit;False;728.1446;829.0439;LightDieValue;4;505;504;611;749;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;472;-7480.39,569.5578;Inherit;False;1587.962;614.7743;NoiseMask1;6;617;616;618;574;924;854;;1,1,1,1;0;0
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
Node;AmplifyShaderEditor.RangedFloatNode;328;-8918.162,3909.629;Inherit;False;Property;_SpecularGloss;SpecularGloss;12;0;Create;True;0;0;0;False;0;False;100;100;0.01;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-8819.636,4001.344;Inherit;False;369;sarMask_g;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;-8641.593,3952.419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;312;-8507.828,3809.629;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-8259.162,3811.629;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-8496.79,3903.197;Inherit;False;Property;_SpecularPower;SpecularPower;13;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;332;-8498.281,3973.95;Inherit;False;Property;_SpecularColor;SpecularColor;14;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.8553459,0.8553459,0.8553459,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
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
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;774;-2848.751,5119.105;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;599;-9637.029,-271.9392;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;596;-9401.604,-137.9614;Inherit;False;Constant;_Float41;Float 41;12;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;598;-9375.966,-62.95251;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;601;-9645.966,-118.2466;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.WorldNormalVector;600;-9636.966,-41.28571;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;597;-9231.637,-64.61916;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;770;-5058.106,5492.391;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;771;-5372.105,5579.059;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;769;-5326.105,5381.726;Inherit;False;World;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;767;-5498.329,5386.361;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;787;-4725.852,5492.076;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;772;-4876.108,5487.055;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;786;-5016.518,5600.745;Inherit;False;Property;_Offset;Offset;55;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;784;-3400.811,5032.847;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;780;-3563.022,5031.473;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;793;-3440.181,4735.442;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;794;-3254.598,4735.299;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;795;-3108.598,4735.965;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;796;-3694.684,4700.641;Inherit;False;Constant;_Float3;Float 3;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;797;-3441.264,4849.967;Inherit;False;Constant;_Float4;Float 4;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;798;-3270.598,4851.299;Inherit;False;Constant;_Float5;Float 5;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;785;-3602.144,5122.852;Inherit;False;Property;_Tilling1;Tilling 1;54;0;Create;True;0;0;0;False;0;False;1,1;6,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-2493.544,2985.865;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;814;-2956.77,2699.861;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;809;-3103.479,2699.817;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;811;-3343.611,2716.415;Inherit;False;Property;_FCol;FCol;56;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6289307,0.6289307,0.6289307,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;790;-3815.447,5051.831;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;816;-4043.49,5267.227;Inherit;False;URP Tangent To World Normal;-1;;3;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;791;-4050.109,5141.793;Inherit;False;Constant;_Float2;Float 2;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;789;-4044.976,5069.303;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;792;-4272.229,4989.555;Inherit;False;Property;_Height3;Height3;52;0;Create;True;0;0;0;False;0;False;0;-2;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;799;-3826.448,4775.678;Inherit;False;Property;_xingkongHue;星空饱和度;53;0;Create;False;0;0;0;False;0;False;0;0.121;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-9212.289,1167.958;Inherit;False;Constant;_Float16;Float 16;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-8276.658,3160.955;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;349;-8119.608,3156.143;Inherit;False;ReflectCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;-9193.208,2293.871;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;354;-9009.602,2295.717;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-8819.46,2291.346;Inherit;True;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-9572.196,2230.883;Inherit;False;Property;_FrsnelIntensity;FrsnelIntensity;32;0;Create;True;0;0;0;False;0;False;1;0.321;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;359;-9574.433,2400.396;Inherit;True;Property;_FresnelMap;FresnelMap;4;0;Create;True;0;0;0;False;0;False;-1;None;357516955bc394d489bf350347f0cf95;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;364;-8595.469,3235.798;Inherit;False;Property;_ReflectPower;Reflect Power;15;0;Create;True;0;0;0;False;0;False;1;0.191;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;360;-8603.279,3017.608;Inherit;True;Property;_ReflectMap;ReflectMap;6;0;Create;True;0;0;0;False;0;False;-1;None;329a792ec57d56b42b61b6c449e42c32;True;0;False;black;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;345;-9007.188,2951.754;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-9404.386,2949.996;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;347;-9174.47,2949.349;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;356;-9621.694,3026.549;Inherit;False;314;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-9238.712,2505.728;Inherit;False;Property;_Float8;Float 8;33;0;Create;True;0;0;0;False;0;False;0.1;1.4;0.1;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;355;-9574.831,2931.991;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-8763.166,3017.617;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;-5822.671,1992.345;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;717;-6253.146,2065.493;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;718;-6013.802,2062.416;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;844;-7283.745,2528.139;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;842;-7087.742,2434.805;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;843;-7087.744,2536.139;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;846;-6943.743,2478.806;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;845;-6793.478,2550.208;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
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
Node;AmplifyShaderEditor.RangedFloatNode;716;-6015.883,2162.402;Inherit;False;Constant;_Float24;Float 24;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;729;-5814.026,2157.098;Inherit;False;Constant;_Float30;Float 30;68;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-6293.075,1953.6;Inherit;False;Property;_Height02;内层闪点02高度;44;0;Create;False;0;0;0;False;0;False;-1;-3;-15;15;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.RangedFloatNode;383;-9418.061,1386.897;Inherit;False;Property;_VertexWeight;VertexWeight;31;0;Create;True;0;0;0;False;0;False;0;0.091;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;374;-8997.701,1247.124;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-8674.019,1200.05;Inherit;False;Property;_Height;Height;34;0;Create;True;0;0;0;False;0;False;1.640666;-1;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;381;-9415.965,1229.669;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;380;-8603.984,1670.425;Inherit;True;Property;_RandomMap;RandomMap;11;0;Create;True;0;0;0;False;0;False;-1;None;db59a147e05cbd94993ee81b8097c979;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.InverseOpNode;830;-8053.142,2149.241;Inherit;False;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.InverseTranspMVMatrixNode;821;-8492.475,2017.909;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.InverseViewMatrixNode;822;-8492.479,2101.907;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;385;-7869.599,1341.578;Inherit;False;CrystalHeight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;815;-3689.413,2634.917;Inherit;False;Property;_FresnaelPower;FresnaelPower;57;0;Create;True;0;0;0;False;0;False;5;5.87;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;378;-8832.352,1697.663;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;777;-2640.31,5114.813;Inherit;False;xingkong;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;779;-3817.202,4926.114;Inherit;False;0;773;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;305;-2887.986,2977.428;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;744;-3321.885,3194.823;Inherit;False;Property;_Tint;Tint;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.9056604,0.9056604,0.9056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;849;-2929.549,3374.545;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;850;-2676.986,3473.561;Inherit;False;Constant;_Float1;Float 1;53;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;752;-1926.378,2988.521;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;QF/NssFX/NssFX_ASE/FX_ASE_Sparkle_Paxton_pack240124;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;IgnoreProjector=True;True;3;True;12;all;0;False;True;0;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;638412318563925137;Forward Only;0;0;Cast Shadows;0;638412315392944719;  Use Shadow Threshold;0;0;Receive Shadows;0;638412315401366939;GPU Instancing;0;638412315406847438;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;638412315435672200;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;True;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;766;-3256.909,3443.902;Inherit;False;Property;_Alphaweight;Alpha权重;1;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;689;-5583.282,4537.006;Inherit;False;Property;_Starry2Intensity;内层闪点02强度;42;0;Create;False;0;0;0;False;0;False;1;0.695;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;685;-5267.414,4607.373;Inherit;False;Property;_Starry2Spec;内层闪点02高光区域;46;0;Create;False;0;0;0;False;0;False;1;0.02;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;684;-5546.541,4353.958;Inherit;False;Property;_Starry2Color;内层闪点02颜色;43;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.7204026,0.9526433,0.9748427,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;730;-6466,4106.412;Inherit;False;Property;_Starry2Tilling;内层闪点02重复;45;0;Create;False;0;0;0;False;0;False;20;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;699;-7279.137,4106.612;Inherit;False;Property;_Starry2Speed;内层闪点02速度;47;0;Create;False;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;775;-3240.976,5242.815;Inherit;False;Property;_xingkongIntensity;星空颜色强度;51;0;Create;False;0;0;0;False;0;False;0;0.312;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;365;-9640.606,355.6091;Inherit;True;Property;_NormalMap;NormalMap;5;0;Create;True;0;0;0;False;0;False;-1;None;bf34050362fe4cc4d82cfcacfb74ff3e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;221;-9359.192,664.062;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-9116.963,360.3181;Inherit;False;NormalTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-9103.959,660.3983;Inherit;False;NDirWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;692;-4658.271,4351.912;Inherit;False;StarryCol2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;702;-6038.953,4282.375;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;773;-3255.064,5003.75;Inherit;True;Property;_SkyTex;星空;50;0;Create;False;0;0;0;False;0;False;-1;None;f52b9f89907516d4a88a9f2f3f8e8dcb;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;807;-3360.311,2546.302;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;620;-6714.76,3084.357;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;672;-6910.64,3096.156;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;-6725.438,3275.48;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-6887.648,2933.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-7054.217,2810.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;237;-7301.623,2752.135;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-7328.219,2855.463;Inherit;False;Property;_StarryFlowSpeed;内层闪点流动速度;38;0;Create;False;0;0;0;False;0;False;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-7139.156,2957.974;Inherit;False;Constant;_Float13;Float 13;28;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;-7127.408,3110.754;Inherit;False;Constant;_Float11;Float 11;28;0;Create;True;0;0;0;False;0;False;-1.1353;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-6997.724,3346.94;Inherit;False;Constant;_Float18;Float 18;17;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;857;-7116.183,3424.473;Inherit;False;Property;_SparkshinFreq;内层闪点01转动闪烁频率;39;0;Create;False;0;0;0;False;0;False;1;0.211;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;297;-5656.546,2989.868;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0.2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;244;-5432.546,2653.868;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;455;-5000.546,3245.868;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-4792.546,3085.868;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-6440.546,3101.868;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-6264.546,2749.868;Inherit;False;StarryTilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;298;-4648.546,3069.868;Inherit;False;StarryCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-6216.546,3037.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;722;-5400.546,2861.868;Inherit;False;StarryPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;721;-5816.546,2829.868;Inherit;False;StarryLightOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;-5656.546,2653.868;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;245;-5400.546,2957.868;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-5064.546,2877.868;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-5608.546,2877.868;Inherit;False;Property;_StarryPower;StarryPower;48;0;Create;True;0;0;0;False;0;False;20;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;-5528.546,3245.868;Inherit;False;Property;_Starry1Intensity;内层闪点强度;35;0;Create;False;0;0;0;False;0;False;1;0.639;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;248;-5528.546,3069.868;Inherit;False;Property;_Starry1Color;内层闪点颜色;36;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.7987421,0.7987421,0.7987421,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;452;-5304.546,3325.868;Inherit;False;Property;_Starry1Spec;内层闪点高光区域;41;0;Create;False;0;0;0;False;0;False;1;7;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;-6136.546,2845.868;Inherit;False;Constant;_StarryLightOffset;StarryLightOffset;46;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-6440.546,2781.868;Inherit;False;Property;_Starry1Tilling;内层闪点Tilling;37;0;Create;False;0;0;0;False;0;False;20;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;-6440.546,2493.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-6248.546,2493.868;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-5208.546,3229.868;Inherit;False;434;Thichness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;445;-6717.601,2816.779;Inherit;False;446;NoiseOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;668;-6780.344,1780.298;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;670;-7195.858,1975.262;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;-6914.264,1987.797;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;765;-7417.111,1886.849;Inherit;False;Property;_Height1;内层闪点01高度;40;0;Create;False;0;0;0;False;0;False;0;-2;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;671;-7186.325,2070.767;Inherit;False;Constant;_Float9;Float 9;68;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;440;-7407.943,1976.18;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;370;-7415.009,1772.331;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-6569.838,1773.864;Inherit;False;NoiseOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;712;-5641.15,1875.349;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;711;-5447.251,1874.848;Inherit;False;NoiseOffset2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;872;-3106.673,174.9245;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;874;-3160.673,402.2578;Inherit;False;890;uvCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;876;-3055.344,506.3966;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;877;-2942.677,509.7299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;878;-3244.011,503.0634;Inherit;False;898;GlitterSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;890;-4031.91,-127.1822;Inherit;False;uvCenter;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;891;-4208.577,-125.8489;Inherit;False;Constant;_uvCenter;uvCenter;2;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;892;-4034.869,-407.7366;Inherit;False;cosAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;893;-4034.869,-323.0699;Inherit;False;sinAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;895;-4157.06,-232.9713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;897;-4032.393,-236.9711;Inherit;False;FusinAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;898;-4041.019,-505.3744;Inherit;False;GlitterSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;900;-3318.341,-162.9025;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;901;-3163.674,-164.9024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;902;-2825.674,-304.2358;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;903;-3030.341,-457.5693;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;904;-3512.341,-314.9025;Inherit;False;Constant;_Float10;Float 10;0;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;906;-3514.701,-218.3503;Inherit;False;898;GlitterSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;908;-3277.008,-336.9025;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;873;-2951.661,144.6446;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;909;-3578.341,-461.5694;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;910;-3303.804,-493.8499;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;882;-3777.751,228.1203;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;883;-3905.477,224.0082;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;884;-4128.89,105.2434;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;894;-4264.868,-399.0699;Inherit;False;1;0;FLOAT;3.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;899;-4266.201,-311.0699;Inherit;False;1;0;FLOAT;3.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;-3585.34,433.4247;Inherit;False;892;cosAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;862;-3279.34,76.25789;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;863;-3443.339,108.9245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;864;-3442.673,14.92436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;865;-3638.006,36.25768;Inherit;False;892;cosAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;866;-3636.006,124.2579;Inherit;False;897;FusinAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;867;-3381.34,302.758;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;868;-3380.673,410.0913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;869;-3576.673,338.7579;Inherit;False;893;sinAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;871;-3235.34,281.5912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;881;-3649.438,228.421;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;751;-1912.488,3253.454;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;True;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.ColorNode;749;-5620.401,933.7418;Inherit;False;Property;_SparkleColor;外层闪点颜色;19;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;504;-5352.419,644.7355;Inherit;False;SparkleCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;888;-4326.819,401.4289;Inherit;False;Constant;_Float7;Float 7;0;0;Create;True;0;0;0;False;0;False;-0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;885;-4036.518,335.0635;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;886;-4176.031,248.1548;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;889;-4329.018,479.4294;Inherit;False;898;GlitterSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;788;-4268.053,5068.919;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;911;-4329.852,245.0635;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;887;-3923.442,459.5424;Inherit;False;890;uvCenter;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;436;-6040.546,2477.868;Inherit;True;Property;_StarryMap;StarryMap;8;0;Create;True;0;0;0;False;0;False;-1;None;a26bfdd73e091e949a32a0c695ec59e6;True;1;False;black;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;437;-6024.546,3005.868;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;701;-6043.026,3749.058;Inherit;True;Property;_TextureSample4;Texture Sample 4;7;0;Create;True;0;0;0;False;0;False;-1;None;a26bfdd73e091e949a32a0c695ec59e6;True;1;False;black;Auto;False;Instance;436;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;611;-5793.414,822.1499;Inherit;False;Property;_SparkIntenrity;外层闪点强度;18;0;Create;False;0;0;0;False;0;False;1;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;905;-2399.094,-333.9972;Inherit;False;GlitterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;875;-2771.938,204.4962;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;880;-2313.313,177.8101;Inherit;False;GlitterColor2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;879;-2641.695,180.989;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;b9e28bf2fd0f6754f8a8640f8aea489d;b9e28bf2fd0f6754f8a8640f8aea489d;True;0;False;white;Auto;False;Instance;907;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;919;-3089.216,724.8235;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;912;-3351.005,729.5079;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;913;-3548.44,658.2909;Inherit;False;Property;_GlitterPower;GlitterPower;23;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;914;-3564.339,806.8412;Inherit;False;880;GlitterColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;915;-3563.499,736.4427;Inherit;False;905;GlitterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;916;-2542.814,900.3297;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;920;-2759.753,859.4127;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;917;-2760.339,946.1073;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;922;-2359.906,895.9661;Inherit;True;Glitter_new;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;848;-2195.277,3630.173;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;778;-2393.212,3624.544;Inherit;False;777;xingkong;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-3671.646,3799.675;Inherit;False;Constant;_aa;aa;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;464;-3495.762,3935.967;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;732;-3473.47,4066.191;Inherit;False;Constant;_Float31;Float 31;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;466;-3840.028,4108.867;Inherit;False;Property;_StarryHue;StarryHue;49;0;Create;True;0;0;0;False;0;False;0;0.149;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;743;-2837.533,3821.166;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;736;-3504.838,4337.957;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;740;-3171.921,4372.477;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;735;-3746.007,4331.819;Inherit;False;Constant;_Float20;Float 20;61;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-3327.921,4517.146;Inherit;False;Constant;_Float33;Float 33;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-3853.104,4407.523;Inherit;False;Property;_SparkHue;外层闪点饱和度;20;0;Create;False;0;0;0;False;0;False;0;0.185;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;463;-4083.62,3932.398;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;461;-3860.181,3906.009;Inherit;True;Property;_ColorMap;ColorMap;10;0;Create;True;0;0;0;False;0;False;-1;None;e4b38866534f2ca44a2e09b37542955a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;727;-3513.395,3770.853;Inherit;False;692;StarryCol2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-3513.923,3673.14;Inherit;False;298;StarryCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;613;-3316.262,3754.519;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;734;-3464.179,4153.152;Inherit;False;Constant;_Float32;Float 32;69;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;738;-3317.254,4372.477;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-3508.587,4477.812;Inherit;False;Constant;_Float21;Float 21;69;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;861;-2652.192,4290.318;Inherit;False;ShiningMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;742;-2953.165,4184.997;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;612;-3011.783,3682.535;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;733;-3191.834,3914.668;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;731;-3346.916,3952.073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;556;-2973.229,4291.688;Inherit;True;Property;_ShiningMask;ShiningMask;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;588;-3191.759,4164.604;Inherit;False;504;SparkleCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;675;-7544.035,3212.233;Inherit;False;366;NormalTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;860;-7296.289,3203.436;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;930;-7099.188,3203.263;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;925;-3095.43,-46.87357;Inherit;False;Property;_SparkleTilling;外层闪点Tilling;21;0;Create;False;0;0;0;False;0;False;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;907;-2683.674,-335.569;Inherit;True;Property;_SparkleMap;SparkleMap;7;0;Create;True;0;0;0;False;0;False;-1;None;294a7782d8c0b2b4d83008cc98071755;True;0;False;black;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;896;-4292.66,-505.2601;Inherit;False;Property;_SparkleOffsetSpeed;外层闪点偏移闪烁速度[0,1];22;0;Create;False;0;0;0;False;0;False;0.5;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;616;-6655.906,873.8427;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;-6964.066,962.1904;Inherit;False;Property;_SparkSpec;外层闪点高光区域;30;0;Create;False;0;0;0;False;0;False;1;3.2;0.02;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;-6961.785,875.0497;Inherit;False;434;Thichness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;574;-6840.554,1062.338;Inherit;False;Property;_SprkleVornojScale;外层闪点消融扭曲比例;27;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;308;-3409.598,2966.642;Inherit;True;Property;_DiffueMap;Diffue Map;0;0;Create;True;0;0;0;False;0;False;-1;None;f5fde3067254a1442b2427758f2aa6eb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;918;-3229.555,949.8724;Inherit;False;880;GlitterColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;921;-3224.572,876.7823;Inherit;False;Property;_GlitterContrast;GlitterContrast;24;0;Create;True;0;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-5531.673,613.3335;Inherit;False;3;3;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;937;-6023.513,214.4933;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;-6340.121,630.8351;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;924;-6990.09,635.3961;Inherit;False;922;Glitter_new;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;581;-7786.678,424.1187;Inherit;False;Property;_SprkleDissolve;外层闪点消融;26;0;Create;False;0;0;0;False;0;False;0.8352941;0.9421114;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;578;-7440.043,-46.73434;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;579;-7244.057,-22.42309;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;580;-7458.396,37.59745;Inherit;False;Property;_SprkleShinSpeed;外层闪点消融闪烁速度;28;0;Create;False;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;575;-7422.403,-243.3562;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;577;-7420.748,-125.0348;Inherit;False;Property;_SprkleVornojStrength;外层闪点消融扭曲强度;29;0;Create;False;0;0;0;False;0;False;21.9;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;800;-6718.503,-169.8357;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;934;-6919.904,56.59421;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3.74;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;573;-7016.661,-186.2971;Inherit;True;Twirl;-1;;5;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;948;-6200.183,149.5859;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;941;-6450.089,-153.7467;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;944;-6616.03,244.5688;Inherit;False;Property;_SparkleWeight;外层闪点消融权重;25;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
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
WireConnection;774;0;795;0
WireConnection;774;1;773;0
WireConnection;774;2;775;0
WireConnection;598;0;601;0
WireConnection;598;1;600;0
WireConnection;597;0;598;0
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
WireConnection;793;0;796;0
WireConnection;793;1;461;0
WireConnection;793;2;799;0
WireConnection;794;0;793;0
WireConnection;794;1;797;0
WireConnection;795;0;794;0
WireConnection;795;1;798;0
WireConnection;304;0;305;0
WireConnection;304;1;310;0
WireConnection;304;2;311;0
WireConnection;304;3;743;0
WireConnection;304;4;848;0
WireConnection;304;5;814;0
WireConnection;814;0;809;0
WireConnection;809;0;807;0
WireConnection;809;1;811;0
WireConnection;790;0;792;0
WireConnection;790;1;789;0
WireConnection;790;2;791;0
WireConnection;789;0;788;0
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
WireConnection;713;0;720;0
WireConnection;713;1;718;0
WireConnection;713;2;716;0
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
WireConnection;380;1;378;0
WireConnection;385;0;372;0
WireConnection;378;0;379;0
WireConnection;378;1;387;0
WireConnection;777;0;774;0
WireConnection;305;0;308;0
WireConnection;305;1;744;0
WireConnection;849;1;308;4
WireConnection;849;2;766;0
WireConnection;221;0;365;0
WireConnection;366;0;365;0
WireConnection;228;0;221;0
WireConnection;692;0;686;0
WireConnection;702;1;691;0
WireConnection;773;1;784;0
WireConnection;807;3;815;0
WireConnection;620;0;240;0
WireConnection;620;1;672;0
WireConnection;672;0;238;0
WireConnection;672;1;673;0
WireConnection;622;0;623;0
WireConnection;622;1;857;0
WireConnection;622;2;930;0
WireConnection;240;0;238;0
WireConnection;240;1;241;0
WireConnection;238;0;237;0
WireConnection;238;1;239;0
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
WireConnection;723;0;234;0
WireConnection;298;0;454;0
WireConnection;439;0;234;0
WireConnection;439;1;288;0
WireConnection;722;0;257;0
WireConnection;721;0;469;0
WireConnection;296;0;436;0
WireConnection;296;1;469;0
WireConnection;245;0;297;0
WireConnection;245;1;257;0
WireConnection;246;0;244;0
WireConnection;246;1;245;0
WireConnection;246;2;248;0
WireConnection;246;3;294;0
WireConnection;283;0;238;0
WireConnection;283;1;445;0
WireConnection;438;0;283;0
WireConnection;438;1;234;0
WireConnection;668;0;370;0
WireConnection;668;1;669;0
WireConnection;670;0;440;0
WireConnection;669;0;765;0
WireConnection;669;1;670;0
WireConnection;669;2;671;0
WireConnection;446;0;668;0
WireConnection;712;0;370;0
WireConnection;712;1;713;0
WireConnection;712;2;729;0
WireConnection;711;0;712;0
WireConnection;872;0;862;0
WireConnection;872;1;871;0
WireConnection;876;0;878;0
WireConnection;877;0;876;0
WireConnection;890;0;891;0
WireConnection;892;0;894;0
WireConnection;893;0;899;0
WireConnection;895;0;899;0
WireConnection;897;0;895;0
WireConnection;898;0;896;0
WireConnection;900;0;906;0
WireConnection;901;0;900;0
WireConnection;902;0;903;0
WireConnection;902;1;901;0
WireConnection;902;2;925;0
WireConnection;903;0;910;0
WireConnection;903;1;908;0
WireConnection;908;0;909;0
WireConnection;908;1;904;0
WireConnection;908;2;906;0
WireConnection;873;0;872;0
WireConnection;873;1;874;0
WireConnection;882;0;883;0
WireConnection;882;1;887;0
WireConnection;883;0;884;0
WireConnection;883;1;885;0
WireConnection;862;0;864;0
WireConnection;862;1;863;0
WireConnection;863;0;881;1
WireConnection;863;1;866;0
WireConnection;864;0;881;0
WireConnection;864;1;865;0
WireConnection;867;0;881;0
WireConnection;867;1;869;0
WireConnection;868;0;881;1
WireConnection;868;1;870;0
WireConnection;871;0;867;0
WireConnection;871;1;868;0
WireConnection;881;0;882;0
WireConnection;751;0;304;0
WireConnection;751;1;849;0
WireConnection;504;0;505;0
WireConnection;885;0;886;0
WireConnection;885;1;888;0
WireConnection;885;2;889;0
WireConnection;886;0;911;0
WireConnection;436;1;438;0
WireConnection;437;1;439;0
WireConnection;701;1;696;0
WireConnection;905;0;907;0
WireConnection;875;0;873;0
WireConnection;875;1;877;0
WireConnection;875;2;925;0
WireConnection;880;0;879;0
WireConnection;879;1;875;0
WireConnection;919;0;912;0
WireConnection;912;0;913;0
WireConnection;912;1;915;0
WireConnection;912;2;914;0
WireConnection;916;0;920;0
WireConnection;916;2;917;0
WireConnection;920;0;919;0
WireConnection;920;1;921;0
WireConnection;917;0;918;0
WireConnection;922;0;916;0
WireConnection;848;0;778;0
WireConnection;848;1;556;0
WireConnection;464;0;465;0
WireConnection;464;1;461;0
WireConnection;464;2;466;0
WireConnection;743;0;612;0
WireConnection;743;1;742;0
WireConnection;736;0;735;0
WireConnection;736;1;461;0
WireConnection;736;2;741;0
WireConnection;740;0;738;0
WireConnection;740;1;739;0
WireConnection;461;1;463;0
WireConnection;613;0;299;0
WireConnection;613;1;727;0
WireConnection;738;0;736;0
WireConnection;738;1;737;0
WireConnection;861;0;556;0
WireConnection;742;0;588;0
WireConnection;742;1;740;0
WireConnection;612;0;299;0
WireConnection;612;1;733;0
WireConnection;612;2;556;0
WireConnection;733;0;731;0
WireConnection;733;1;734;0
WireConnection;731;0;464;0
WireConnection;731;1;732;0
WireConnection;860;0;675;0
WireConnection;907;1;902;0
WireConnection;616;0;617;0
WireConnection;616;1;618;0
WireConnection;505;0;937;0
WireConnection;505;1;611;0
WireConnection;505;2;749;0
WireConnection;937;0;948;0
WireConnection;937;1;854;0
WireConnection;854;0;924;0
WireConnection;854;1;616;0
WireConnection;579;0;578;0
WireConnection;579;1;580;0
WireConnection;800;0;573;0
WireConnection;800;1;934;0
WireConnection;934;0;577;0
WireConnection;573;1;575;0
WireConnection;573;3;577;0
WireConnection;573;4;579;0
WireConnection;948;1;941;0
WireConnection;948;2;944;0
WireConnection;941;0;800;0
ASEEND*/
//CHKSM=D7CB878EC936C97C3D5B93417F8578711ADFF21D