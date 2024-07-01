Shader "PaxtonLiu/Paxton_PBR"
{
    Properties
    {
        [NoScaleOffset][MainTexture]_MainTex("Color" , 2D) = "white"{}
        [Header(Ramp)]
        [NoScaleOffset]_CrystalRampMap("Ramp Map",2D) = "black"{}
        [NoScaleOffset]_CrystalRampMask("Ramp Mask",2D) = "black"{}
        _CrystalRampIntensity("RampIntensity",Range(0,10)) = 1
        
        [NoScaleOffset]_MRTex("R:Metallic G:Roughness B:  A:",2D) = "white"{}

        
        [Header(Normal)]
        [NoScaleOffset]_NormalMap("法线贴图"  ,2D) = "bump"{}
        [NoScaleOffset]_NormalIntensity("法线强度", Range( 0 , 2)) = 1
        _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 1
        
        
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

            

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
            

            struct appdata
            {
                half3 vertex : POSITION;
                half2 uv : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
                half4 normalOS : NORMAL;
                half4 tangent : TANGENT;
                half4 color : COLOR;
            };

            struct v2f
            {
                half4 posCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
                half3 posWS : TEXCOORD2;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;
                half3 vDirTS : TEXCOORD7;
                half4 color : TEXCOORD8;

            };

            CBUFFER_START(UnityPerMaterial)
            half _specularPowIint;
            half _RampRange;
			half _MetalIntensity;
			half _AlbedoIntensity;
            half _Bump;
            half _EnvSpecInt;
            half _RimRadius;
            half _RimIntensity;
            half _HardSpecInt1;
            half _HardSpecInt2;
            half _UvOffsetX;
            half _UvOffsetY;
            half _UvOffsetZ;
            half _CrystalHeight1;
            half _CrystalHeight2;
            half _CrystalTilling1;
            half _CrystalTilling2;
            half _CrystalCol1Int;
            half _CrystalCol2Int;
            half _IOR;
            half _A;
            half _B;
            half _VertexIntensity;
            half _NormalIntensity;
            half _NormalDetilIntensity;
            half _CrystalRampIntensity;
            half _SpecSize;
            half _SpecSize2;
            half _SpecHardness;
            half3 _SpecColor;
            
            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint; 
            sampler2D _MRTex; half4 _MRTex_ST;
            sampler2D _lightMap; 
            sampler2D _MetalMap;
            sampler2D _CrystalMap;half4 _CrystalMap_ST;
            sampler2D _CrystalMap2;half4 _CrystalMap2_ST;
            sampler2D _NormalMap;half4 _NormalMap_ST;
            sampler2D _NormalDetil;half4 _NormalDetil_ST;
            sampler2D _CrystalRampMap;half4 _CrystalRampMap_ST;
            sampler2D _CrystalRampMask;half4 _CrystalRampMask_ST;
            
            sampler2D _RampTex;
            sampler2D _RampTexSpec;
            sampler2D _CrystalMap3; half4 _CrystalMap3_ST;
            samplerCUBE _Cubemap;
            half3 _CrystalColor;
            half3 _RimColor;
            
            
            
            
            
           

             half3 NPR_Base_Ramp (half NdotL,sampler2D RampTex, half4 lightMap, half RampRange)
            {
                half halfLambert = smoothstep(0,0.5,NdotL) * lightMap.g * 2;
                //halfLambert = smoothstep(0,0.5,NdotL) * 1;
                 //halfLambert = NdotL * 0.5 + 0.5;
                 //halfLambert = NdotL;

                /* 
                Skin = 1.0
                Silk = 0.7
                Metal = 0.5
                Soft = 0.3
                Hand = 0.0
                */
                
                    return tex2D(RampTex ,half2(halfLambert, RampRange)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
                    return halfLambert; 
                    return NdotL; 
                    //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
            }
            
            half3 NPR_Base_Specular(half NdotL,half NdotH ,sampler2D RampTex,half3 baseColor,half4 lightMap,half3 MetalFactor)
            {
                half Ks = 0.04;
                half  SpecularPow = exp2(0.5 * lightMap.r * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
                half  SpecularNorm = (SpecularPow+8.0) / 8.0;
                half3 SpecularColor =  baseColor * lightMap.b;
                 SpecularColor = lerp(half3(0.3, 0.3, 0.3), baseColor,  0) * lightMap.b;
                half SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));
                 
                 half halfLambert = max(0,NdotL * 0.5 + 0.5);
                half SpecRamp = tex2D(RampTex ,half2(halfLambert, 0.2)).rgb;
                //原神的金属贴图（这里我使用了一种拟合曲线来模拟）
                // half MetalDir = normalize(mul(UNITY_MATRIX_V,normalDir));
                // half MetalRadius = saturate(1 - MetalDir) * saturate(1 + MetalDir);
                // half MetalFactor = saturate(step(0.5,MetalRadius)+0.25) * 0.5 * saturate(step(0.15,MetalRadius) + 0.25)  ;
                //简单方法是直接采样
                 MetalFactor *= lerp(_MetalIntensity * 5,_MetalIntensity  * 10, lightMap.r) ;
                half3 MetalColor = MetalFactor * baseColor * step(0.95,lightMap.r);
                return MetalColor * SpecularColor ;
                return SpecularColor.b ;
                return MetalColor;
                return SpecularColor * (SpecularContrib  * NdotL* Ks * lightMap.g + MetalColor) ;
                return SpecRamp;
            }

                float3 NPR_Base_RimLight(float NdotV,float NdotL,float3 RimColor)
                {
                    return (1 - smoothstep(_RimRadius,_RimRadius + 0.1,NdotV)) * _RimIntensity * (1 - (NdotL * 0.5 + 0.5 )) * RimColor;
                }

            half3 NPR_Crystal(half3 VDirTS,half3 NDirTS,half IOR,sampler2D CrystalMap,float2 uv,
                half A,half B,half3 _CrystalColor,half4 VertexColor)
             {
                 //NDirTS = float3(0,0,1);
                 half3 Refract = refract(VDirTS,NDirTS,1/IOR);
                 half2 Refract_xy = Refract.xy/Refract.z; 
                 float2  Crystaluv1 = uv * float2(1.2,1) + Refract_xy;
                 float2  Crystaluv2 = uv * float2(1,1.75) + Refract_xy;
                 half CrystalCol1 = lerp(0.6,tex2D(CrystalMap,Crystaluv1).r , lerp( 1 ,VertexColor,_VertexIntensity)) * A;
                 half CrystalCol2 = lerp(0.8,tex2D(CrystalMap,Crystaluv2).r ,lerp( 1 ,VertexColor,_VertexIntensity)) * (A + B);
                 half CrystalCol = CrystalCol1 * CrystalCol2;
                 return CrystalCol * _CrystalColor;
             }
            v2f vert (appdata v)
            {
                v2f o ;
                //posOS=>CS  "ShaderVariablesFunctions.hlsl"
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;
                //o.posCS = TransformObjectToHClip(v.vertex);
                
                //法线OS=>WS "ShaderVariablesFunctions.hlsl"
                 VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                 o.normalWS = normalize(normalInputs.normalWS);
                 half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normalOS).xyz;
                 o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                 o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.color = v.color;
                 //TANGENT_SPACE_ROTATION;
                return o;
            }
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
            
            half4 frag (v2f i) : SV_TARGET
            {
                //float3 worldTangent = i.tangentWS.xyz;
				// float3 worldNormal = i.normalWS.xyz;

				// float3 worldBitangent = i.binormalWS.xyz;
                float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
				float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
                float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 vDirTS = tanToWorld0 * vDirWS.x + tanToWorld1 * vDirWS.y  + tanToWorld2 * vDirWS.z;
                vDirTS = normalize(vDirTS);
                float3x3 worldToTangent = float3x3(i.tangentWS,i.binormalWS,i.normalWS);
                
                
                Light light = GetMainLight();
                
                half3 reflectDir = reflect(vDirWS, i.normalWS);
                //half3 matCapUV = reflectDir * 0.5 + 0.5;

                half2 uv_nDirTS = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                half3 nDirTS = UnpackNormal(tex2D(_NormalMap,uv_nDirTS));
                //nDirTS.xy *= _NormalIntensity;
                nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);
                half3 nDirTSD = UnpackNormal(tex2D(_NormalDetil,i.uv));
                //nDirTSD.xy *= _NormalDetilIntensity;
                nDirTSD = lerp(float3(0,0,1),nDirTSD,_NormalDetilIntensity);
                nDirTS+= nDirTSD;
                half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                
                //tangent2World方法
                //float3 vDirTS =  tanToWorld0 * vDirWS.x + tanToWorld1 * vDirWS.y  + tanToWorld2 * vDirWS.z;
                //vDirTS = normalize(vDirTS);
                
                half3 ViewN =  i.normalVS_uv;
                ViewN.xy += nDirTS.xy * _Bump;
                half NdotL = dot(nDirWS,normalize(light.direction));
                half halfNdotL = NdotL * 0.5 + 0.5;
                NdotL = max(0,NdotL);
                
                half NdotV = dot(nDirWS,vDirWS);
                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                half NdotHOffset = dot(nDirWS,normalize(light.direction + vDirWS + half3(_UvOffsetX,_UvOffsetY,_UvOffsetZ) ));
                NdotH = max(0,NdotH);
                half NdotVOffset = dot(nDirWS,normalize(light.direction + vDirWS +  half3(_UvOffsetX,_UvOffsetY,_UvOffsetZ)));
                NdotVOffset = max(0,NdotVOffset);
                half LdotH = dot(normalize(light.direction),normalize(light.direction + vDirWS));
                float Lightatten = light.distanceAttenuation ;
                
                half halfLambert = smoothstep(0,0.5,NdotL);
                
                // sample the texture
                half4 baseColor  = tex2D(_MainTex, i.uv).rgba;
                half4 var_MRMap  = tex2D(_MRTex, i.uv);
                half matelness = var_MRMap.r;
                half roughness = 1 - var_MRMap.a;
                //lightMap.b = 1;

                //Ddiff
                float3 kd = OneMinusReflectivityMetallic(roughness);
                float3 diffColor = kd * baseColor * light.color * NdotL * Lightatten;

                //Dspec
                //这里默认一个环境光基数为0.04，unity内置了一个预定义unity_ColorSpaceDielectricSpec，但与0.04有点差距，因此我们使用0.04
                //half3 F0 = unity_ColorSpaceDielectricSpec.rgb;
                half3 F0 = half3(0.04,0.04,0.04);
                F0 = lerp(F0, baseColor, matelness);
                float3 F = FresnelEquation(F0 , LdotH);
                float D = Distribution(roughness , NdotH);
                float G = Geometry(roughness , NdotL , NdotV);

                float3 Specular = F*D*G/(4 * NdotV * NdotL + 0.001);//一定要有这个+0.001，来防止边缘处除以0导致过曝
                float3 SpecColor = Specular * PI * light.color * NdotL * Lightatten;
                
                
                
                half4 finalcol = 1;
                finalcol.xyz = NdotH;
                finalcol.xyz = SpecColor + diffColor;
                half4 Test = 1;
                Test.xyz = F;

                return finalcol;
                return Test;

            }
            ENDHLSL
        }
    }
}
