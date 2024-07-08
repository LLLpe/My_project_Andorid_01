Shader "QF/NssFX/NssFX_ASE/FX_ASE_Crystal_01_Paxton"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _AlbedoColorTint("颜色强度" , color) = (1,1,1,1)
        _AlphaWeight("AlphaWeight",Range( 0 , 1)) = 0
        // _AmbientInt("Ambient强度" , Range( 0 , 1)) = 1
        // _MRTex("MRTex:R 金属度 G:粗糙度 B：自发光" ,2D) = "black"{}
        // [Toggle(_REVERTSMOOTH)] _RevertSmooth("粗糙度翻转",Float)=0
        // [HDR]_EmissionColor("自发光颜色",color) = (0,0,0,0)
        
        [Space(20)]
        [NoScaleOffset]_NormalMap("NRM"  ,2D) = "white"{}
        [NoScaleOffset]_NormalIntensity("法线强度", Range( 0 , 2)) = 1
        _Smoothness("粗糙度强度" , Range( 0.15 , 1)) = 1
        // [Toggle(_FLIPY)] _flipY("flipY",Float)=0
        // _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        // _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 0

        [Space(20)]
        [NoScaleOffset]_FresnelMap("菲涅尔贴图",2D) = "black"{}
        // [HDR]_FresnelColor("菲涅尔颜色" , color) = (1,1,1,1)
        // _FresnelRadius("菲涅尔范围" , Range( 0 , 1)) = 1
        _FresnelIntensity("菲涅尔强度" ,Range( 0 , 10)) = 0
        
        [Space(20)]
        [NoScaleOffset]_RampMap("RampMap",2D) = "white"{}
        _FinalPower("强度", Range( 0 , 100)) = 0
        _RampColorTint("颜色", color) = (1,1,1,1)
        _RampRemapMax("颜色衰减", Range( 0 , 1)) = 1
        _RampOffsetExp("颜色偏移", Range( -1 , 5)) = 0
        // _vertexColNegate("顶点色权重", Range( 0 , 1)) = 1
        
        
        [Space(20)]
        [NoScaleOffset]_InnerRimMask("内发光Mask" , 2D) = "white"{}
        [Toggle] _RimMaskFlip("翻转贴图",Float)=0
        // [Toggle(_INNERRIMENABLE)] _InnerRinEnable("Inner Rim Enable",Float)=1
        // [Toggle(_RimMaskFlip)] _Toggle("Inner Rim Mask Flip",Float)=0
        // [Toggle(_UESVERTEXR)] _UseVertex("UseVertex",Float)=0
        // [Toggle(_VERTEXRFLIP)] _VertexRFlip("Inner VertexColR Flip",Float)=0
        _InnerRimMaskNegate("Mask权重衰减" , Range( 0 , 1)) = 1
        _InnerRimMaskExp("内发光MaskExp" , Range( 0 , 10)) = 1
        // _InnerRimExp("内发光聚集" , Range( 0 , 10)) = 1
        _InnerRimHackNormals("内发光法线衰减" , Range( 0 , 1)) = 1
        
        [Space(20)]
        _ParallaxNoiseMap("视差贴图", 2D) = "white"{}
        // _ParallaxNoiseScaleU("_ParallaxNoiseScaleU", Range( 0 , 5)) = 1
        // _ParallaxNoiseScaleV("_ParallaxNoiseScaleV", Range( 0 , 5)) = 1
        _ParallaxNoiseDepth("深度", Range( 0 , 1)) = 0
        _ParallaxNoiseNegate("视差法线衰减", Range( 0 , 1)) = 0
        
        // [KeywordEnum(Worldposition,Objectposition, Uvposition)] _Position("Position", Float) = 0
        _VerticalGradientFlipSwitch("顶点色遮罩翻转", Range( 0 , 1)) = 0

        [Header(UV2Gradient)]
        // [Toggle] _ObjectPosition("自身坐标",Float)=0
        _VerticalGradientRemapMax("Gradient过渡", Range( 0 , 10)) = 1
        _VerticalGradientExp("Gradient衰减", Range( 0.1 , 5)) = 1
        _VerticalGradientOffset("Gradient偏移", Range( -10 , 10)) = 0

        // [Space(20)]
        // [NoScaleOffset]_AlphaTex("Alpha" , 2D) = "white"{}

              
    }
    
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100
        HLSLINCLUDE
		#define GAMMA_TEXTURE
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"
		#include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_BASE_MACRO.cginc"

		ENDHLSL


        Pass
		{   
            Tags{"LightMode" = "SRPDefaultUnlit"}
            Name"BasePass"
			ZWrite On
			ColorMask 0
		}

        Pass
        {
            Name "DoublePass" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
            // CGINCLUDE
			// #pragma target 3.0
			// ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			// Blend One, Zero
			AlphaToMask Off
			Cull Back
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma shader_feature _REVERTSMOOTH
            // #pragma shader_feature _INNERRIMMASKFLIP
            // #pragma shader_feature _UESVERTEXR
            // #pragma shader_feature _VERTEXRFLIP
            // #pragma shader_feature _FLIPY
            // #pragma shader_feature _INNERRIMENABLE
            // #pragma shader_feature_local   _POSITION_OBJECTPOSITION _POSITION_UVPOSITION _POSITION_WORLDPOSITION  

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                half4 normalOS : NORMAL;
                half4 tangent : TANGENT;
                half4 color : COLOR;
            };

            struct v2f
            {
                float4 posCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 posWS : TEXCOORD2;
                // float3 posOS : TEXCOORD9;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;
                half3 vDirTS : TEXCOORD7;
                // half4 color : TEXCOORD8;

            };

            CBUFFER_START(UnityPerMaterial)

            half3 _Color;
           
            half3 _AlbedoColorTint;
            // half _AmbientInt;
            half _Smoothness;
            half _NormalIntensity;
            
            
            // half3 _FresnelColor;
            // half _FresnelRadius;
            half _FresnelIntensity;
            
            
            half _RampRemapMax;
            half _RampOffsetExp;
            // half _vertexColNegate;
            half _RimMaskFlip;
            half _InnerRimHackNormals;
            // half _InnerRimExp;
            half _InnerRimMaskExp;
            half _InnerRimMaskNegate;
            // half _ParallaxNoiseScaleU; half _ParallaxNoiseScaleV;
            half _ParallaxNoiseDepth;
            half _ParallaxNoiseNegate;
            half _FinalPower;
            
            // half _ObjectPosition;
            half _VerticalGradientFlipSwitch;
            half _VerticalGradientOffset;
            half _VerticalGradientRemapMax;
            half _VerticalGradientExp;

            half _AlphaWeight;
			CBUFFER_END
            
            float4 _RampColorTint;
            half3 _EmissionColor;
            sampler2D _MainTex; half4 _MainTex_ST;
            sampler2D _MRTex; 
            sampler2D _FresnelMap; 
            sampler2D _NormalMap;
            half4 _NormalMap_ST;
            sampler2D _InnerRimMask;
            sampler2D _ParallaxNoiseMap;half4 _ParallaxNoiseMap_ST;
            sampler2D _RampMap;
            // sampler2D _AlphaTex;
            

            half3 NssUnpackScaleNormalXY(half2 packednormal, half bumpScale)
            {
                //// This do the trick
                half3 normal;
                normal.xy = (packednormal.xy * 2 - 1);
                // SM2.0: instruction count limitation
                // SM2.0: normal scaler is not supported
                normal.xy *= bumpScale;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                return normal;
            }

            v2f vert (appdata v)
            {
                v2f o ;
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;
                // o.posOS = v.vertex;
                
                 VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                 o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                 half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normalOS).xyz;
                 o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                 o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                o.uv = v.uv;
                o.uv2 = v.uv2;
                // o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                Light light = GetMainLight();
                // sample the texture
                half4 baseColor  = tex2D(_MainTex, i.uv).rgba;
                half Alpha0 = baseColor.a;
                half4 var_MRMap  = tex2D(_MRTex, i.uv);
                half matelness = var_MRMap.r;
                
                
                //平铺贴图UV
                float2 tiling_uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                //sample

                float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
				float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
                float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );
                half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                float3x3 worldToTangent = float3x3(tanToWorld0,tanToWorld1,tanToWorld2);
                
                //vDirTS
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 vDirTS = normalize(mul(vDirWS,worldToTangent)); //half3 vDirTS = tanToWorld0 * vDirWS.x + tanToWorld1 * vDirWS.y  + tanToWorld2 * vDirWS.z;
                
                //reflectDir
                half3 reflectDir = reflect(vDirWS, i.normalWS);
                
                half4 var_NRM  = tex2D(_NormalMap, i.uv);          
                half3 nDirTS = NssUnpackScaleNormalXY(var_NRM.rg, _NormalIntensity);
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));

                half3 Rim_nDirWS = normalize(lerp(nDirWS , i.normalWS , _InnerRimHackNormals ));
                // half3 Rim_nDirWS =  i.normalWS ;
                


                
                // #ifdef _REVERTSMOOTH
                // half Smoothness = clamp(var_MRMap.g, 0 , 1);
                // #else
                half Smoothness = 1 - clamp(var_NRM.b, 0 , 1);
                // #endif

                // half roughness = clamp((1 - var_MRMap.a), 0 , 1);
                // half emission = var_MRMap.b ;
                //lightMap.b = 1;
                
                
                //MatCap_UV
                half3 ViewN =  i.normalVS_uv;
                ViewN.xy += nDirTS.xy ;
                
                //NdotL
                half NdotL = dot(nDirWS,normalize(light.direction));
                NdotL = max(0,NdotL);
                
                //NdotV
                half NdotV = dot(nDirWS,vDirWS);
                NdotV = clamp(NdotV , 0 ,1);
                half RimNdotV = dot(Rim_nDirWS,vDirWS);
                RimNdotV = clamp(RimNdotV , 0 ,1);

                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                NdotH = max(0,NdotH);
                half LdotH = dot(normalize(light.direction),normalize(light.direction + vDirWS));
                LdotH = clamp(normalize(LdotH),0.01,1);
                half Lightatten = light.distanceAttenuation;
                

                float3 diffuse = baseColor * light.color  * _AlbedoColorTint;
				float3 specular_BlinPhong = light.color * clamp(pow(NdotH, Smoothness * 100 / _Smoothness), 0 , 1) ;
                
                //NPR菲涅尔
                half3 Fresnel = tex2D(_FresnelMap,  ViewN.xy) * _FresnelIntensity;

                
                half3 BlinnCol = diffuse + specular_BlinPhong  + Fresnel;
                half InnerRimMask =  tex2D( _InnerRimMask , i.uv).r;
                #ifdef  _INNERRIMMASKFLIP
                InnerRimMask = 1 - InnerRimMask;
                #endif
                InnerRimMask = ( _RimMaskFlip )?( ( 1.0 - InnerRimMask ) ):( InnerRimMask );
                InnerRimMask = pow(InnerRimMask , _InnerRimMaskExp) + _InnerRimMaskNegate;
                InnerRimMask= clamp(InnerRimMask , 0 ,1);    
                
                //Parallax Noise
                float2 parallax_uv = i.uv * _ParallaxNoiseMap_ST.xy + _ParallaxNoiseMap_ST.zw;
                half parallaxHeight = tex2D(_ParallaxNoiseMap,parallax_uv).r;
                parallaxHeight = parallaxHeight * _ParallaxNoiseDepth - _ParallaxNoiseDepth/2.0;
                vDirTS.z += 0.42;
                parallax_uv += parallaxHeight* (vDirTS.xy / vDirTS.z);
                half parallaxNoise = tex2D(_ParallaxNoiseMap,parallax_uv).r + _ParallaxNoiseNegate ;
                parallaxNoise = clamp(parallaxNoise, 0 ,1);
                float VerticalGradientPosY = i.uv2.y ;


                float VerticalGradientMask= clamp((VerticalGradientPosY + _VerticalGradientOffset)/_VerticalGradientRemapMax,0 , 1 );
                float VerticalMask = lerp(VerticalGradientMask , 1 - VerticalGradientMask , 0 );
                VerticalMask = pow(VerticalMask , _VerticalGradientExp) * InnerRimMask * parallaxNoise;

                half ComposeMask =  VerticalMask;


                ComposeMask = clamp(ComposeMask , 0 ,1) ;  
                

                //Remap
                ComposeMask = clamp(ComposeMask / _RampRemapMax , 0 , 1 );
                float ramp_uvx  = 1 - ComposeMask ;
                ramp_uvx = pow(ramp_uvx , (_RampOffsetExp + 1) );
                ramp_uvx = 1 - ramp_uvx ;

                //Ramp
                float2 ramp_uv = half2(ramp_uvx , 0.5 );
                half4 RampCol = tex2D(_RampMap , ramp_uv) * _RampColorTint * ComposeMask;

                
                half3 finalcol = RampCol.xyz * _FinalPower ;
                finalcol *= ComposeMask ;
                Alpha0 =  lerp( 1.0 , Alpha0 , _AlphaWeight);

                half4 c = 1;
                c.xyz = BlinnCol + finalcol;
                c.a = Alpha0;
                


                // return NSS_OUTPUT_COLOR_SPACE( c); 
                return c; 
            }
            ENDHLSL
        }
    }
}
