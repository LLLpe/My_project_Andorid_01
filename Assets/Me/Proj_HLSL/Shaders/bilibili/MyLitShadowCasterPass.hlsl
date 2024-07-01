#ifndef MY_ShadowCasterPass_HLSL
#define MY_ShadowCasterPass_HLSL
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    struct appdata
        {
            float3 vertex : POSITION;
        };

        struct v2f
        {
            float4 posCS : SV_POSITION;

        };

        float4 _ColorTint; 
        sampler2D _MainTex; half4 _MainTex_ST;
        float _Specularint,_Metallicint,_Smoothness;

        v2f vert (appdata v)
        {
            v2f o ;

            VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
            o.posCS = posnInputs.positionCS;

            return o;
        }


        float4 frag (v2f i) : SV_TARGET
        {
            return 0 ;
        }
#endif
