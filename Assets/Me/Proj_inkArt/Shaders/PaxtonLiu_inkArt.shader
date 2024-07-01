Shader "PaxtonLiu/Paxton_Ink"
{
    Properties
    {
        _MianTex("MianTex",2D) = "black"{}
        [HDR]_Color("颜色" , color) = (1,1,1,1)
        _FlowMap("FlowMap",2D) = "white"{}
        _FlowSpeed("FlowSpeed",float) = 0.1
        _TimeSpeed("TimeSpeed",float) = 1
        [Toggle]_reverse_flow("反转流向"，int) =



        [Header(Reflection)]
        [NoScaleOffset]_ReflectMap("反射贴图",2D) = "black"{}
        [NoScaleOffset]_ReflectPower("反射强度",Range( 0 , 10)) = 1
        
        [Header(Normal)]
        [NoScaleOffset]_NormalMap("法线贴图"  ,2D) = "bump"{}
        [NoScaleOffset]_NormalIntensity("法线强度", Range( 0 , 2)) = 1
        _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 1
        
        [Header(RimColor)]
        _RimColor("边缘光颜色" , color) = (1,1,1,1)
        _RimRadius("边缘光范围", Range( 0 , 1)) = 1
        _RimIntensity("边缘光强度", Range( 0 , 10)) = 1
        
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
            #pragma shader_feature _REVERSE_FLOW_ON

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

            half3 _Color;
           
            half _NormalIntensity;
            half _NormalDetilIntensity;
            half _FlowSpeed; half _TimeSpeed;
            
			CBUFFER_END

            sampler2D _MianTex; half4 _MianTex_ST;
            sampler2D _ReflectMap; 
            sampler2D _NormalMap;half4 _NormalMap_ST;
            sampler2D _NormalDetil;half4 _NormalDetil_ST;
            sampler2D _FlowMap; half4 _FlowMap_ST;
            

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
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                Light light = GetMainLight();


                half3 flowDir = tex2D(_FlowMap , i.uv) * 2 - 1;
                flowDir *= -_FlowSpeed;

                #ifdef _REVERSE_FLOW_ON
                flowDir *= -1;
                #endif

                //构造相位周期
                float phase0 = frac(_Time * 0.1 * _TimeSpeed);
                float phase1 = frac(_Time * 0.1 * _TimeSpeed + 0.5);

                //平铺贴图UV
                float tiling_uv = i.uv * _MianTex_ST.xy + _MianTex_ST.zw;

                //sample
                half3 flowtex0 = tex2D(_MianTex , tiling_uv - flowDir * phase0);
                half3 flowtex1 = tex2D(_MianTex , tiling_uv - flowDir * phase1);
                half floatLerp = abs((0.5 - phase0)/0.5);

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
                half3 nDirTS = UnpackNormal(tex2D(_NormalMap,uv_nDirTS));
                nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);

                half2 uv_nDirTSD = i.uv * _NormalDetil_ST.xy + _NormalDetil_ST.zw;
                half3 nDirTSD = UnpackNormal(tex2D(_NormalDetil,uv_nDirTSD));
                nDirTSD = lerp(float3(0,0,1),nDirTSD,_NormalDetilIntensity);
                nDirTS+= nDirTSD;
    
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                
                //MatCap_UV
                half3 ViewN =  i.normalVS_uv;
                ViewN.xy += nDirTS.xy ;

                //NdotL
                half NdotL = dot(nDirWS,normalize(light.direction));
                // half halfNdotL = NdotL * 0.5 + 0.5;
                NdotL = max(0,NdotL);
                
                //NdotV
                half NdotV = dot(nDirWS,vDirWS);

                              
                


                //NPR菲涅尔
                half3 Fresnel = NPR_Base_RimLight(NdotV,_RimColor);

                
                half3 finalcol = lerp(flowtex0 , flowtex1 ,floatLerp ) * _Color;

                half4 c = 1;
                c.xyz = finalcol;
                


                return finalcol;
            }
            ENDHLSL
        }
    }
}
