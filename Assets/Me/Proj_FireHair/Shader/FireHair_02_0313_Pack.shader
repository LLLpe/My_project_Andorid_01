// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PaxtonLiu/FireHair_02"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainTexCol("MainTexCol", Color) = (0,0,0,0)
		_Noise01("Noise01", 2D) = "white" {}
		_Frequence("Frequence", Range( 0 , 10)) = 0.2
		_SineMultilper("Sine Multilper", Range( 0 , 1)) = 0
		_MainTex_NoiseIntensity("MainTex_NoiseIntensity", Float) = 1
		_MainTex01U_Speed("MainTex01U移动", Float) = 0
		_MainTex01_V_Speed("MainTex01V移动", Float) = -0.5
		_Noise02("Noise02", 2D) = "black" {}
		_Maindissolve("Maindissolve", Range( 0 , 2)) = 0.7741094
		_MaskGdissolve("MaskGdissolve", Range( 0 , 2)) = 1.031352
		_Buring("Buring", Range( 0 , 1)) = 0.4041814
		[HDR]_MainTex02_Color("MainTex02_Color", Color) = (1,1,1,1)
		_MainCol02Intensity("MainCol02Intensity", Range( 0 , 1)) = 1
		_MainTex02_NoiseIntensity("MainTex02_NoiseIntensity", Float) = 1
		_MainTex02U_Speed("MainTex02U移动", Float) = 0
		_MainTex02_V_Speed("MainTex02V移动", Float) = -0.5
		_Noisetex("Noise图", 2D) = "white" {}
		_NoiseVqiangdu("Noise强度", Float) = 0
		_mainspeedU2("Noise图U移动", Float) = 0
		_mainspeedV2("Noise图V移动", Float) = 0
		_MaskRG("MaskRG", 2D) = "white" {}
		_Mask_NoiseIntensity("Mask_NoiseIntensity", Float) = 1
		_MaskSpeedU("MaskU移动", Float) = 0
		_MaskSpeedU1("MaskV移动", Float) = 0
		_OffsetTex4("OffsetTex4", 2D) = "white" {}
		_VertexOffsetTimeZoomer("VertexOffsetTimeZoomer", Float) = 0
		_VertexOffsetScrollSpeed("VertexOffsetScrollSpeed", Float) = 0
		_VertexOffsetFactor4("VertexOffsetFactor4", Float) = 0
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_ColorEdgeIntensity("ColorEdgeIntensity", Range( 0 , 1)) = 1
		_NormalOffset("NormalOffset", Range( 0 , 1)) = 0.01
		_Flare("尾焰", Range( 0 , 1)) = 0
		[Toggle]_OneMinusR("One Minus R", Float) = 0
		_G_Sub("G_Sub", Float) = 0
		[Toggle(_ADD_B_ON)] _Add_B("Add_B", Float) = 0
		_Col_Root0("Col_Root0", Color) = (1,1,1,0)
		[ASEEnd][Toggle(_LERPA_ON)] _LerpA("LerpA", Float) = 0
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

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" "IgnoreProjector"="True" }

		Cull Off
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		#pragma only_renderers d3d11 // ensure rendering platforms toggle list is visible

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
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009
			#define REQUIRE_DEPTH_TEXTURE 1


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
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _LERPA_ON
			#pragma shader_feature_local _ADD_B_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
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
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OffsetTex4_ST;
			float4 _Noise02_ST;
			float4 _Color0;
			float4 _Col_Root0;
			float4 _Noisetex_ST;
			float4 _Noise01_ST;
			float4 _MainTex02_Color;
			float4 _MaskRG_ST;
			float4 _MainTex_ST;
			float4 _MainTexCol;
			float _MaskSpeedU1;
			float _Maindissolve;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _NormalOffset;
			float _Frequence;
			float _SineMultilper;
			float _ColorEdgeIntensity;
			float _G_Sub;
			float _MainTex_NoiseIntensity;
			float _MainTex02_V_Speed;
			float _Mask_NoiseIntensity;
			float _Buring;
			float _MainTex02U_Speed;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			float _MainTex02_NoiseIntensity;
			float _MaskGdissolve;
			float _MainCol02Intensity;
			float _OneMinusR;
			float _VertexOffsetFactor4;
			float _VertexOffsetTimeZoomer;
			float _VertexOffsetScrollSpeed;
			float _MaskSpeedU;
			float _Flare;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _OffsetTex4;
			sampler2D _MainTex;
			sampler2D _Noise02;
			sampler2D _Noisetex;
			sampler2D _MaskRG;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _Noise01;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_OffsetTex4 = v.ase_texcoord.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _OffsetTex4, float4( ( uv_OffsetTex4 + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.ase_color.r ) ):( v.ase_color.r )) );
				
				float3 PosOS528 = ( v.vertex.xyz + VertexOffset4367 );
				float3 customSurfaceDepth487 = PosOS528;
				float customEye487 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth487 )).z;
				o.ase_texcoord3.z = customEye487;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord4 = v.vertex;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexOffset4367;

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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_537_0 = ( tex2D( _MainTex, uv_MainTex ) * _MainTexCol );
				float3 temp_output_272_0 = (_MainTex02_Color).rgb;
				float2 uv_Noisetex = IN.ase_texcoord3.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				float2 uv_Noise02 = IN.ase_texcoord3.xy * _Noise02_ST.xy + _Noise02_ST.zw;
				float2 appendResult185 = (float2(_MainTex02U_Speed , _MainTex02_V_Speed));
				float2 uv_MaskRG = IN.ase_texcoord3.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float2 appendResult75 = (float2(_MaskSpeedU , _MaskSpeedU1));
				float4 tex2DNode79 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise94 ) + uv_MaskRG ) + ( appendResult75 * _TimeParameters.x ) ) );
				float MaskB276 = tex2DNode79.b;
				float saferPower446 = abs( MaskB276 );
				float temp_output_266_0 = ( _MainCol02Intensity * step( _MaskGdissolve , ( ( tex2D( _Noise02, ( ( ( _MainTex02_NoiseIntensity * Noise94 ) + uv_Noise02 ) + ( appendResult185 * _TimeParameters.x ) ) ).r * pow( saferPower446 , _G_Sub ) ) + 0.0 ) ) );
				float3 MainCol02194 = ( temp_output_272_0 * temp_output_266_0 );
				float Alpha02253 = temp_output_266_0;
				float4 lerpResult260 = lerp( temp_output_537_0 , float4( MainCol02194 , 0.0 ) , Alpha02253);
				float4 FinalRGB248 = lerpResult260;
				float4 EdgeColor497 = ( _ColorEdgeIntensity * _Color0 );
				float3 objToViewDir514 = mul( UNITY_MATRIX_IT_MV, float4( IN.ase_normal, 0 ) ).xyz;
				float3 appendResult515 = (float3(objToViewDir514));
				float2 uv_OffsetTex4 = IN.ase_texcoord3.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2D( _OffsetTex4, ( uv_OffsetTex4 + mulTime359 ) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - IN.ase_color.r ) ):( IN.ase_color.r )) );
				float3 PosOS528 = ( IN.ase_texcoord4.xyz + VertexOffset4367 );
				float3 objToView509 = mul( UNITY_MATRIX_MV, float4( PosOS528, 1 ) ).xyz;
				float3 appendResult505 = (float3(objToView509));
				float3 temp_output_507_0 = ( ( _NormalOffset * appendResult515 ) + appendResult505 );
				float4 appendResult504 = (float4(temp_output_507_0 , 1.0));
				float4 computeScreenPos512 = ComputeScreenPos( mul( UNITY_MATRIX_P, appendResult504 ) );
				computeScreenPos512 = computeScreenPos512 / computeScreenPos512.w;
				computeScreenPos512.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos512.z : computeScreenPos512.z* 0.5 + 0.5;
				float eyeDepth488 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( computeScreenPos512.xy ),_ZBufferParams);
				float customEye487 = IN.ase_texcoord3.z;
				float EdgeMask501 = saturate( ( eyeDepth488 - customEye487 ) );
				float4 lerpResult502 = lerp( FinalRGB248 , EdgeColor497 , EdgeMask501);
				float MaskA282 = tex2DNode79.a;
				#ifdef _LERPA_ON
				float staticSwitch575 = MaskA282;
				#else
				float staticSwitch575 = 0.0;
				#endif
				float4 lerpResult572 = lerp( lerpResult502 , _Col_Root0 , staticSwitch575);
				
				float2 uv_Noise01 = IN.ase_texcoord3.xy * _Noise01_ST.xy + _Noise01_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float2 texCoord483 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break471 = texCoord483;
				float lerpResult472 = lerp( ( break471.x + ( sin( ( _TimeParameters.x * _Frequence ) ) * _SineMultilper ) ) , break471.x , pow( break471.y , 2.8 ));
				float2 appendResult480 = (float2(lerpResult472 , 0.0));
				float2 UVOffset485 = appendResult480;
				float4 tex2DNode109 = tex2D( _Noise01, ( ( ( _MainTex_NoiseIntensity * Noise94 ) + uv_Noise01 ) + ( appendResult99 * _TimeParameters.x ) + UVOffset485 ) );
				#ifdef _ADD_B_ON
				float staticSwitch569 = MaskB276;
				#else
				float staticSwitch569 = 0.0;
				#endif
				float MaskR81 = tex2DNode79.r;
				float2 texCoord438 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult462 = lerp( MaskR81 , ( 1.0 - texCoord438.y ) , _Buring);
				float MaskRTerm566 = ( staticSwitch569 + lerpResult462 );
				float saferPower440 = abs( MaskRTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( MaskRTerm566 , 0.3 ) , _Flare);
				float Alpha01254 = step( _Maindissolve , ( ( tex2DNode109.r * lerpResult541 ) + temp_output_440_0 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult572.rgb;
				float Alpha = Alpha01254;
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
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _ADD_B_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OffsetTex4_ST;
			float4 _Noise02_ST;
			float4 _Color0;
			float4 _Col_Root0;
			float4 _Noisetex_ST;
			float4 _Noise01_ST;
			float4 _MainTex02_Color;
			float4 _MaskRG_ST;
			float4 _MainTex_ST;
			float4 _MainTexCol;
			float _MaskSpeedU1;
			float _Maindissolve;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _NormalOffset;
			float _Frequence;
			float _SineMultilper;
			float _ColorEdgeIntensity;
			float _G_Sub;
			float _MainTex_NoiseIntensity;
			float _MainTex02_V_Speed;
			float _Mask_NoiseIntensity;
			float _Buring;
			float _MainTex02U_Speed;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			float _MainTex02_NoiseIntensity;
			float _MaskGdissolve;
			float _MainCol02Intensity;
			float _OneMinusR;
			float _VertexOffsetFactor4;
			float _VertexOffsetTimeZoomer;
			float _VertexOffsetScrollSpeed;
			float _MaskSpeedU;
			float _Flare;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _OffsetTex4;
			sampler2D _Noise01;
			sampler2D _Noisetex;
			sampler2D _MaskRG;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_OffsetTex4 = v.ase_texcoord.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _OffsetTex4, float4( ( uv_OffsetTex4 + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.ase_color.r ) ):( v.ase_color.r )) );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexOffset4367;

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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Noisetex = IN.ase_texcoord2.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				float2 uv_Noise01 = IN.ase_texcoord2.xy * _Noise01_ST.xy + _Noise01_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float2 texCoord483 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break471 = texCoord483;
				float lerpResult472 = lerp( ( break471.x + ( sin( ( _TimeParameters.x * _Frequence ) ) * _SineMultilper ) ) , break471.x , pow( break471.y , 2.8 ));
				float2 appendResult480 = (float2(lerpResult472 , 0.0));
				float2 UVOffset485 = appendResult480;
				float4 tex2DNode109 = tex2D( _Noise01, ( ( ( _MainTex_NoiseIntensity * Noise94 ) + uv_Noise01 ) + ( appendResult99 * _TimeParameters.x ) + UVOffset485 ) );
				float2 uv_MaskRG = IN.ase_texcoord2.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float2 appendResult75 = (float2(_MaskSpeedU , _MaskSpeedU1));
				float4 tex2DNode79 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise94 ) + uv_MaskRG ) + ( appendResult75 * _TimeParameters.x ) ) );
				float MaskB276 = tex2DNode79.b;
				#ifdef _ADD_B_ON
				float staticSwitch569 = MaskB276;
				#else
				float staticSwitch569 = 0.0;
				#endif
				float MaskR81 = tex2DNode79.r;
				float2 texCoord438 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult462 = lerp( MaskR81 , ( 1.0 - texCoord438.y ) , _Buring);
				float MaskRTerm566 = ( staticSwitch569 + lerpResult462 );
				float saferPower440 = abs( MaskRTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( MaskRTerm566 , 0.3 ) , _Flare);
				float Alpha01254 = step( _Maindissolve , ( ( tex2DNode109.r * lerpResult541 ) + temp_output_440_0 ) );
				

				float Alpha = Alpha01254;
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

			#pragma shader_feature_local _ADD_B_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
			float4 _OffsetTex4_ST;
			float4 _Noise02_ST;
			float4 _Color0;
			float4 _Col_Root0;
			float4 _Noisetex_ST;
			float4 _Noise01_ST;
			float4 _MainTex02_Color;
			float4 _MaskRG_ST;
			float4 _MainTex_ST;
			float4 _MainTexCol;
			float _MaskSpeedU1;
			float _Maindissolve;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _NormalOffset;
			float _Frequence;
			float _SineMultilper;
			float _ColorEdgeIntensity;
			float _G_Sub;
			float _MainTex_NoiseIntensity;
			float _MainTex02_V_Speed;
			float _Mask_NoiseIntensity;
			float _Buring;
			float _MainTex02U_Speed;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			float _MainTex02_NoiseIntensity;
			float _MaskGdissolve;
			float _MainCol02Intensity;
			float _OneMinusR;
			float _VertexOffsetFactor4;
			float _VertexOffsetTimeZoomer;
			float _VertexOffsetScrollSpeed;
			float _MaskSpeedU;
			float _Flare;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _OffsetTex4;
			sampler2D _Noise01;
			sampler2D _Noisetex;
			sampler2D _MaskRG;


			
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

				float2 uv_OffsetTex4 = v.ase_texcoord.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _OffsetTex4, float4( ( uv_OffsetTex4 + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.ase_color.r ) ):( v.ase_color.r )) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexOffset4367;

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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Noisetex = IN.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				float2 uv_Noise01 = IN.ase_texcoord.xy * _Noise01_ST.xy + _Noise01_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float2 texCoord483 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break471 = texCoord483;
				float lerpResult472 = lerp( ( break471.x + ( sin( ( _TimeParameters.x * _Frequence ) ) * _SineMultilper ) ) , break471.x , pow( break471.y , 2.8 ));
				float2 appendResult480 = (float2(lerpResult472 , 0.0));
				float2 UVOffset485 = appendResult480;
				float4 tex2DNode109 = tex2D( _Noise01, ( ( ( _MainTex_NoiseIntensity * Noise94 ) + uv_Noise01 ) + ( appendResult99 * _TimeParameters.x ) + UVOffset485 ) );
				float2 uv_MaskRG = IN.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float2 appendResult75 = (float2(_MaskSpeedU , _MaskSpeedU1));
				float4 tex2DNode79 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise94 ) + uv_MaskRG ) + ( appendResult75 * _TimeParameters.x ) ) );
				float MaskB276 = tex2DNode79.b;
				#ifdef _ADD_B_ON
				float staticSwitch569 = MaskB276;
				#else
				float staticSwitch569 = 0.0;
				#endif
				float MaskR81 = tex2DNode79.r;
				float2 texCoord438 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult462 = lerp( MaskR81 , ( 1.0 - texCoord438.y ) , _Buring);
				float MaskRTerm566 = ( staticSwitch569 + lerpResult462 );
				float saferPower440 = abs( MaskRTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( MaskRTerm566 , 0.3 ) , _Flare);
				float Alpha01254 = step( _Maindissolve , ( ( tex2DNode109.r * lerpResult541 ) + temp_output_440_0 ) );
				

				surfaceDescription.Alpha = Alpha01254;
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

			#pragma shader_feature_local _ADD_B_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
			float4 _OffsetTex4_ST;
			float4 _Noise02_ST;
			float4 _Color0;
			float4 _Col_Root0;
			float4 _Noisetex_ST;
			float4 _Noise01_ST;
			float4 _MainTex02_Color;
			float4 _MaskRG_ST;
			float4 _MainTex_ST;
			float4 _MainTexCol;
			float _MaskSpeedU1;
			float _Maindissolve;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _NormalOffset;
			float _Frequence;
			float _SineMultilper;
			float _ColorEdgeIntensity;
			float _G_Sub;
			float _MainTex_NoiseIntensity;
			float _MainTex02_V_Speed;
			float _Mask_NoiseIntensity;
			float _Buring;
			float _MainTex02U_Speed;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			float _MainTex02_NoiseIntensity;
			float _MaskGdissolve;
			float _MainCol02Intensity;
			float _OneMinusR;
			float _VertexOffsetFactor4;
			float _VertexOffsetTimeZoomer;
			float _VertexOffsetScrollSpeed;
			float _MaskSpeedU;
			float _Flare;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _OffsetTex4;
			sampler2D _Noise01;
			sampler2D _Noisetex;
			sampler2D _MaskRG;


			
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

				float2 uv_OffsetTex4 = v.ase_texcoord.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _OffsetTex4, float4( ( uv_OffsetTex4 + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.ase_color.r ) ):( v.ase_color.r )) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset4367;
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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Noisetex = IN.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				float2 uv_Noise01 = IN.ase_texcoord.xy * _Noise01_ST.xy + _Noise01_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float2 texCoord483 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break471 = texCoord483;
				float lerpResult472 = lerp( ( break471.x + ( sin( ( _TimeParameters.x * _Frequence ) ) * _SineMultilper ) ) , break471.x , pow( break471.y , 2.8 ));
				float2 appendResult480 = (float2(lerpResult472 , 0.0));
				float2 UVOffset485 = appendResult480;
				float4 tex2DNode109 = tex2D( _Noise01, ( ( ( _MainTex_NoiseIntensity * Noise94 ) + uv_Noise01 ) + ( appendResult99 * _TimeParameters.x ) + UVOffset485 ) );
				float2 uv_MaskRG = IN.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float2 appendResult75 = (float2(_MaskSpeedU , _MaskSpeedU1));
				float4 tex2DNode79 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise94 ) + uv_MaskRG ) + ( appendResult75 * _TimeParameters.x ) ) );
				float MaskB276 = tex2DNode79.b;
				#ifdef _ADD_B_ON
				float staticSwitch569 = MaskB276;
				#else
				float staticSwitch569 = 0.0;
				#endif
				float MaskR81 = tex2DNode79.r;
				float2 texCoord438 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult462 = lerp( MaskR81 , ( 1.0 - texCoord438.y ) , _Buring);
				float MaskRTerm566 = ( staticSwitch569 + lerpResult462 );
				float saferPower440 = abs( MaskRTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( MaskRTerm566 , 0.3 ) , _Flare);
				float Alpha01254 = step( _Maindissolve , ( ( tex2DNode109.r * lerpResult541 ) + temp_output_440_0 ) );
				

				surfaceDescription.Alpha = Alpha01254;
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

			#pragma shader_feature_local _ADD_B_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
			float4 _OffsetTex4_ST;
			float4 _Noise02_ST;
			float4 _Color0;
			float4 _Col_Root0;
			float4 _Noisetex_ST;
			float4 _Noise01_ST;
			float4 _MainTex02_Color;
			float4 _MaskRG_ST;
			float4 _MainTex_ST;
			float4 _MainTexCol;
			float _MaskSpeedU1;
			float _Maindissolve;
			float _MainTex01U_Speed;
			float _MainTex01_V_Speed;
			float _NormalOffset;
			float _Frequence;
			float _SineMultilper;
			float _ColorEdgeIntensity;
			float _G_Sub;
			float _MainTex_NoiseIntensity;
			float _MainTex02_V_Speed;
			float _Mask_NoiseIntensity;
			float _Buring;
			float _MainTex02U_Speed;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			float _MainTex02_NoiseIntensity;
			float _MaskGdissolve;
			float _MainCol02Intensity;
			float _OneMinusR;
			float _VertexOffsetFactor4;
			float _VertexOffsetTimeZoomer;
			float _VertexOffsetScrollSpeed;
			float _MaskSpeedU;
			float _Flare;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _OffsetTex4;
			sampler2D _Noise01;
			sampler2D _Noisetex;
			sampler2D _MaskRG;


			
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

				float2 uv_OffsetTex4 = v.ase_texcoord.xy * _OffsetTex4_ST.xy + _OffsetTex4_ST.zw;
				float mulTime359 = _TimeParameters.x * _VertexOffsetScrollSpeed;
				float3 objToWorld345 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime347 = _TimeParameters.x * _VertexOffsetTimeZoomer;
				float3 VertexOffset4367 = ( ( ( ( (tex2Dlod( _OffsetTex4, float4( ( uv_OffsetTex4 + mulTime359 ), 0, 0.0) )).rgb * ( ( sin( ( ( objToWorld345.x + objToWorld345.y + objToWorld345.z ) + mulTime347 ) ) * 0.5 ) + 1.5 ) ) * _VertexOffsetFactor4 * 0.01 ) + float3( 0,0,0 ) ) * (( _OneMinusR )?( ( 1.0 - v.ase_color.r ) ):( v.ase_color.r )) );
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = VertexOffset4367;

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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Noisetex = IN.ase_texcoord1.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				float2 appendResult69 = (float2(_mainspeedU2 , _mainspeedV2));
				float Noise94 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult69 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				float2 uv_Noise01 = IN.ase_texcoord1.xy * _Noise01_ST.xy + _Noise01_ST.zw;
				float2 appendResult99 = (float2(_MainTex01U_Speed , _MainTex01_V_Speed));
				float2 texCoord483 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break471 = texCoord483;
				float lerpResult472 = lerp( ( break471.x + ( sin( ( _TimeParameters.x * _Frequence ) ) * _SineMultilper ) ) , break471.x , pow( break471.y , 2.8 ));
				float2 appendResult480 = (float2(lerpResult472 , 0.0));
				float2 UVOffset485 = appendResult480;
				float4 tex2DNode109 = tex2D( _Noise01, ( ( ( _MainTex_NoiseIntensity * Noise94 ) + uv_Noise01 ) + ( appendResult99 * _TimeParameters.x ) + UVOffset485 ) );
				float2 uv_MaskRG = IN.ase_texcoord1.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				float2 appendResult75 = (float2(_MaskSpeedU , _MaskSpeedU1));
				float4 tex2DNode79 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise94 ) + uv_MaskRG ) + ( appendResult75 * _TimeParameters.x ) ) );
				float MaskB276 = tex2DNode79.b;
				#ifdef _ADD_B_ON
				float staticSwitch569 = MaskB276;
				#else
				float staticSwitch569 = 0.0;
				#endif
				float MaskR81 = tex2DNode79.r;
				float2 texCoord438 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult462 = lerp( MaskR81 , ( 1.0 - texCoord438.y ) , _Buring);
				float MaskRTerm566 = ( staticSwitch569 + lerpResult462 );
				float saferPower440 = abs( MaskRTerm566 );
				float temp_output_440_0 = pow( saferPower440 , 0.9 );
				float lerpResult541 = lerp( temp_output_440_0 , pow( MaskRTerm566 , 0.3 ) , _Flare);
				float Alpha01254 = step( _Maindissolve , ( ( tex2DNode109.r * lerpResult541 ) + temp_output_440_0 ) );
				

				surfaceDescription.Alpha = Alpha01254;
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
Node;AmplifyShaderEditor.CommentaryNode;66;-2553.382,-118.5112;Inherit;False;1341.136;695.6919;Comment;14;93;92;91;90;89;88;81;80;79;78;77;76;75;74;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-4157.621,-1822.03;Inherit;False;1582.669;594.3846;Noise;13;94;87;86;85;84;83;82;73;72;71;70;69;68;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;95;-2536.876,-2127.226;Inherit;False;1388.581;956.9758;MainTex;13;109;108;107;106;104;103;102;100;99;98;96;97;486;MainTex;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;114;-2572.505,723.2262;Inherit;False;1877.861;818.8665;Dissolve;14;126;127;121;125;117;115;124;123;122;120;119;118;116;282;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;180;-3596.387,-1146.561;Inherit;False;2446.12;842.6599;MainTex02;25;227;197;196;202;191;190;189;188;187;186;185;184;183;182;181;236;253;265;266;268;272;284;287;447;194;MainTex02;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-341.4327,264.1222;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-449.2947,475.865;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-497.7567,187.6224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-746.5573,569.954;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-906.5284,473.611;Float;False;Property;_MaskSpeedU3;VectorTexV移动;38;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-682.5573,393.9541;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;68;-3980.2,-1337.645;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;-3916.199,-1513.645;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-3648.337,-1629.387;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-3756.2,-1417.645;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-4127.09,-1547.819;Float;False;Property;_mainspeedU2;Noise图U移动;24;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-4127.09,-1467.819;Float;False;Property;_mainspeedV2;Noise图V移动;25;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2267.9,-29.44707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-2259.411,291.1818;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2503.382,311.8388;Float;False;Property;_MaskSpeedU;MaskU移动;28;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2503.382,391.8388;Float;False;Property;_MaskSpeedU1;MaskV移动;29;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-2147.873,98.93892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-3173.726,-1390.38;Float;False;Property;_NoiseVqiangdu;Noise强度;23;0;Create;False;0;0;0;False;0;False;0;1.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2992.663,-1632.045;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;84;-3048.921,-1749.897;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-3180.97,-1642.497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2496.895,-68.51214;Inherit;False;Property;_Mask_NoiseIntensity;Mask_NoiseIntensity;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1968.149,166.3388;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2117.611,366.3817;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;92;-2298.711,454.1808;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2491.592,42.13569;Inherit;False;94;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-3956.923,-1761.41;Inherit;False;0;87;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2066.054,-1360.251;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;-2226.054,-1456.251;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-2209.563,-2050.534;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2502.739,-2072.818;Inherit;False;Property;_MainTex_NoiseIntensity;MainTex_NoiseIntensity;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-2438.022,-1984.894;Inherit;False;94;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-2486.876,-1524.636;Float;False;Property;_MainTex01U_Speed;MainTex01U移动;8;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2485.077,-1423.836;Float;False;Property;_MainTex01_V_Speed;MainTex01V移动;9;0;Create;False;0;0;0;False;0;False;-0.5;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;97;-2323.806,-1271.813;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-1443.371,7.146915;Inherit;True;MaskR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;89;-2489.886,136.1318;Inherit;False;0;79;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;87;-3494.156,-1664.484;Inherit;True;Property;_Noisetex;Noise图;22;0;Create;False;0;0;0;False;0;False;-1;None;17a7225c02deaec4792c3da5c9a099f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-2779.44,-1635.683;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-1949.793,-1565.294;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-54.03455,103.7583;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;116;-1372.435,965.2262;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2503.431,1153.333;Float;False;Property;_mainspeedV3;Dissolve图V移动;33;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2034.638,1169.11;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;-2194.637,1073.11;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-1884.92,807.4463;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;123;-2240.938,1272.12;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;124;-1148.435,965.2262;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;115;-1613.611,1201.865;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-2500.801,1036.008;Float;False;Property;_mainspeedU3;Dissolve图U移动;32;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-2500.485,795.4598;Inherit;False;0;127;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-1990.534,1369.938;Inherit;False;Property;_Float0;溶解进度;31;0;Create;False;0;0;0;False;0;False;0;0.434166;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-909.6119,958.9463;Inherit;False;Dissolove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;127;-1773.435,776.2262;Inherit;True;Property;_DissolveTex;DissolveTex;30;0;Create;True;0;0;0;False;0;False;-1;ff27762f0320a9f4ab657e3bf3eb5d05;0285e121f0ba5f04388ffbe35d5a1846;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-54.36933,473.6558;Inherit;False;81;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;56;-293.2236,75.7733;Inherit;False;Property;_VectorOffsetScaleXYZ;VectorOffsetScaleXYZ;36;0;Create;True;0;0;0;False;0;False;0,0,0;0.1,0.2,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;61;-904.5284,386.611;Float;False;Property;_MaskSpeedU2;VectorTexU移动;37;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-910.4425,202.9058;Inherit;False;0;59;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;65;-61.0085,566.4796;Inherit;False;Property;_VertexOffsetFactor1;VertexOffsetFactor1;35;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-199.0316,232.6286;Inherit;True;Property;_VectorTex;OffsetTex1;34;0;Create;False;0;0;0;False;0;False;-1;None;6561523cb6569664182a73767da1fa66;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;372;-111.4497,-107.7385;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;328;-478.0657,-340.5934;Inherit;False;Property;_EdgeSoft;EdgeSoft;20;0;Create;True;0;0;0;False;0;False;0.2;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;57;-180.796,-338.5046;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;297.9195,26.93549;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;371;416.2223,-181.3608;Inherit;False;VertexOffset1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;357;1080.013,-65.4516;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;359;802.0135,-11.45151;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;544.0133,-12.11816;Inherit;False;Property;_VertexOffsetScrollSpeed;VertexOffsetScrollSpeed;41;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;354;1350.013,-96.11826;Inherit;True;Property;_OffsetTex4;OffsetTex4;39;0;Create;True;0;0;0;False;0;False;-1;None;de4cec289154b2a4eb3471c7c86c0432;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;1890.014,200.5485;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-3580.449,-1067.128;Inherit;False;Property;_MainTex02_NoiseIntensity;MainTex02_NoiseIntensity;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;272;-2509.472,-1087.434;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-3125.563,-488.5789;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-3546.387,-652.9642;Float;False;Property;_MainTex02U_Speed;MainTex02U移动;17;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;185;-3285.563,-584.5792;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;186;-3359.866,-396.2763;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;187;-3097.831,-887.8497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-3528.15,-961.5568;Inherit;False;94;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-3312.49,-1041.154;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;191;-3389.671,-849.8904;Inherit;False;0;202;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;197;-2735.854,-1092.423;Inherit;False;Property;_MainTex02_Color;MainTex02_Color;14;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;9.082411,3.60736,0.9425132,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-2113.498,-1075.496;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-1674.251,-1055.003;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-1988.296,-867.5859;Inherit;False;Property;_MainCol02Intensity;MainCol02Intensity;15;0;Create;True;0;0;0;False;0;False;1;0.404;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-3003.701,-688.6221;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;411;-503.9238,-754.8827;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;79;-1823.781,136.6338;Inherit;True;Property;_MaskRG;MaskRG;26;0;Create;True;0;0;0;False;0;False;-1;f2fb5ff6bcc8c3745af85b84bc9f3cec;5d8eb61a77b37ef469f6c9349c9da3ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;-1433.815,479.5806;Inherit;True;MaskB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;-1436.085,700.2304;Inherit;True;MaskA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-1422.857,244.7124;Inherit;True;MaskG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-3544.586,-552.1641;Float;False;Property;_MainTex02_V_Speed;MainTex02V移动;18;0;Create;False;0;0;0;False;0;False;-0.5;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-2585.163,-678.0635;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;-2441.545,-775.8341;Inherit;False;Property;_MaskGdissolve;MaskGdissolve;12;0;Create;True;0;0;0;False;0;False;1.031352;0.384;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;268;-2014.2,-707.251;Inherit;True;2;0;FLOAT;1.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;284;-2346.638,-619.5147;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-1005.445,-507.7664;Inherit;True;81;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;412;-158.6474,-759.3983;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;289;1877.297,-638.3842;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;True;True;2;5;False;;10;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-2137.58,-1930.18;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-2407.542,-1861.359;Inherit;False;0;109;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;1518.014,407.2151;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;352;1669.346,407.2152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;350;1380.331,403.2246;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;346;1212.335,434.4219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;486;-2222.104,-1646.326;Inherit;False;485;UVOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;2075.372,275.9173;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;523;2201.123,414.934;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;361;1777.86,312.1405;Inherit;False;Property;_VertexOffsetFactor4;VertexOffsetFactor4;42;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;524;1823.123,426.2674;Inherit;False;Constant;_Float3;Float 3;51;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;347;952.9982,557.8914;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;349;678.998,553.8914;Inherit;False;Property;_VertexOffsetTimeZoomer;VertexOffsetTimeZoomer;40;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;918.3314,315.8914;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;345;524.1528,287.314;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;527;1690.285,-16.81049;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;202;-2926.17,-894.2578;Inherit;True;Property;_Noise02;Noise02;10;0;Create;True;0;0;0;False;0;False;-1;6b64fced3364cde49b79f2ff59e1fe95;16ee8d3544abd0240a42b9273b252bb9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;490;4315.692,-2181.923;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;496;4491.206,-2171.91;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;513;2528.563,-2605.113;Inherit;False;Property;_NormalOffset;NormalOffset;49;0;Create;True;0;0;0;False;0;False;0.01;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;516;2932.279,-2378.128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;515;2780.949,-2300.52;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;514;2536.135,-2306.228;Inherit;False;Object;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;519;2622.594,-2526.001;Inherit;False;Constant;_Float2;Float 2;51;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;517;2249.978,-2300.473;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;510;3212.436,-2087.535;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;529;2273.255,-2138.952;Inherit;False;528;PosOS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;509;2553.87,-2137.515;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;505;2797.954,-2132.861;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;507;3086.896,-2221.713;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ProjectionMatrixNode;511;3361.287,-2352.064;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;504;3360.56,-2224.918;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;3531.547,-2352.299;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SurfaceDepthNode;487;4007.366,-2117.239;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;534;3789.781,-2114.917;Inherit;False;528;PosOS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;512;3796.369,-2262.859;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenDepthNode;488;4065.401,-2267.068;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;508;2251.505,-2025.812;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;525;2505.543,-1945.411;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;526;2242.44,-1850.753;Inherit;False;367;VertexOffset4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;2691.284,-1950.628;Inherit;False;PosOS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;468;-3541.869,-2545.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;471;-3889.67,-2854.755;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;472;-3377.003,-2861.888;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;-4202.536,-2440.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;476;-3631.135,-2815.288;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;483;-4219.071,-2853.688;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;475;-4477.123,-2325.128;Inherit;False;Property;_Frequence;Frequence;3;0;Create;True;0;0;0;False;0;False;0.2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;480;-3048.603,-2682.022;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;485;-2849.155,-2688.677;Inherit;False;UVOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;473;-3800.535,-2441.822;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;470;-4046.536,-2440.489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;469;-4431.202,-2441.822;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;477;-4075.27,-2318.289;Inherit;False;Property;_SineMultilper;Sine Multilper;4;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;2356.897,394.2269;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;2588.983,390.8433;Inherit;False;VertexOffset4;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;545;2124.345,547.0531;Inherit;False;Property;_OneMinusR;One Minus R;51;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;546;1947.012,681.0532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;369;1740.087,539.7278;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;356;686.6801,-165.4516;Inherit;False;0;354;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;376;-2353.647,2702.211;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;379;-1520.315,2824.878;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;378;-2330.315,2625.545;Inherit;False;0;2;2;0,0,0,0;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.PowerNode;384;-2212.047,2499.544;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;385;-2084.313,2848.878;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-2225.648,3002.212;Inherit;False;Property;_StepSmooth;StepSmooth;44;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;404;-1875.25,2952.251;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;382;-1750.981,2959.545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;-1187.828,2712.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;375;-2014.116,2348.224;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;434;-1641.855,2308.124;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-2833.806,2491.947;Inherit;True;Property;_Color3Range;Color3Range;43;0;Create;True;0;0;0;False;0;False;0.2353042;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;390;-2550.852,2496.533;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;260;478.1284,2641.321;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;807.6781,2613.086;Inherit;False;FinalRGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;406;-1508.017,2647.689;Inherit;False;Property;_Color3Intensity;Color3Intensity;45;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;537;-106.0511,2945.158;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;547;-953.166,3087.697;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;548;-849.8574,2780.838;Inherit;False;Property;_UseG;Use G;52;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;388;-995.0891,2436.316;Inherit;False;Property;_HairTailColor;HairTailColor;6;1;[HDR];Create;True;0;0;0;False;0;False;0.8301887,0.4987443,0.2323484,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;227;-2871.794,-597.1777;Inherit;True;80;MaskG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;389;-492.7036,2613.259;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;222;-555.5005,2280.959;Inherit;False;Property;_HairRootColor;HairRootColor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;263;281.5945,3127.284;Inherit;False;253;Alpha02;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;231.8724,2907.785;Inherit;False;194;MainCol02;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;435;-1360.274,2320.474;Inherit;False;GradientCol;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;539;-383.4889,3100.823;Inherit;False;Property;_MainTexCol;MainTexCol;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.9803922,0.8166667,0.1617647,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;536;-448.7176,2875.825;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;0d6e1a3a914df964abcfa4c42b3bdf09;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;535;13.03137,2627.847;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;444;-3682.285,-205.9495;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;540;-3261.473,-294.9926;Inherit;True;276;MaskB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;560;-3175.017,42.02152;Inherit;False;Property;_G_Sub;G_Sub;54;0;Create;True;0;0;0;False;0;False;0;1.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;-3424.587,-136.4741;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;446;-2990.303,-278.605;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;409;-732.1923,-772.9277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;415;2957.457,-1248.093;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;417;2546.52,-1333.733;Inherit;False;Property;_ColorEdgeIntensity;ColorEdgeIntensity;48;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;408;2563.224,-1237.378;Inherit;False;Property;_Color0;Color 0;46;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;5.992157,0.3137255,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;291;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;292;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;293;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;294;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;295;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;296;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;297;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;298;1224.245,-931.8829;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;290;3982.929,-869.3609;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;PaxtonLiu/FireHair_02;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;IgnoreProjector=True;True;3;True;1;d3d11;0;False;True;0;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;0;638463327703531174;  Blend;0;0;Two Sided;0;638464178283038386;Forward Only;0;0;Cast Shadows;0;638428029876647446;  Use Shadow Threshold;0;0;Receive Shadows;0;638428029871758769;GPU Instancing;0;638428029867254559;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;638460878713070612;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;638461043334223128;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;497;3189.279,-1249.384;Inherit;False;EdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;518;3215.036,-1179.643;Inherit;False;501;EdgeMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;3216.864,-1322.211;Inherit;False;248;FinalRGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;502;3477.41,-1248.055;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;572;3675.09,-1115.67;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;574;3301.09,-1077.67;Inherit;False;Property;_Col_Root0;Col_Root0;56;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;576;3147.399,-882.3629;Inherit;False;Constant;_Float5;Float 5;59;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;575;3364.767,-870.8079;Inherit;False;Property;_LerpA;LerpA;57;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;558;1635.564,-2997.241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;324;397.2739,-3214.701;Inherit;False;Property;_EdgeCol;EdgeCol;19;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;329;324.8416,-3018.034;Inherit;False;Property;_EdgeColIntensity;EdgeColIntensity;21;0;Create;True;0;0;0;False;0;False;1;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;709.5085,-3088.7;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;556;1387.564,-3044.574;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;557;1177.564,-3046.574;Inherit;False;Property;_Vector0;Vector 0;53;0;Create;True;0;0;0;False;0;False;0,0,0;0,12.2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;945.6814,-3063.804;Inherit;False;MainCol03;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-1576.99,-2719.427;Inherit;True;81;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;462;-1302.544,-2652.793;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;464;-1616.184,-2340.687;Inherit;False;Property;_Buring;Buring;13;0;Create;True;0;0;0;False;0;False;0.4041814;0.81;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;568;-948.0108,-2684.422;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;570;-1462.036,-3065.824;Inherit;False;Constant;_Float4;Float 4;57;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-1528.831,-2917.717;Inherit;False;276;MaskB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;569;-1171.325,-2944.52;Inherit;False;Property;_Add_B;Add_B;55;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;463;-1580.012,-2532.706;Inherit;True;80;MaskG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;566;-689.5461,-2574.063;Inherit;False;MaskRTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;439;-1888.031,-2744.447;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;438;-2167.027,-2791.219;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;442;94.59081,-1368.204;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;577;-246.2702,-1338.22;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;330.0611,-645.3208;Inherit;True;254;Alpha01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;413;654.2477,-763.5188;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;450;3695.588,-577.209;Inherit;False;Constant;_Float1;Float 1;47;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;368;3724.455,-432.3335;Inherit;False;367;VertexOffset4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;573;3135.279,-707.3409;Inherit;False;282;MaskA;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;3453.591,-614.5557;Inherit;False;254;Alpha01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;501;4664.256,-2180.525;Inherit;False;EdgeMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;-1077.887,-641.1257;Inherit;False;Property;_Edge;Edge;47;0;Create;True;0;0;0;False;0;False;-0.02;0;-0.02;0.02;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1381.463,-1074.97;Inherit;True;MainCol02;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-1608.389,-760.7087;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;-1356.112,-774.1836;Inherit;True;Alpha02;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;541;-390.9181,-1705.39;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;109;-1586.054,-1768.695;Inherit;True;Property;_Noise01;Noise01;2;0;Create;True;0;0;0;False;0;False;-1;7f0203d64f5adcb47b029f50d006d896;16ee8d3544abd0240a42b9273b252bb9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;567;-1062.763,-1591.558;Inherit;False;566;MaskRTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;440;-758.3266,-1706.636;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;543;-756.2707,-1493.64;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;542;-796.028,-1268.752;Inherit;False;Property;_Flare;尾焰;50;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;451;448.6182,-1585.061;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-191.4984,-1728.154;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;88.81441,-1619.488;Inherit;False;Property;_Maindissolve;Maindissolve;11;0;Create;True;0;0;0;False;0;False;0.7741094;0.656;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;254;711.4158,-1590.446;Inherit;True;Alpha01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;52;0;54;0
WireConnection;52;1;53;0
WireConnection;53;0;63;0
WireConnection;53;1;55;0
WireConnection;54;1;60;0
WireConnection;63;0;61;0
WireConnection;63;1;62;0
WireConnection;69;0;72;0
WireConnection;69;1;73;0
WireConnection;70;0;85;0
WireConnection;70;1;71;0
WireConnection;71;0;69;0
WireConnection;71;1;68;0
WireConnection;74;0;88;0
WireConnection;74;1;93;0
WireConnection;75;0;76;0
WireConnection;75;1;77;0
WireConnection;78;0;74;0
WireConnection;78;1;89;0
WireConnection;83;0;84;0
WireConnection;83;1;82;0
WireConnection;84;0;86;0
WireConnection;86;0;87;1
WireConnection;90;0;78;0
WireConnection;90;1;91;0
WireConnection;91;0;75;0
WireConnection;91;1;92;0
WireConnection;98;0;99;0
WireConnection;98;1;97;0
WireConnection;99;0;104;0
WireConnection;99;1;100;0
WireConnection;102;0;103;0
WireConnection;102;1;106;0
WireConnection;81;0;79;1
WireConnection;87;1;70;0
WireConnection;94;0;83;0
WireConnection;96;0;108;0
WireConnection;96;1;98;0
WireConnection;96;2;486;0
WireConnection;51;0;56;1
WireConnection;51;1;56;2
WireConnection;51;2;56;3
WireConnection;116;0;127;3
WireConnection;116;1;115;0
WireConnection;119;0;120;0
WireConnection;119;1;123;0
WireConnection;120;0;117;0
WireConnection;120;1;118;0
WireConnection;122;0;125;0
WireConnection;122;1;119;0
WireConnection;124;0;127;3
WireConnection;115;0;121;0
WireConnection;126;0;124;0
WireConnection;127;1;122;0
WireConnection;59;1;52;0
WireConnection;50;0;372;1
WireConnection;50;1;51;0
WireConnection;50;2;59;0
WireConnection;50;3;65;0
WireConnection;371;0;50;0
WireConnection;357;0;356;0
WireConnection;357;1;359;0
WireConnection;359;0;360;0
WireConnection;354;1;357;0
WireConnection;353;0;527;0
WireConnection;353;1;352;0
WireConnection;272;0;197;0
WireConnection;181;0;185;0
WireConnection;181;1;186;0
WireConnection;185;0;182;0
WireConnection;185;1;183;0
WireConnection;187;0;189;0
WireConnection;187;1;191;0
WireConnection;189;0;190;0
WireConnection;189;1;188;0
WireConnection;196;0;272;0
WireConnection;236;0;272;0
WireConnection;236;1;266;0
WireConnection;184;0;187;0
WireConnection;184;1;181;0
WireConnection;411;0;409;0
WireConnection;411;1;277;0
WireConnection;79;1;90;0
WireConnection;276;0;79;3
WireConnection;282;0;79;4
WireConnection;80;0;79;2
WireConnection;447;0;202;1
WireConnection;447;1;446;0
WireConnection;268;0;287;0
WireConnection;268;1;284;0
WireConnection;284;0;447;0
WireConnection;412;0;411;0
WireConnection;108;0;102;0
WireConnection;108;1;107;0
WireConnection;351;0;350;0
WireConnection;352;0;351;0
WireConnection;350;0;346;0
WireConnection;346;0;344;0
WireConnection;346;1;347;0
WireConnection;362;0;353;0
WireConnection;362;1;361;0
WireConnection;362;2;524;0
WireConnection;523;0;362;0
WireConnection;347;0;349;0
WireConnection;344;0;345;1
WireConnection;344;1;345;2
WireConnection;344;2;345;3
WireConnection;527;0;354;0
WireConnection;202;1;184;0
WireConnection;490;0;488;0
WireConnection;490;1;487;0
WireConnection;496;0;490;0
WireConnection;516;0;513;0
WireConnection;516;1;515;0
WireConnection;515;0;514;0
WireConnection;514;0;517;0
WireConnection;510;0;507;0
WireConnection;510;2;509;3
WireConnection;509;0;529;0
WireConnection;505;0;509;0
WireConnection;507;0;516;0
WireConnection;507;1;505;0
WireConnection;504;0;507;0
WireConnection;506;0;511;0
WireConnection;506;1;504;0
WireConnection;487;0;534;0
WireConnection;512;0;506;0
WireConnection;488;0;512;0
WireConnection;525;0;508;0
WireConnection;525;1;526;0
WireConnection;528;0;525;0
WireConnection;468;0;471;0
WireConnection;468;1;473;0
WireConnection;471;0;483;0
WireConnection;472;0;468;0
WireConnection;472;1;471;0
WireConnection;472;2;476;0
WireConnection;474;0;469;0
WireConnection;474;1;475;0
WireConnection;476;0;471;1
WireConnection;480;0;472;0
WireConnection;485;0;480;0
WireConnection;473;0;470;0
WireConnection;473;1;477;0
WireConnection;470;0;474;0
WireConnection;370;0;523;0
WireConnection;370;1;545;0
WireConnection;367;0;370;0
WireConnection;545;0;369;1
WireConnection;545;1;546;0
WireConnection;546;0;369;1
WireConnection;379;0;375;1
WireConnection;379;1;385;0
WireConnection;379;2;382;0
WireConnection;384;0;390;0
WireConnection;385;0;384;0
WireConnection;404;0;385;0
WireConnection;404;1;383;0
WireConnection;382;0;404;0
WireConnection;405;0;406;0
WireConnection;405;1;379;0
WireConnection;375;0;378;0
WireConnection;375;1;376;2
WireConnection;434;0;375;1
WireConnection;390;0;380;0
WireConnection;260;0;537;0
WireConnection;260;1;262;0
WireConnection;260;2;263;0
WireConnection;248;0;260;0
WireConnection;537;0;536;0
WireConnection;537;1;539;0
WireConnection;548;0;405;0
WireConnection;548;1;547;2
WireConnection;389;0;222;0
WireConnection;389;1;388;0
WireConnection;389;2;548;0
WireConnection;435;0;434;0
WireConnection;535;0;389;0
WireConnection;535;1;537;0
WireConnection;445;0;444;2
WireConnection;446;0;540;0
WireConnection;446;1;560;0
WireConnection;409;0;109;1
WireConnection;409;1;410;0
WireConnection;415;0;417;0
WireConnection;415;1;408;0
WireConnection;290;2;572;0
WireConnection;290;3;257;0
WireConnection;290;4;450;0
WireConnection;290;5;368;0
WireConnection;497;0;415;0
WireConnection;502;0;249;0
WireConnection;502;1;497;0
WireConnection;502;2;518;0
WireConnection;572;0;502;0
WireConnection;572;1;574;0
WireConnection;572;2;575;0
WireConnection;575;1;576;0
WireConnection;575;0;573;0
WireConnection;558;0;556;2
WireConnection;330;0;324;0
WireConnection;330;1;329;0
WireConnection;556;0;557;0
WireConnection;325;0;330;0
WireConnection;462;0;461;0
WireConnection;462;1;439;0
WireConnection;462;2;464;0
WireConnection;568;0;569;0
WireConnection;568;1;462;0
WireConnection;569;1;570;0
WireConnection;569;0;571;0
WireConnection;566;0;568;0
WireConnection;439;0;438;2
WireConnection;442;0;441;0
WireConnection;442;1;577;0
WireConnection;577;0;440;0
WireConnection;413;0;412;0
WireConnection;413;1;256;0
WireConnection;501;0;496;0
WireConnection;194;0;236;0
WireConnection;266;0;265;0
WireConnection;266;1;268;0
WireConnection;253;0;266;0
WireConnection;541;0;440;0
WireConnection;541;1;543;0
WireConnection;541;2;542;0
WireConnection;109;1;96;0
WireConnection;440;0;567;0
WireConnection;543;0;567;0
WireConnection;451;0;160;0
WireConnection;451;1;442;0
WireConnection;441;0;109;1
WireConnection;441;1;541;0
WireConnection;254;0;451;0
ASEEND*/
//CHKSM=5722FBB2C681CAD134D5A170C60F24AA4996E021