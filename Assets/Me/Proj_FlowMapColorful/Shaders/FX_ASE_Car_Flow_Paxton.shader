// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "QF/NssFX/NssFX_ASE/FX_ASE_Car_Flow_Paxton"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _VTInfoBlock( "VT( auto )", Vector ) = ( 0, 0, 0, 0 )
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex("颜色贴图", 2D) = "white" {}
		_AlphaTex("Alpha贴图", 2D) = "white" {}
		_AlphaWeight("AlphaWeight", Range( 0 , 1)) = 1
		[Space(20)][Header(________Emission________)][Space(10)]_EmissiveMap("EmissiveMap", 2D) = "black" {}
		[HDR]_Emissive("Emissive", Color) = (0,0,0,0)
		[Toggle]_EmisionParallaxFlow("计算视差和Flow", Float) = 0
		[Space(20)][Header(________Flow________)][Space(10)]_FlowMap("FlowMap", 2D) = "white" {}
		[Toggle]_UseUV2("使用UV2", Float) = 0
		_FlowPower("Flow强度", Range( -1 , 1)) = 0
		_TimeSpeed("Flow速度", Range( 0 , 5)) = 0
		[Space(20)][Header(________Height________)][Space(10)]_Height("Height", 2D) = "white" {}
		_IOR("视差强度", Range( 0.1 , 1)) = 0.1
		[Space(20)][Header(________Noise________)][Space(10)]_NoiseTex("噪声贴图", 2D) = "black" {}
		_NoiseIntensity("强度", Range( 0 , 5)) = 0
		_NoiseV("NoiseV", Range( 0 , 1)) = 0
		_NoiseU("NoiseU", Range( 0 , 1)) = 0
		[NoScaleOffset][Space(20)][Header(________Ramp________)][Space(10)]_Ramp("Ramp", 2D) = "white" {}
		_SpeedU("流动速度U", Float) = 0
		_SpeedV("流动速度V", Float) = 0
		_RampLerp("Ramp图强度", Range( 0 , 1)) = 0
		_RemapMax("RemapMax", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}

	}

	SubShader
	{

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
	LOD 100

		HLSLINCLUDE
		#define GAMMA_TEXTURE
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"
		ENDHLSL
		

		
		Pass
		{
			
			Name "DoublePassUnlit"

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend Off
			AlphaToMask Off
			Cull Back
			ColorMask 0
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			HLSLPROGRAM
			#define ASE_SRP_VERSION -1

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			CBUFFER_START( UnityPerMaterial )
			half4 _MainTex_ST;
			half4 _FlowMap_ST;
			half4 _Emissive;
			half4 _Height_ST;
			half4 _NoiseTex_ST;
			half4 _EmissiveMap_ST;
			half _EmisionParallaxFlow;
			half _RampLerp;
			half _RemapMax;
			half _SpeedV;
			half _SpeedU;
			half _NoiseV;
			half _NoiseU;
			half _IOR;
			half _TimeSpeed;
			half _FlowPower;
			half _UseUV2;
			half _NoiseIntensity;
			half _AlphaWeight;
			CBUFFER_END

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			

			v2f vert(appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = TransformObjectToHClip(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
				#endif
				return o;
			}

			real4 frag(v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				real4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				

				finalColor = real4(1,1,1,1);
				return NSS_OUTPUT_COLOR_SPACE(finalColor);
			}
			ENDHLSL
		}

		
		Pass
		{
			Name "DoublePass"

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			AlphaToMask Off
			Cull Back
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			

			HLSLPROGRAM
			#define ASE_SRP_VERSION -1

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_POSITION

			sampler2D _MainTex;
			sampler2D _FlowMap;
			sampler2D _Height;
			sampler2D _NoiseTex;
			sampler2D _Ramp;
			sampler2D _EmissiveMap;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			half4 _MainTex_ST;
			half4 _FlowMap_ST;
			half4 _Emissive;
			half4 _Height_ST;
			half4 _NoiseTex_ST;
			half4 _EmissiveMap_ST;
			half _EmisionParallaxFlow;
			half _RampLerp;
			half _RemapMax;
			half _SpeedV;
			half _SpeedU;
			half _NoiseV;
			half _NoiseU;
			half _IOR;
			half _TimeSpeed;
			half _FlowPower;
			half _UseUV2;
			half _NoiseIntensity;
			half _AlphaWeight;
			CBUFFER_END

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				half4 ase_tangent : TANGENT;
				half3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			

			v2f vert(appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord2.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = TransformObjectToHClip(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
				#endif
				return o;
			}

			real4 frag(v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				real4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				half2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half2 UV_Noise133 = uv_MainTex;
				float2 uv_FlowMap = i.ase_texcoord1.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float2 uv1_FlowMap = i.ase_texcoord1.zw * _FlowMap_ST.xy + _FlowMap_ST.zw;
				half3 temp_cast_1 = (1.0).xxx;
				half3 FLowDir20 = ( ( ( ((( _UseUV2 )?( tex2D( _FlowMap, uv1_FlowMap ) ):( tex2D( _FlowMap, uv_FlowMap ) ))).rgb * 2.0 ) - temp_cast_1 ) * _FlowPower );
				half mulTime22 = _TimeParameters.x * 0.5;
				half TimeSeed65 = _TimeSpeed;
				half phase033 = frac( ( ( mulTime22 * TimeSeed65 ) + 0.5 ) );
				half3 ase_worldTangent = i.ase_texcoord2.xyz;
				half3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				half3x3 ase_worldToTangent = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				half3 worldToTangentDir79 = mul( ase_worldToTangent, ase_worldNormal);
				float2 uv_Height = i.ase_texcoord1.xy * _Height_ST.xy + _Height_ST.zw;
				half4 Height96 = tex2D( _Height, uv_Height );
				half4 temp_cast_2 = (2.0).xxxx;
				half3 temp_output_76_0 = refract( ase_tanViewDir , worldToTangentDir79 , pow( ( _IOR * Height96 ) , temp_cast_2 ).r );
				half2 Refract_xy86 = ( (temp_output_76_0).xy / (temp_output_76_0).z );
				half2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				half2 appendResult244 = (half2(_NoiseU , _NoiseV));
				half lerpResult240 = lerp( 0.0 , NSS_TEX2D_GAMMA_TO_LINEAR( _NoiseTex, ( uv_NoiseTex + ( appendResult244 * _TimeParameters.x ) ) ).r , _NoiseIntensity);
				half disturbance245 = lerpResult240;
				half3 temp_output_48_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase033 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half mulTime25 = _TimeParameters.x * 0.5;
				half phase134 = frac( ( ( mulTime25 * TimeSeed65 ) + 1.0 ) );
				half3 temp_output_55_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase134 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half4 lerpResult56 = lerp( tex2D( _MainTex, temp_output_48_0.xy ) , tex2D( _MainTex, temp_output_55_0.xy ) , abs( ( ( 0.5 - phase033 ) / 0.5 ) ));
				half3 BaseCol128 = (lerpResult56).rgb;
				half2 appendResult73 = (half2(_SpeedU , _SpeedV));
				half mulTime74 = _TimeParameters.x * 0.1;
				half2 temp_cast_10 = (_RemapMax).xx;
				half3 lerpResult122 = lerp( BaseCol128 , ( BaseCol128 * (tex2D( _Ramp, (float2( 0,0 ) + ((( BaseCol128 + half3( ( appendResult73 * mulTime74 ) ,  0.0 ) )).xy - float2( 0,0 )) * (temp_cast_10 - float2( 0,0 )) / (float2( 1,1 ) - float2( 0,0 ))) )).rgb * 2.0 ) , _RampLerp);
				half3 FlowColor188 = lerpResult122;
				half4 Emissive114 = _Emissive;
				half4 saferPower309 = abs( Emissive114 );
				half4 temp_cast_12 = (3.0).xxxx;
				float2 uv_EmissiveMap = i.ase_texcoord1.xy * _EmissiveMap_ST.xy + _EmissiveMap_ST.zw;
				half3 temp_output_262_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase033 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half3 temp_output_264_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase134 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half4 lerpResult282 = lerp( tex2D( _EmissiveMap, temp_output_262_0.xy ) , tex2D( _EmissiveMap, temp_output_264_0.xy ) , abs( ( ( 0.5 - phase033 ) / 0.5 ) ));
				half clampResult295 = clamp( ( ((( _EmisionParallaxFlow )?( lerpResult282 ):( NSS_TEX2D_GAMMA_TO_LINEAR( _EmissiveMap, uv_EmissiveMap ) ))).r + ((( _EmisionParallaxFlow )?( lerpResult282 ):( NSS_TEX2D_GAMMA_TO_LINEAR( _EmissiveMap, uv_EmissiveMap ) ))).g + ((( _EmisionParallaxFlow )?( lerpResult282 ):( NSS_TEX2D_GAMMA_TO_LINEAR( _EmissiveMap, uv_EmissiveMap ) ))).b ) , 0.0 , 1.0 );
				half EmisionMask292 = clampResult295;
				half4 lerpResult308 = lerp( half4( FlowColor188 , 0.0 ) , pow( saferPower309 , temp_cast_12 ) , EmisionMask292);
				half3 temp_output_212_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase033 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half3 temp_output_214_0 = ( half3( UV_Noise133 ,  0.0 ) + ( FLowDir20 * phase134 ) + half3( Refract_xy86 ,  0.0 ) + disturbance245 );
				half4 lerpResult203 = lerp( tex2D( _AlphaTex, temp_output_212_0.xy ) , tex2D( _AlphaTex, temp_output_214_0.xy ) , abs( ( ( 0.5 - phase033 ) / 0.5 ) ));
				half Var_Alpha229 = (lerpResult203).r;
				half lerpResult179 = lerp( 1.0 , Var_Alpha229 , _AlphaWeight);
				half4 appendResult198 = (half4((lerpResult308).rgb , lerpResult179));
				

				finalColor = appendResult198;
				return NSS_OUTPUT_COLOR_SPACE(finalColor);
			}
			ENDHLSL
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}

/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;193;-2373.732,-1680.682;Inherit;False;2848.069;2128.292;Comment;2;190;191;FlowColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;191;-2163.515,-124.2601;Inherit;False;2015.214;480.3221;Ramp;18;167;124;123;125;122;68;119;121;120;118;73;70;72;71;187;74;177;188;Ramp;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;190;-2184.723,-1531.831;Inherit;False;2466.961;1278.983;SampleColor;31;44;52;54;53;89;160;50;51;49;48;162;163;55;149;183;152;161;155;40;45;43;56;57;63;59;61;62;60;64;128;246;Sample;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;186;-2180.049,1109.213;Inherit;False;1331.94;280;MatCap;5;108;107;109;110;111;MatCap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-3787.421,641.6636;Inherit;False;1468.272;776.6423;Refract_xy;15;80;86;84;83;85;76;78;79;90;93;95;91;97;94;96;Refract_xy;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-3771.781,-746.7513;Inherit;False;1192.464;1028.283;FlowMap;2;19;35;FlowMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-3720.481,-229.4681;Inherit;False;1084.167;508.4;phase;14;34;33;32;21;30;31;29;28;26;25;23;22;66;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-3718.317,-696.7513;Inherit;False;1089;446;FLowDir;9;18;17;13;14;16;15;12;20;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RefractOpVec;76;-3084.569,719.1084;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;85;-2697.871,745.3506;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;83;-2868.871,812.3506;Inherit;False;FLOAT;3;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;84;-2876.871,721.3506;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;90;-3244.814,1041.723;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3595.094,1307.2;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;79;-3509.421,860.6636;Inherit;False;World;Tangent;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;78;-3737.421,864.6636;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;80;-3481.153,710.1106;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-3247.317,-599.7514;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;15;-3385.317,-627.7514;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3219.317,-472.7512;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-3073.317,-562.7514;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2953.317,-466.7512;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-3385.317,-547.7512;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-2818.688,-472.4411;Inherit;False;FLowDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;108;-2130.049,1180.672;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;107;-1902.048,1176.672;Inherit;False;World;View;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;109;-1668.108,1183.213;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-1072.108,1172.213;Inherit;False;MatCap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-3196.458,-913.1237;Inherit;False;TimeSeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3759.575,1030.165;Inherit;False;Property;_IOR;视差强度;13;0;Create;False;0;0;0;False;0;False;0.1;0.739;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-553.4852,1120.18;Inherit;False;Property;_AlphaWeight;AlphaWeight;2;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;110;-1435.108,1159.213;Inherit;True;Property;_MatCap;MatCap;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;147;-4049.711,-477.8308;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-4048.317,-665.3925;Inherit;True;Property;_FlowMapSampler;FlowMapSampler;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;143;-3615.811,-639.1896;Inherit;False;Property;_UseUV2;使用UV2;7;0;Create;False;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3236.01,-373.7513;Inherit;False;Property;_FlowPower;Flow强度;8;0;Create;False;0;0;0;False;0;False;0;-0.496;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3572.301,-914.8528;Inherit;False;Property;_TimeSpeed;Flow速度;9;0;Create;False;0;0;0;False;0;False;0;2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-3197.943,-1109.377;Inherit;False;FlowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-930.0521,145.47;Inherit;False;Constant;_Float7;Float 7;16;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;121;-1539.044,70.9768;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1541.368,167.2595;Inherit;False;Property;_RemapMax;RemapMax;22;0;Create;True;0;0;0;False;0;False;0;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1654.893,76.40096;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-1954.825,102.3747;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1799.652,140.6169;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-1821.047,40.44545;Inherit;False;128;BaseCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;74;-2000.999,245.062;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-908.9479,-67.26011;Inherit;False;128;BaseCol;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;167;-902.2241,46.15764;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;119;-1392.437,75.16537;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;68;-1214.525,46.42595;Inherit;True;Property;_Ramp;Ramp;18;1;[NoScaleOffset];Create;True;0;0;0;False;3;Space(20);Header(________Ramp________);Space(10);False;-1;None;bfc48f1d7925ecc4a97492155e51965f;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2113.515,91.86358;Inherit;False;Property;_SpeedU;流动速度U;19;0;Create;False;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2112.515,176.8632;Inherit;False;Property;_SpeedV;流动速度V;20;0;Create;False;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-3659.814,-179.4681;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3451.814,-174.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;25;-3670.481,45.5319;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-3462.481,50.5319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-3273.814,-153.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3426.814,-61.46805;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-3386.314,165.5319;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-3255.314,56.5319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;21;-3059.814,-157.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;32;-3060.814,48.5319;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-2892.814,-145.4681;Inherit;False;phase0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2894.814,28.5319;Inherit;False;phase1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-3664.195,-87.5368;Inherit;False;65;TimeSeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-3671.693,147.7633;Inherit;False;65;TimeSeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2134.723,-671.2604;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2133.723,-589.2604;Inherit;False;34;phase1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1958.725,-626.2604;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;-1494.059,-1451.447;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1921.833,-1266.008;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2123.074,-1172.931;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-2124.073,-1306.616;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1516.438,-1307.027;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-2126.968,-772.7859;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1538.236,-696.9719;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;149;-1228.518,-1418.656;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-1506.187,-816.1467;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-2122.434,-1426.129;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-1494.382,-1023.263;Inherit;False;182;FlowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-974.6201,-445.1716;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-978.2512,-596.377;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-993.7567,-523.0334;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;152;-1185.292,-807.5907;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1043.261,-1352.61;Inherit;False;157;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1027.922,-843.1664;Inherit;False;157;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;200;-2203.461,-3043.58;Inherit;False;2466.961;1278.983;SampleAlpha;30;232;231;230;229;227;226;225;224;223;222;221;220;219;218;217;215;214;213;212;211;210;209;208;207;206;205;204;203;201;247;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-521.5649,1018.328;Inherit;False;229;Var_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;181;-3570.928,-1134.41;Inherit;True;Property;_FLowMask;FLowMask;10;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-2633.619,1191.053;Inherit;False;Height;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-3501.222,1486.267;Inherit;False;Constant;_flo0;flo 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;240;-3334.222,1573.267;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-3178.222,1573.267;Inherit;False;disturbance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-2165.452,-998.7797;Inherit;False;86;Refract_xy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-1864.552,-947.8102;Inherit;False;245;disturbance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;248;-4194.944,1523.254;Inherit;False;0;237;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;244;-4313.222,1661.267;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-4145.944,1735.254;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;253;-4374.944,1841.254;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-3911.944,1613.254;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-4615.222,1710.267;Inherit;False;Property;_NoiseV;NoiseV;16;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-4616.222,1633.267;Inherit;False;Property;_NoiseU;NoiseU;17;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-3644.222,1808.267;Inherit;False;Property;_NoiseIntensity;强度;15;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;237;-3752.562,1575.253;Inherit;True;Property;_NoiseTex;噪声贴图;14;0;Create;False;0;0;0;False;3;Space(20);Header(________Noise________);Space(10);False;-1;None;None;True;0;False;black;Auto;False;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;204;-2153.461,-2183.01;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-2152.461,-2101.01;Inherit;False;34;phase1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1977.464,-2138.01;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-1512.797,-2963.196;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-1940.571,-2777.757;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-2141.813,-2684.68;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;-2142.812,-2818.365;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;212;-1535.176,-2818.776;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-2145.707,-2284.535;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-1556.974,-2208.721;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;215;-1247.256,-2930.405;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1524.925,-2327.896;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-2141.172,-2937.878;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-1513.12,-2535.012;Inherit;False;182;FlowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-993.3583,-1956.92;Inherit;False;Constant;_flo2;flo 2;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;224;-996.9894,-2108.126;Inherit;False;Constant;_flo3;flo 3;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-1012.495,-2034.783;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;226;-1204.03,-2319.34;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1046.66,-2354.916;Inherit;False;234;Alpha;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-1061.999,-2864.359;Inherit;False;234;Alpha;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-2141.19,-2472.529;Inherit;False;86;Refract_xy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-1918.29,-2465.729;Inherit;False;245;disturbance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;254;-2196.514,-4406.1;Inherit;False;2666.687;1258.257;SampleEmisive;39;114;117;279;282;281;280;278;277;276;275;274;273;272;271;270;269;268;267;266;265;264;263;262;261;260;259;258;257;256;255;287;288;289;302;303;304;305;306;307;Emisive;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-2146.514,-3545.53;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;-2145.514,-3463.53;Inherit;False;34;phase1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-1970.517,-3500.53;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;-1505.85,-4325.716;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-1933.624,-4140.277;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2134.866,-4047.2;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-2135.865,-4180.885;Inherit;False;20;FLowDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;262;-1528.229,-4181.296;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-2138.76,-3647.055;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;264;-1550.027,-3571.241;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;265;-1240.309,-4292.925;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-1517.978,-3690.416;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;-2134.225,-4300.398;Inherit;False;133;UV_Noise;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-1506.173,-3897.532;Inherit;False;182;FlowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;272;-986.4113,-3319.44;Inherit;False;Constant;_flo1;flo 1;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-990.0424,-3470.646;Inherit;False;Constant;_flo4;flo 4;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-1005.548,-3397.303;Inherit;False;33;phase0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;275;-1197.083,-3681.86;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-1039.713,-3717.436;Inherit;False;286;EmissiveTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;280;-2134.243,-3835.049;Inherit;False;86;Refract_xy;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;-1911.343,-3828.249;Inherit;False;245;disturbance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;278;-1087.448,-4142.534;Inherit;False;286;EmissiveTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;141;-4293.78,-561.5288;Inherit;True;Property;_FlowMap;FlowMap;6;0;Create;True;0;0;0;False;3;Space(20);Header(________Flow________);Space(10);False;None;21aca1890220a7044b957250740e274d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;41;-3569.14,-1968.331;Inherit;True;Property;_MainTex;颜色贴图;0;0;Create;False;0;0;0;False;0;False;None;1d8e52feb9be99b48b63633f6d7385c6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2993.274,-1959.6;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VirtualTextureObject;285;-3573.32,-1675.423;Inherit;True;Property;_EmissiveMap;EmissiveMap;3;0;Create;True;0;0;0;False;3;Space(20);Header(________Emission________);Space(10);False;-1;None;405a31472c271c441bc1298b09a0a95d;False;black;Auto;Unity5;0;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-2733.346,-1953.146;Inherit;False;UV_Noise;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-3235.388,-1967.356;Inherit;False;MainTex;-1;True;1;0;SAMPLER2D;0,0,0,0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;236;-3569.551,-1421.276;Inherit;True;Property;_AlphaTex;Alpha贴图;1;0;Create;False;0;0;0;False;0;False;None;7f0384c16e35a2344b7919d3ab284e9d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;234;-3241.635,-1427.27;Inherit;False;Alpha;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-3246.222,-1674.755;Inherit;False;EmissiveTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;279;-853.6906,-4051.728;Inherit;True;Property;_TextureSample6;Texture Sample 6;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;288;-688.913,-4314.791;Inherit;True;Property;_TextureSample7;Texture Sample 7;23;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;289;-963.0723,-4325.255;Inherit;False;286;EmissiveTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;122;-523.0411,-22.26975;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-692.0289,1.838597;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-799.9866,147.4914;Inherit;False;Property;_RampLerp;Ramp图强度;21;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;57;-110.7098,-1134.114;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;56;-314.8972,-1092.778;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-812.5522,-1000.919;Inherit;False;-1;;1;0;OBJECT;;False;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;63;-617.1212,-464.8484;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;59;-466.3776,-513.4656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-786.1211,-544.8483;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;59.60189,-1134.117;Inherit;False;BaseCol;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;40;-831.8585,-1334.1;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-835.2299,-728.5553;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;218;-635.8591,-1976.597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;219;-485.1154,-2025.215;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;220;-804.8592,-2056.598;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;231;-853.9679,-2240.305;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;267;-628.912,-3339.117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;268;-478.1682,-3387.735;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;269;-797.9122,-3419.118;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;276;-847.0208,-3602.825;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;230;-850.5966,-2845.849;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;203;-333.6351,-2604.527;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;201;-116.7359,-2590.578;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;229;46.50008,-2589.933;Inherit;False;Var_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;287;-202.9094,-3920.373;Inherit;False;Property;_EmisionParallaxFlow;计算视差和Flow;5;0;Create;False;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;282;-385.5297,-3894.27;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;197;-240.4866,622.2147;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-519.1412,895.4913;Inherit;False;Constant;_Float9;Float 9;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;302;173.9549,-4151.957;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-133.1915,-4157.61;Inherit;False;Constant;_flo7;flo 7;23;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;306;14.80847,-4153.61;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;349.9549,-4105.957;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;295;508.5677,-4110.141;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-801.0189,531.8425;Inherit;False;188;FlowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;239.2749,-3655.161;Inherit;False;Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;308;-531.627,584.599;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;304;174.9549,-3994.957;Inherit;False;FLOAT;2;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;303;178,-4070;Inherit;False;FLOAT;1;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;292;679.7513,-4113.971;Inherit;False;EmisionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;311;-960.6033,700.8286;Inherit;False;Constant;_flo5;flo 5;23;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;309;-808.6033,625.8286;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-827.9375,797.4648;Inherit;False;292;EmisionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-975.165,614.6996;Inherit;False;114;Emissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;117;-136.0003,-3651.302;Inherit;False;Property;_Emissive;Emissive;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;18.38509,0.3089932,24.25596,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;179;-272.4855,984.1794;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;196;108.9323,854.0764;Half;False;False;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;27193298e141a4e4c827166eeb9f556e;True;DoublePass;0;1;DoublePass;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;False;False;0;True;True;2;5;False;;10;False;;2;5;False;;10;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;False;True;2;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;198;-89.6358,835.1097;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;195;110.9323,723.0763;Half;False;True;-1;2;ASEMaterialInspector;100;1;QF/NssFX/NssFX_ASE/FX_ASE_Car_Flow_Paxton;27193298e141a4e4c827166eeb9f556e;True;DoublePassUnlit;0;0;DoublePassUnlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;False;False;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;True;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;2;False;0;;0;0;Standard;0;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-365.581,-29.05231;Inherit;False;FlowColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-2549.871,741.3506;Inherit;False;Refract_xy;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-3465.543,1051.067;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-3667.196,1134.214;Inherit;False;96;Height;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;-2942.746,1190.759;Inherit;True;Property;_Height;Height;12;0;Create;True;0;0;0;False;3;Space(20);Header(________Height________);Space(10);False;-1;None;None;True;0;False;white;Auto;False;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;76;0;80;0
WireConnection;76;1;79;0
WireConnection;76;2;90;0
WireConnection;85;0;84;0
WireConnection;85;1;83;0
WireConnection;83;0;76;0
WireConnection;84;0;76;0
WireConnection;90;0;95;0
WireConnection;90;1;93;0
WireConnection;79;0;78;0
WireConnection;12;0;15;0
WireConnection;12;1;13;0
WireConnection;15;0;143;0
WireConnection;14;0;12;0
WireConnection;14;1;16;0
WireConnection;17;0;14;0
WireConnection;17;1;18;0
WireConnection;20;0;17;0
WireConnection;107;0;108;0
WireConnection;109;0;107;0
WireConnection;111;0;110;0
WireConnection;65;0;24;0
WireConnection;110;1;109;0
WireConnection;147;0;141;0
WireConnection;11;0;141;0
WireConnection;143;0;11;0
WireConnection;143;1;147;0
WireConnection;182;0;181;1
WireConnection;121;0;118;0
WireConnection;118;0;187;0
WireConnection;118;1;70;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;70;0;73;0
WireConnection;70;1;74;0
WireConnection;167;0;68;0
WireConnection;119;0;121;0
WireConnection;119;4;120;0
WireConnection;68;1;119;0
WireConnection;23;0;22;0
WireConnection;23;1;66;0
WireConnection;26;0;25;0
WireConnection;26;1;67;0
WireConnection;28;0;23;0
WireConnection;28;1;29;0
WireConnection;30;0;26;0
WireConnection;30;1;31;0
WireConnection;21;0;28;0
WireConnection;32;0;30;0
WireConnection;33;0;21;0
WireConnection;34;0;32;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;50;0;49;0
WireConnection;50;1;51;0
WireConnection;48;0;163;0
WireConnection;48;1;50;0
WireConnection;48;2;89;0
WireConnection;48;3;246;0
WireConnection;55;0;162;0
WireConnection;55;1;53;0
WireConnection;55;2;89;0
WireConnection;55;3;246;0
WireConnection;149;0;160;0
WireConnection;149;1;48;0
WireConnection;149;2;155;0
WireConnection;152;0;161;0
WireConnection;152;1;55;0
WireConnection;152;2;155;0
WireConnection;96;0;94;0
WireConnection;240;0;239;0
WireConnection;240;1;237;1
WireConnection;240;2;241;0
WireConnection;245;0;240;0
WireConnection;244;0;242;0
WireConnection;244;1;243;0
WireConnection;252;0;244;0
WireConnection;252;1;253;0
WireConnection;251;0;248;0
WireConnection;251;1;252;0
WireConnection;237;1;251;0
WireConnection;206;0;204;0
WireConnection;206;1;205;0
WireConnection;209;0;211;0
WireConnection;209;1;210;0
WireConnection;212;0;221;0
WireConnection;212;1;209;0
WireConnection;212;2;207;0
WireConnection;212;3;247;0
WireConnection;214;0;213;0
WireConnection;214;1;206;0
WireConnection;214;2;207;0
WireConnection;214;3;247;0
WireConnection;215;0;208;0
WireConnection;215;1;212;0
WireConnection;215;2;222;0
WireConnection;226;0;217;0
WireConnection;226;1;214;0
WireConnection;226;2;222;0
WireConnection;257;0;255;0
WireConnection;257;1;256;0
WireConnection;259;0;261;0
WireConnection;259;1;260;0
WireConnection;262;0;270;0
WireConnection;262;1;259;0
WireConnection;262;2;280;0
WireConnection;262;3;281;0
WireConnection;264;0;263;0
WireConnection;264;1;257;0
WireConnection;264;2;280;0
WireConnection;264;3;281;0
WireConnection;265;0;258;0
WireConnection;265;1;262;0
WireConnection;265;2;271;0
WireConnection;275;0;266;0
WireConnection;275;1;264;0
WireConnection;275;2;271;0
WireConnection;133;0;46;0
WireConnection;157;0;41;0
WireConnection;234;0;236;0
WireConnection;286;0;285;0
WireConnection;279;0;278;0
WireConnection;279;1;262;0
WireConnection;288;0;289;0
WireConnection;122;0;177;0
WireConnection;122;1;124;0
WireConnection;122;2;123;0
WireConnection;124;0;177;0
WireConnection;124;1;167;0
WireConnection;124;2;125;0
WireConnection;57;0;56;0
WireConnection;56;0;40;0
WireConnection;56;1;44;0
WireConnection;56;2;59;0
WireConnection;63;0;61;0
WireConnection;63;1;64;0
WireConnection;59;0;63;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;128;0;57;0
WireConnection;40;0;43;0
WireConnection;40;1;48;0
WireConnection;44;0;45;0
WireConnection;44;1;55;0
WireConnection;218;0;220;0
WireConnection;218;1;223;0
WireConnection;219;0;218;0
WireConnection;220;0;224;0
WireConnection;220;1;225;0
WireConnection;231;0;232;0
WireConnection;231;1;214;0
WireConnection;267;0;269;0
WireConnection;267;1;272;0
WireConnection;268;0;267;0
WireConnection;269;0;273;0
WireConnection;269;1;274;0
WireConnection;276;0;277;0
WireConnection;276;1;264;0
WireConnection;230;0;227;0
WireConnection;230;1;212;0
WireConnection;203;0;230;0
WireConnection;203;1;231;0
WireConnection;203;2;219;0
WireConnection;201;0;203;0
WireConnection;229;0;201;0
WireConnection;287;0;288;0
WireConnection;287;1;282;0
WireConnection;282;0;279;0
WireConnection;282;1;276;0
WireConnection;282;2;268;0
WireConnection;197;0;308;0
WireConnection;302;0;287;0
WireConnection;306;0;307;0
WireConnection;306;1;287;0
WireConnection;305;0;302;0
WireConnection;305;1;303;0
WireConnection;305;2;304;0
WireConnection;295;0;305;0
WireConnection;114;0;117;0
WireConnection;308;0;189;0
WireConnection;308;1;309;0
WireConnection;308;2;293;0
WireConnection;304;0;287;0
WireConnection;303;0;287;0
WireConnection;292;0;295;0
WireConnection;309;0;115;0
WireConnection;309;1;311;0
WireConnection;179;0;178;0
WireConnection;179;1;176;0
WireConnection;179;2;180;0
WireConnection;196;0;198;0
WireConnection;198;0;197;0
WireConnection;198;3;179;0
WireConnection;188;0;122;0
WireConnection;86;0;85;0
WireConnection;95;0;91;0
WireConnection;95;1;97;0
ASEEND*/
//CHKSM=47D05FA92FD7B840B02164A4146E796502E501BF