Shader "PaxtonLiu/HLSL_YS"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
        _lightMap("R:Gloss G:Spec B:LighMap A:",2D) = "white"{}
        _RampTex("RampTex",2D) = "white"{}
        _RampTexSpec("RampTexSpec",2D) = "white"{}
        _MetalMap("MetalFactor",2D) = "Black"{}
        _NormalMap("Normal贴图"  ,2D) = "bump"{}
        _Cubemap("Cubemap" ,cube) = "Black"{}
        _Bump("_Bump" , Range(0,2)) = 1
        _specularPowIint ("specularPow", Range( 0 , 1)) = 1
        _RampRange ("RampRange", Range( 0 , 1)) = 0.5
        _AlbedoIntensity("AlbedoIntensity", Range( 0 , 1)) = 1
        _MetalIntensity("MetalIntensity", Range( 0 , 5)) = 1
        _EnvSpecInt("EnvSpecInt", Range( 0 , 1)) = 1
        _RimRadius("_RimRadius", Range( 0 , 1)) = 1
        _RimIntensity("_RimIntensity", Range( 0 , 10)) = 1
        _HardSpecInt1("_HardSpecInt1", Range( 0 , 10)) = 0
        _HardSpecInt2("_HardSpecInt2", Range( 0 , 10)) = 1
        _UvOffsetX("UvOffsetX", Range( -10 , 10)) = 1
        _UvOffsetY("UvOffsetY", Range( -10 , 10)) = 1
        _UvOffsetZ("UvOffsetZ", Range( -10 , 10)) = 1
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

            

            struct appdata
            {
                half3 vertex : POSITION;
                half2 uv : TEXCOORD0;
                half4 normalOS : NORMAL;
                half4 tangent : TANGENT;
            };

            struct v2f
            {
                half4 posCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                half3 posWS : TEXCOORD1;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;

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
            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint; 
            sampler2D _lightMap; 
            sampler2D _MetalMap;
            sampler2D _NormalMap;
            sampler2D _RampTex;
            sampler2D _RampTexSpec;
            samplerCUBE _Cubemap;
            
            
            
            
            
           

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

                float3 NPR_Base_RimLight(float NdotV,float NdotL,float3 baseColor)
                {
                    return (1 - smoothstep(_RimRadius,_RimRadius + 0.1,NdotV)) * _RimIntensity * (1 - (NdotL * 0.5 + 0.5 )) * baseColor;
                }
            half RoughnessToSpecularExponent(half roughness)
            {
               return  sqrt(2 / (roughness + 2));
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
                 o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                 o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                o.uv = TRANSFORM_TEX(v.uv ,_MainTex);

                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                
                Light light = GetMainLight();
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                
                half3 reflectDir = reflect(vDirWS, i.normalWS);
                //half3 matCapUV = reflectDir * 0.5 + 0.5;
                
                half3 TS_TexNormal = UnpackNormal(tex2D(_NormalMap,i.uv));
                half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                half3 nDirWS = normalize(mul(TS_TexNormal,tangent2World));
                
                half3 ViewN =  i.normalVS_uv;
                ViewN.xy += TS_TexNormal.xy * _Bump;
                half NdotL = dot(nDirWS,normalize(light.direction));
                NdotL = max(0,NdotL);
                
                half NdotV = dot(nDirWS,vDirWS);
                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                NdotH = max(0,NdotH);
                half NdotVOffset = dot(nDirWS,normalize(light.direction + vDirWS +  half3(_UvOffsetX,_UvOffsetY,_UvOffsetZ)));
                NdotVOffset = max(0,NdotVOffset);
                
                half halfLambert = smoothstep(0,0.5,NdotL);
                
                // sample the texture
                half4 mainTex  = tex2D(_MainTex, i.uv).rgba;
                half4 lightMap  = tex2D(_lightMap, i.uv);
                half metaMask = step(0.9,lightMap.r);
                //lightMap.b = 1;



                
                half MetalFactor = tex2D(_MetalMap,ViewN.xy).g;
                //MetalFactor = smoothstep(0.2,0.3,MetalFactor);
                half3 envCube = texCUBElod(_Cubemap, float4(ViewN, lerp(8.0, 0.0, lightMap.r))).rgb;
                half3 SpecularColor = lerp(half3(0.3, 0.3, 0.3), mainTex,  0) * lightMap.b;
                
                half3 RampColor = NPR_Base_Ramp (NdotL , _RampTex, lightMap, _RampRange);
                
                half3 Albedo = mainTex * RampColor;
                Albedo *= (1 - step(0.95,lightMap.r))* _AlbedoIntensity ;

                //MetaMap镜面反射
                half3 Specular = NPR_Base_Specular(NdotL,NdotH,_RampTexSpec,mainTex,lightMap,MetalFactor);

                // Cube环境镜面反射
                half reflectInt = step(0.95,lightMap.r) * lightMap.b;
                half3 envSpec = SpecularColor * reflectInt * envCube * _EnvSpecInt;

                //NPR菲涅尔
                half3 Fresnel = NPR_Base_RimLight(NdotV,NdotL,mainTex);

                //主光镜面反射
                half Var_SpecRamp = tex2D(_RampTexSpec ,pow(NdotVOffset,5) );
                half HardSpec = lightMap.b * Var_SpecRamp * step(0.95,lightMap.r) * _HardSpecInt1 ;
                HardSpec += smoothstep(0.1,0.2,lightMap.b * pow(NdotVOffset,100) * step(0.95,lightMap.r) )* _HardSpecInt2 ;
                //HardSpec = smoothstep(0.1,0.2,HardSpec) * _HardSpecInt ;
                
                half4 finalcol = 1;
                half4 Test = 1;
                Test.rgb =   (Specular + HardSpec) + Albedo * (1 -metaMask );
                //Test.rgb = Albedo * (1 -metaMask );
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, finalcol);
                return Test;
                return Test;
            }
            ENDHLSL
        }
    }
}
