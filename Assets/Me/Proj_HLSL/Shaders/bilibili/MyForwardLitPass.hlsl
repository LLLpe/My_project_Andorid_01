#ifndef MY_ForwardLitPass_HLSL
#define MY_ForwardLitPass_HLSL
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

        float4 _ColorTint; 
        sampler2D _MainTex; half4 _MainTex_ST;
        float _Specularint,_Metallicint,_Smoothness;

        v2f vert (appdata v)
        {
            v2f o ;
            //posOS=>CS 方法一 "ShaderVariablesFunctions.hlsl"
            VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
            o.posCS = posnInputs.positionCS;
            o.posWS = posnInputs.positionWS;
            //posOS=>CS 方法二
            //o.pos = TransformObjectToHClip(v.vertex);
            
            //法线OS=>WS "ShaderVariablesFunctions.hlsl"
            VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
            o.normalWS = normalize(normalInputs.normalWS);

            o.uv = TRANSFORM_TEX(v.uv ,_MainTex);

            return o;
        }

        // float4 frag (v2f i) : SV_TARGET
        // {
        //     
        //     Light light = GetMainLight();
        //     float3 NdotL = dot(i.normalWS,normalize(light.direction));
        //     float3 halfLambert = NdotL * 0.5 + 0.5;
        //     // sample the texture
        //     float3 _ColorMap  = tex2D(_MainTex, i.uv).rgb;
        //     float4 finalcol = 1;
        //     finalcol.rgb *= _ColorMap * _ColorTint * halfLambert;
        //     // apply fog
        //     //UNITY_APPLY_FOG(i.fogCoord, finalcol);
        //     return _ColorTint;
        // }
        float4 frag (v2f i) : SV_TARGET
        {
            float2 uv = i.uv;
            float4 _ColorMap  = tex2D(_MainTex, i.uv);
            
            InputData lightingInput = (InputData)0;
            lightingInput.positionWS = i.posWS;
            lightingInput.normalWS = i.normalWS;
            lightingInput.viewDirectionWS = GetWorldSpaceViewDir(i.posWS);
            lightingInput.shadowCoord = TransformWorldToShadowCoord(i.posWS);
            
            SurfaceData surfaceInput = (SurfaceData)0;
            surfaceInput.albedo = _ColorMap * _ColorTint;
            surfaceInput.alpha = _ColorMap.a;
            surfaceInput.specular = _Specularint;
            surfaceInput.metallic = _Metallicint;
            surfaceInput.smoothness = _Smoothness;
            
            
            #if UNITY_VERSION >= 202120
                return UniversalFragmentBlinnPhong(lightingInput,surfaceInput);
            #else
                return UniversalFragmentBlinnPhong(lightingInput,surfaceInput);
            #endif
        }
#endif
