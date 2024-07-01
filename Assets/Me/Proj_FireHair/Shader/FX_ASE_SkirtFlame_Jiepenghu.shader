// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/QF/NssFX/NssFX_ASE/SkirtFlame"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_MainTex01("MainTex01", 2D) = "white" {}
		[HDR]_MainTex01_Color("MainTex01_Color", Color) = (1,1,1,1)
		_MainTex_NoiseIntensity("MainTex_NoiseIntensity", Float) = 1
		_MainTex01U_Speed("MainTex01U移动", Float) = 0
		_MainTex01_V_Speed("MainTex01V移动", Float) = 0
		[HDR]_UnderskirtColor("裙底颜色", Color) = (0,0,0,0)
		_UnderskirtColorEdge("UnderskirtColorEdge", Float) = 0.73
		_MainTex02("MainTex02", 2D) = "white" {}
		[Enum(OFF,0,ON,1)]_MainTexorMaskR("是否和MaskR相乘", Float) = 0
		_MainTex02_Peower("MainTex02_Peower", Float) = 0
		[HDR]_MainTex02_Color("MainTex02_Color", Color) = (1,1,1,1)
		_MainTex02_NoiseIntensity("MainTex02_NoiseIntensity", Float) = 1
		_MainTex02U_Speed("MainTex02U移动", Float) = 0
		_MainTex02_V_Speed("MainTex02V移动", Float) = 0
		_Noisetex("Noise图", 2D) = "white" {}
		_NoiseVqiangdu("Noise强度", Float) = 0
		_mainspeedU2("Noise图U移动", Float) = 0
		_mainspeedV2("Noise图V移动", Float) = 0
		_MaskRG("MaskRG", 2D) = "white" {}
		_Mask_NoiseIntensity("Mask_NoiseIntensity", Float) = 1
		_MaskSpeedU("MaskU移动", Float) = 0
		_MaskSpeedU1("MaskV移动", Float) = 0
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_Float0("溶解进度", Range( 0 , 1)) = 0.522944
		_mainspeedU3("Dissolve图U移动", Float) = 0
		_mainspeedV3("Dissolve图V移动", Float) = 0
		_RemapTex("RemapTex(Clamp)", 2D) = "white" {}
		_RemapTex_NoiseIntensity("RemapTex_NoiseIntensity", Range( 0 , 10)) = 1
		[HDR]_DissolveEge_Color("DissolveEge_Color", Color) = (1,1,1,1)
		_DissolveEge_Distance("DissolveEge_Distance", Range( 0 , 2)) = 0.25
		_DissolveEge_Scale("DissolveEge_Scale", Range( 0 , 10)) = 0
		_VectorTex("VectorTex乘了MaskR通道", 2D) = "white" {}
		_VectorOffsetScaleXYZ("VectorOffsetScaleXYZ", Vector) = (0,0,0,0)
		_MaskSpeedU2("VectorTexU移动", Float) = 0
		_MaskSpeedU3("VectorTexV移动", Float) = 0
		[Enum(ON,1,OFF,0)]_Fresnel("Fresnel", Float) = 0
		_Min("Min", Float) = 0.13
		[ASEEnd]_Max("Max", Float) = 1.8


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

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Off
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.0
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

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _SURFACE_TYPE_TRANSPARENT 1
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _VectorTex_ST;
			half4 _DissolveEge_Color;
			half4 _MainTex02_Color;
			half4 _Noisetex_ST;
			half4 _UnderskirtColor;
			half4 _MainTex01_ST;
			half4 _MaskRG_ST;
			half4 _MainTex02_ST;
			half4 _DissolveTex_ST;
			half4 _MainTex01_Color;
			half3 _VectorOffsetScaleXYZ;
			half _MainTexorMaskR;
			half _UnderskirtColorEdge;
			float _mainspeedV3;
			half _Float0;
			half _DissolveEge_Distance;
			half _DissolveEge_Scale;
			half _RemapTex_NoiseIntensity;
			half _Min;
			float _mainspeedU3;
			half _MainTex02_Peower;
			half _MainTex02_NoiseIntensity;
			float _MainTex02U_Speed;
			half _Max;
			float _MainTex01_V_Speed;
			float _MainTex01U_Speed;
			half _MainTex_NoiseIntensity;
			float _MaskSpeedU1;
			float _MaskSpeedU;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			half _Mask_NoiseIntensity;
			float _MaskSpeedU3;
			float _MaskSpeedU2;
			float _MainTex02_V_Speed;
			half _Fresnel;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VectorTex;
			sampler2D _MaskRG;
			sampler2D _Noisetex;
			sampler2D _MainTex01;
			sampler2D _MainTex02;
			sampler2D _RemapTex;
			sampler2D _DissolveTex;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 appendResult147 = (half3(_VectorOffsetScaleXYZ.x , _VectorOffsetScaleXYZ.y , _VectorOffsetScaleXYZ.z));
				half2 uv_VectorTex = v.ase_texcoord.xy * _VectorTex_ST.xy + _VectorTex_ST.zw;
				half2 appendResult219 = (half2(_MaskSpeedU2 , _MaskSpeedU3));
				half2 uv_Noisetex = v.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2Dlod( _Noisetex, float4( ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ), 0, 0.0) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = v.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2Dlod( _MaskRG, float4( ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ), 0, 0.0) );
				half MaskR159 = tex2DNode12.r;
				
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( v.ase_normal * appendResult147 * tex2Dlod( _VectorTex, float4( ( ( float2( 0,0 ) + uv_VectorTex ) + ( appendResult219 * _TimeParameters.x ) ), 0, 0.0) ).r * MaskR159 );

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
				half4 ase_color : COLOR;

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

				half3 appendResult269 = (half3(IN.ase_color.r , IN.ase_color.g , IN.ase_color.b));
				half2 uv_Noisetex = IN.ase_texcoord3.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MainTex01 = IN.ase_texcoord3.xy * _MainTex01_ST.xy + _MainTex01_ST.zw;
				half2 appendResult11 = (half2(_MainTex01U_Speed , _MainTex01_V_Speed));
				half4 MainTex169 = ( ( _MainTex01_Color * _MainTex01_Color.a ) * tex2D( _MainTex01, ( ( ( _MainTex_NoiseIntensity * Noise62 ) + uv_MainTex01 ) + ( appendResult11 * _TimeParameters.x ) ) ) );
				half2 uv_MainTex02 = IN.ase_texcoord3.xy * _MainTex02_ST.xy + _MainTex02_ST.zw;
				half2 appendResult36 = (half2(_MainTex02U_Speed , _MainTex02_V_Speed));
				half4 temp_cast_1 = (_MainTex02_Peower).xxxx;
				half4 temp_output_32_0 = ( ( _MainTex02_Color * _MainTex02_Color.a ) * saturate( pow( tex2D( _MainTex02, ( ( ( _MainTex02_NoiseIntensity * Noise62 ) + uv_MainTex02 ) + ( appendResult36 * _TimeParameters.x ) ) ) , temp_cast_1 ) ) );
				half2 uv_MaskRG = IN.ase_texcoord3.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ) );
				half MaskR159 = tex2DNode12.r;
				half4 lerpResult260 = lerp( temp_output_32_0 , ( temp_output_32_0 * MaskR159 ) , _MainTexorMaskR);
				half4 MainTex02179 = lerpResult260;
				half4 temp_output_278_0 = ( _UnderskirtColor * _UnderskirtColor.a );
				half2 texCoord270 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				half2 uv_DissolveTex = IN.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half2 appendResult104 = (half2(_mainspeedU3 , _mainspeedV3));
				half clampResult94 = clamp( ( tex2D( _DissolveTex, ( uv_DissolveTex + ( appendResult104 * _TimeParameters.x ) ) ).r - (-1.0 + (_Float0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				half Dissolove124 = clampResult94;
				half2 appendResult92 = (half2(saturate( ( 1.0 - ( distance( Dissolove124 , _DissolveEge_Distance ) / _DissolveEge_Scale ) ) ) , 1.0));
				half4 DissoloveEge112 = tex2D( _RemapTex, ( appendResult92 + ( Noise62 * _RemapTex_NoiseIntensity ) ) );
				half4 lerpResult128 = lerp( ( MainTex169 + MainTex02179 + ( temp_output_278_0 * saturate( ( ( 1.0 - ( Noise62 + texCoord270.y ) ) - _UnderskirtColorEdge ) ) ) ) , ( ( DissoloveEge112 * _DissolveEge_Color ) * MaskR159 ) , DissoloveEge112);
				half4 temp_output_143_0 = ( half4( appendResult269 , 0.0 ) * lerpResult128 );
				
				half MaskG242 = tex2DNode12.g;
				half temp_output_85_0 = ( MaskR159 * IN.ase_color.a * Dissolove124 * MaskG242 );
				half3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult245 = dot( ase_worldNormal , ase_worldViewDir );
				half smoothstepResult247 = smoothstep( _Min , _Max , abs( dotResult245 ));
				half Fresnel251 = saturate( smoothstepResult247 );
				half lerpResult236 = lerp( temp_output_85_0 , ( temp_output_85_0 * Fresnel251 ) , _Fresnel);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = temp_output_143_0.rgb;
				float Alpha = lerpResult236;
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

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _VectorTex_ST;
			half4 _DissolveEge_Color;
			half4 _MainTex02_Color;
			half4 _Noisetex_ST;
			half4 _UnderskirtColor;
			half4 _MainTex01_ST;
			half4 _MaskRG_ST;
			half4 _MainTex02_ST;
			half4 _DissolveTex_ST;
			half4 _MainTex01_Color;
			half3 _VectorOffsetScaleXYZ;
			half _MainTexorMaskR;
			half _UnderskirtColorEdge;
			float _mainspeedV3;
			half _Float0;
			half _DissolveEge_Distance;
			half _DissolveEge_Scale;
			half _RemapTex_NoiseIntensity;
			half _Min;
			float _mainspeedU3;
			half _MainTex02_Peower;
			half _MainTex02_NoiseIntensity;
			float _MainTex02U_Speed;
			half _Max;
			float _MainTex01_V_Speed;
			float _MainTex01U_Speed;
			half _MainTex_NoiseIntensity;
			float _MaskSpeedU1;
			float _MaskSpeedU;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			half _Mask_NoiseIntensity;
			float _MaskSpeedU3;
			float _MaskSpeedU2;
			float _MainTex02_V_Speed;
			half _Fresnel;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VectorTex;
			sampler2D _MaskRG;
			sampler2D _Noisetex;
			sampler2D _DissolveTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 appendResult147 = (half3(_VectorOffsetScaleXYZ.x , _VectorOffsetScaleXYZ.y , _VectorOffsetScaleXYZ.z));
				half2 uv_VectorTex = v.ase_texcoord.xy * _VectorTex_ST.xy + _VectorTex_ST.zw;
				half2 appendResult219 = (half2(_MaskSpeedU2 , _MaskSpeedU3));
				half2 uv_Noisetex = v.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2Dlod( _Noisetex, float4( ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ), 0, 0.0) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = v.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2Dlod( _MaskRG, float4( ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ), 0, 0.0) );
				half MaskR159 = tex2DNode12.r;
				
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( v.ase_normal * appendResult147 * tex2Dlod( _VectorTex, float4( ( ( float2( 0,0 ) + uv_VectorTex ) + ( appendResult219 * _TimeParameters.x ) ), 0, 0.0) ).r * MaskR159 );

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
				half4 ase_color : COLOR;

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

				half2 uv_Noisetex = IN.ase_texcoord2.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = IN.ase_texcoord2.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ) );
				half MaskR159 = tex2DNode12.r;
				half2 uv_DissolveTex = IN.ase_texcoord2.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half2 appendResult104 = (half2(_mainspeedU3 , _mainspeedV3));
				half clampResult94 = clamp( ( tex2D( _DissolveTex, ( uv_DissolveTex + ( appendResult104 * _TimeParameters.x ) ) ).r - (-1.0 + (_Float0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				half Dissolove124 = clampResult94;
				half MaskG242 = tex2DNode12.g;
				half temp_output_85_0 = ( MaskR159 * IN.ase_color.a * Dissolove124 * MaskG242 );
				half3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult245 = dot( ase_worldNormal , ase_worldViewDir );
				half smoothstepResult247 = smoothstep( _Min , _Max , abs( dotResult245 ));
				half Fresnel251 = saturate( smoothstepResult247 );
				half lerpResult236 = lerp( temp_output_85_0 , ( temp_output_85_0 * Fresnel251 ) , _Fresnel);
				

				float Alpha = lerpResult236;
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

			#define _SURFACE_TYPE_TRANSPARENT 1
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _VectorTex_ST;
			half4 _DissolveEge_Color;
			half4 _MainTex02_Color;
			half4 _Noisetex_ST;
			half4 _UnderskirtColor;
			half4 _MainTex01_ST;
			half4 _MaskRG_ST;
			half4 _MainTex02_ST;
			half4 _DissolveTex_ST;
			half4 _MainTex01_Color;
			half3 _VectorOffsetScaleXYZ;
			half _MainTexorMaskR;
			half _UnderskirtColorEdge;
			float _mainspeedV3;
			half _Float0;
			half _DissolveEge_Distance;
			half _DissolveEge_Scale;
			half _RemapTex_NoiseIntensity;
			half _Min;
			float _mainspeedU3;
			half _MainTex02_Peower;
			half _MainTex02_NoiseIntensity;
			float _MainTex02U_Speed;
			half _Max;
			float _MainTex01_V_Speed;
			float _MainTex01U_Speed;
			half _MainTex_NoiseIntensity;
			float _MaskSpeedU1;
			float _MaskSpeedU;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			half _Mask_NoiseIntensity;
			float _MaskSpeedU3;
			float _MaskSpeedU2;
			float _MainTex02_V_Speed;
			half _Fresnel;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VectorTex;
			sampler2D _MaskRG;
			sampler2D _Noisetex;
			sampler2D _DissolveTex;


			
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

				half3 appendResult147 = (half3(_VectorOffsetScaleXYZ.x , _VectorOffsetScaleXYZ.y , _VectorOffsetScaleXYZ.z));
				half2 uv_VectorTex = v.ase_texcoord.xy * _VectorTex_ST.xy + _VectorTex_ST.zw;
				half2 appendResult219 = (half2(_MaskSpeedU2 , _MaskSpeedU3));
				half2 uv_Noisetex = v.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2Dlod( _Noisetex, float4( ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ), 0, 0.0) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = v.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2Dlod( _MaskRG, float4( ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ), 0, 0.0) );
				half MaskR159 = tex2DNode12.r;
				
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( v.ase_normal * appendResult147 * tex2Dlod( _VectorTex, float4( ( ( float2( 0,0 ) + uv_VectorTex ) + ( appendResult219 * _TimeParameters.x ) ), 0, 0.0) ).r * MaskR159 );

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
				half4 ase_color : COLOR;

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

				half2 uv_Noisetex = IN.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = IN.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ) );
				half MaskR159 = tex2DNode12.r;
				half2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half2 appendResult104 = (half2(_mainspeedU3 , _mainspeedV3));
				half clampResult94 = clamp( ( tex2D( _DissolveTex, ( uv_DissolveTex + ( appendResult104 * _TimeParameters.x ) ) ).r - (-1.0 + (_Float0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				half Dissolove124 = clampResult94;
				half MaskG242 = tex2DNode12.g;
				half temp_output_85_0 = ( MaskR159 * IN.ase_color.a * Dissolove124 * MaskG242 );
				half3 ase_worldNormal = IN.ase_texcoord1.xyz;
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult245 = dot( ase_worldNormal , ase_worldViewDir );
				half smoothstepResult247 = smoothstep( _Min , _Max , abs( dotResult245 ));
				half Fresnel251 = saturate( smoothstepResult247 );
				half lerpResult236 = lerp( temp_output_85_0 , ( temp_output_85_0 * Fresnel251 ) , _Fresnel);
				

				surfaceDescription.Alpha = lerpResult236;
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

			#define _SURFACE_TYPE_TRANSPARENT 1
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _VectorTex_ST;
			half4 _DissolveEge_Color;
			half4 _MainTex02_Color;
			half4 _Noisetex_ST;
			half4 _UnderskirtColor;
			half4 _MainTex01_ST;
			half4 _MaskRG_ST;
			half4 _MainTex02_ST;
			half4 _DissolveTex_ST;
			half4 _MainTex01_Color;
			half3 _VectorOffsetScaleXYZ;
			half _MainTexorMaskR;
			half _UnderskirtColorEdge;
			float _mainspeedV3;
			half _Float0;
			half _DissolveEge_Distance;
			half _DissolveEge_Scale;
			half _RemapTex_NoiseIntensity;
			half _Min;
			float _mainspeedU3;
			half _MainTex02_Peower;
			half _MainTex02_NoiseIntensity;
			float _MainTex02U_Speed;
			half _Max;
			float _MainTex01_V_Speed;
			float _MainTex01U_Speed;
			half _MainTex_NoiseIntensity;
			float _MaskSpeedU1;
			float _MaskSpeedU;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			half _Mask_NoiseIntensity;
			float _MaskSpeedU3;
			float _MaskSpeedU2;
			float _MainTex02_V_Speed;
			half _Fresnel;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VectorTex;
			sampler2D _MaskRG;
			sampler2D _Noisetex;
			sampler2D _DissolveTex;


			
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

				half3 appendResult147 = (half3(_VectorOffsetScaleXYZ.x , _VectorOffsetScaleXYZ.y , _VectorOffsetScaleXYZ.z));
				half2 uv_VectorTex = v.ase_texcoord.xy * _VectorTex_ST.xy + _VectorTex_ST.zw;
				half2 appendResult219 = (half2(_MaskSpeedU2 , _MaskSpeedU3));
				half2 uv_Noisetex = v.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2Dlod( _Noisetex, float4( ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ), 0, 0.0) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = v.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2Dlod( _MaskRG, float4( ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ), 0, 0.0) );
				half MaskR159 = tex2DNode12.r;
				
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( v.ase_normal * appendResult147 * tex2Dlod( _VectorTex, float4( ( ( float2( 0,0 ) + uv_VectorTex ) + ( appendResult219 * _TimeParameters.x ) ), 0, 0.0) ).r * MaskR159 );
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
				half4 ase_color : COLOR;

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

				half2 uv_Noisetex = IN.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = IN.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ) );
				half MaskR159 = tex2DNode12.r;
				half2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half2 appendResult104 = (half2(_mainspeedU3 , _mainspeedV3));
				half clampResult94 = clamp( ( tex2D( _DissolveTex, ( uv_DissolveTex + ( appendResult104 * _TimeParameters.x ) ) ).r - (-1.0 + (_Float0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				half Dissolove124 = clampResult94;
				half MaskG242 = tex2DNode12.g;
				half temp_output_85_0 = ( MaskR159 * IN.ase_color.a * Dissolove124 * MaskG242 );
				half3 ase_worldNormal = IN.ase_texcoord1.xyz;
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult245 = dot( ase_worldNormal , ase_worldViewDir );
				half smoothstepResult247 = smoothstep( _Min , _Max , abs( dotResult245 ));
				half Fresnel251 = saturate( smoothstepResult247 );
				half lerpResult236 = lerp( temp_output_85_0 , ( temp_output_85_0 * Fresnel251 ) , _Fresnel);
				

				surfaceDescription.Alpha = lerpResult236;
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

			#define _SURFACE_TYPE_TRANSPARENT 1
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _VectorTex_ST;
			half4 _DissolveEge_Color;
			half4 _MainTex02_Color;
			half4 _Noisetex_ST;
			half4 _UnderskirtColor;
			half4 _MainTex01_ST;
			half4 _MaskRG_ST;
			half4 _MainTex02_ST;
			half4 _DissolveTex_ST;
			half4 _MainTex01_Color;
			half3 _VectorOffsetScaleXYZ;
			half _MainTexorMaskR;
			half _UnderskirtColorEdge;
			float _mainspeedV3;
			half _Float0;
			half _DissolveEge_Distance;
			half _DissolveEge_Scale;
			half _RemapTex_NoiseIntensity;
			half _Min;
			float _mainspeedU3;
			half _MainTex02_Peower;
			half _MainTex02_NoiseIntensity;
			float _MainTex02U_Speed;
			half _Max;
			float _MainTex01_V_Speed;
			float _MainTex01U_Speed;
			half _MainTex_NoiseIntensity;
			float _MaskSpeedU1;
			float _MaskSpeedU;
			float _NoiseVqiangdu;
			float _mainspeedV2;
			float _mainspeedU2;
			half _Mask_NoiseIntensity;
			float _MaskSpeedU3;
			float _MaskSpeedU2;
			float _MainTex02_V_Speed;
			half _Fresnel;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VectorTex;
			sampler2D _MaskRG;
			sampler2D _Noisetex;
			sampler2D _DissolveTex;


			
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

				half3 appendResult147 = (half3(_VectorOffsetScaleXYZ.x , _VectorOffsetScaleXYZ.y , _VectorOffsetScaleXYZ.z));
				half2 uv_VectorTex = v.ase_texcoord.xy * _VectorTex_ST.xy + _VectorTex_ST.zw;
				half2 appendResult219 = (half2(_MaskSpeedU2 , _MaskSpeedU3));
				half2 uv_Noisetex = v.ase_texcoord.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2Dlod( _Noisetex, float4( ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ), 0, 0.0) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = v.ase_texcoord.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2Dlod( _MaskRG, float4( ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ), 0, 0.0) );
				half MaskR159 = tex2DNode12.r;
				
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( v.ase_normal * appendResult147 * tex2Dlod( _VectorTex, float4( ( ( float2( 0,0 ) + uv_VectorTex ) + ( appendResult219 * _TimeParameters.x ) ), 0, 0.0) ).r * MaskR159 );

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
				half4 ase_color : COLOR;

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

				half2 uv_Noisetex = IN.ase_texcoord1.xy * _Noisetex_ST.xy + _Noisetex_ST.zw;
				half2 appendResult61 = (half2(_mainspeedU2 , _mainspeedV2));
				half Noise62 = ( saturate( ( tex2D( _Noisetex, ( uv_Noisetex + ( appendResult61 * _TimeParameters.x ) ) ).r - 0.5 ) ) * _NoiseVqiangdu );
				half2 uv_MaskRG = IN.ase_texcoord1.xy * _MaskRG_ST.xy + _MaskRG_ST.zw;
				half2 appendResult73 = (half2(_MaskSpeedU , _MaskSpeedU1));
				half4 tex2DNode12 = tex2D( _MaskRG, ( ( ( _Mask_NoiseIntensity * Noise62 ) + uv_MaskRG ) + ( appendResult73 * _TimeParameters.x ) ) );
				half MaskR159 = tex2DNode12.r;
				half2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				half2 appendResult104 = (half2(_mainspeedU3 , _mainspeedV3));
				half clampResult94 = clamp( ( tex2D( _DissolveTex, ( uv_DissolveTex + ( appendResult104 * _TimeParameters.x ) ) ).r - (-1.0 + (_Float0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				half Dissolove124 = clampResult94;
				half MaskG242 = tex2DNode12.g;
				half temp_output_85_0 = ( MaskR159 * IN.ase_color.a * Dissolove124 * MaskG242 );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult245 = dot( IN.normalWS , ase_worldViewDir );
				half smoothstepResult247 = smoothstep( _Min , _Max , abs( dotResult245 ));
				half Fresnel251 = saturate( smoothstepResult247 );
				half lerpResult236 = lerp( temp_output_85_0 , ( temp_output_85_0 * Fresnel251 ) , _Fresnel);
				

				surfaceDescription.Alpha = lerpResult236;
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
Node;AmplifyShaderEditor.CommentaryNode;264;-3556.653,1983.004;Inherit;False;1341.136;695.6919;Comment;14;82;75;68;71;72;73;69;70;76;12;81;44;159;242;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;178;-4084.758,163.8354;Inherit;False;2132.572;848.1752;MainTex02;22;262;261;260;263;259;211;42;32;212;40;39;80;79;63;64;34;36;33;38;37;35;268;MainTex02;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;208;-1860.45,-410.8124;Inherit;False;782.4055;457.3885;DissolveEgeColor;6;118;111;120;198;134;213;DissolveEgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;186;592.3575,1116.447;Inherit;False;2409.855;593.7942;Dissolve_Ege;14;93;89;97;99;184;96;98;92;91;192;194;195;196;207;Dissolve_Ege;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;185;-1629.55,1076.664;Inherit;False;1858.787;780.7178;Dissolve;13;105;106;108;101;102;103;104;95;109;100;107;94;124;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-3618.284,-1096.98;Inherit;False;1388.581;956.9758;MainTex;15;6;9;10;11;7;8;66;1;5;77;78;65;13;14;267;MainTex;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;177;-3600.576,1227.484;Inherit;False;1582.669;594.3846;Noise;13;57;58;59;61;52;83;54;56;60;53;51;62;298;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-2990.199,-530.0474;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;9;-3371.461,-250.0044;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3147.461,-330.0045;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-3307.461,-426.0045;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3566.484,-393.5897;Float;False;Property;_MainTex01_V_Speed;MainTex01V移动;4;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2489.758,-691.0765;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;107;-689.7292,1555.303;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-448.5537,1318.664;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-784.5537,1126.664;Inherit;True;Property;_DissolveTex;DissolveTex;22;0;Create;True;0;0;0;False;0;False;-1;adf6a78cad6381c48a67721b468cdb2c;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;3034.288,1177.966;Inherit;False;DissoloveEge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;89;1362.249,1197.069;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;806.4594,1511.446;Inherit;False;Property;_DissolveEge_Scale;DissolveEge_Scale;30;0;Create;False;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;195;2311.76,1192.228;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;96;605.3724,1388.463;Inherit;False;Property;_DissolveEge_Distance;DissolveEge_Distance;29;0;Create;True;0;0;0;False;0;False;0.25;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;642.3575,1192.318;Inherit;False;124;Dissolove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;97;896.1699,1196.324;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;99;1111.85,1431.745;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;192;1563.3,1193.209;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;1786.989,1194.851;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;1617.964,1449.317;Inherit;False;Constant;_Float3;Float 3;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;1865.615,1616.732;Inherit;False;Property;_RemapTex_NoiseIntensity;RemapTex_NoiseIntensity;27;0;Create;True;0;0;0;False;0;False;1;0.1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;2158.653,1454.472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;1939.109,1417.098;Inherit;True;62;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1526.372,-303.5008;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;120;-1825.063,-264.1907;Inherit;False;Property;_DissolveEge_Color;DissolveEge_Color;28;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1753.99,-358.1555;Inherit;False;112;DissoloveEge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-1293.499,-182.4487;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1487.05,-54.36706;Inherit;False;159;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;214;-1136.6,-520.8487;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-3145.902,-882.2514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-3290.97,-1020.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-3519.43,-954.6481;Inherit;False;62;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3584.146,-1042.572;Inherit;False;Property;_MainTex_NoiseIntensity;MainTex_NoiseIntensity;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-3423.154,1711.869;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-3359.154,1535.869;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-3091.291,1420.127;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-3199.154,1631.869;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-3570.046,1501.695;Float;False;Property;_mainspeedU2;Noise图U移动;16;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3570.046,1581.695;Float;False;Property;_mainspeedV2;Noise图V移动;17;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-2937.11,1385.03;Inherit;True;Property;_Noisetex;Noise图;14;0;Create;False;0;0;0;False;0;False;-1;None;c1519c9f72096a449981674decd92746;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;1847.79,-155.026;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;1495.836,-78.2032;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;216;1204.32,213.9342;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;1096.458,425.677;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;1047.996,137.4344;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;217;799.1954,519.7659;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;219;863.1954,343.7661;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;172;1256.647,-106.1882;Inherit;False;Property;_VectorOffsetScaleXYZ;VectorOffsetScaleXYZ;32;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;220;619.2243,364.423;Float;False;Property;_MaskSpeedU2;VectorTexU移动;33;0;Create;False;0;0;0;False;0;False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;634.2243,444.423;Float;False;Property;_MaskSpeedU3;VectorTexV移动;34;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;140.5193,-245.1693;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;276.5824,-120.8763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;282.0482,25.99362;Inherit;False;Property;_Fresnel;Fresnel;35;1;[Enum];Create;True;0;2;ON;1;OFF;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;145;1464.808,-236.7327;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-3399.877,1288.104;Inherit;False;0;51;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;236;476.1167,-249.8219;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1569.483,1387.959;Float;False;Property;_mainspeedU3;Dissolve图U移动;24;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1579.55,1506.771;Float;False;Property;_mainspeedV3;Dissolve图V移动;25;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1110.757,1522.548;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;-1270.757,1426.548;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1047.509,1742.382;Inherit;False;Property;_Float0;溶解进度;23;0;Create;False;0;0;0;False;0;False;0.522944;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-961.0392,1160.884;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;102;-1317.057,1625.558;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;109;-1549.123,1164.831;Inherit;False;0;100;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;243;-751.8615,2696.94;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;245;-476.0532,2752.689;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;244;-729.4897,2856.283;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;254;-233.2825,2748.086;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-211.6401,2982.025;Inherit;False;Property;_Min;Min;36;0;Create;True;0;0;0;False;0;False;0.13;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-175.4613,3055.136;Inherit;False;Property;_Max;Max;37;0;Create;True;0;0;0;False;0;False;1.8;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;247;1.575281,2745.137;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;250;282.1722,2743.939;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;251;520.9078,2738.545;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;223;669.3102,201.7178;Inherit;False;0;215;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-2854.727,-549.7485;Inherit;True;Property;_MainTex01;MainTex01;0;0;Create;True;0;0;0;False;0;False;-1;37f1d0acc9a5c4c44b9cdd34d8bca251;9f12324cf6115a443b277025f7fa16e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;215;1350.839,50.66708;Inherit;True;Property;_VectorTex;VectorTex乘了MaskR通道;31;0;Create;False;0;0;0;False;0;False;-1;None;45a3db1d2536ea34c99cd2816ea4d5ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-3568.284,-494.3896;Float;False;Property;_MainTex01U_Speed;MainTex01U移动;3;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;1449.857,289.6657;Inherit;False;159;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;94;-224.5537,1318.664;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-3613.934,821.817;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-4034.758,657.4317;Float;False;Property;_MainTex02U_Speed;MainTex02U移动;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-4032.957,758.2318;Float;False;Property;_MainTex02_V_Speed;MainTex02V移动;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-3456.672,621.7739;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-3773.933,725.8168;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-3848.237,914.1196;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-3586.201,422.5463;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-3878.042,460.5056;Inherit;False;0;40;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;40;-3321.665,596.0728;Inherit;True;Property;_MainTex02;MainTex02;7;0;Create;True;0;0;0;False;0;False;-1;None;57b44e6f95657d142a89474810ab68c2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-3271.171,2072.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-3494.863,2143.651;Inherit;False;62;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-2994.82,2276.954;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;71;-3326.682,2568.696;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-3102.682,2488.697;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-3262.682,2392.697;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3506.653,2413.354;Float;False;Property;_MaskSpeedU;MaskU移动;20;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3506.653,2493.354;Float;False;Property;_MaskSpeedU1;MaskV移动;21;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-3151.144,2200.454;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-2828.129,2239.226;Inherit;True;Property;_MaskRG;MaskRG;18;0;Create;True;0;0;0;False;0;False;-1;None;9f12324cf6115a443b277025f7fa16e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;81;-3500.166,2033.003;Inherit;False;Property;_Mask_NoiseIntensity;Mask_NoiseIntensity;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-3456.567,2250.647;Inherit;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-2439.517,2363.736;Inherit;True;MaskG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;-3194.794,247.7832;Inherit;False;Property;_MainTex02_Color;MainTex02_Color;10;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;-2866.158,-800.5911;Inherit;False;Property;_MainTex01_Color;MainTex01_Color;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;11.98431,1.129412,0.1882353,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;-2635.829,-786.225;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-2623.924,1407.017;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;211;-2973.948,604.898;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;91;2607.696,1180.947;Inherit;True;Property;_RemapTex;RemapTex(Clamp);26;0;Create;False;0;0;0;False;0;False;-1;b76bcda6cc404784897ec078f082eacc;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-3415.864,-813.4305;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-2446.642,2108.662;Inherit;True;MaskR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-1688.514,-1031.597;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;109.9866,84.95889;Inherit;False;251;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2616.68,1659.134;Float;False;Property;_NoiseVqiangdu;Noise强度;15;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2435.617,1417.469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;298;-2491.875,1299.617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;277;-2223.321,-1884.028;Inherit;False;Property;_UnderskirtColor;裙底颜色;5;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;47.93726,3.764706,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-1952.176,-1816.735;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;297;-1743.41,-1822.406;Inherit;False;UnderskirtColorA;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;294;-1968.622,-1506.333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-3047.445,-1552.35;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;280;-2808.171,-1644.421;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;293;-2209.476,-1546.999;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;292;-2525.049,-1634.224;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-2575.098,-1414.544;Inherit;False;Property;_UnderskirtColorEdge;UnderskirtColorEdge;6;0;Create;True;0;0;0;False;0;False;0.73;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;-3005.726,-1649.218;Inherit;False;62;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-2263.677,1417.01;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;35.73211,1321.327;Inherit;False;Dissolove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-2390.239,617.41;Inherit;False;Property;_MainTexorMaskR;是否和MaskR相乘;8;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3800.861,269.2419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-4068.82,243.2682;Inherit;False;Property;_MainTex02_NoiseIntensity;MainTex02_NoiseIntensity;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-4016.521,348.8394;Inherit;False;62;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-3244.796,827.5746;Inherit;False;Property;_MainTex02_Peower;MainTex02_Peower;9;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;259;-2810.5,594.0385;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-2628.516,498.9932;Inherit;False;159;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-2906.292,273.6602;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2627.984,290.0826;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-2413.089,444.5719;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;260;-2147.096,301.3554;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;-1864.469,315.3995;Inherit;False;MainTex02;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-1454.869,-1304.062;Inherit;True;169;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;-1463.468,-1097.04;Inherit;False;179;MainTex02;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1078.157,-293.8591;Inherit;False;112;DissoloveEge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;269;-557.5025,-846.2138;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;189;-768.2714,-869.8779;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;299;-555.2041,-674.5083;Inherit;False;Constant;_flo0;flo 0;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1190.925,-1057.613;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-273.9406,-382.658;Inherit;False;159;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;84;-274.8214,-290.9989;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;126;-268.1009,-103.4193;Inherit;False;124;Dissolove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;-293.7516,3.98293;Inherit;False;242;MaskG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;301;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;303;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;304;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;305;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;306;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;307;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;308;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;309;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;310;2213.328,-658.3865;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-2156.281,-699.3677;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;128;-872.4731,-631.4571;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-386.2258,-649.347;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;311;1232.602,-267.2944;Inherit;False;Constant;_Float1;Float 1;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;302;1340.28,-724.0016;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;Hidden/QF/NssFX/NssFX_ASE/SkirtFlame;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;2;True;1;d3d11;0;False;True;2;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638459958152299266;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638459958718405272;  Use Shadow Threshold;0;0;Receive Shadows;0;638459958730101194;GPU Instancing;0;638459958723256966;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;633.9987,-587.8287;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
WireConnection;6;0;66;0
WireConnection;6;1;10;0
WireConnection;10;0;11;0
WireConnection;10;1;9;0
WireConnection;11;0;7;0
WireConnection;11;1;8;0
WireConnection;14;0;267;0
WireConnection;14;1;1;0
WireConnection;107;0;108;0
WireConnection;95;0;100;1
WireConnection;95;1;107;0
WireConnection;100;1;101;0
WireConnection;112;0;91;0
WireConnection;89;0;99;0
WireConnection;195;0;92;0
WireConnection;195;1;207;0
WireConnection;97;0;184;0
WireConnection;97;1;96;0
WireConnection;99;0;97;0
WireConnection;99;1;98;0
WireConnection;192;0;89;0
WireConnection;92;0;192;0
WireConnection;92;1;93;0
WireConnection;207;0;194;0
WireConnection;207;1;196;0
WireConnection;118;0;111;0
WireConnection;118;1;120;0
WireConnection;213;0;118;0
WireConnection;213;1;198;0
WireConnection;214;0;213;0
WireConnection;66;0;77;0
WireConnection;66;1;5;0
WireConnection;77;0;78;0
WireConnection;77;1;65;0
WireConnection;61;0;57;0
WireConnection;61;1;58;0
WireConnection;56;0;52;0
WireConnection;56;1;60;0
WireConnection;60;0;61;0
WireConnection;60;1;59;0
WireConnection;51;1;56;0
WireConnection;150;0;145;0
WireConnection;150;1;147;0
WireConnection;150;2;215;1
WireConnection;150;3;160;0
WireConnection;147;0;172;1
WireConnection;147;1;172;2
WireConnection;147;2;172;3
WireConnection;216;0;222;0
WireConnection;216;1;218;0
WireConnection;218;0;219;0
WireConnection;218;1;217;0
WireConnection;222;1;223;0
WireConnection;219;0;220;0
WireConnection;219;1;221;0
WireConnection;85;0;187;0
WireConnection;85;1;84;4
WireConnection;85;2;126;0
WireConnection;85;3;240;0
WireConnection;237;0;85;0
WireConnection;237;1;235;0
WireConnection;236;0;85;0
WireConnection;236;1;237;0
WireConnection;236;2;238;0
WireConnection;103;0;104;0
WireConnection;103;1;102;0
WireConnection;104;0;105;0
WireConnection;104;1;106;0
WireConnection;101;0;109;0
WireConnection;101;1;103;0
WireConnection;245;0;243;0
WireConnection;245;1;244;0
WireConnection;254;0;245;0
WireConnection;247;0;254;0
WireConnection;247;1;248;0
WireConnection;247;2;249;0
WireConnection;250;0;247;0
WireConnection;251;0;250;0
WireConnection;1;1;6;0
WireConnection;215;1;216;0
WireConnection;94;0;95;0
WireConnection;35;0;36;0
WireConnection;35;1;34;0
WireConnection;33;0;64;0
WireConnection;33;1;35;0
WireConnection;36;0;37;0
WireConnection;36;1;38;0
WireConnection;64;0;79;0
WireConnection;64;1;39;0
WireConnection;40;1;33;0
WireConnection;82;0;81;0
WireConnection;82;1;75;0
WireConnection;68;0;76;0
WireConnection;68;1;72;0
WireConnection;72;0;73;0
WireConnection;72;1;71;0
WireConnection;73;0;69;0
WireConnection;73;1;70;0
WireConnection;76;0;82;0
WireConnection;76;1;44;0
WireConnection;12;1;68;0
WireConnection;242;0;12;2
WireConnection;267;0;13;0
WireConnection;267;1;13;4
WireConnection;83;0;51;1
WireConnection;211;0;40;0
WireConnection;211;1;212;0
WireConnection;91;1;195;0
WireConnection;159;0;12;1
WireConnection;275;0;278;0
WireConnection;275;1;294;0
WireConnection;54;0;298;0
WireConnection;54;1;53;0
WireConnection;298;0;83;0
WireConnection;278;0;277;0
WireConnection;278;1;277;4
WireConnection;297;0;278;0
WireConnection;294;0;293;0
WireConnection;280;0;281;0
WireConnection;280;1;270;2
WireConnection;293;0;292;0
WireConnection;293;1;291;0
WireConnection;292;0;280;0
WireConnection;62;0;54;0
WireConnection;124;0;94;0
WireConnection;79;0;80;0
WireConnection;79;1;63;0
WireConnection;259;0;211;0
WireConnection;268;0;42;0
WireConnection;268;1;42;4
WireConnection;32;0;268;0
WireConnection;32;1;259;0
WireConnection;263;0;32;0
WireConnection;263;1;262;0
WireConnection;260;0;32;0
WireConnection;260;1;263;0
WireConnection;260;2;261;0
WireConnection;179;0;260;0
WireConnection;269;0;189;1
WireConnection;269;1;189;2
WireConnection;269;2;189;3
WireConnection;46;0;181;0
WireConnection;46;1;180;0
WireConnection;46;2;275;0
WireConnection;169;0;14;0
WireConnection;128;0;46;0
WireConnection;128;1;214;0
WireConnection;128;2;134;0
WireConnection;143;0;269;0
WireConnection;143;1;128;0
WireConnection;302;2;143;0
WireConnection;302;3;236;0
WireConnection;302;5;150;0
WireConnection;2;0;143;0
WireConnection;2;3;236;0
ASEEND*/
//CHKSM=0D3C88258318D8FCA9537EA4F72BFEB0A1DFEF48