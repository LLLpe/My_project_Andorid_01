//*********
//风格化金属Shader
//*********

Shader "PaxtonLiu/Paxton_GBVSStyle"
{
    Properties
    {
         [Header(GBVS)]
        _MainTex("BaseMap" , 2D) = "white"{}
        _SSSMap      ("SssMap" , 2D) = "black"{}
        _ILMMap      ("ILMMap" , 2D) = "white"{}  
        _DetailMap      ("DetailMap" , 2D) = "white"{}  
        _ShadowThreshold     ("ShadowThreshold"  ,Range( 0 , 1)) = 1
        _ShadowHardness      ("ShadowHardness"  ,Range( 0 , 50)) = 50
        _SpecSize("_SpecSize"  ,Range( 0 , 1)) = 1
        _Outline("_Outline"  ,Range( 0 , 1)) = 0.1
        _SpecColor("_SpecColor" , color) = (1,1,1,1)
        _SpecDarkColor("_SpecDarkColor" , color) = (1,1,1,1)
        _SpecIntensity("_SpecIntensity"  ,Range( 0 , 10)) = 1
        _RimDir("RimDir"  ,Vector) = (1,0,-1,0)
        _RimColor("RimColor" , color) = (1,1,1,1)
        _RimIntensity("RimInt" , Range( 0 , 1)) = 1

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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            

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
                half2 uv2 : TEXCOORD8;
                half3 posWS : TEXCOORD1;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;
                half4 vertex_color : TEXCOORD7;

            };

            CBUFFER_START(UnityPerMaterial)
            half _AlbedoInt;
            half _specularPowIint;
            half _RampRange;
			half _MetalIntensity;
			half _AlbedoIntensity;
            half _Bump;
            half _Routhness;
            half _roughnessADD;
            half _Matelness;
            half _NormalIntensity;
            half _EnvSpecInt;
            half _specInt;
            half _specHardness;
            half _env_specInt;
            half _HardSpecInt1;
            half _HardSpecInt2;
            half _ShadowThreshold;
            half _ShadowHardness;
            half _SpecSize;
            half3 _SpecColor;
            half3 _SpecDarkColor;
            half _SpecIntensity;
            half3 _RimDir;
            half3 _RimColor;
            half _SmoothstepMin;
            half _SmoothstepMax;
            half _RimIntensity;

            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint;
            samplerCUBE _Cubemap;
            sampler2D _RMMap; 
            sampler2D _MetalMap;
            sampler2D _RimMap;
            sampler2D _NormalMap;
            sampler2D _RampTex;
            sampler2D _RampTexSpec;
            sampler2D _lightMap; half4 _lightMap_ST;
            sampler2D _rampCol2; 
            sampler2D _BaseMap; 
            sampler2D _SSSMap; 
            sampler2D _ILMMap; 
            sampler2D _DetailMap; 
             
            
            
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
                o.uv = v.uv;
                o.uv2 = v.uv2;
                 o.vertex_color = v.color;

                return o;
            }
                
            half4 frag (v2f i) : SV_TARGET
            {
                
                half4 shadowCoord = TransformWorldToShadowCoord(i.posWS);
                Light light = GetMainLight(shadowCoord);
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 reflectDir = reflect(-vDirWS, i.normalWS);
                half3 nDirTS = UnpackNormal(tex2D(_NormalMap,i.uv));
                nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);
                half3 nDirVS = TransformWorldToView(vDirWS);
                
                half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                
                half3 matCapUV = reflectDir * 0.5 + 0.5;
                half3 ViewN =  i.normalVS_uv;
                
                half NdotL = dot(nDirWS,normalize(light.direction));
                NdotL = max(0,NdotL);
                half NdotV = dot(nDirWS,vDirWS);
                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                NdotH = max(0,NdotH);
                half LdotH = dot(normalize(light.direction),normalize(light.direction + vDirWS));
                
                half halfLambert = smoothstep(0,0.5,NdotL);
                


                //MatCap菲涅尔
                half RimColor = tex2D(_RimMap,matCapUV).r * _RimIntensity;
                
                
                //***********************************
                //GBVS
                half4 var_base = tex2D(_MainTex,i.uv);
                half4 var_sss = tex2D(_SSSMap,i.uv);
                half4 var_ilm = tex2D(_ILMMap,i.uv);
                
                half spec_intensity = var_ilm.r;
                half shadow_control = var_ilm.g * 2 - 1 ;//0~0.5 => -1 到 0
                half spec_size = var_ilm.b;
                half inner_line = var_ilm.a;
                half base_mask = var_base.a;

                half ao = i.vertex_color.r;
                //diff
                half lambert_term = halfLambert * ao + shadow_control; //shadow_control就是上面所说的阴影倾向权重
                half toon_diffuse = saturate((lambert_term - _ShadowThreshold) * _ShadowHardness);  //色阶化处理得到亮暗部分mask
                half3 GBVSdiff = lerp(var_sss, var_base, toon_diffuse);//进行混合

                
                //spec
                half spec_term = (NdotV + 1.0) * 0.5 * ao + shadow_control;
                // spec_term = halfLambert * 0.9 + spec_term * 0.1;
                spec_term = spec_term * 0.1 + halfLambert * 0.9;   //反射所占权重
                // spec_term = spec_term * toon_diffuse;
                half toon_spec = saturate((spec_term - (1 - spec_size * _SpecSize)) * 500)* spec_intensity * _SpecIntensity;//色阶化处理得到高光mask
                half3 spec_col = _SpecColor.xyz * 0.6 + var_base * 0.4; //希望高光颜色带有basecolor的倾向
                half3 GBVSspec = toon_spec * spec_col  ;//进行混合

                //描线
                half3 inner_line_color = lerp(var_base * 0.2, float3(1.0,1.0,1.0), inner_line);
                half3 detail_color = tex2D(_DetailMap,i.uv2);
                half3 final_line = inner_line_color * detail_color;
                
                //rimcol
                float3 rimlight_dir =  normalize(light.direction + _RimDir.xyz );//转换到相机空间
                half rim_lambert = (dot(normalize(nDirWS), rimlight_dir) + 1.0) * 0.5;//从-1.0-1.0映射到0.0-1.0                 
                half rim_term = rim_lambert * ao + shadow_control;//边缘光因子
                half toon_rim = saturate((rim_term - _ShadowThreshold) * 100);
                half3 rim_color = (_RimColor + var_base) * 0.5 ;//sss_mask区分边缘光区域的强度
                half3 GBVSrim = toon_rim * rim_color  * base_mask * _RimIntensity;//base_mask区分皮肤与非皮肤区域，看自己喜欢选择乘不乘

                
                //rimdark
                half rimdark_term = normalize(_RimDir.xyz);
                rimdark_term = lerp( 1 ,rimdark_term, 1- toon_diffuse);
                half3 GBVSrim2 = rimdark_term * _RimColor;

                
                half4 finalColor = 1;
                finalColor.xyz = (GBVSdiff + GBVSspec + GBVSrim ) * final_line  ;
                
                // finalColor.xyz = GBVSrim;

                return finalColor;

            }
            ENDHLSL
        }
        Pass
        {
            
//                Name "ForwardLit" // For debugging
//                Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
                
                Cull Front
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                

                struct appdata
                {
                    half3 vertex : POSITION;
                    half4 normalOS : NORMAL;
                    half4 color : COLOR;
                };

                struct v2f
                {
                    half4 posCS : SV_POSITION;
                    half3 posWS : TEXCOORD1;
                    half3 normalWS : TEXCOORD32;
                    half4 vertex_color : TEXCOORD3;

                };
                
                 
            CBUFFER_START(UnityPerMaterial)
                
            half _Outline;
                
			CBUFFER_END
                
                v2f vert (appdata v)
                {
                    v2f o ;
                    //posOS=>CS  "ShaderVariablesFunctions.hlsl"
                    VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                    o.posWS = posnInputs.positionWS;
                    //o.posCS = TransformObjectToHClip(v.vertex);
                    
                    //法线OS=>WS "ShaderVariablesFunctions.hlsl"
                    VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                    o.normalWS = normalize(normalInputs.normalWS);
                    o.posWS += o.normalWS * _Outline *0.01 ;
			        o.posCS = mul(UNITY_MATRIX_VP , float4(o.posWS,1.0));
                     o.vertex_color = v.color;

                    return o;
                }
                    
                half4 frag (v2f i) : SV_TARGET
                {


                    half4 Test = 1;
                    Test.xyz =0;

                    return Test;

                }
                ENDHLSL
            
        }
    }
}
