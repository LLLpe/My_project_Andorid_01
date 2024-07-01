Shader "PC/FX/Stylized/Stylized_Fire"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 10
		//[Enum(UnityEngine.Rendering.BlendOp)] _OpColor("OpColor", Float) = 0
		[Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2

        _NoiseTex ("噪声图", 2D) = "white" {}
        _Noise1Scale("噪声缩放1", Float) = 1
        _Noise2Scale("噪声缩放2", Float) = -2
        _Noise1Speed("噪声速度1", Float) = -1
        _Noise2Speed("噪声速度2", Float) = 0.5

        //_MaskTex("MaskTex", 2D) = "white"{}
        //_GradientTex("GradientTex", 2D) = "white"{}
        //_GradientValue("GradientValue", Range(0, 1)) = 0

        _YOffset("火焰长度", Float) = 0
        _Contrast("火焰范围", Float) = 1

        _OutColorBase("焰心外焰颜色", Color) = (0, 0, 0, 1)
        _OutColorTop("焰尾外焰颜色", Color) = (0, 0, 0, 1)
        _OutColorBlend("外焰颜色混合系数", Range(0, 1)) = 0
        _InnerColor("焰心内焰颜色", Color) = (0, 0, 0, 1)

        _InnerFlameStep("内焰大小", Range(0, 1)) = 0.5
        _OpacityStep("火焰大小", Range(0, 1)) = 0.1

        _ShadingAmount("提亮范围", Range(0, 1)) = 0.5
        _Brightness("提亮", Float) = 1

        [Toggle]_EnbaleBloom("边沿Bloom(仅GB生效)", float) = 0
    }
    SubShader
    {
        // No culling or depth
        ZWrite[_ZWrite]
		Cull[_Cull]
		Blend[_SrcBlend][_DstBlend]
        ZTest[_ZTest]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //#include "../PC_CommonCore.cginc"

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Noise1Scale;
            float _Noise1Speed;
            float _Noise2Scale;
            float _Noise2Speed;
            //sampler2D _MaskTex;
            //sampler2D _GradientTex;
            //float _GradientValue;
            float _YOffset;
            float _Contrast;
            float4 _OutColorBase;
            float4 _OutColorTop;
            float4 _InnerColor;
            float _OutColorBlend;
            float _InnerFlameStep;
            float _OpacityStep;
            float _ShadingAmount;
            float _Brightness;
            float _EnbaleBloom;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wnormal : TEXCOORD1;
                float3 wpos : TEXCOORD2;
                float3 wLightDir:TEXCOORD3;
            };

            struct PixelOut2
            {
                float4 Col0 : SV_Target0 ;
                float4 Col1 : SV_Target1 ;
            };

            float3 UnityToGBVector (float3 v)
            {
            #ifdef UNITY_TO_GB 
                return float3(-v.x , -v.z,v.y);
            #else
                return v;
            #endif
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.wnormal = UnityObjectToWorldNormal(v.normal);
                o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.wLightDir = UnityObjectToWorldDir(UnityToGBVector(float3(0, 0, 1)));
                return o;
            }

            float2 Panner(float2 uv, float2 speed)
            {
                // 计算基于时间的偏移
                float2 f = speed * _Time.y;

                // 将偏移添加到原始 UV 坐标上
                float2 pannedUV = uv + f;

                return pannedUV;
            }

            float IncreaseContrast(float input, float contrast)
            {
                float pivot = 0.5f;
                float output = (input - pivot) * contrast + pivot;
                return output;
            }

            // PixelOut2 frag (v2f i) : SV_Target
            float3 frag (v2f i) : SV_Target
            {
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
                float3 N = normalize(i.wnormal);
                float3 L= normalize(i.wLightDir);

                float NdotL = dot(N, L);
                float NdotV = dot(N, V);
                //NdotV = saturate(NdotV - 0.5) * 2;
                NdotV = IncreaseContrast(NdotV, _Contrast);
                
                //return float4(NdotV, NdotV, NdotV, 1.0);
                //float mask = saturate(1.0 - tex2D(_MaskTex, float2(NdotV, i.uv.y)).r);
                //return float4(mask, mask, mask, 1.0);
                //float mask = NdotV;

                //mask *= tex2D(_MaskTex, float2(0.5, saturate(i.uv.y + _YOffset))).r;
                float mask = (1-pow(i.uv.y, _YOffset)) * NdotV;
                //return float4(mask, mask, mask, 1.0);

                float2 noiseUV = i.uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw;

                float2 speed1 = float2(0, _Noise1Speed);
                float2 scale1 = noiseUV * _Noise1Scale;
                float2 UV1 = Panner(scale1, speed1);

                float2 speed2 = float2(0, _Noise2Speed);
                float2 scale2 = noiseUV * _Noise2Scale;
                float2 UV2 = Panner(scale2, speed2);

                float noise1 = tex2D(_NoiseTex, UV1).r;
                float noise2 = tex2D(_NoiseTex, UV2).r;

                float result = noise1 * noise2;
                result += mask;
                result *= mask;

                //float3 gradient = tex2D(_GradientTex, float2(_GradientValue, 0)).rgb;
                //float3 gradient = lerp(_Color1, _Color2, mask);
                //float alpha = tex2D(_GradientTex, float2(result, 0)).a;


                float step1 = step(1-_InnerFlameStep, result);
                float step2 = step(1-_OpacityStep, result);
                float alpha = step2;
                float outBlend = smoothstep(0, _OutColorBlend, i.uv.y);
                float4 _OutColor = ((1-outBlend) * _OutColorBase) + outBlend*_OutColorTop;
                float3 final = ((1-step1) * _OutColor + step1 * _InnerColor).rgb;
                //调亮
                final = saturate(_ShadingAmount + NdotL) * final * _Brightness;
                float4 outColor1 = float4(final, alpha);
                alpha = step2 * (1-step1);

                float4 outColor2 = float4((1-step1)*_OutColor.rgb, alpha);

                PixelOut2 o;
                o.Col0 = outColor1;
                o.Col1 = lerp(float4(0, 0, 0, 0), outColor2, _EnbaleBloom);
                float4 c ;
                c = lerp(float4(0, 0, 0, 0), outColor2, _EnbaleBloom);
                return c;
            }
            ENDCG
        }
    }
}
