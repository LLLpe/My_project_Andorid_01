Shader "PaxtonLiu/HLSL_01"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
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

            float4 _ColorTint; 
            sampler2D _MainTex; half4 _MainTex_ST;

            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normalWS : TEXCOORD3;

            };


            v2f vert (appdata v)
            {
                v2f o ;
                //posOS=>CS 方法一 "ShaderVariablesFunctions.hlsl"
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.pos = posnInputs.positionCS;
                //posOS=>CS 方法二
                //o.pos = TransformObjectToHClip(v.vertex);
                
                //法线OS=>WS "ShaderVariablesFunctions.hlsl"
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                o.normalWS = normalize(normalInputs.normalWS);

                o.uv = TRANSFORM_TEX(v.uv ,_MainTex);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
                
                Light light = GetMainLight();
                float3 NdotL = dot(i.normalWS,normalize(light.direction));
                float3 halfLambert = NdotL * 0.5 + 0.5;
                // sample the texture
                float3 _ColorMap  = tex2D(_MainTex, i.uv).rgb;
                float4 finalcol = 1;
                finalcol.rgb *= _ColorMap * _ColorTint * halfLambert;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, finalcol);
                return finalcol;
            }
            ENDHLSL
        }
    }
}
