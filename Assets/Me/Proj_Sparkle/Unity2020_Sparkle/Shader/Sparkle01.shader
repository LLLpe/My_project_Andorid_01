Shader "Sparkle/Sparkle01"
{
    Properties
    {
        _MainTex ("Main Texture",2D) = "White"{}
        _Tint ("Tint", Color) = (0.5,0.5,0.5,1)
        _NormTex("Normal Texture" ,2D) = "bump"{}
        _Cubemap    ("Cubemap", cube)  = "_Skybox" {}

        _MaskTex ("Specular/Gloss", 2D) = "Grey"{}
        _Specular ("Specular", Range(0,10)) = 1
        _Gloss ("Gloss", Range(0,10) ) = 1

        _EnvDiffInt ("Env DiffInt", Range(0, 1))  = 0.2
        _SpecPow    ("Env SpecPow",  Range(1, 90)) = 30
        _EnvSpecInt ("Env SpecInt", Range(0, 5))  = 0.2
        _CubemapMip ("Cubemap Mip",  Range(1, 7))  = 1

        [Header(Starry)]
            _SkyTex ("Starry Texture", 2D) = "Black" {}
            _SkySize ("SkySize Size", Range(1, 7)) = 1
            _SkySpeed("Sky Speed", Float) = 0.1
            _Skyint("Skyint", Range(0, 1)) = 1
            _SkyDistort("SkyDistort", Range(0,7 )) = 1

        [Header(Sparkle)]
            _SparkTex_base ("Base Sparkle Texture", 2D) = "Black" {}
            _NoiseSize0 ("Sparkle Size",Range(1, 7)) = 1
            _Specular_Detail ("Detail Specular", Range(0,10)) = 1
            _Gloss_Detail ("Detail Gloss", Range(0,3) ) = 1
            _ShiningSpeed0 ("Shining Speed", Float) = 0.1
            [HDR]_SparkleColor0 ("sparkle Color1", Color) = (0,0,0,0)

            _SparkTex_second ("Second Sparkle Texture", 2D) = "Black" {}
            _NoiseSize ("Sparkle Size", Range(1, 7)) = 2
            _ShiningSpeed ("Shining Speed", Float) = 0.1
            _SparkleColor1 ("Sparkle Color1", Color) = (1,1,1,1)
            _SparkleColor2 ("Sparkle Color2", Color) = (1,1,1,1)
            _SparkleColor3 ("Sparkle Color3", Color) = (1,1,1,1)
            _Specular_Sparkle ("Sparkle Specular", Float) = 20
            _SparklePower ("Sparkle Power", Float) = 10
            _DiffsparkleRate ("Sparkle Diffuse Rate", Float) = 1
            _SparkleArea("Sparkle Back Area", Range(0,1)) = 0.5
            _SpakleMask ("Spakle Mask", 2D) = "white" {}
            _SpakleClamp ("SpakleClamp", Range(0, 1)) = 0
        
        [Header(Rim)]
            _RimColor ("Rim Color", Color) = (0.17,0.36,0.81,0.0)
            _RimPower ("Rim Power", Range(0.6,36.0)) = 8.0
            _RimIntensity ("Rim Intensity", Range(0.0,100.0)) = 1.0      
            _RimsparkleRate ("Rim sparkle Rate", Float) = 10

        [Header(Parallax)]
            _ParallaxMap ("Parallax Map", 2D) = "white" {}
            _HeightFactor ("Height Scale", Range(-5, 5)) = 0


        
    }
    
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque" 
        }
        
        LOD 100
        
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            
            //#pragma glsl
 
            sampler2D _MainTex,_SparkTex_second,_SparkTex_base, _ParallaxMap,_NormTex,_MaskTex,_SpakleMask,_SkyTex;
            samplerCUBE _Cubemap;
            float4 _SparkTex_second_ST,_SparkTex_base_ST, _ParallaxMap_ST,_ScreenTex_ST;
            float4 _Tint, _RimColor,_SparkleColor0, _SparkleColor1,_SparkleColor2,_SparkleColor3;
            float _SpecPow,_EnvSpecInt,_EnvDiffInt,_FresnelPow,_CubemapMip,_Specular,_Gloss,_Specular_Detail,_Gloss_Detail, _NoiseSize,_NoiseSize0, _ShiningSpeed0,_ShiningSpeed,_SkySize,_SkySpeed,_Skyint,_SkyDistort,_SparkleArea,_Specular_Sparkle,_SpakleClamp;
            float _RimPower, _RimIntensity, _RimsparkleRate, _DiffsparkleRate, _SparklePower;
            float _HeightFactor;
 
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 tangent : TANGENT;
            };
 
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 viewUV : TEXCOORD2;
                float4 posWorld : TEXCOORD3;
                float3 normalDir : TEXCOORD4;
                float3 tDirWS   : TEXCOORD5;  // 世界空间切线方向
                float3 bDirWS   : TEXCOORD6;  // 世界空间副切线方向
                float3 lightDir : TEXCOORD7;
                float3 lightDir_TS   : TEXCOORD8;
                LIGHTING_COORDS(9,10)
                UNITY_FOG_COORDS(11)
            };
            
            // 切线空间 视差偏移
            inline float2 CaculateParallaxUV(v2f i, float heightMulti)
            {
                float height = tex2D(_ParallaxMap, i.uv).r;
                //偏移值 = 切线空间的视线方向.xy（uv空间下的视线方向）* height * 控制系数
                float2 offset = i.lightDir_TS.xy * height * _HeightFactor*0.01 * heightMulti;
                return offset;
            }
 
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                o.bDirWS = normalize(cross(o.normalDir, o.tDirWS) * v.tangent.w);  // 副切线方向
                o.posWorld = mul (unity_ObjectToWorld, v.vertex);

                o.uv = v.uv;
                o.uv1 = TRANSFORM_TEX(v.uv1, _SparkTex_second);

                float3 posVS = UnityObjectToViewPos(v.vertex).xyz;                  // 顶点位置 OS>VS
                float3 posVS000 = UnityObjectToViewPos(float3(0.0, 0.0, 0.0));   // 原点位置 OS>VS
                o.viewUV = float3 (posVS - posVS000).xy;

                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

                TANGENT_SPACE_ROTATION;
                o.lightDir_TS = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
                
                UNITY_TRANSFER_FOG (o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT (o)
                return o;
            }
 
            float4 frag(v2f i) : SV_Target
            {
                //i.normalDir = normalize(i.normalDir);
                half3 nDirTS = UnpackNormal(tex2D(_NormTex, i.uv));
                half3x3 TBN = half3x3(i.tDirWS, i.bDirWS, i.normalDir);
                half3 normalDir = normalize(mul(nDirTS, TBN));
                // attenuation
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;

                //向量准备
                fixed3 viewDirWS = normalize(UnityWorldSpaceViewDir(i.posWorld));
                float3 vrDirWS = reflect(-viewDirWS, normalDir);
                float3 lrDirWS = reflect(-i.lightDir, normalDir);
                

                // 准备点积结果
                float NdotL = saturate (dot (normalDir, i.lightDir));
                float vdotr = dot(viewDirWS, lrDirWS);
                float vdotn = dot(viewDirWS, normalDir);

                //纹理采样
                float4 Var_Diffuse = tex2D(_MainTex , i.uv);
                float3 Var_Specular = tex2D(_MaskTex ,i.uv).xyz;
                float Var_Gloss = tex2D(_MaskTex ,i.uv).a;
                fixed3 Var_SpakleMask = tex2D(_SpakleMask , i.uv);
                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, lerp(_CubemapMip, 0.0, Var_Gloss))).rgb;

                // 光照模型(直接光照部分)
                float3 baseCol = Var_Diffuse.rgb * _Tint;
                float lambert = max(0.0, NdotL);
                float specCol = Var_Specular*_Specular;
                float specPow = lerp(1, _SpecPow, Var_Gloss * _Gloss);
                float phong = pow(max(0.0, vdotr), specPow);   
                float shadow = LIGHT_ATTENUATION(i);
                float3 dirLighting = (baseCol * lambert + specCol * phong) * _LightColor0 * shadow;

                // 光照模型(环境光照部分)
                float3 envdiff = baseCol  *_EnvDiffInt;   //环境diff
                float3 envspe = var_Cubemap * _EnvDiffInt * Var_Gloss; //环境spe
                float3 envLighting = (envdiff + envspe);
    
                // Rim
                float rim = 1.0 - max(0, vdotn);
                fixed3 rimCol = _RimColor.rgb * pow (rim, _RimPower) * _RimIntensity; 
                
                // sparkle specular
                float specularPow_Detail = exp2 ((1 - _Gloss_Detail * Var_Gloss) * 10.0 + 1.0);
                float3 halfVector_Detail = normalize (i.lightDir + viewDirWS);
                float3 directSpecular_Detail = pow (max (0,vdotr), specularPow_Detail) * Var_Specular;
                float3 specular_Detail = directSpecular_Detail * attenColor * _Specular_Detail;

                    //星空
                float2 uvOffset = CaculateParallaxUV(i, 3);
                float3 skyCol = tex2D (_SkyTex , i.viewUV * _SkySize  +viewDirWS/(100*(2-_SkyDistort)) + float2 (_Time.x * _SkySpeed , 0) + uvOffset)*_Skyint * NdotL;  //视空间采样

                    //sparkle0
                float4 noise_base1 = tex2D(_SparkTex_base, i.uv1 * _NoiseSize0+ float2 ( _Time.x * _ShiningSpeed0, 0)).r;
                float4 noise_base2 = tex2D(_SparkTex_base, i.uv1 * _NoiseSize0 + i.lightDir/5 +viewDirWS/5 + i.normalDir/5);    //三种偏移,分别实现视角转动,光源转动,角色转动时的扰动效果



                    //sparkle1
                uvOffset = CaculateParallaxUV(i, 1);
                float noise1 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize + float2 (0, _Time.x * _ShiningSpeed) + uvOffset).r;
                float noise2 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0)).r;
                float sparkle1 = pow (noise1 * noise2 * 2, _SparklePower);
    
                    //sparkle2
                uvOffset = CaculateParallaxUV(i, 2);
                noise1 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize + float2 (0.3, _Time.x * _ShiningSpeed) + uvOffset).r;
                noise2 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0.3) + uvOffset).r;
                float sparkle2 = pow (noise1 * noise2 * 2, _SparklePower);

                    //sparkle3
                uvOffset = CaculateParallaxUV(i, 3);
                noise1 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize + float2 (0.6, _Time.x * _ShiningSpeed) + uvOffset).r;
                noise2 = tex2D (_SparkTex_second, i.uv1 * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0.6) + uvOffset).r;
                float sparkle3 = pow (noise1 * noise2 * 2, _SparklePower);
                
                // Spakele diffuse               
                float HalfNdotL = NdotL * 0.5 + 0.5;
                float3 directDiffuse = NdotL * attenColor;
                float3 HalfdirectDiffuse = HalfNdotL * attenColor;
                                
                    // Spakele final color
                float sparkleArea = lerp(directDiffuse,HalfdirectDiffuse,_SparkleArea);  //对暗部细节做一个lerp
                fixed3 sparkleCol0 = noise_base1.rgb * noise_base2 .rgb * specular_Detail * _SparkleColor0;  
                fixed3 sparkleCol1 = sparkle1 * (specular_Detail * _Specular_Sparkle  + sparkleArea * _DiffsparkleRate + rimCol * _RimsparkleRate) *  lerp(_SparkleColor1, fixed3(1,1,1), 0.5);
                fixed3 sparkleCol2 = sparkle2 * (specular_Detail * _Specular_Sparkle  + sparkleArea * _DiffsparkleRate + rimCol * _RimsparkleRate) * _SparkleColor2;
                fixed3 sparkleCol3 = sparkle3 * (specular_Detail * _Specular_Sparkle  + sparkleArea * _DiffsparkleRate + rimCol * _RimsparkleRate) * 0.5 *_SparkleColor3;              
                fixed3 sparkleCol = (sparkleCol0 + sparkleCol1 + sparkleCol2 + sparkleCol3) * lerp(1,Var_SpakleMask,_SpakleClamp);

                //finalCol
                fixed4 finalCol = fixed4 (dirLighting + envLighting + sparkleCol + rimCol + skyCol, 1);
                
                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                return finalCol;
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
