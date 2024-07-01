Shader "PaxtonLiu/Paxton_Crystal_S02"
{
    Properties
    {
        _MainTex("MainTex",2D) = "black"{}
        _AlbedoColorTint("颜色" , color) = (1,1,1,1)
        _AmbientInt("Ambient强度" , Range( 0 , 1)) = 1
        _MRTex("MRTex:R 金属度 G:粗糙度 B：自发光" ,2D) = "black"{}
        [Toggle(_REVERTSMOOTH)] _RevertSmooth("粗糙度翻转",Float)=0
        _Smoothness("粗糙度强度" , Range( 0.15 , 1)) = 1
        [HDR]_EmissionColor("自发光颜色",color) = (0,0,0,0)
        
        [Space(20)]
        [NoScaleOffset]_NormalMap("NormalMap"  ,2D) = "bump"{}
        [NoScaleOffset]_NormalIntensity("法线强度", Range( 0 , 2)) = 1
        [Toggle(_FLIPY)] _flipY("flipY",Float)=0
        // _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        // _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 0

        [Space(20)]
        [NoScaleOffset]_FresnelMap("菲涅尔贴图",2D) = "black"{}
        [HDR]_FresnelColor("菲涅尔颜色" , color) = (1,1,1,1)
        _FresnelRadius("菲涅尔范围" , Range( 0 , 1)) = 1
        _FresnelIntensity("菲涅尔强度" ,Range( 0 , 10)) = 0
        
        [Space(20)]
        [NoScaleOffset]_RampMap("RampMap",2D) = "white"{}
        _FinalPower("强度", Range( 0 , 100)) = 0
        _RampColorTint("颜色", color) = (1,1,1,1)
        _RampRemapMax("颜色衰减", Range( 0 , 1)) = 1
        _RampOffsetExp("颜色偏移", Range( -1 , 5)) = 0
        _vertexColNegate("顶点色权重", Range( 0 , 1)) = 1
        
        
        [Header(InnerRim)]
        [NoScaleOffset]_InnerRimMask("内发光Mask" , 2D) = "white"{}
        [Toggle(_INNERRIMENABLE)] _InnerRinEnable("Inner Rim Enable",Float)=1
        [Toggle(_INNERRIMMASKFLIP)] _Toggle("Inner Rim Mask Flip",Float)=0
        [Toggle(_UESVERTEXR)] _UseVertex("UseVertex",Float)=0
        [Toggle(_VERTEXRFLIP)] _VertexRFlip("Inner VertexColR Flip",Float)=0
        _InnerRimMaskNegate("Mask权重衰减" , Range( 0 , 1)) = 1
        _InnerRimMaskExp("内发光MaskExp" , Range( 0 , 10)) = 1
        _InnerRimExp("内发光聚集" , Range( 0 , 10)) = 1
        _InnerRimHackNormals("内发光法线衰减" , Range( 0 , 1)) = 1
        
        [Header(ParallaxNoise)]
        [NoScaleOffset]_ParallaxNoiseMap("_ParallaxNoiseMap", 2D) = "white"{}
        _ParallaxNoiseScaleU("_ParallaxNoiseScaleU", Range( 0 , 5)) = 1
        _ParallaxNoiseScaleV("_ParallaxNoiseScaleV", Range( 0 , 5)) = 1
        _ParallaxNoiseDepth("_ParallaxNoiseDepth", Range( 0 , 1)) = 0
        _ParallaxNoiseNegate("视差法线衰减", Range( 0 , 1)) = 0
        
        [Toggle(_VERTICALGRADIENTWORLDPOSITION)] _UseWorldPos("使用世界坐标",Float)=0
        [KeywordEnum(Worldposition,Objectposition, Uvposition)] _Position("Position", Float) = 0
        _VerticalGradientFlipSwitch("顶点色遮罩翻转", Range( 0 , 1)) = 0
        _VerticalGradientExp("衰减", Range( 0.1 , 5)) = 1
        _VerticalGradientRemapMax("渐变色RemapMax", Range( 0 , 10)) = 1
        _VerticalGradientOffset("渐变偏移", Range( -10 , 10)) = 0
        


        
    }
    
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Name "ForwardLit" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _REVERTSMOOTH
            #pragma shader_feature _INNERRIMMASKFLIP
            #pragma shader_feature _UESVERTEXR
            #pragma shader_feature _VERTEXRFLIP
            #pragma shader_feature _FLIPY
            #pragma shader_feature _INNERRIMENABLE
            #pragma shader_feature_local   _POSITION_OBJECTPOSITION _POSITION_UVPOSITION _POSITION_WORLDPOSITION  

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
            
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
                float3 posOS : TEXCOORD9;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;
                half3 vDirTS : TEXCOORD7;
                half4 color : TEXCOORD8;

            };

            CBUFFER_START(UnityPerMaterial)

            half3 _Color;
           
            half3 _AlbedoColorTint;
            half _AmbientInt;
            half _Smoothness;
            half _NormalIntensity;
            
            
            half3 _FresnelColor;
            half _FresnelRadius;
            half _FresnelIntensity;
            
            
            half _RampRemapMax;
            half _RampOffsetExp;
            half _vertexColNegate;
            half _InnerRimHackNormals;
            half _InnerRimExp;
            half _InnerRimMaskExp;
            half _InnerRimMaskNegate;
            half _ParallaxNoiseScaleU; half _ParallaxNoiseScaleV;
            half _ParallaxNoiseDepth;
            half _ParallaxNoiseNegate;
            half _FinalPower;
            
            half _VerticalGradientFlipSwitch;
            half _VerticalGradientOffset;
            half _VerticalGradientRemapMax;
            half _VerticalGradientExp;
			CBUFFER_END
            
            float4 _RampColorTint;
            half3 _EmissionColor;
            sampler2D _MainTex; half4 _MainTex_ST;
            sampler2D _MRTex; 
            sampler2D _FresnelMap; 
            sampler2D _NormalMap;half4 _NormalMap_ST;
            sampler2D _InnerRimMask;
            sampler2D _ParallaxNoiseMap;
            sampler2D _RampMap;
            
            //D
            float Distribution(float roughness , float ndoth)
            {
                float lerpSquareRoughness = pow(lerp(0.002, 1, roughness), 2);
                float D = lerpSquareRoughness / (pow((pow(ndoth, 2) * (lerpSquareRoughness - 1) + 1), 2) * PI);
                return D;
            }
        //G
            float Geometry(float roughness , float ndotl , float ndotv)
            {
                float k = pow(roughness + 1, 2) / 8;  //光线吸收系数//会有1/8的保底值
                k = max(k,0.5);
                //k = 1;
                float GLeft = ndotl / lerp(ndotl, 1, k);
                float GRight = ndotv / lerp(ndotv, 1, k);
                float G = GLeft * GRight;
                return G;
            }
        //F
            float3 FresnelEquation(float3 F0 , float ldoth)
            {
                float3 F = F0 + (1 - F0) * pow((1.0 - ldoth),5);
                return F;
            }

            float3 NPR_Base_RimLight(float NdotV,float3 RimColor)
            {
                return (1 - smoothstep(_FresnelRadius,_FresnelRadius + 0.1,NdotV)) * _FresnelIntensity * 0.01 * RimColor;
            }
            
            float3 NPR_Base_RimLight2(float NdotV,float3 RimColor)
            {
                return (1 - smoothstep(_FresnelRadius,_FresnelRadius + 0.1,NdotV)) * _FresnelIntensity * RimColor;
            }

            v2f vert (appdata v)
            {
                v2f o ;
                //posOS=>CS  "ShaderVariablesFunctions.hlsl"
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;
                o.posOS = v.vertex;
                //o.posCS = TransformObjectToHClip(v.vertex);
                
                //法线OS=>WS "ShaderVariablesFunctions.hlsl"
                 VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                //  o.normalWS = normalize(normalInputs.normalWS);
                 o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                 half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normalOS).xyz;
                 o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                 o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                Light light = GetMainLight();


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

                //nDirWS
                half2 uv_nDirTS = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                float4 normalTex2D = tex2D(_NormalMap,uv_nDirTS);
                #ifdef _FLIPY
                normalTex2D.y = 1 - normalTex2D.y ;
                #endif

                half3 nDirTS = UnpackNormal(normalTex2D);
                nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);
    
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                half3 Rim_nDirWS = normalize(lerp(nDirWS , i.normalWS , _InnerRimHackNormals ));
                // half3 Rim_nDirWS =  i.normalWS ;
                


                // sample the texture
                half4 baseColor  = tex2D(_MainTex, i.uv).rgba;
                half4 var_MRMap  = tex2D(_MRTex, i.uv);
                half matelness = var_MRMap.r;
                
                #ifdef _REVERTSMOOTH
                half Smoothness = clamp(var_MRMap.g, 0 , 1);
                #else
                half Smoothness = 1 - clamp(var_MRMap.g, 0 , 1);
                #endif

                half roughness = clamp((1 - var_MRMap.a), 0 , 1);
                half emission = var_MRMap.b ;
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
                
                //**************PBR****************
                //*********************************
                //Ddiff
                half kd = OneMinusReflectivityMetallic(roughness);
                half3 PBRdiffColor = kd * baseColor * light.color * NdotL * Lightatten;

                //Dspec
                half3 F0 = half3(0.04,0.04,0.04);
                F0 = lerp(F0, baseColor, matelness);
                half3 F = FresnelEquation(F0 , LdotH);
                half D = Distribution(roughness , NdotH);
                half G = Geometry(roughness , NdotL , NdotV);

                half3 Specular = F*D*G/(4 * NdotV * NdotL + 0.001);//一定要有这个+0.001，来防止边缘处除以0导致过曝
                half3 PBRSpecColor = Specular * PI * light.color * NdotL * Lightatten;
                half3 PBRCol = PBRSpecColor + PBRdiffColor;
                //***********************************
                //***********************************



                
                // Blinn-Phong
                //***********************************
                //***********************************
                float3 diffuse = baseColor * light.color * NdotL * _AlbedoColorTint;
				float3 specular_BlinPhong = light.color * clamp(pow(NdotH, Smoothness * 50 / _Smoothness), 0 , 1) ;
                float3 ka = (0.1, 0.1, 0.1);
                ka = 1;
				float3 ambient = ka* baseColor * _AmbientInt;
                
                //NPR菲涅尔
                // half3 Fresnel = NPR_Base_RimLight(NdotV,_FresnelColor);
                half3 Fresnel = tex2D(_FresnelMap,  ViewN.xy) * _FresnelIntensity;
                // half Fresnel2 = FresnelEquation(0.04 , LdotH);
                
                half3 BlinnCol = diffuse + specular_BlinPhong + ambient + Fresnel;
                //***********************************
                //***********************************
                
                //Main
                // half4 Albedo = tex2D(_MainTex , i.uv) * _AlbedoColorTint;
                //InnerRimPower
                half InnerRimPower = pow(RimNdotV , _InnerRimExp);
                
                #ifdef  _UESVERTEXR
                InnerRimPower = lerp(InnerRimPower , 1 ,   i.color.r);
                
                #ifdef  _VERTEXRFLIP
                InnerRimPower = lerp(InnerRimPower , 1 ,   i.color.r);
                #else
                InnerRimPower = lerp(InnerRimPower , 1 , 1 - i.color.r);
                #endif
                
                #endif
                
                
                
                //Inner Rim Mask
                half InnerRimMask =  tex2D( _InnerRimMask , i.uv).r;
                #ifdef  _INNERRIMMASKFLIP
                InnerRimMask = 1 - InnerRimMask;
                #endif
                InnerRimMask = pow(InnerRimMask , _InnerRimMaskExp) + _InnerRimMaskNegate;
                InnerRimMask= clamp(InnerRimMask , 0 ,1);    
                
                //Parallax Noise
                float2 parallax_uv = float2(i.uv.x * _ParallaxNoiseScaleU ,i.uv.y * _ParallaxNoiseScaleV);
                half parallaxHeight = tex2D(_ParallaxNoiseMap,parallax_uv).r;
                parallaxHeight = parallaxHeight * _ParallaxNoiseDepth - _ParallaxNoiseDepth/2.0;
                vDirTS.z += 0.42;
                parallax_uv += parallaxHeight* (vDirTS.xy / vDirTS.z);
                half parallaxNoise = tex2D(_ParallaxNoiseMap,parallax_uv).r + _ParallaxNoiseNegate ;
                parallaxNoise = clamp(parallaxNoise, 0 ,1);

                //Vertical Gradient
                #ifdef _POSITION_OBJECTPOSITION
                float VerticalGradientPosY = i.posOS.y;
                #elif _POSITION_WORLDPOSITION
                float VerticalGradientPosY = i.posWS.y;
                #elif _POSITION_UVPOSITION
                float VerticalGradientPosY = i.uv2.y;
                #endif

                float VerticalGradientMask= clamp((VerticalGradientPosY + _VerticalGradientOffset)/_VerticalGradientRemapMax,0 , 1 );
                VerticalGradientMask = lerp(VerticalGradientMask , 1 - VerticalGradientMask , round(_VerticalGradientFlipSwitch) );
                VerticalGradientMask = pow(VerticalGradientMask , _VerticalGradientExp) * InnerRimMask * parallaxNoise;

                //Mask Compose
                #ifdef _INNERRIMENABLE
                // half ComposeMask = InnerRimMask * parallaxNoise + VerticalGradientMask;
                half ComposeMask = InnerRimMask * parallaxNoise ;
                #else
                half ComposeMask =  VerticalGradientMask;
                #endif

                ComposeMask = clamp(ComposeMask , 0 ,1) * lerp(1 , i.color.r , _vertexColNegate);  
                

                //Remap
                //y = (x - t1) / (t2 - t1) * (s2 - s1) + s1;Remap
                ComposeMask = clamp(ComposeMask / _RampRemapMax , 0 , 1 );
                //colorOffset
                float ramp_uvx  = 1 - ComposeMask ;
                ramp_uvx = pow(ramp_uvx , (_RampOffsetExp + 1) );
                ramp_uvx = 1 - ramp_uvx ;

                //Ramp
                float2 ramp_uv = half2(ramp_uvx , 0.5 );
                half4 RampCol = tex2D(_RampMap , ramp_uv) * _RampColorTint * ComposeMask;

                //emission
                half3 EmiCol = clamp(emission * _EmissionColor , 0 , 20 );
                
                half3 finalcol = RampCol.xyz * _FinalPower ;
                finalcol *= ComposeMask;
                finalcol +=  EmiCol ;

                half4 c = 1;
                c.xyz = BlinnCol + finalcol;
                // c.xyz = RampCol;
                


                return  c ;
            }
            ENDHLSL
        }
    }
}
