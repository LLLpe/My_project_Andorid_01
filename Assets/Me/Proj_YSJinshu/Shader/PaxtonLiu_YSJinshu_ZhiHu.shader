Shader "PaxtonLiu/HLSL_YS"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
        _lightMap("R:Gloss G:Spec B:LighMap A:",2D) = "white"{}
        _RampTex("RampTex",2D) = "white"{}
        _MetalFactor("MetalFactor",2D) = "Black"{}
        _NormalMap("Normal贴图"  ,2D) = "bump"{}
        _specularPowIint ("specularPow", Range( 0 , 1)) = 1
        _RampRange ("RampRange", Range( 0 , 1)) = 0.5
        _MetalIntensity("MetalIntensity", Range( 0 , 1)) = 0
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
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 posCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 normalWS : TEXCOORD3;

            };

            CBUFFER_START(UnityPerMaterial)
            float _specularPowIint;
            float _RampRange;
			float _MetalIntensity;
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            float4 _ColorTint; 
            sampler2D _lightMap; 
            sampler2D _MetalFactor;
            sampler2D _NormalMap;
            TEXTURE2D( _RampTex);
            SAMPLER(sampler_RampTex);
            
            
            
            

             float3 NPR_Base_Ramp (float NdotL,float4 lightMap,float RampRange)
            {
                float halfLambert = smoothstep(0,0.5,NdotL) * lightMap.b;
                 halfLambert = clamp(halfLambert,0.01,0.999);

                /* 
                Skin = 1.0
                Silk = 0.7
                Metal = 0.5
                Soft = 0.3
                Hand = 0.0
                */
                    return SAMPLE_TEXTURE2D(_RampTex,sampler_RampTex ,float2(halfLambert, RampRange)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
                    return halfLambert; 
                    //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
            }
            
            float3 NPR_Base_Specular(float NdotL,float NdotH ,float3 normalDir,float3 baseColor,float4 lightMap)//优化掉了金属贴图
            {
                float Ks = 0.04;
                float  SpecularPow = exp2(0.5 * lightMap.r * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
                float  SpecularNorm = (SpecularPow+8.0) / 8.0;
                float3 SpecularColor =  baseColor * lightMap.b;
                float SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));

                //原神的金属贴图（这里我使用了一种拟合曲线来模拟）
                float MetalDir = normalize(mul(UNITY_MATRIX_V,normalDir));
                float MetalRadius = saturate(1 - MetalDir) * saturate(1 + MetalDir);
                float MetalFactor = saturate(step(0.5,MetalRadius)+0.25) * 0.5 * saturate(step(0.15,MetalRadius) + 0.25)  ;
                 MetalFactor *= lerp(_MetalIntensity * 5,_MetalIntensity  * 10, 0.5);
                //简单方法是直接采样
                // float MetalFactor = tex2D(_MetalFactor,UV);
                float3 MetalColor = MetalFactor * baseColor * step(0.95,lightMap.r);
                return SpecularColor * (SpecularContrib  * NdotL* 0.04 * lightMap.g + MetalColor);
                return 1 * MetalColor;
                return SpecularContrib;
                return SpecularColor * (1 + MetalColor);
            }
            float RoughnessToSpecularExponent(float roughness)
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

                o.uv = TRANSFORM_TEX(v.uv ,_MainTex);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
                
                Light light = GetMainLight();
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 reflectDir = reflect(vDirWS, i.normalWS);
                float3 matCapUV = reflectDir * 0.5 + 0.5;
                
                float NdotL = dot(i.normalWS,normalize(light.direction));
                NdotL = max(0,NdotL);
                float ClampNdotL = clamp(NdotL,0.01,1);
                float NdotV = dot(i.normalWS,vDirWS);
                float NdotH = dot(i.normalWS,normalize(light.direction + vDirWS));
                NdotH = max(0,NdotH);
                
                float halfLambert = NdotL * 0.5 + 0.5;
                // sample the texture
                float4 baseColor  = tex2D(_MainTex, i.uv).rgba;
                float4 lightMap  = tex2D(_lightMap, i.uv);
                //lightMap.b = 0.5;
                float3 RampColor = NPR_Base_Ramp (ClampNdotL ,lightMap,_RampRange);
                
                float3 Albedo = baseColor * RampColor;
                

                //高光系数    
                float specularPow = pow(NdotH, RoughnessToSpecularExponent(lightMap.b));

                //衣服材质，高光区间
                half strokeVMask = step(1 - _StrokeRange, NdotH);
                half patternVMask = step(1 - _PatternRange, NdotH);

                //头部，高光区间
                half hairMask = step(_HairRange, lightMap.r);
                half hairViewMask = step(_HairViewSpecularThreshold, ndotV);
                half hairSpecAreaMask = step(_HairSpecAreaBaseline, lightMap.b);
                half hairAccGroveMask = step(_HairAccGroveBaseline, lightMap.r);
                
                //高光specular: Metal+Non-metal

                // ILM的R通道，视角高亮
                half strokeMask = step(0.001, lightMap.r) - step(_StrokeRange, lightMap.r);
                half3 strokeSpecular = lightMap.b  * strokeVMask  * strokeMask;
                half patternMask = step(_StrokeRange, lightMap.r) - step(_PatternRange, lightMap.r);
                half3 patternSpecular = lightMap.b  * patternVMask  * patternMask;

                // 金属高光, Blinn-Phong
                half metalMask = step(_PatternRange, lightMap.r);
                half3 metalSpecular = _MetalIntensity * metalMap * metalMask;
                                    
                //最终高光
                specular = (strokeSpecular + patternSpecular  + metalSpecular) * baseColor;
                                    

                //高光部分: 头发顶视角高亮
                float shadowUpperBound = step(ndotLRaw, _HairShadowSmooth) ;
                float isHair = step(0.11, lightMap.r) - step(0.9, lightMap.r);
                float litHair = step(0.0, ndotLRaw);

                specular = _HairViewSpecularIntensity * specularPow * hairViewMask * hairMask;
                specular *= hairSpecAreaMask * baseColor * litHair;
                specular += metalMap.b * hairAccGroveMask * baseColor;
                specular += hairAccGroveMask * baseColor;
                
                float4 finalcol = 1;
                float4 Test = 1;
                finalcol.rgb = baseColor;
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, finalcol);
                return Test;
                return finalcol;
            }
            ENDHLSL
        }
    }
}
