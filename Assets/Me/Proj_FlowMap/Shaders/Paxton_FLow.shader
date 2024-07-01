Shader "Paxton/FlowMap"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        [MainTexture]_FlowMap("FlowMap" , 2D) = "white"{}
        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
        _Specularint("Specular" , Range(0,1)) = 1
        _Smoothness("Smoorhness" , Range(0,1)) = 1
        _Metallicint("Metallic" , Range(0,1)) = 1

        _TimeSeed("TimeSeed" , Range(0,10)) = 1
        _FlowSpeed("FlowSpeed" , Range(-5,5)) = 1
        
        _Cutoff("Alpha cutout threshold", Range(0, 1)) = 0.5
        
        [HideInInspector] _Cull("Cull mode", Float) = 2 // 2 is "Back"
        [HideInInspector] _SourceBlend("Source blend", Float) = 0
        [HideInInspector] _DestBlend("Destination blend", Float) = 0
        [HideInInspector] _ZWrite("ZWrite", Float) = 0
        [HideInInspector] _SurfaceType("Surface type", Float) = 0
        [HideInInspector] _FaceRenderingMode("Face rendering type", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
            sampler2D _FlowMap;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _ColorTint;
            float _Cutoff;
            float _Smoothness,_Specularint,_Metallicint;
            float _TimeSeed;
            float _FlowSpeed;
            CBUFFER_END
        ENDHLSL

        Pass
        {
            
            Name "ForwardLit" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
            
            // Blend [_SourceBlend] [_DestBlend]
            ZWrite On
            Cull Back
            
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
        
            
        
                v2f vert (appdata v)
                {
                    v2f o ;
                    VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                    o.posCS = posnInputs.positionCS;
                    o.posWS = posnInputs.positionWS;

                    VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                    o.normalWS = normalize(normalInputs.normalWS);
        
                    o.uv = TRANSFORM_TEX(v.uv ,_MainTex);
        
                    return o;
                }


                float4 frag (v2f i) : SV_TARGET
                {
                    float3 flowDir = tex2D(_FlowMap, i.uv) * 2.0 - 1;
                    flowDir *= _FlowSpeed;
                    //构造周期
                    float phase0 = frac(_Time * 0.5 * _TimeSeed + 0.5);
                    float phase1 = frac(_Time * 0.5 * _TimeSeed + 1);

                    // float2 tiling_uv = i..uv * _BumpMap

                    //偏移后的uv对贴图采样
                    float2 uv_MainTex = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                    float4 ColorMap0 = tex2D(_MainTex, uv_MainTex + flowDir.xy * phase0) ;
                    float4 ColorMap1 = tex2D(_MainTex, uv_MainTex + flowDir.xy * phase1) ;
                    float flowLerp = abs((0.5 - phase0) / 0.5);
                    float3 ColorMap = lerp(ColorMap0 , ColorMap1 , flowLerp);
                    
                    float4 c = 1;
                    c.xyz = ColorMap;
                    return c;
                }
                ENDHLSL
        }
    }
}