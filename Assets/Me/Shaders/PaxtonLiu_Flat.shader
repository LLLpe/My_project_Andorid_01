Shader "PaxtonLiu/Flat"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
        _AlbedoInt("_AlbedoInt" , Range( 0 , 4)) = 1


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
                half4 normalOS : NORMAL;
                half4 tangent : TANGENT;
                half4 color : COLOR;
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
                half4 vertex_color : TEXCOORD7;

            };

            CBUFFER_START(UnityPerMaterial)
            half _AlbedoInt;


            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint;



            
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
                 o.vertex_color = v.color;

                return o;
            }
            //D
                float Distribution(float roughness , float ndoth)
                {
	                float lerpSquareRoughness = pow(lerp(0.002, 1, roughness), 2);
	                float D = lerpSquareRoughness / (pow((pow(ndoth, 2) * (lerpSquareRoughness - 1) + 1), 2) * PI);
	                return D;
                }
            //G
                float Geometry(float roughness , float ndotl , float ndotv)
                {
                    float k = pow(roughness + 1, 2) / 8;
                    k = max(k,0.5);
                    float GLeft = ndotl / lerp(ndotl, 1, k);
                    float GRight = ndotv / lerp(ndotv, 1, k);
                    float G = GLeft * GRight;
                    return G;
                }
            //F
                float3 FresnelEquation(float3 F0 , float ldoth)
                {
                    float3 F = F0 + (1 - F0) * pow((1.0 - ldoth),5);
                    return F;
                }
                
            half4 frag (v2f i) : SV_TARGET
            {
                // sample the texture
                half4 Albedo  = tex2D(_MainTex, i.uv).rgba * _ColorTint ;
                


                
                half4 finalcol = 1;
                finalcol.rgb = Albedo;

                return finalcol;
            }
            ENDHLSL
        }
    }
}
