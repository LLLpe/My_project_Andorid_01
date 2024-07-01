// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VertexDirTest"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[Toggle]_Y("Y", Float) = 0
		[Toggle]_Z("Z", Float) = 0

	}

	SubShader
	{
		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
	LOD 100

		HLSLINCLUDE
		#define GAMMA_TEXTURE
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"
		ENDHLSL
		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		

		
		Pass
		{
			Name "SFXShader"

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
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#define ASE_NEEDS_FRAG_POSITION


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
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START( UnityPerMaterial )
			float _Z;
			float _Y;
			CBUFFER_END


			v2f vert(appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1 = v.vertex;
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
				half4 temp_cast_0 = ((( _Z )?( i.ase_texcoord1.xyz.z ):( (( _Y )?( i.ase_texcoord1.xyz.y ):( i.ase_texcoord1.xyz.x )) ))).xxxx;
				

				finalColor = temp_cast_0;
				return NSS_OUTPUT_COLOR_SPACE(finalColor);
			}
			ENDHLSL
		}
	}
	CustomEditor "ASEMaterialInspector"
	Fallback "QF/Simple/Simple_Diffuse_NoVertexColor"
	
}

/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.PosVertexDataNode;4;-693.5,-74;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;6;-245.5,-79;Inherit;False;Property;_Y;Y;0;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;8;10.5,-47;Inherit;False;Property;_Z;Z;1;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;356,-55;Half;False;True;-1;2;ASEMaterialInspector;100;0;VertexDirTest;0b19a0ea5d24852478f6e85e927203ca;True;SFXShader;0;0;SFXShader;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;QF/Simple/Simple_Diffuse_NoVertexColor;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;6;0;4;1
WireConnection;6;1;4;2
WireConnection;8;0;6;0
WireConnection;8;1;4;3
WireConnection;3;0;8;0
ASEEND*/
//CHKSM=7676447518A1F3B6918F7248BEAC3A409D7A376A