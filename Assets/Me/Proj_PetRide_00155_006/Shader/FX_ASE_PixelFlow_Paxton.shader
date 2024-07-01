// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QF/NssFX/NssFX_ASE/FX_ASE_PixelFlow_Paxton"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_BaseMap("BaseMap", 2D) = "white" {}
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
		_RootAlpha("RootAlpha", Range( 0 , 2)) = 1
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
		[ASEEnd]_StarTillingSpeed("StarTillingSpeed", Vector) = (1,1,0,0)
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
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
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
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _BaseMap;
			sampler2D _SquareMap;
			sampler2D _Matcap;
			sampler2D _NormalMap;
			sampler2D _FresnelMap;
			sampler2D _SparkTex;
			sampler2D _ReflectMap;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
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
				
				o.ase_texcoord3.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				o.ase_texcoord3.zw = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv2_Pix1Map = IN.ase_texcoord3.xy * _Pix1Map_ST.xy + _Pix1Map_ST.zw;
				float mulTime299 = _TimeParameters.x * 0.1;
				float2 FlowSpeed202 = ( _Speed * mulTime299 );
				int PixTilling152 = _PixTilling;
				float mulTime113 = _TimeParameters.x * 0.1;
				float Mask1164 = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed202 ) * PixTilling152 ) ) / PixTilling152 ) + float2( 0,0.01 ) + ( _seed1 * mulTime113 ) ) ).r - _Dissolve );
				float clampResult522 = clamp( Mask1164 , 0.0 , 1.0 );
				float2 uv2_Pix2Map = IN.ase_texcoord3.xy * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _TimeParameters.x * 0.1;
				float4 tex2DNode82 = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed202 + uv2_Pix2Map ) * PixTilling152 ) ) / PixTilling152 ) + ( _seed2 * mulTime109 ) ) );
				float temp_output_180_0 = step( clampResult522 , tex2DNode82.r );
				float2 texCoord361 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float saferPower235 = abs( pow( texCoord361.x , 1.8 ) );
				float temp_output_235_0 = pow( saferPower235 , _DissolvePower );
				float clampResult495 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * temp_output_235_0 ) ) , 0.0 , 1.0 );
				float clampResult488 = clamp( ( _ShadowAlpha * ( ( temp_output_180_0 * IN.ase_color.r ) * ( 1.0 - clampResult495 ) ) ) , 0.0 , 1.0 );
				float MaskShadow277 = clampResult488;
				float2 uv_BaseMap = IN.ase_texcoord3.zw * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float3 temp_output_517_0 = (tex2D( _BaseMap, uv_BaseMap )).rgb;
				float clampResult485 = clamp( ( IN.ase_color.g * _RootAlpha ) , 0.0 , 1.0 );
				float MaskRoot289 = clampResult485;
				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * temp_output_235_0 ) , _DissolveTail);
				float clampResult523 = clamp( ( tex2DNode82.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );
				float2 uv2_SquareMap = IN.ase_texcoord3.xy * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 tex2DNode197 = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed202 ) * PixTilling152 ) );
				float temp_output_198_0 = step( clampResult523 , tex2DNode197.r );
				float temp_output_212_0 = ( temp_output_180_0 * temp_output_198_0 );
				float fangkuaiTex426 = tex2DNode197.r;
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep( fangkuaiTex426 , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * IN.ase_color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMaskBase423 = clampResult487;
				float clampResult486 = clamp( ( ( IN.ase_color.r * temp_output_212_0 ) - EdgeMaskBase423 ) , 0.0 , 1.0 );
				float MaskPxl287 = clampResult486;
				float MaskPxlBase492 = temp_output_212_0;
				float temp_output_490_0 = ( EdgeMaskBase423 * MaskPxlBase492 );
				float EdgeMask501 = temp_output_490_0;
				float2 uv_NormalMap = IN.ase_texcoord3.zw * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 tex2DNode229 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal228 = tex2DNode229;
				float3 worldNormal228 = normalize( float3(dot(tanToWorld0,tanNormal228), dot(tanToWorld1,tanNormal228), dot(tanToWorld2,tanNormal228)) );
				float3 NDirWS224 = worldNormal228;
				float3 normalizeResult222 = normalize( mul( UNITY_MATRIX_V, float4( NDirWS224 , 0.0 ) ).xyz );
				float3 MatCapCol231 = (tex2D( _Matcap, ((normalizeResult222).xy*0.5 + 0.5) )).rgb;
				float3 normalizeResult340 = ASESafeNormalize( mul( UNITY_MATRIX_V, float4( NDirWS224 , 0.0 ) ).xyz );
				float3 NDirTangent227 = tex2DNode229;
				float3 temp_output_335_0 = ( (normalizeResult340*0.5 + 0.5) + NDirTangent227 );
				float3 temp_cast_5 = (_FresnelPower).xxx;
				float3 Fresnel390 = pow( ( _FrsnelIntensity * (tex2D( _FresnelMap, temp_output_335_0.xy )).rgb ) , temp_cast_5 );
				float mulTime267 = _TimeParameters.x * ( (_StarTillingSpeed).zw * 0.01 ).x;
				float2 temp_cast_7 = (mulTime267).xx;
				float2 texCoord259 = IN.ase_texcoord3.xy * (_StarTillingSpeed).xy + temp_cast_7;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 saferPower253 = abs( ( (tex2D( _SparkTex, texCoord259 )).rgb * (tex2D( _SparkTex, ( ( texCoord259 + ( ( (ase_worldViewDir).xy / 20.0 ) + ( (ase_worldNormal).xy / 20.0 ) ) ) * 1.5 ) )).rgb * _StarIntensity ) );
				float3 temp_cast_8 = (_StarPower).xxx;
				float3 SparkCol270 = ( (_StarCol).rgb * pow( saferPower253 , temp_cast_8 ) );
				float3 ReflectCol338 = ( (tex2D( _ReflectMap, temp_output_335_0.xy )).rgb * _ReflectIntensity );
				float3 LightCol463 = ( MatCapCol231 + Fresnel390 + SparkCol270 + ReflectCol338 );
				float clampResult524 = clamp( ( ( 1.0 - max( IN.ase_color.r , IN.ase_color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float MaskMid324 = clampResult524;
				float3 MidCol448 = ( (_MidCol).rgb * MaskMid324 * (tex2D( _BaseMap, uv_BaseMap )).rgb );
				
				float clampResult438 = clamp( ( MaskShadow277 + MaskRoot289 + MaskPxl287 + MaskMid324 + temp_output_490_0 ) , 0.0 , 1.0 );
				float Alpha300 = clampResult438;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = (( _Light * ( max( ( MaskShadow277 * (_ShadowCol).rgb * temp_output_517_0 ) , ( ( MaskRoot289 * temp_output_517_0 ) + ( temp_output_517_0 * MaskPxl287 * (_TailCol).rgb ) ) ) + ( EdgeMask501 * (_EdgeCol).rgb ) + LightCol463 + MidCol448 ) )).xyz;
				float Alpha = Alpha300;
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
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
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
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _SquareMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv2_Pix1Map = IN.ase_texcoord2.xy * _Pix1Map_ST.xy + _Pix1Map_ST.zw;
				float mulTime299 = _TimeParameters.x * 0.1;
				float2 FlowSpeed202 = ( _Speed * mulTime299 );
				int PixTilling152 = _PixTilling;
				float mulTime113 = _TimeParameters.x * 0.1;
				float Mask1164 = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed202 ) * PixTilling152 ) ) / PixTilling152 ) + float2( 0,0.01 ) + ( _seed1 * mulTime113 ) ) ).r - _Dissolve );
				float clampResult522 = clamp( Mask1164 , 0.0 , 1.0 );
				float2 uv2_Pix2Map = IN.ase_texcoord2.xy * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _TimeParameters.x * 0.1;
				float4 tex2DNode82 = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed202 + uv2_Pix2Map ) * PixTilling152 ) ) / PixTilling152 ) + ( _seed2 * mulTime109 ) ) );
				float temp_output_180_0 = step( clampResult522 , tex2DNode82.r );
				float2 texCoord361 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float saferPower235 = abs( pow( texCoord361.x , 1.8 ) );
				float temp_output_235_0 = pow( saferPower235 , _DissolvePower );
				float clampResult495 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * temp_output_235_0 ) ) , 0.0 , 1.0 );
				float clampResult488 = clamp( ( _ShadowAlpha * ( ( temp_output_180_0 * IN.ase_color.r ) * ( 1.0 - clampResult495 ) ) ) , 0.0 , 1.0 );
				float MaskShadow277 = clampResult488;
				float clampResult485 = clamp( ( IN.ase_color.g * _RootAlpha ) , 0.0 , 1.0 );
				float MaskRoot289 = clampResult485;
				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * temp_output_235_0 ) , _DissolveTail);
				float clampResult523 = clamp( ( tex2DNode82.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );
				float2 uv2_SquareMap = IN.ase_texcoord2.xy * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 tex2DNode197 = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed202 ) * PixTilling152 ) );
				float temp_output_198_0 = step( clampResult523 , tex2DNode197.r );
				float temp_output_212_0 = ( temp_output_180_0 * temp_output_198_0 );
				float fangkuaiTex426 = tex2DNode197.r;
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep( fangkuaiTex426 , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * IN.ase_color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMaskBase423 = clampResult487;
				float clampResult486 = clamp( ( ( IN.ase_color.r * temp_output_212_0 ) - EdgeMaskBase423 ) , 0.0 , 1.0 );
				float MaskPxl287 = clampResult486;
				float clampResult524 = clamp( ( ( 1.0 - max( IN.ase_color.r , IN.ase_color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float MaskMid324 = clampResult524;
				float MaskPxlBase492 = temp_output_212_0;
				float temp_output_490_0 = ( EdgeMaskBase423 * MaskPxlBase492 );
				float clampResult438 = clamp( ( MaskShadow277 + MaskRoot289 + MaskPxl287 + MaskMid324 + temp_output_490_0 ) , 0.0 , 1.0 );
				float Alpha300 = clampResult438;
				

				float Alpha = Alpha300;
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
			#pragma multi_compile_instancing
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

			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
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
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _SquareMap;


			
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

				o.ase_texcoord.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv2_Pix1Map = IN.ase_texcoord.xy * _Pix1Map_ST.xy + _Pix1Map_ST.zw;
				float mulTime299 = _TimeParameters.x * 0.1;
				float2 FlowSpeed202 = ( _Speed * mulTime299 );
				int PixTilling152 = _PixTilling;
				float mulTime113 = _TimeParameters.x * 0.1;
				float Mask1164 = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed202 ) * PixTilling152 ) ) / PixTilling152 ) + float2( 0,0.01 ) + ( _seed1 * mulTime113 ) ) ).r - _Dissolve );
				float clampResult522 = clamp( Mask1164 , 0.0 , 1.0 );
				float2 uv2_Pix2Map = IN.ase_texcoord.xy * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _TimeParameters.x * 0.1;
				float4 tex2DNode82 = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed202 + uv2_Pix2Map ) * PixTilling152 ) ) / PixTilling152 ) + ( _seed2 * mulTime109 ) ) );
				float temp_output_180_0 = step( clampResult522 , tex2DNode82.r );
				float2 texCoord361 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float saferPower235 = abs( pow( texCoord361.x , 1.8 ) );
				float temp_output_235_0 = pow( saferPower235 , _DissolvePower );
				float clampResult495 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * temp_output_235_0 ) ) , 0.0 , 1.0 );
				float clampResult488 = clamp( ( _ShadowAlpha * ( ( temp_output_180_0 * IN.ase_color.r ) * ( 1.0 - clampResult495 ) ) ) , 0.0 , 1.0 );
				float MaskShadow277 = clampResult488;
				float clampResult485 = clamp( ( IN.ase_color.g * _RootAlpha ) , 0.0 , 1.0 );
				float MaskRoot289 = clampResult485;
				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * temp_output_235_0 ) , _DissolveTail);
				float clampResult523 = clamp( ( tex2DNode82.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );
				float2 uv2_SquareMap = IN.ase_texcoord.xy * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 tex2DNode197 = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed202 ) * PixTilling152 ) );
				float temp_output_198_0 = step( clampResult523 , tex2DNode197.r );
				float temp_output_212_0 = ( temp_output_180_0 * temp_output_198_0 );
				float fangkuaiTex426 = tex2DNode197.r;
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep( fangkuaiTex426 , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * IN.ase_color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMaskBase423 = clampResult487;
				float clampResult486 = clamp( ( ( IN.ase_color.r * temp_output_212_0 ) - EdgeMaskBase423 ) , 0.0 , 1.0 );
				float MaskPxl287 = clampResult486;
				float clampResult524 = clamp( ( ( 1.0 - max( IN.ase_color.r , IN.ase_color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float MaskMid324 = clampResult524;
				float MaskPxlBase492 = temp_output_212_0;
				float temp_output_490_0 = ( EdgeMaskBase423 * MaskPxlBase492 );
				float clampResult438 = clamp( ( MaskShadow277 + MaskRoot289 + MaskPxl287 + MaskMid324 + temp_output_490_0 ) , 0.0 , 1.0 );
				float Alpha300 = clampResult438;
				

				surfaceDescription.Alpha = Alpha300;
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
			#pragma multi_compile_instancing
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

			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
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
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _SquareMap;


			
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

				o.ase_texcoord.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv2_Pix1Map = IN.ase_texcoord.xy * _Pix1Map_ST.xy + _Pix1Map_ST.zw;
				float mulTime299 = _TimeParameters.x * 0.1;
				float2 FlowSpeed202 = ( _Speed * mulTime299 );
				int PixTilling152 = _PixTilling;
				float mulTime113 = _TimeParameters.x * 0.1;
				float Mask1164 = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed202 ) * PixTilling152 ) ) / PixTilling152 ) + float2( 0,0.01 ) + ( _seed1 * mulTime113 ) ) ).r - _Dissolve );
				float clampResult522 = clamp( Mask1164 , 0.0 , 1.0 );
				float2 uv2_Pix2Map = IN.ase_texcoord.xy * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _TimeParameters.x * 0.1;
				float4 tex2DNode82 = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed202 + uv2_Pix2Map ) * PixTilling152 ) ) / PixTilling152 ) + ( _seed2 * mulTime109 ) ) );
				float temp_output_180_0 = step( clampResult522 , tex2DNode82.r );
				float2 texCoord361 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float saferPower235 = abs( pow( texCoord361.x , 1.8 ) );
				float temp_output_235_0 = pow( saferPower235 , _DissolvePower );
				float clampResult495 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * temp_output_235_0 ) ) , 0.0 , 1.0 );
				float clampResult488 = clamp( ( _ShadowAlpha * ( ( temp_output_180_0 * IN.ase_color.r ) * ( 1.0 - clampResult495 ) ) ) , 0.0 , 1.0 );
				float MaskShadow277 = clampResult488;
				float clampResult485 = clamp( ( IN.ase_color.g * _RootAlpha ) , 0.0 , 1.0 );
				float MaskRoot289 = clampResult485;
				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * temp_output_235_0 ) , _DissolveTail);
				float clampResult523 = clamp( ( tex2DNode82.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );
				float2 uv2_SquareMap = IN.ase_texcoord.xy * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 tex2DNode197 = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed202 ) * PixTilling152 ) );
				float temp_output_198_0 = step( clampResult523 , tex2DNode197.r );
				float temp_output_212_0 = ( temp_output_180_0 * temp_output_198_0 );
				float fangkuaiTex426 = tex2DNode197.r;
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep( fangkuaiTex426 , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * IN.ase_color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMaskBase423 = clampResult487;
				float clampResult486 = clamp( ( ( IN.ase_color.r * temp_output_212_0 ) - EdgeMaskBase423 ) , 0.0 , 1.0 );
				float MaskPxl287 = clampResult486;
				float clampResult524 = clamp( ( ( 1.0 - max( IN.ase_color.r , IN.ase_color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float MaskMid324 = clampResult524;
				float MaskPxlBase492 = temp_output_212_0;
				float temp_output_490_0 = ( EdgeMaskBase423 * MaskPxlBase492 );
				float clampResult438 = clamp( ( MaskShadow277 + MaskRoot289 + MaskPxl287 + MaskMid324 + temp_output_490_0 ) , 0.0 , 1.0 );
				float Alpha300 = clampResult438;
				

				surfaceDescription.Alpha = Alpha300;
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
			#pragma multi_compile_instancing
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

			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
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
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Pix1Map;
			sampler2D _Pix2Map;
			sampler2D _SquareMap;


			
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

				o.ase_texcoord1.xy = v.ase_texcoord1.xy;
				o.ase_color = v.ase_color;
				
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv2_Pix1Map = IN.ase_texcoord1.xy * _Pix1Map_ST.xy + _Pix1Map_ST.zw;
				float mulTime299 = _TimeParameters.x * 0.1;
				float2 FlowSpeed202 = ( _Speed * mulTime299 );
				int PixTilling152 = _PixTilling;
				float mulTime113 = _TimeParameters.x * 0.1;
				float Mask1164 = ( tex2D( _Pix1Map, ( ( floor( ( ( uv2_Pix1Map + FlowSpeed202 ) * PixTilling152 ) ) / PixTilling152 ) + float2( 0,0.01 ) + ( _seed1 * mulTime113 ) ) ).r - _Dissolve );
				float clampResult522 = clamp( Mask1164 , 0.0 , 1.0 );
				float2 uv2_Pix2Map = IN.ase_texcoord1.xy * _Pix2Map_ST.xy + _Pix2Map_ST.zw;
				float mulTime109 = _TimeParameters.x * 0.1;
				float4 tex2DNode82 = tex2D( _Pix2Map, ( ( floor( ( ( FlowSpeed202 + uv2_Pix2Map ) * PixTilling152 ) ) / PixTilling152 ) + ( _seed2 * mulTime109 ) ) );
				float temp_output_180_0 = step( clampResult522 , tex2DNode82.r );
				float2 texCoord361 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float saferPower235 = abs( pow( texCoord361.x , 1.8 ) );
				float temp_output_235_0 = pow( saferPower235 , _DissolvePower );
				float clampResult495 = clamp( ( _ShadowBalancee + ( _ShadowDissolve * temp_output_235_0 ) ) , 0.0 , 1.0 );
				float clampResult488 = clamp( ( _ShadowAlpha * ( ( temp_output_180_0 * IN.ase_color.r ) * ( 1.0 - clampResult495 ) ) ) , 0.0 , 1.0 );
				float MaskShadow277 = clampResult488;
				float clampResult485 = clamp( ( IN.ase_color.g * _RootAlpha ) , 0.0 , 1.0 );
				float MaskRoot289 = clampResult485;
				float lerpResult211 = lerp( 0.0 , ( _DissolveIntensity * temp_output_235_0 ) , _DissolveTail);
				float clampResult523 = clamp( ( tex2DNode82.r + lerpResult211 + _DissolveBalance ) , 0.0 , 1.0 );
				float2 uv2_SquareMap = IN.ase_texcoord1.xy * _SquareMap_ST.xy + _SquareMap_ST.zw;
				float4 tex2DNode197 = tex2D( _SquareMap, ( ( uv2_SquareMap + FlowSpeed202 ) * PixTilling152 ) );
				float temp_output_198_0 = step( clampResult523 , tex2DNode197.r );
				float temp_output_212_0 = ( temp_output_180_0 * temp_output_198_0 );
				float fangkuaiTex426 = tex2DNode197.r;
				float BasePxlGradient306 = clampResult523;
				float smoothstepResult409 = smoothstep( fangkuaiTex426 , ( BasePxlGradient306 + _EdgeScale ) , BasePxlGradient306);
				float clampResult487 = clamp( ( (( step( ( 1.0 - 0.6 ) , ( 1.0 - smoothstepResult409 ) ) * IN.ase_color.r )).x * _EdgeAlpha * 10.0 ) , 0.0 , 1.0 );
				float EdgeMaskBase423 = clampResult487;
				float clampResult486 = clamp( ( ( IN.ase_color.r * temp_output_212_0 ) - EdgeMaskBase423 ) , 0.0 , 1.0 );
				float MaskPxl287 = clampResult486;
				float clampResult524 = clamp( ( ( 1.0 - max( IN.ase_color.r , IN.ase_color.g ) ) * _MidAlpha ) , 0.0 , 1.0 );
				float MaskMid324 = clampResult524;
				float MaskPxlBase492 = temp_output_212_0;
				float temp_output_490_0 = ( EdgeMaskBase423 * MaskPxlBase492 );
				float clampResult438 = clamp( ( MaskShadow277 + MaskRoot289 + MaskPxl287 + MaskMid324 + temp_output_490_0 ) , 0.0 , 1.0 );
				float Alpha300 = clampResult438;
				

				surfaceDescription.Alpha = Alpha300;
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
Node;AmplifyShaderEditor.CommentaryNode;468;-4834.618,-870.7404;Inherit;False;5786.802;2331.255;Comment;101;202;108;299;106;300;302;322;328;320;324;456;329;438;460;445;446;200;235;291;361;292;293;211;239;82;85;204;467;206;174;170;152;83;95;180;120;109;110;91;198;306;408;212;164;203;199;115;287;461;462;286;289;444;353;354;277;290;246;276;382;383;426;197;395;113;112;97;142;143;96;104;171;173;86;141;84;117;195;205;194;94;103;485;486;488;491;490;492;495;497;501;505;506;507;512;513;520;521;522;523;524;PixFlow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;465;-399.2463,1684.713;Inherit;False;2024.752;562.7627;EdgeMask;17;430;457;458;409;422;413;425;427;421;420;419;429;431;423;487;493;494;EdgeMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;348;-4851.659,1692.184;Inherit;False;1776.707;602.5183;ReflectMap;12;337;338;334;336;345;341;340;343;344;335;339;532;ReflectMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;275;-2912.178,1691.169;Inherit;False;2396.271;374.8401;MatCap;12;220;221;222;223;224;226;227;228;229;230;231;526;MatCap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;248;-2963.591,2437.711;Inherit;False;2565.733;656.45;Spark;31;249;255;271;269;268;267;266;265;264;259;258;256;254;253;252;250;272;270;274;471;474;475;476;472;477;470;469;473;529;530;531;SparkCol;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;384;-4000.281,2423.58;Inherit;False;976.335;655.5257;Fresnel;7;390;387;389;388;386;385;527;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;421;485.3931,1822.672;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;419;694.4952,1785.922;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-816.3378,2626.064;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-1911.522,1779.686;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-2126.814,1864.253;Inherit;False;NDirWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-2478.178,1756.009;Inherit;False;NDirTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;222;-1711.742,1783.879;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;223;-1562.076,1777.669;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;430;805.2656,1951.041;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;256;-1866.046,2794.831;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-1740.246,2795.231;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;409;171.1646,1822.343;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;1112.714,1954.52;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;494;506.6388,1729.708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;420;165.3596,1734.175;Inherit;False;Constant;_EdgeScaleOut;EdgeScaleOut;19;0;Create;True;0;0;0;False;0;False;0.6;0.6;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;266;-2312.411,2502.33;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;267;-2395.112,2592.629;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;264;-2926.869,2487.3;Inherit;False;Property;_StarTillingSpeed;StarTillingSpeed;36;0;Create;True;0;0;0;False;0;False;1,1,0,0;2,2,-3,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;265;-2711.782,2590.466;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-2536.288,2601.717;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-2720.481,2669.355;Inherit;False;Constant;_Float11;Float 11;42;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;471;-2756.195,2831.671;Inherit;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;472;-2680.937,2934.218;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;475;-2126.588,2834.651;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;474;-2320.199,2736.848;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;476;-2324.199,2880.848;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;470;-2720.726,2740.609;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;259;-2147.669,2508.962;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;422;-49.53731,1926.614;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;413;-351.9891,1958.695;Inherit;False;Property;_EdgeScale;EdgeScale;29;0;Create;True;0;0;0;False;0;False;0.1;0.463;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;477;-2937.388,2938.144;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;473;-2941.948,2743.451;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;249;-1574.87,2988.635;Inherit;False;Property;_StarIntensity;StarIntensity;34;0;Create;True;0;0;0;False;0;False;1;7;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;427;-87.81075,1719.594;Inherit;True;426;fangkuaiTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;486;-173.3823,505.641;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;445;-214.3838,5.20223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;194;-2233.751,994.4606;Inherit;False;1;197;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;109;-2672.947,653.9139;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-2181.921,1154.957;Inherit;False;202;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;382;-648.0421,207.3327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;276;-619.4129,-14.8249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;461;-315.9337,516.722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;462;-523.2414,570.5587;Inherit;False;423;EdgeMaskBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;-536.5202,371.4481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-939.9461,325.5936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;354;-622.1895,100.8396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;-415.8929,26.46938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;-488.412,171.2073;Inherit;False;287;MaskPxl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;460;-312.4771,160.3827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-2728.984,983.296;Inherit;False;Property;_DissolvePower;DissolvePower;18;0;Create;True;0;0;0;False;0;False;2.143974;2.86;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;235;-2404.466,752.2661;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;512;-2686.611,751.4146;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;361;-3015.311,727.826;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;513;-2946.996,836.9888;Inherit;False;Constant;_flo1;flo 1;37;0;Create;True;0;0;0;False;0;False;1.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;488;-94.58564,158.7522;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;490;367.0885,1020.844;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-2459.381,472.0352;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;120;-2663.09,450.8646;Inherit;False;Property;_seed2;seed2;7;0;Create;True;0;0;0;False;0;False;0,2.4;1,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FloorOpNode;142;-2785.702,-423.3146;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-3187.845,-350.1879;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-3508.501,-242.3805;Inherit;False;202;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-3181.38,-166.5541;Inherit;False;152;PixTilling;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2838.01,-200.5509;Inherit;False;152;PixTilling;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-3011.926,-423.7477;Inherit;True;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-2455.061,-129.4584;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;113;-2684.857,-18.69138;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;395;-2684.43,-139.597;Inherit;False;Property;_seed1;seed1;6;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-3530.59,-387.8531;Inherit;False;1;94;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;96;-2635.9,-418.695;Inherit;True;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-957.6467,226.0814;Inherit;False;Property;_RootAlpha;RootAlpha;21;0;Create;True;0;0;0;False;0;False;1;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;386;-3384.806,2646.154;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;-3224.136,2639.678;Inherit;True;Fresnel;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;220;-2085.477,1752.615;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-2828.005,262.582;Inherit;False;152;PixTilling;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;86;-2599.272,123.9825;Inherit;True;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;141;-2782.616,117.9975;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;485;-246.2762,295.2035;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;277;44.39546,154.7804;Inherit;False;MaskShadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;10.80171,320.6138;Inherit;False;MaskRoot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;-16.42142,481.2282;Inherit;False;MaskPxl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;487;1245.336,2001.802;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;1399.605,1999.344;Inherit;False;EdgeMaskBase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;492;-776.0048,318.3831;Inherit;False;MaskPxlBase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;408;-762.8092,735.7025;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;302;-767.2086,662.647;Inherit;False;PxlSize1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;322;-632.159,972.7158;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;520;-445.1702,992.6838;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;320;-549.0449,850.7101;Inherit;False;Constant;_Float6;Float 6;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-515.2053,1198.58;Inherit;False;Property;_MidAlpha;MidAlpha;23;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;-186.1569,932.3472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;521;-332.2003,860.1897;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;524;-55.20019,917.5461;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;99.1806,923.5953;Inherit;False;MaskMid;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;491;102.3692,1213.433;Inherit;True;492;MaskPxlBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;99.15903,1015.215;Inherit;True;423;EdgeMaskBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;501;602.9066,1022.073;Inherit;False;EdgeMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;-739.909,1746.694;Inherit;False;MatCapCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;228;-2474.318,1869.667;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;-4625.559,1815.714;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;335;-4017.404,1904.351;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;-4826.835,1947.686;Inherit;False;224;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;343;-4830.575,1814.201;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.NormalizeNode;340;-4408.244,1815.812;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;341;-4244.943,1816.552;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-4236.436,2027.143;Inherit;False;227;NDirTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;391;1696.613,-662.9058;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;432;2183.756,227.4234;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;393;2183.709,7.702929;Inherit;False;Property;_Light;Light;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;502;2004.367,7.923229;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;1687.906,-25.8508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;516;1284.587,-225.5689;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;504;1872.833,154.994;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;1219.076,217.9729;Inherit;False;287;MaskPxl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;1350.18,-90.18698;Inherit;False;289;MaskRoot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;518;1632.362,1151.005;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;327;1567.209,1064.808;Inherit;False;324;MaskMid;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;439;1430.269,871.6857;Inherit;False;Property;_MidCol;MidCol;22;0;Create;True;0;0;0;False;0;False;0.6320754,0.6320754,0.6320754,0;0.6462264,0.9512035,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;519;1621.141,873.1257;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;1850.307,924.632;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;448;2045.98,568.305;Inherit;False;MidCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;515;2585.732,106.291;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;377;1115.219,625.3146;Inherit;False;Property;_EdgeCol;EdgeCol;30;1;[HDR];Create;True;0;0;0;False;0;False;0.4978195,0.741802,0.9339623,0;0.6462264,0.9507037,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;525;1343.455,624.5905;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;226;-1397.166,1775.904;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;230;-1216.508,1748.404;Inherit;True;Property;_Matcap;Matcap;11;0;Create;True;0;0;0;False;0;False;-1;None;acd36e173046c71458cc25a67d46841a;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;526;-896.5095,1751.999;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;1220.011,-699.6837;Inherit;False;390;Fresnel;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-3747.286,2918.612;Inherit;False;Property;_FresnelPower;FresnelPower;14;0;Create;True;0;0;0;False;0;False;1;3.7;0.1;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;-3517.413,2643.308;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;527;-3660.057,2690.917;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;253;-1083.752,2741.554;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-1215.129,2732.252;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;529;-1315.948,2506.059;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;530;-1354.948,2771.059;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;531;-908.9478,2510.059;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;270;-607.292,2628.238;Inherit;False;SparkCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;338;-3274.354,2025.851;Inherit;False;ReflectCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;131;1098.309,338.0246;Inherit;False;Property;_TailCol;TailCol;24;0;Create;True;0;0;0;False;0;False;0.427451,0.9803922,0.9803922,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;533;1303.252,329.1883;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;535;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;537;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;538;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;539;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;540;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;541;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;542;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;543;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;544;3004.338,160.5074;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-2329.202,595.2988;Inherit;False;Property;_DissolveIntensity;DissolveIntensity;19;0;Create;True;0;0;0;False;0;False;2.143974;2.200459;0.1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-2235.375,348.956;Inherit;False;Property;_ShadowBalancee;ShadowBalancee;27;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;-2106.848,431.7043;Inherit;False;2;2;0;FLOAT;0.86;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;497;-2377.377,427.8471;Inherit;False;Property;_ShadowDissolve;ShadowDissolve;26;0;Create;True;0;0;0;False;0;False;2.381026;2.381026;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-2288.376,-418.0454;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0.01;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-2297.794,121.9121;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;-1135.499,1103.45;Inherit;False;fangkuaiTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-1171.051,417.6351;Inherit;False;BasePxlGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;198;-1125.958,668.9865;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;-1946.608,1062.939;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1669.433,1062.928;Inherit;True;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;200;-2057.094,865.7538;Inherit;False;Property;_DissolveTail;DissolveTail;17;0;Create;True;0;0;0;False;0;False;2.143974;0.62;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;467;-1947.607,1192.911;Inherit;False;152;PixTilling;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-1715.9,765.5179;Inherit;False;Property;_DissolveBalance;DissolveBalance;20;0;Create;True;0;0;0;False;0;False;0;-0.4;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;523;-1274.575,570.73;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;197;-1430.728,1053.666;Inherit;True;Property;_SquareMap;SquareMap;4;0;Create;True;0;0;0;False;0;False;-1;None;a6ab19bd9461f0145aad538ffacf783d;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1972.287,596.4013;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;505;-1940.581,350.3512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;495;-1766.213,275.6885;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;211;-1766.364,502.3051;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;199;-1483.082,458.4646;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;-1797.273,81.70709;Inherit;True;Property;_Pix2Map;Pix2Map;3;0;Create;True;0;0;0;False;0;False;-1;10c8833c53acc224cae79c276f7882dc;e73da1081bab94b4eb361a3eae7f865e;True;1;False;black;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;180;-1181.468,-22.53723;Inherit;True;2;0;FLOAT;1.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;489;1346.181,1153.338;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;655770a14a4aeac4b8f0e7f26940e970;True;0;False;white;Auto;False;Instance;218;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;336;-3459.929,2031.993;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;532;-3592.784,1879.421;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;387;-3934.625,2698.941;Inherit;True;Property;_FresnelMap;FresnelMap;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;334;-3877.46,1874.899;Inherit;True;Property;_ReflectMap;ReflectMap;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;229;-2862.178,1836.009;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;258;-1629.178,2757.687;Inherit;True;Property;_StarMap02;StarMap02;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;274;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;274;-1624.693,2481.206;Inherit;True;Property;_SparkTex;SparkTex;32;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;425;-349.9954,1743.968;Inherit;True;306;BasePxlGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2029.47,-151.8249;Inherit;False;Property;_Dissolve;Dissolve;16;0;Create;True;0;0;0;False;0;False;0.001407384;0.43;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-1718.919,-282.139;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;164;-1571.149,-278.5533;Inherit;True;Mask1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;522;-1379.957,-277.2666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-3913.089,-120.5926;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;83;-4136.612,-412.2247;Inherit;False;Property;_PixTilling;PixTilling;5;0;Create;True;0;0;0;False;0;False;6;13;False;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-3936.052,-412.893;Inherit;False;PixTilling;-1;True;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.VertexColorNode;246;-941.5485,5.384164;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;290;263.637,318.8123;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;438;428.973,317.8779;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;641.1498,312.2435;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;-761.9164,-93.70094;Inherit;False;Property;_ShadowAlpha;ShadowAlpha;28;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;1574.488,346.7795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;464;1898.476,394.2451;Inherit;False;463;LightCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;1268.681,527.4452;Inherit;False;501;EdgeMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;429;491.4877,2042.143;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;431;987.5642,1869.093;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;458;765.5802,2166.221;Inherit;False;Property;_EdgeAlpha;EdgeAlpha;31;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;493;1091.596,2177.966;Inherit;False;Constant;_flo_0;flo_0;35;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;271;-1114.223,2482.531;Inherit;False;Property;_StarCol;StarCol;33;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;2.996078,2.996078,2.996078,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;250;-1196.948,2988.394;Inherit;False;Property;_StarPower;StarPower;35;0;Create;True;0;0;0;False;0;False;1;2.5;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-1890.86,2932.173;Inherit;False;Constant;_Flo2;Flo2;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;-2677.594,3012.843;Inherit;False;Constant;_Float14;Float14;28;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;388;-3871.913,2592.542;Inherit;False;Property;_FrsnelIntensity;FrsnelIntensity;13;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-3804.216,2140.479;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;12;0;Create;True;0;0;0;False;0;False;1;0.288;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3028.664,118.4297;Inherit;True;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-3235.864,258.5476;Inherit;False;152;PixTilling;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-3579.467,214.9652;Inherit;False;1;82;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-3197.757,118.0542;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-3543.705,107.3046;Inherit;False;202;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-3773.874,-124.6424;Inherit;False;FlowSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;442;1063.017,-225.4839;Inherit;False;Property;_ShadowCol;ShadowCol;25;1;[HDR];Create;True;0;0;0;False;0;False;0.6320754,0.6320754,0.6320754,0;0.4896759,0.7722677,0.7924528,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;440;1264.528,-304.8634;Inherit;False;277;MaskShadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;1213.848,-777.5413;Inherit;False;231;MatCapCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;1218.194,-626.4643;Inherit;False;270;SparkCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;1214.19,-556.1376;Inherit;False;338;ReflectCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;463;1892.907,-669.2253;Inherit;False;LightCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;1790.052,-237.7739;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;218;984.6792,-11.12738;Inherit;True;Property;_BaseMap;BaseMap;0;0;Create;True;0;0;0;False;0;False;-1;None;655770a14a4aeac4b8f0e7f26940e970;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;517;1354.665,-10.80346;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;1566.57,179.0344;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;536;2994.338,113.174;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;QF/NssFX/NssFX_ASE/FX_ASE_PixelFlow_Paxton;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638487579921432269;  Use Shadow Threshold;0;0;Receive Shadows;0;638487579929735908;GPU Instancing;1;638487579992640697;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;452;2568.584,183.3707;Inherit;False;300;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;2365.069,109.1251;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;94;-2010.87,-548.4995;Inherit;True;Property;_Pix1Map;Pix1Map;2;0;Create;True;0;0;0;False;0;False;-1;2d834d0305d240a4990b7722ccd3537d;94ab701356a2f5b4b8d61d90dc7a302d;True;1;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;106;-4146.48,-195.514;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;0;False;0;False;0,0;-2,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;545;-2653.189,-723.2357;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;546;-2652.352,-968.3898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;299;-4160.89,-30.32652;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
WireConnection;421;0;409;0
WireConnection;419;0;494;0
WireConnection;419;1;421;0
WireConnection;272;0;531;0
WireConnection;272;1;253;0
WireConnection;221;0;220;0
WireConnection;221;1;224;0
WireConnection;224;0;228;0
WireConnection;227;0;229;0
WireConnection;222;0;221;0
WireConnection;223;0;222;0
WireConnection;430;0;419;0
WireConnection;430;1;429;1
WireConnection;256;0;259;0
WireConnection;256;1;475;0
WireConnection;254;0;256;0
WireConnection;254;1;255;0
WireConnection;409;0;425;0
WireConnection;409;1;427;0
WireConnection;409;2;422;0
WireConnection;457;0;431;0
WireConnection;457;1;458;0
WireConnection;457;2;493;0
WireConnection;494;0;420;0
WireConnection;266;0;264;0
WireConnection;267;0;268;0
WireConnection;265;0;264;0
WireConnection;268;0;265;0
WireConnection;268;1;269;0
WireConnection;472;0;477;0
WireConnection;475;0;474;0
WireConnection;475;1;476;0
WireConnection;474;0;470;0
WireConnection;474;1;471;0
WireConnection;476;0;472;0
WireConnection;476;1;469;0
WireConnection;470;0;473;0
WireConnection;259;0;266;0
WireConnection;259;1;267;0
WireConnection;422;0;425;0
WireConnection;422;1;413;0
WireConnection;486;0;461;0
WireConnection;445;0;446;0
WireConnection;445;1;353;0
WireConnection;382;0;246;2
WireConnection;382;1;383;0
WireConnection;276;0;180;0
WireConnection;276;1;246;1
WireConnection;461;0;286;0
WireConnection;461;1;462;0
WireConnection;286;0;246;1
WireConnection;286;1;212;0
WireConnection;212;0;180;0
WireConnection;212;1;198;0
WireConnection;354;0;495;0
WireConnection;353;0;276;0
WireConnection;353;1;354;0
WireConnection;460;0;444;0
WireConnection;235;0;512;0
WireConnection;235;1;291;0
WireConnection;512;0;361;1
WireConnection;512;1;513;0
WireConnection;488;0;445;0
WireConnection;490;0;456;0
WireConnection;490;1;491;0
WireConnection;110;0;120;0
WireConnection;110;1;109;0
WireConnection;142;0;97;0
WireConnection;104;0;95;0
WireConnection;104;1;203;0
WireConnection;97;0;104;0
WireConnection;97;1;170;0
WireConnection;112;0;395;0
WireConnection;112;1;113;0
WireConnection;96;0;142;0
WireConnection;96;1;171;0
WireConnection;386;0;385;0
WireConnection;386;1;389;0
WireConnection;390;0;386;0
WireConnection;86;0;141;0
WireConnection;86;1;174;0
WireConnection;141;0;84;0
WireConnection;485;0;382;0
WireConnection;277;0;488;0
WireConnection;289;0;485;0
WireConnection;287;0;486;0
WireConnection;487;0;457;0
WireConnection;423;0;487;0
WireConnection;492;0;212;0
WireConnection;408;0;198;0
WireConnection;302;0;198;0
WireConnection;520;0;322;1
WireConnection;520;1;322;2
WireConnection;329;0;521;0
WireConnection;329;1;328;0
WireConnection;521;0;320;0
WireConnection;521;1;520;0
WireConnection;524;0;329;0
WireConnection;324;0;524;0
WireConnection;501;0;490;0
WireConnection;231;0;526;0
WireConnection;228;0;229;0
WireConnection;339;0;343;0
WireConnection;339;1;344;0
WireConnection;335;0;341;0
WireConnection;335;1;345;0
WireConnection;340;0;339;0
WireConnection;341;0;340;0
WireConnection;391;0;233;0
WireConnection;391;1;392;0
WireConnection;391;2;273;0
WireConnection;391;3;349;0
WireConnection;432;0;502;0
WireConnection;432;1;459;0
WireConnection;432;2;464;0
WireConnection;432;3;448;0
WireConnection;502;0;441;0
WireConnection;502;1;504;0
WireConnection;301;0;314;0
WireConnection;301;1;517;0
WireConnection;516;0;442;0
WireConnection;504;0;301;0
WireConnection;504;1;433;0
WireConnection;518;0;489;0
WireConnection;519;0;439;0
WireConnection;326;0;519;0
WireConnection;326;1;327;0
WireConnection;326;2;518;0
WireConnection;448;0;326;0
WireConnection;515;0;394;0
WireConnection;525;0;377;0
WireConnection;226;0;223;0
WireConnection;230;1;226;0
WireConnection;526;0;230;0
WireConnection;385;0;388;0
WireConnection;385;1;527;0
WireConnection;527;0;387;0
WireConnection;253;0;252;0
WireConnection;253;1;250;0
WireConnection;252;0;529;0
WireConnection;252;1;530;0
WireConnection;252;2;249;0
WireConnection;529;0;274;0
WireConnection;530;0;258;0
WireConnection;531;0;271;0
WireConnection;270;0;272;0
WireConnection;338;0;336;0
WireConnection;533;0;131;0
WireConnection;507;0;497;0
WireConnection;507;1;235;0
WireConnection;143;0;96;0
WireConnection;143;2;112;0
WireConnection;91;0;86;0
WireConnection;91;1;110;0
WireConnection;426;0;197;1
WireConnection;306;0;523;0
WireConnection;198;0;523;0
WireConnection;198;1;197;1
WireConnection;205;0;194;0
WireConnection;205;1;206;0
WireConnection;195;0;205;0
WireConnection;195;1;467;0
WireConnection;523;0;199;0
WireConnection;197;1;195;0
WireConnection;293;0;292;0
WireConnection;293;1;235;0
WireConnection;505;0;506;0
WireConnection;505;1;507;0
WireConnection;495;0;505;0
WireConnection;211;1;293;0
WireConnection;211;2;200;0
WireConnection;199;0;82;1
WireConnection;199;1;211;0
WireConnection;199;2;239;0
WireConnection;82;1;91;0
WireConnection;180;0;522;0
WireConnection;180;1;82;1
WireConnection;336;0;532;0
WireConnection;336;1;337;0
WireConnection;532;0;334;0
WireConnection;387;1;335;0
WireConnection;334;1;335;0
WireConnection;258;1;254;0
WireConnection;274;1;259;0
WireConnection;117;0;94;1
WireConnection;117;1;115;0
WireConnection;164;0;117;0
WireConnection;522;0;164;0
WireConnection;108;0;106;0
WireConnection;108;1;299;0
WireConnection;152;0;83;0
WireConnection;290;0;277;0
WireConnection;290;1;289;0
WireConnection;290;2;287;0
WireConnection;290;3;324;0
WireConnection;290;4;490;0
WireConnection;438;0;290;0
WireConnection;300;0;438;0
WireConnection;459;0;428;0
WireConnection;459;1;525;0
WireConnection;431;0;430;0
WireConnection;84;0;103;0
WireConnection;84;1;173;0
WireConnection;103;0;204;0
WireConnection;103;1;85;0
WireConnection;202;0;108;0
WireConnection;463;0;391;0
WireConnection;441;0;440;0
WireConnection;441;1;516;0
WireConnection;441;2;517;0
WireConnection;517;0;218;0
WireConnection;433;0;517;0
WireConnection;433;1;434;0
WireConnection;433;2;533;0
WireConnection;536;2;515;0
WireConnection;536;3;452;0
WireConnection;394;0;393;0
WireConnection;394;1;432;0
WireConnection;94;1;143;0
ASEEND*/
//CHKSM=A558B49D8059B289CA5348A2D249FD19EEF04B3F