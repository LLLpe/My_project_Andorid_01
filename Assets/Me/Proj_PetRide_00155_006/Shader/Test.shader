// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Spark_ASE_ChiBang"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_BaseMap("BaseMap", 2D) = "white" {}
		_BaseCol("BaseCol", Color) = (1,1,1,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_ReflectMap("ReflectMap", 2D) = "black" {}
		_RampMap("RampMap", 2D) = "black" {}
		_FresnelMap("FresnelMap", 2D) = "black" {}
		_MatCap("MatCap", 2D) = "white" {}
		_ParalaxMap("ParalaxMap", 2D) = "white" {}
		_CrystalCol("CrystalCol", Color) = (1,1,1,0)
		_RandomMap("RandomMap", 2D) = "white" {}
		_RandomMapTillingSpeed("RandomMapTillingSpeed", Vector) = (1,1,0,0)
		_Height("Height", Range( -10 , 10)) = 1.640666
		_RandomWeight("RandomWeight", Range( 0 , 1)) = 0
		_VertexWeight("VertexWeight", Range( 0 , 1)) = 0
		_CrystalTilling("CrystalTilling", Vector) = (1,1,0,0)
		_Alpha("Alpha", Range( 0 , 1)) = 1
		_AlphaVColIntensity("AlphaVColIntensity", Range( 0 , 1)) = 0
		_ReflectIntensity("ReflectIntensity", Range( 0 , 1)) = 1
		_FrsnelPower("FrsnelPower", Float) = 1
		_RampIntensity("RampIntensity", Range( 0 , 1)) = 0.5
		_Light("Light", Range( 0 , 5)) = 1
		_StarMap("StarMap", 2D) = "black" {}
		[HDR]_StarCol("StarCol", Color) = (1,1,1,0)
		_StarIntensity("StarIntensity", Range( 0 , 50)) = 1
		_StarPower("StarPower", Range( 0 , 20)) = 1
		_StarTillingSpeed("StarTillingSpeed", Vector) = (1,1,0,0)
		[HDR]_ParalaxStarCol01("ParalaxStarCol01", Color) = (1,1,1,0)
		_ParalaxStarIntensity01("ParalaxStarIntensity01", Range( 0 , 10)) = 10
		_ParalaxStarPower01("ParalaxStarPower01", Range( 0 , 20)) = 1
		_ParalaxHeight01("Paralax Height01", Range( 0 , 10)) = 0
		_ParalaxSpeed("ParalaxSpeed", Float) = 0.3
		[HDR]_ParalaxStarCol02("ParalaxStarCol02", Color) = (1,1,1,0)
		_ParalaxStarIntensity02("ParalaxStarIntensity02", Range( 0 , 10)) = 1
		_ParalaxStarPower02("ParalaxStarPower02", Range( 0 , 20)) = 1
		_ParalaxHeight02("Paralax Height02", Range( 0 , 10)) = 1.640666
		_ParalaxSpeed2("ParalaxSpeed2", Float) = 0.3
		[ASEEnd]_ParalaxTillingScale("Paralax TillingScale", Vector) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

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
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 100700


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _NormalMap_ST;
			half4 _ParalaxStarCol01;
			half4 _StarTillingSpeed;
			half4 _StarCol;
			half4 _BaseMap_ST;
			half4 _BaseCol;
			half4 _ParalaxTillingScale;
			half4 _CrystalCol;
			half4 _RandomMapTillingSpeed;
			half4 _ParalaxStarCol02;
			half2 _CrystalTilling;
			half _ParalaxStarIntensity02;
			half _ParalaxStarPower02;
			half _ParalaxSpeed2;
			half _FrsnelPower;
			half _ParalaxStarPower01;
			half _ParalaxHeight02;
			half _ParalaxStarIntensity01;
			half _StarIntensity;
			half _ParalaxSpeed;
			half _StarPower;
			half _Alpha;
			half _Light;
			half _RandomWeight;
			half _VertexWeight;
			half _Height;
			half _RampIntensity;
			half _ReflectIntensity;
			half _ParalaxHeight01;
			half _AlphaVColIntensity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MatCap;
			sampler2D _NormalMap;
			sampler2D _ReflectMap;
			sampler2D _RampMap;
			sampler2D _ParalaxMap;
			sampler2D _RandomMap;
			sampler2D _BaseMap;
			sampler2D _StarMap;
			sampler2D _FresnelMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				o.ase_color = v.ase_color;
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
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;

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

				float2 uv_NormalMap = IN.ase_texcoord3.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half3 tex2DNode222 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), 1.0f );
				half3 ase_worldTangent = IN.ase_texcoord4.xyz;
				half3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal221 = tex2DNode222;
				half3 worldNormal221 = normalize( float3(dot(tanToWorld0,tanNormal221), dot(tanToWorld1,tanNormal221), dot(tanToWorld2,tanNormal221)) );
				half3 NDirWS228 = worldNormal221;
				half3 normalizeResult307 = normalize( mul( UNITY_MATRIX_V, half4( NDirWS228 , 0.0 ) ).xyz );
				half2 MatCapUV280 = ((normalizeResult307).xy*0.5 + 0.5);
				half4 MatCapCol283 = tex2D( _MatCap, MatCapUV280 );
				half3 normalizeResult317 = normalize( mul( UNITY_MATRIX_V, half4( NDirWS228 , 0.0 ) ).xyz );
				half3 NDirTangent319 = tex2DNode222;
				half3 temp_output_318_0 = ( (normalizeResult317*0.5 + 0.5) + NDirTangent319 );
				half4 ReflectCol321 = ( tex2D( _ReflectMap, temp_output_318_0.xy ) * _ReflectIntensity * ( 1.0 - IN.ase_color.r ) );
				half dotResult223 = dot( worldNormal221 , _MainLightPosition.xyz );
				half HLambet227 = saturate( ( ( dotResult223 * 0.5 ) + 0.5 ) );
				half2 appendResult340 = (half2(HLambet227 , 0.2));
				half4 RampCol342 = ( tex2D( _RampMap, appendResult340 ) * _RampIntensity );
				half lerpResult393 = lerp( 1.0 , ( 1.0 - IN.ase_color.g ) , _VertexWeight);
				half mulTime407 = _TimeParameters.x * ( (_RandomMapTillingSpeed).zw * float2( 0.01,0.01 ) ).x;
				half2 temp_cast_6 = (mulTime407).xx;
				half2 texCoord409 = IN.ase_texcoord3.xy * (_RandomMapTillingSpeed).xy + temp_cast_6;
				half lerpResult394 = lerp( 1.0 , tex2D( _RandomMap, texCoord409 ).r , _RandomWeight);
				half CrystalHeight396 = ( _Height * lerpResult393 * lerpResult394 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = SafeNormalize( ase_tanViewDir );
				half2 texCoord259 = IN.ase_texcoord3.xy * _CrystalTilling + ( CrystalHeight396 * (ase_tanViewDir).xy * 0.1 );
				half4 Crystal305 = ( ( 1.0 - IN.ase_color.r ) * tex2D( _ParalaxMap, texCoord259 ) * _CrystalCol );
				half4 temp_output_293_0 = ( float4( 0,0,0,0 ) + MatCapCol283 + ReflectCol321 + RampCol342 + Crystal305 );
				float2 uv_BaseMap = IN.ase_texcoord3.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				half Light372 = _Light;
				half mulTime235 = _TimeParameters.x * ( (_StarTillingSpeed).zw * 0.01 ).x;
				half2 temp_cast_8 = (mulTime235).xx;
				half2 texCoord25 = IN.ase_texcoord3.xy * (_StarTillingSpeed).xy + temp_cast_8;
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				half2 UVOffset115 = ( ( (ase_worldViewDir).xy / 20.0 ) + ( (ase_worldNormal).xy / 20.0 ) );
				half4 saferPower128 = abs( ( tex2D( _StarMap, texCoord25 ) * tex2D( _StarMap, ( ( texCoord25 + UVOffset115 ) * 1.5 ) ) * _StarIntensity ) );
				half4 temp_cast_9 = (_StarPower).xxxx;
				half4 SparkMask33 = pow( saferPower128 , temp_cast_9 );
				half mulTime197 = _TimeParameters.x * _ParalaxSpeed;
				half2 texCoord43 = IN.ase_texcoord3.xy * (_ParalaxTillingScale).xy + ( ( mulTime197 * 0.01 ) + ( ( 1.0 - _ParalaxHeight01 ) * (ase_tanViewDir).xy * 0.01 ) );
				half2 ParalaxUV47 = texCoord43;
				half4 saferPower190 = abs( ( tex2D( _StarMap, ParalaxUV47 ) * tex2D( _StarMap, ( ( ParalaxUV47 + UVOffset115 ) * 1.5 ) ) * _ParalaxStarIntensity01 ) );
				half4 temp_cast_10 = (_ParalaxStarPower01).xxxx;
				half4 ParalaxSparkMask67 = pow( saferPower190 , temp_cast_10 );
				half mulTime199 = _TimeParameters.x * _ParalaxSpeed2;
				half2 texCoord100 = IN.ase_texcoord3.xy * (_ParalaxTillingScale).zw + ( ( mulTime199 * 0.01 ) + ( ( 1.0 - ( _ParalaxHeight01 + _ParalaxHeight02 ) ) * (ase_tanViewDir).xy * 0.01 ) );
				half2 ParalaxUV298 = texCoord100;
				half4 saferPower191 = abs( ( tex2D( _StarMap, ParalaxUV298 ) * tex2D( _StarMap, ( ( ParalaxUV298 + UVOffset115 ) * 1.5 ) ) * _ParalaxStarIntensity02 ) );
				half4 temp_cast_11 = (_ParalaxStarPower02).xxxx;
				half4 ParalaxSparkMask299 = pow( saferPower191 , temp_cast_11 );
				half4 Fresnel208 = ( _FrsnelPower * tex2D( _FresnelMap, temp_output_318_0.xy ) );
				
				half lerpResult302 = lerp( _Alpha , ( 1.0 - IN.ase_color.r ) , _AlphaVColIntensity);
				

				float3 Color = ( ( ( ( IN.ase_color.r * temp_output_293_0 ) + temp_output_293_0 ) * ( _BaseCol * tex2D( _BaseMap, uv_BaseMap ) * Light372 ) ) + ( ( ( ( _StarCol * SparkMask33 ) + ( ParalaxSparkMask67 * _ParalaxStarCol01 ) ) + ( ParalaxSparkMask299 * _ParalaxStarCol02 ) ) * ( 1.0 - IN.ase_color.r ) ) + Fresnel208 ).rgb;
				float Alpha = lerpResult302;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
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
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask A

			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 100700


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

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
			half4 _NormalMap_ST;
			half4 _ParalaxStarCol01;
			half4 _StarTillingSpeed;
			half4 _StarCol;
			half4 _BaseMap_ST;
			half4 _BaseCol;
			half4 _ParalaxTillingScale;
			half4 _CrystalCol;
			half4 _RandomMapTillingSpeed;
			half4 _ParalaxStarCol02;
			half2 _CrystalTilling;
			half _ParalaxStarIntensity02;
			half _ParalaxStarPower02;
			half _ParalaxSpeed2;
			half _FrsnelPower;
			half _ParalaxStarPower01;
			half _ParalaxHeight02;
			half _ParalaxStarIntensity01;
			half _StarIntensity;
			half _ParalaxSpeed;
			half _StarPower;
			half _Alpha;
			half _Light;
			half _RandomWeight;
			half _VertexWeight;
			half _Height;
			half _RampIntensity;
			half _ReflectIntensity;
			half _ParalaxHeight01;
			half _AlphaVColIntensity;
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

				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = float3( 0.5, 0.5, 0.5 );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define ASE_SRP_VERSION 100700


			#pragma vertex vert
			#pragma fragment frag

			

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
			half4 _NormalMap_ST;
			half4 _ParalaxStarCol01;
			half4 _StarTillingSpeed;
			half4 _StarCol;
			half4 _BaseMap_ST;
			half4 _BaseCol;
			half4 _ParalaxTillingScale;
			half4 _CrystalCol;
			half4 _RandomMapTillingSpeed;
			half4 _ParalaxStarCol02;
			half2 _CrystalTilling;
			half _ParalaxStarIntensity02;
			half _ParalaxStarPower02;
			half _ParalaxSpeed2;
			half _FrsnelPower;
			half _ParalaxStarPower01;
			half _ParalaxHeight02;
			half _ParalaxStarIntensity01;
			half _StarIntensity;
			half _ParalaxSpeed;
			half _StarPower;
			half _Alpha;
			half _Light;
			half _RandomWeight;
			half _VertexWeight;
			half _Height;
			half _RampIntensity;
			half _ReflectIntensity;
			half _ParalaxHeight01;
			half _AlphaVColIntensity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			float3 _LightDirection;
			#if ASE_SRP_VERSION >= 110000
				float3 _LightPosition;
			#endif

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if ASE_SRP_VERSION >= 110000
					#if _CASTING_PUNCTUAL_LIGHT_SHADOW
						float3 lightDirectionWS = normalize(_LightPosition - positionWS);
					#else
						float3 lightDirectionWS = _LightDirection;
					#endif

					float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#endif
				#else
					float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

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

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
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

			#define ASE_SRP_VERSION 100700


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
			half4 _NormalMap_ST;
			half4 _ParalaxStarCol01;
			half4 _StarTillingSpeed;
			half4 _StarCol;
			half4 _BaseMap_ST;
			half4 _BaseCol;
			half4 _ParalaxTillingScale;
			half4 _CrystalCol;
			half4 _RandomMapTillingSpeed;
			half4 _ParalaxStarCol02;
			half2 _CrystalTilling;
			half _ParalaxStarIntensity02;
			half _ParalaxStarPower02;
			half _ParalaxSpeed2;
			half _FrsnelPower;
			half _ParalaxStarPower01;
			half _ParalaxHeight02;
			half _ParalaxStarIntensity01;
			half _StarIntensity;
			half _ParalaxSpeed;
			half _StarPower;
			half _Alpha;
			half _Light;
			half _RandomWeight;
			half _VertexWeight;
			half _Height;
			half _RampIntensity;
			half _ReflectIntensity;
			half _ParalaxHeight01;
			half _AlphaVColIntensity;
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
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;402;87.79799,-1279.466;Inherit;False;1171.742;841.605;RandomMap;12;258;392;247;391;395;393;390;394;381;396;378;384;RandomMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;343;-2395.801,5460.762;Inherit;False;984.0298;280;RampCol;6;338;339;340;341;342;347;RampCol;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;325;-2415.43,4860.376;Inherit;False;1781.21;507.1108;ReflectMap;11;314;315;316;317;318;312;320;323;322;311;399;ReflectMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;288;-2386.152,4030.287;Inherit;False;1165.792;688.3389;Fresnel;8;210;207;215;287;209;211;214;229;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;285;102.9999,81.07434;Inherit;False;2342.329;451.2591;Crystal Col;14;305;310;252;357;358;359;360;244;250;251;249;259;397;400;Crystal Col;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;284;105.5682,-339.7881;Inherit;False;1425.556;309.5074;MatCap;3;283;282;281;MatCap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;206;-2423.811,2798.458;Inherit;False;3012.877;1110.253;Spark;5;180;181;156;398;152;闪点;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2425.437,144.9359;Inherit;False;1428.591;712.107;Spark;4;23;25;24;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-2420.602,994.2558;Inherit;False;1074.066;638.9739;ParalaxUV;13;41;240;117;47;43;203;204;198;197;55;39;46;40;视差;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1304.351,990.7654;Inherit;False;1428.591;712.107;ParalaxSpark;5;68;189;74;75;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;80;-2413.964,1956.033;Inherit;False;1074.066;638.9739;ParalaxUV;1;100;视差;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1299.11,1955.833;Inherit;False;1428.591;712.107;ParalaxSpark;4;87;192;90;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1179.598,2045.355;Inherit;False;98;ParalaxUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-974.285,2424.322;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-350.9683,2197.479;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;191;-227.7177,2303.139;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-356.2105,1232.411;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2354.125,1325.08;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;190;-230.4185,1338.938;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;39;-2400.754,1141.516;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;55;-2236.427,1141.668;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;197;-1778.484,1070.737;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-1938.017,1066.498;Inherit;False;Property;_ParalaxSpeed;ParalaxSpeed;31;0;Create;True;0;0;0;False;0;False;0.3;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1605.432,1107.786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-1758.832,1155.725;Inherit;False;Constant;_Float13;Float 13;25;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1264.524,1046.978;Inherit;False;47;ParalaxUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-975.524,1342.808;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-846.3909,1342.28;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-853.342,1458.052;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;206.4633,3401.313;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-78.84753,3299.464;Inherit;True;2;2;0;COLOR;1,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-1532.453,3280.351;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;165;-1305.571,3494.998;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;-1244.471,2980.951;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1083.928,3041.826;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-569.5116,3286.456;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0.2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-576.6221,3116.55;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-770.2621,3213.346;Inherit;False;Constant;_Float9;Float 9;21;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;185;-901.4406,3360.372;Inherit;True;Property;_TextureSample1;Texture Sample 1;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;184;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-1076.184,3381.012;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;157;-1849.952,3438.051;Inherit;False;True;4;0;FLOAT3;1,0,1;False;1;FLOAT;-90;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;167;-1854.183,3646.359;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;158;-2073.452,3280.351;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;177;-425.7783,3381.851;Inherit;True;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;176;-419.8311,3116.56;Inherit;True;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;20;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;184;-890.1287,2976.16;Inherit;True;Property;_SparkMap;SparkMap;37;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-1385.902,3277.261;Inherit;False;Property;_SparkTiling;SparkTiling;40;0;Create;True;0;0;0;False;0;False;5;10;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-1644.831,3719.843;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-1456.157,3730.283;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-1860.601,3793.712;Inherit;False;Property;_SparkSpeed;SparkSpeed;39;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;-1514.253,2856.627;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;151;-2373.811,2852.858;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;154;-1836.661,3031.707;Inherit;False;False;4;0;FLOAT3;0,1,0;False;1;FLOAT;90;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-822.0351,3578.461;Inherit;False;Property;_SparkPower;SparkPower;41;0;Create;True;0;0;0;False;0;False;1;1;0.1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1504.126,426.5753;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;128;-1356.748,432.8768;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1830.667,680.2575;Inherit;False;Property;_StarIntensity;StarIntensity;23;0;Create;True;0;0;0;False;0;False;1;3.9;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1995.871,488.5545;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2009.089,582.4955;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-2123.043,488.1531;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2407.63,586.6263;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1463.444,666.7154;Inherit;False;Property;_StarPower;StarPower;24;0;Create;True;0;0;0;False;0;False;1;1.7;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;65;-1271.276,1385.734;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;66;-1271.095,1563.916;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-1096.065,1445.852;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-1108.465,2428.561;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-2412.577,690.7278;Inherit;False;115;UVOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-1233.594,1696.221;Inherit;False;115;UVOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-2244.086,487.1145;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;28;-2421.441,421.4555;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1554.252,1296.62;Inherit;False;ParalaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-1801.284,1347.449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;240;-2186.586,1559.304;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;91;-1306.676,2336.443;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;92;-1284.495,2493.625;Inherit;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;96;-690.6285,2281.539;Inherit;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;white;Auto;False;Instance;74;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-844.7717,2303.024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-963.2448,2304.357;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-1279.848,2572.039;Inherit;False;115;UVOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;83;-2025.897,2104.591;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-2119.405,1995.72;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2332.398,2303.622;Inherit;False;Constant;_Float7;Float 7;8;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;-2397.484,2151.563;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;85;-2207.194,2158.811;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2031.685,2221.86;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1683.427,2261.912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;199;-1694.487,2032.039;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;200;-1873.333,2025.225;Inherit;False;Property;_ParalaxSpeed2;ParalaxSpeed2;36;0;Create;True;0;0;0;False;0;False;0.3;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-1660.298,2116.711;Inherit;False;Constant;_Float12;Float 12;25;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;-1506.898,2085.511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-2396.292,2071.796;Inherit;False;Property;_ParalaxHeight02;Paralax Height02;35;0;Create;True;0;0;0;False;0;False;1.640666;4.56;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;241;-2325.69,2448.125;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1542.25,2258.812;Inherit;False;ParalaxUV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1931.796,4395.066;Inherit;False;Property;_FresnelIntensity;FresnelIntensity;42;0;Create;True;0;0;0;False;0;False;0;0.061;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;209;-1853.562,4169.955;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-1608.396,4360.818;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;214;-1873.747,4506.612;Inherit;False;Property;_FresnelCol;FresnelCol;44;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4386792,0.6257862,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;311;-1332.758,5021.106;Inherit;True;Property;_ReflectMap;ReflectMap;3;0;Create;True;0;0;0;False;0;False;-1;None;21de4dbae3faa724a94be5964984d78f;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewMatrixNode;314;-2293.518,4910.376;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;-2136.865,4930.894;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-1513.921,5031.756;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;317;-1910.948,4934.847;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;334;-1069.679,4758.835;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;316;-1726.667,4936.253;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-1732.956,5154.545;Inherit;False;319;NDirTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;333;-1262.679,4713.835;Inherit;False;Property;_FrsnelPower;FrsnelPower;18;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;278.5999,1517.128;Inherit;False;67;ParalaxSparkMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;541.5604,1599.598;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;895.6176,1482.894;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;1045.91,1659.839;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;787.531,1929.904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;506.6978,1856.37;Inherit;False;99;ParalaxSparkMask2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;79;274.9422,1662.745;Inherit;False;Property;_ParalaxStarCol01;ParalaxStarCol01;27;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.8486246,0.9417664,1.976675,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;104;503.0401,2001.987;Inherit;False;Property;_ParalaxStarCol02;ParalaxStarCol02;32;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.8486246,0.9417664,1.976675,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;302;1269.427,2282.229;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;330;909.7018,2333.28;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;332;-1375.041,4812.669;Inherit;True;Property;_FresnelMap;FresnelMap;5;0;Create;True;0;0;0;False;0;False;-1;None;d44519f0b35d9564494e702db04accf9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;340;-2165.115,5539.139;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-1704.221,5605.804;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;342;-1591.771,5534.705;Inherit;False;RampCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;293;1488.419,911.7026;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;180;-84.69765,3603.844;Inherit;False;Property;_SparkCol;SparkCol;38;1;[HDR];Create;True;0;0;0;False;0;False;0.9622642,0.9622642,0.9622642,0;0.9622642,0.9622642,0.9622642,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;339;-2341.115,5628.139;Inherit;False;Constant;_Float10;Float 10;41;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;835.3905,2219.71;Inherit;False;Property;_Alpha;Alpha;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;331;713.2943,2309.53;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;346;-1934.043,5795.843;Inherit;False;Property;_RampIntensity;RampIntensity;19;0;Create;True;0;0;0;False;0;False;0.5;0.172;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-1012.862,5138.487;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-806.3105,5114.721;Inherit;False;ReflectCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;354;-1218.519,5402.69;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;353;-1378.578,5402.728;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;322;-1346.596,5252.487;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-907.1471,4634.892;Inherit;True;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-83.83454,786.5023;Inherit;False;227;HLambet;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-2350.952,4082.273;Inherit;False;228;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-2147.342,4307.956;Inherit;False;Property;_FresnelPower;FresnelPower;43;0;Create;True;0;0;0;False;0;False;1;1;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;-1696.967,4121.292;Inherit;False;FresnelMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;1629.737,773.3334;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;1113.923,-246.8431;Inherit;False;MatCapCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;359;1697.886,134.2137;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;1973.726,248.1339;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;739.3922,1287.371;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;36;365.5045,1240.222;Inherit;False;Property;_StarCol;StarCol;22;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.8486246,0.9417664,1.976675,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;37;361.2326,1417.265;Inherit;False;33;SparkMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;357;1557.772,352.8044;Inherit;False;Property;_CrystalCol;CrystalCol;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;189;-371.2105,1558.719;Inherit;False;Property;_ParalaxStarPower01;ParalaxStarPower01;29;0;Create;True;0;0;0;False;0;False;1;2.5;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-368.5096,2522.92;Inherit;False;Property;_ParalaxStarPower02;ParalaxStarPower02;34;0;Create;True;0;0;0;False;0;False;1;5.8;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-682.4712,2525.639;Inherit;False;Property;_ParalaxStarIntensity02;ParalaxStarIntensity02;33;0;Create;True;0;0;0;False;0;False;1;1.79;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-683.7125,1560.571;Inherit;False;Property;_ParalaxStarIntensity01;ParalaxStarIntensity01;28;0;Create;True;0;0;0;False;0;False;10;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;90;-693.8638,2028.164;Inherit;True;Property;_ParalaxStarMap02;ParalaxStarMap02;21;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;black;Auto;False;Instance;74;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1863.866,193.9122;Inherit;True;Property;_StarMap01;StarMap01;21;0;Create;True;0;0;0;False;0;False;-1;294a7782d8c0b2b4d83008cc98071755;4d338736dec3e27489089bcbb41ae3c0;True;0;False;black;Auto;False;Instance;74;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;24;-1852.688,461.0086;Inherit;True;Property;_StarMap02;StarMap02;21;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;white;Auto;False;Instance;74;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;303;936.4274,2437.229;Inherit;False;Property;_AlphaVColIntensity;AlphaVColIntensity;16;0;Create;True;0;0;0;False;0;False;0;0.341;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;367;1246.317,1870.61;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;1394.22,1732.098;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;366;1057.138,1870.49;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;349;1771.927,889.3177;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;351;1407.287,744.6266;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;372;1322.696,587.9935;Inherit;False;Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;645.9828,828.9795;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;356.1125,1056.218;Inherit;False;372;Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;1054.027,584.9338;Inherit;False;Property;_Light;Light;20;0;Create;True;0;0;0;False;0;False;1;1.47;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;1219.896,870.9002;Inherit;False;283;MatCapCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;1221.236,949.7258;Inherit;False;321;ReflectCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;1226.348,1101.476;Inherit;False;342;RampCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;306;1226.023,1178.024;Inherit;False;305;Crystal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;1429.358,1346.916;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;149;1649.027,1555.528;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;1383.706,1914.37;Inherit;False;208;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;60;312.1522,623.9993;Inherit;False;Property;_BaseCol;BaseCol;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.9119486,0.8726415,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;268.5502,816.8785;Inherit;True;Property;_BaseMap;BaseMap;0;0;Create;True;0;0;0;False;0;False;-1;None;5a374eae922306947a9f52fa36103312;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;360;1521.648,107.9695;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;75;-711.3317,1322.442;Inherit;True;Property;_TextureSample2;Texture Sample 2;21;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;white;Auto;False;Instance;74;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2042.71,1254.715;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;40;-2229.36,1050.336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;136.7142,-268.4762;Inherit;False;280;MatCapUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;74;-718.1216,1048.872;Inherit;True;Property;_StarMap;StarMap;21;0;Create;True;0;0;0;False;0;False;-1;None;4d338736dec3e27489089bcbb41ae3c0;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;2163.913,245.1624;Inherit;False;Crystal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;365.0659,3394.983;Inherit;False;Spark00;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-158.5286,2192.066;Inherit;False;ParalaxSparkMask2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-144.2193,1228.109;Inherit;False;ParalaxSparkMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1181.858,430.3189;Inherit;False;SparkMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-860.4704,691.8105;Inherit;False;Constant;_Float14;Float 14;28;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;121;-756.0179,211.046;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-888.8723,406.223;Inherit;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;122;-798.0143,513.9693;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;216;-972.4174,515.2958;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;108;-956.4018,209.9738;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;193;-626.3069,319.224;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-484.8542,435.2812;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;194;-630.3069,463.224;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-334.6514,423.8214;Inherit;False;UVOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;20;95.31122,-85.27846;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;21;95.31122,-85.27846;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;22;95.31122,-85.27846;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2936.961,1035.231;Inherit;False;Property;_ParalaxHeight01;Paralax Height01;30;0;Create;True;0;0;0;False;0;False;0;2.25;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;239;-2935.327,1874.834;Inherit;False;Property;_ParalaxTillingScale;Paralax TillingScale;45;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1.5,1.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;223;-1856.062,-260.533;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-1639.15,-255.0997;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-1502.15,-253.0997;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;278;-1065.274,-491.1047;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;-831.1616,-487.2221;Inherit;False;MatCapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;277;-1811.285,-526.8401;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;276;-1647.632,-488.3225;Inherit;True;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;307;-1447.852,-484.1294;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;279;-1298.184,-490.3398;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-1086.477,-254.3861;Inherit;False;HLambet;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;345;-1264.384,-194.8732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;156;-2349.218,3267.624;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-1862.924,-403.7555;Inherit;False;NDirWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;152;-2123.211,2848.458;Inherit;True;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;398;-2346.408,3425.779;Inherit;False;228;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;312;-2377.109,5001.404;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;399;-2372.574,5166.645;Inherit;False;228;NDirWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;224;-2248.548,-168.3506;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;-2226.106,-481.6843;Inherit;False;NDirTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;221;-2223.672,-383.3371;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;310;691.019,189.965;Inherit;False;Property;_CrystalTilling;CrystalTilling;14;0;Create;True;0;0;0;False;0;False;1,1;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;676.3572,338.1601;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;250;150.448,272.6128;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;249;173.2016,419.3335;Inherit;False;Constant;_Float15;Float 15;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;251;367.2097,334.2071;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;288,190.5771;Inherit;False;396;CrystalHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;400;1223.871,173.0063;Inherit;False;CrystalUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-2950.194,-376.0458;Inherit;False;400;CrystalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;222;-2625.252,-402.5315;Inherit;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;0;False;0;False;-1;72eb5e6f6b07bfa4fadcbfb0079fcf17;72eb5e6f6b07bfa4fadcbfb0079fcf17;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;282;550.5893,-289.9638;Inherit;True;Property;_MatCap;MatCap;6;0;Create;True;0;0;0;False;0;False;-1;None;ef001cc2b6c9fb949a58f6985d4b1016;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;244;1241.881,255.8689;Inherit;True;Property;_ParalaxMap;ParalaxMap;7;0;Create;True;0;0;0;False;0;False;-1;None;d1d4e6cda54c5214cad6904aba2cfd50;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;259;983.8162,277.8503;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-1638.541,1472.001;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;-1634.957,2418.613;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;207;-2157.494,4082.817;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;348;-2287.275,5368.768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;-2466.382,5511.398;Inherit;False;227;HLambet;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;341;-1995.322,5493.057;Inherit;True;Property;_RampMap;RampMap;4;0;Create;True;0;0;0;False;0;False;-1;None;7ed3eabddafb4184d8870a2e5e52f873;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;395;344.9154,-811.379;Inherit;False;Constant;_Float17;Float 17;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;822.3518,-1052.567;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;394;594.5138,-740.4246;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;285.8982,-552.8613;Inherit;False;Property;_RandomWeight;RandomWeight;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;236;-3270,400;Inherit;False;Property;_Speed;Speed;26;0;Create;True;0;0;0;False;0;False;1;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;231;-3268,206;Inherit;False;Property;_StarTillingSpeed;StarTillingSpeed;25;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;403;-3063.326,290.264;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;232;-2608,208;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;235;-2774,400;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-2908,398;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-2416,208;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;365;-3152,480;Inherit;False;Constant;_Float11;Float 11;42;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;405;-642.9127,-655.4343;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;407;-353.5864,-545.6983;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;406;-187.5864,-719.575;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;-487.5867,-547.6983;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.01,0.01;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;404;-914.9809,-730.3042;Inherit;False;Property;_RandomMapTillingSpeed;RandomMapTillingSpeed;10;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;384;272.855,-740.0676;Inherit;True;Property;_RandomMap;RandomMap;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;396;1035.54,-998.3729;Inherit;False;CrystalHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;258;452.3262,-1229.466;Inherit;False;Property;_Height;Height;11;0;Create;True;0;0;0;False;0;False;1.640666;-1.35;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;332.7211,-1105.223;Inherit;False;Constant;_Float16;Float 16;45;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;247;329.8221,-1003.501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;391;247.0618,-889.4521;Inherit;False;Property;_VertexWeight;VertexWeight;13;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;393;547.3099,-1026.057;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;378;137.798,-1050.805;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;19;1958.499,1181.814;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;13;Spark_ASE_ChiBang;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;638366851244826349;  Blend;0;0;Two Sided;0;638366850506406571;Cast Shadows;1;638367367109654851;  Use Shadow Threshold;0;0;Receive Shadows;1;638366847850174230;GPU Instancing;0;638366833524775814;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;638366907272880813;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;True;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;18;1970.31,1415.473;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;3;True;12;all;0;True;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;409;4.413544,-737.6983;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;88;0;90;0
WireConnection;88;1;96;0
WireConnection;88;2;87;0
WireConnection;191;0;88;0
WireConnection;191;1;192;0
WireConnection;63;0;74;0
WireConnection;63;1;75;0
WireConnection;63;2;68;0
WireConnection;190;0;63;0
WireConnection;190;1;189;0
WireConnection;55;0;39;0
WireConnection;197;0;198;0
WireConnection;204;0;197;0
WireConnection;204;1;203;0
WireConnection;69;0;76;0
WireConnection;69;1;218;0
WireConnection;70;0;69;0
WireConnection;70;1;71;0
WireConnection;179;0;178;0
WireConnection;179;1;180;0
WireConnection;178;0;176;0
WireConnection;178;1;177;0
WireConnection;159;0;158;0
WireConnection;159;1;157;0
WireConnection;165;0;159;0
WireConnection;165;1;171;0
WireConnection;173;0;155;0
WireConnection;173;1;168;0
WireConnection;186;0;173;0
WireConnection;186;1;162;0
WireConnection;174;0;188;0
WireConnection;174;1;185;0
WireConnection;175;0;184;0
WireConnection;175;1;188;0
WireConnection;185;1;187;0
WireConnection;187;0;162;0
WireConnection;187;1;165;0
WireConnection;157;3;158;0
WireConnection;158;0;398;0
WireConnection;177;0;174;0
WireConnection;177;1;205;0
WireConnection;176;0;175;0
WireConnection;176;1;205;0
WireConnection;184;1;186;0
WireConnection;168;0;167;0
WireConnection;168;1;169;0
WireConnection;171;0;168;0
WireConnection;155;0;152;0
WireConnection;155;1;154;0
WireConnection;154;3;152;0
WireConnection;30;0;23;0
WireConnection;30;1;24;0
WireConnection;30;2;32;0
WireConnection;128;0;30;0
WireConnection;128;1;129;0
WireConnection;52;0;27;0
WireConnection;52;1;53;0
WireConnection;27;0;25;0
WireConnection;27;1;217;0
WireConnection;64;0;65;0
WireConnection;64;1;66;0
WireConnection;93;0;91;0
WireConnection;93;1;92;0
WireConnection;29;0;28;0
WireConnection;29;1;31;0
WireConnection;47;0;43;0
WireConnection;117;0;204;0
WireConnection;117;1;41;0
WireConnection;240;0;239;0
WireConnection;96;1;89;0
WireConnection;89;0;94;0
WireConnection;89;1;95;0
WireConnection;94;0;97;0
WireConnection;94;1;219;0
WireConnection;83;0;107;0
WireConnection;107;0;38;0
WireConnection;107;1;101;0
WireConnection;85;0;84;0
WireConnection;86;0;83;0
WireConnection;86;1;85;0
WireConnection;86;2;102;0
WireConnection;118;0;202;0
WireConnection;118;1;86;0
WireConnection;199;0;200;0
WireConnection;202;0;199;0
WireConnection;202;1;201;0
WireConnection;241;0;239;0
WireConnection;98;0;100;0
WireConnection;209;0;207;0
WireConnection;209;1;210;0
WireConnection;215;0;209;0
WireConnection;215;1;211;0
WireConnection;215;2;214;0
WireConnection;311;1;318;0
WireConnection;315;0;314;0
WireConnection;315;1;399;0
WireConnection;318;0;316;0
WireConnection;318;1;320;0
WireConnection;317;0;315;0
WireConnection;334;0;333;0
WireConnection;334;1;332;0
WireConnection;316;0;317;0
WireConnection;78;0;77;0
WireConnection;78;1;79;0
WireConnection;49;0;363;0
WireConnection;49;1;78;0
WireConnection;106;0;49;0
WireConnection;106;1;105;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;302;0;298;0
WireConnection;302;1;330;0
WireConnection;302;2;303;0
WireConnection;330;0;331;1
WireConnection;332;1;318;0
WireConnection;340;0;338;0
WireConnection;340;1;339;0
WireConnection;347;0;341;0
WireConnection;347;1;346;0
WireConnection;342;0;347;0
WireConnection;293;1;286;0
WireConnection;293;2;324;0
WireConnection;293;3;344;0
WireConnection;293;4;306;0
WireConnection;323;0;311;0
WireConnection;323;1;322;0
WireConnection;323;2;354;0
WireConnection;321;0;323;0
WireConnection;354;0;353;1
WireConnection;208;0;334;0
WireConnection;287;0;209;0
WireConnection;350;0;351;1
WireConnection;350;1;293;0
WireConnection;283;0;282;0
WireConnection;359;0;360;1
WireConnection;358;0;359;0
WireConnection;358;1;244;0
WireConnection;358;2;357;0
WireConnection;363;0;36;0
WireConnection;363;1;37;0
WireConnection;90;1;97;0
WireConnection;23;1;25;0
WireConnection;24;1;52;0
WireConnection;367;0;366;1
WireConnection;368;0;106;0
WireConnection;368;1;367;0
WireConnection;349;0;350;0
WireConnection;349;1;293;0
WireConnection;372;0;352;0
WireConnection;61;0;60;0
WireConnection;61;1;56;0
WireConnection;61;2;373;0
WireConnection;362;0;349;0
WireConnection;362;1;61;0
WireConnection;149;0;362;0
WireConnection;149;1;368;0
WireConnection;149;2;213;0
WireConnection;75;1;70;0
WireConnection;41;0;40;0
WireConnection;41;1;55;0
WireConnection;41;2;46;0
WireConnection;40;0;38;0
WireConnection;74;1;76;0
WireConnection;305;0;358;0
WireConnection;181;0;179;0
WireConnection;99;0;191;0
WireConnection;67;0;190;0
WireConnection;33;0;128;0
WireConnection;121;0;108;0
WireConnection;122;0;216;0
WireConnection;193;0;121;0
WireConnection;193;1;110;0
WireConnection;111;0;193;0
WireConnection;111;1;194;0
WireConnection;194;0;122;0
WireConnection;194;1;220;0
WireConnection;115;0;111;0
WireConnection;223;0;221;0
WireConnection;223;1;224;0
WireConnection;225;0;223;0
WireConnection;226;0;225;0
WireConnection;278;0;279;0
WireConnection;280;0;278;0
WireConnection;276;0;277;0
WireConnection;276;1;228;0
WireConnection;307;0;276;0
WireConnection;279;0;307;0
WireConnection;227;0;345;0
WireConnection;345;0;226;0
WireConnection;228;0;221;0
WireConnection;152;0;151;0
WireConnection;319;0;222;0
WireConnection;221;0;222;0
WireConnection;252;0;397;0
WireConnection;252;1;251;0
WireConnection;252;2;249;0
WireConnection;251;0;250;0
WireConnection;400;0;259;0
WireConnection;282;1;281;0
WireConnection;244;1;259;0
WireConnection;259;0;310;0
WireConnection;259;1;252;0
WireConnection;43;0;240;0
WireConnection;43;1;117;0
WireConnection;100;0;241;0
WireConnection;100;1;118;0
WireConnection;207;0;229;0
WireConnection;348;0;338;0
WireConnection;341;1;340;0
WireConnection;390;0;258;0
WireConnection;390;1;393;0
WireConnection;390;2;394;0
WireConnection;394;0;395;0
WireConnection;394;1;384;1
WireConnection;394;2;381;0
WireConnection;403;0;231;0
WireConnection;232;0;231;0
WireConnection;235;0;364;0
WireConnection;364;0;403;0
WireConnection;364;1;365;0
WireConnection;25;0;232;0
WireConnection;25;1;235;0
WireConnection;405;0;404;0
WireConnection;407;0;408;0
WireConnection;406;0;404;0
WireConnection;408;0;405;0
WireConnection;384;1;409;0
WireConnection;396;0;390;0
WireConnection;247;0;378;2
WireConnection;393;0;392;0
WireConnection;393;1;247;0
WireConnection;393;2;391;0
WireConnection;18;0;149;0
WireConnection;18;1;302;0
WireConnection;409;0;406;0
WireConnection;409;1;407;0
ASEEND*/
//CHKSM=EEA7E63544827BAA6788F22AADC13C3D5E180FCC