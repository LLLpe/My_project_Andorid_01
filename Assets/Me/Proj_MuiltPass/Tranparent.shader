Shader "Unlit/Tranparent"
{
    Properties
    {
        _MainCol ("_MainCol", color) = (1,1,1,1)
        _Alpha ("_Alpha", Range( 0 , 1)) = 0
    }
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="SRPDefaultUnlit"}
            // Tags {"LightMode"="UniversalForward"}
            ZWrite On
            ColorMask 0 
        }



        Pass
        {
            Tags {"LightMode"="UniversalForward"}
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma enable_cbuffer

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                // float2 uv : TEXCOORD0;

            };

            struct v2f
            {
                // float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float fogCoord : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;


            };


            CBUFFER_START(UnityPerMaterial)
                half4 _MainCol;
                float _Alpha;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                float3 worldPos = TransformObjectToWorld(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.fogCoord = ComputeFogFactor(o.vertex.z);
                o.shadowCoord = TransformWorldToShadowCoord(worldPos);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float shadow = MainLightRealtimeShadow(i.shadowCoord);

                // sample the texture
                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half4 col = _MainCol;
                // col *= _MainLightColor * shadow;
                // apply fog
                // col.rgb = MixFog(col,i.fogCoord);
                col.a = _Alpha;
                return col;
                // return half4(shadow,shadow,shadow,1);
            }
            ENDHLSL
        }
    }
}
