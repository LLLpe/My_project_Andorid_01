Shader "PaxtonLiu/Fresnel_2c"
{
    Properties
    {
        [Header(MainTex)]
        [NoScaleOffset] _MainTex("MainTex",2D) = "Black"{}
        
        [Header(RimColor)]
        _RimColor("边缘光颜色" , color) = (1,1,1,1)
        _RimArea("边缘光范围", Range(0.1,5)) = 1
        _RimHardness("边缘光硬度", Range(0.1,3)) = 1
        
        [Header(LightMap)]
        [NoScaleOffset] _LightMap("LightMap",2D) = "Gray"{}
        _LightMapIntensity("LightMapIntensity",Range(0,2)) = 0
        
        
        
        [Header(Normal)]
        [NoScaleOffset]_NormalMap("法线贴图"  ,2D) = "bump"{}

        
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

            half _LightMapIntensity;
            half _RimArea;
            half _RimHardness;
            half3 _SpecColor;
            
            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint; 
            sampler2D _lightMap; 
            sampler2D _MetalMap;
            sampler2D _CrystalMap;half4 _CrystalMap_ST;
            sampler2D _CrystalMap2;half4 _CrystalMap2_ST;
            sampler2D _NormalMap;half4 _NormalMap_ST;
            sampler2D _NormalDetil;half4 _NormalDetil_ST;
            sampler2D _CrystalRampMap;half4 _CrystalRampMap_ST;
            sampler2D _CrystalRampMask;half4 _CrystalRampMask_ST;
            
            sampler2D _LightMap;
            sampler2D _RampTex;

            half3 _RimColor;
            
            
            
            half3 RimStyleMask(half NdotV,half halfLambert,half RimControl)
             {
                half rimControl_term = RimControl * 2 - 1 + lerp(0 , _LightMapIntensity , RimControl) + 1;
                half fresnael_term = (1-NdotV) * halfLambert * rimControl_term;
                half RimStyleMask = pow(fresnael_term * _RimArea , _RimHardness * 100);
                RimStyleMask = saturate(RimStyleMask);
                
                 return RimStyleMask;
                 return RimStyleMask;
             }
            v2f vert (appdata v)
            {
                v2f o ;
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;

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
                float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
				float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
                float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 vDirTS = tanToWorld0 * vDirWS.x + tanToWorld1 * vDirWS.y  + tanToWorld2 * vDirWS.z;
                vDirTS = normalize(vDirTS);
                float3x3 worldToTangent = float3x3(i.tangentWS,i.binormalWS,i.normalWS);
                
                
                

                half2 uv_nDirTS = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                half3 nDirTS = UnpackNormal(tex2D(_NormalMap,uv_nDirTS));
                half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                
                
                half3 ViewN =  i.normalVS_uv;
                
                half NdotL = dot(nDirWS,normalize(light.direction));
                half halfNdotL = NdotL * 0.5 + 0.5;
                NdotL = max(0,NdotL);
                half NdotV = dot(nDirWS,vDirWS);
                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                
                half3 Abedo = tex2D(_MainTex , i.uv);
                half rimControl = tex2D(_LightMap , i.uv).r;
                half rimMask = RimStyleMask(NdotV,halfNdotL ,rimControl );

                
                half4 finalcol = 1;
                finalcol .xyz = lerp(Abedo , _RimColor , rimMask);
                return finalcol;
            }
            ENDHLSL
        }
    }
}
