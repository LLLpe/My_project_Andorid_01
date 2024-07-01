Shader "Paxton/GlitterColor"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "Gray"{}
        _Glitter01FlowSpeed("_Glitter01FlowSpeed" , Float) = 0

		_ColorMap("颜色图", 2D) = "white" {}
		_GlitterMaskMap("密度图", 2D) = "black" {}
		_GlitterMaskStep("密度阈值", Range(0, 2)) = 0.5
		_Glitter01Tex("闪点01贴图", 2D) = "black" {}
		[HDR]_Glitter01Color("闪点颜色", Color) = (1, 1, 1, 0)
		_Glitter01Hue("饱和度", Range(0, 1)) = 0.342
		_Glitter01Intensity("强度", Range(0.1, 100)) = 42
		_Glitter01Power("对比度", Range(0.1, 2)) = 1.26
		_Glitter01OffsetSpeed("闪点速度", Range(0.1, 5)) = 0.382
		_Glitter01DotMaskSscale("闪点密度", Range(0.1, 10)) = 4.73
		_Glitter01FlowSpeed("流动速度", Range(0, 1)) = 0.16
		_Glitter01Height("高度", Range(-15, 15)) = -4
		_Glitter01InvertFresnel("边缘反向衰减", Float) = 0
		_Glitter01FresnelArea("菲涅尔区域", Range(0.02, 50)) = 1
		_Glitter01NoiseWarp("Noise扰动强度", Range(0, 1)) = 0.0


        
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
            sampler2D _ColorMap;
            sampler2D _GlitterMaskMap;
            half4 _GlitterMaskMap_ST;
            half _GlitterMaskStep;
            half4 _ColorMap_ST;
            sampler2D _Glitter01Tex;
            half4 _Glitter01Tex_ST;

            half4 _Glitter01Color;
            half _Glitter01Hue;
            half _Glitter01Intensity;
            half _Glitter01Power;
            half _Glitter01OffsetSpeed;
            half _Glitter01DotMaskSscale;
            half _Glitter01FlowSpeed;
            half _Glitter01Height;
            half _Glitter01InvertFresnel;
            half _Glitter01FresnelArea;
            half _Glitter01NoiseWarp;
            
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
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
            #include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"	



            
            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 uv3 : TEXCOORD2;
                half4 normalOS : NORMAL;
                half4 tangent : TANGENT;
                half4 color : COLOR;
            };

            struct v2f
            {
                float4 posCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 uv3 : TEXCOORD8;
                float3 posWS : TEXCOORD2;
                float3 posOS : TEXCOORD9;
                half3 normalWS : TEXCOORD3;
				half3 tangentWS: TEXCOORD4;
				half3 binormalWS: TEXCOORD5;
                half3 normalVS_uv: TEXCOORD6;
                half3 vDirTS : TEXCOORD7;
                // half4 color : TEXCOORD8;

            };
        
            
        
            v2f vert (appdata v)
            {
                v2f o ;
                //posOS=>CS  "ShaderVariablesFunctions.hlsl"
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;
                o.posOS = v.vertex;
                //o.posCS = TransformObjectToHClip(v.vertex);
                
                //法线OS=>WS "ShaderVariablesFunctions.hlsl"
                    VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                //  o.normalWS = normalize(normalInputs.normalWS);
                    o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                    half3 normalVS = mul(UNITY_MATRIX_IT_MV, v.normalOS).xyz;
                    o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                    o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.uv3 = v.uv3;
                // o.color = v.color;
                return o;
            }
            //保护参数
            half NssPow(half base,half power)
            {
                return pow(max(0.001,base), power + 0.01);
            }
            half3 GetGlitterColor(float2 uv3, half3 tsView, half NdotV)
            {
                half fresnel = abs(NdotV * 0.5 + 0.5);
                // fresnel = lerp(fresnel, 1.0 - fresnel, _Glitter01InvertFresnel);
                float fTime = fmod(_Time.y, 3600.0f) * 0.01;
                half2 uv3_ColorMap = uv3 * _ColorMap_ST.xy + _ColorMap_ST.zw;
                half4 colorMap = tex2Dlod(_ColorMap, float4(uv3_ColorMap, 0, 0.0));
        
                half4 glitter02 = 0.0;
        // #ifdef _PARALLAX_GLITTER02
        //         half glitter02Freq = (fTime * _Glitter02FlowFreq);
        //         half2 uv3_Glitter02Tex = uv3 * _Glitter02Tex_ST.xy + _Glitter02Tex_ST.zw;
        //         half2 uvGlitter02 = ((uv3_Glitter02Tex + (_Glitter02Height1 * (tsView).xy * 0.01)) * _Glitter02Tilling1);
        //         half4 glitter02_1 = abs((tex2Dlod(_Glitter02Tex, float4((glitter02Freq + uvGlitter02), 0, 0.0)) + 0.2));
        //         half2 appendResult620 = (half2((glitter02Freq * -1.0), (glitter02Freq * -1.1353)));
        //         half4 glitter02_2 = abs((0.2 + tex2Dlod(_Glitter02Tex, float4((half3(appendResult620, 0.0) + half3(uvGlitter02, 0.0) + (tsView * 0.05 * _Glitter02shinFreq)).xy, 0, 0.0))));
        //         glitter02 = (NssPow(glitter02_1, _Glitter02Power) * NssPow(glitter02_2, _Glitter02Power) * _Glitter02Color * _Glitter02Intensity) * NssPow(fresnel, _Glitter02FresnelArea);
        
        //         half4 glitter02Color = lerp((1.0).xxxx, colorMap, _Glitter02Hue);
        //         glitter02 = glitter02 * NssPow((glitter02Color + 0.2), 8.0);
        // #endif
        
                half2 glitter01Parallax = _Glitter01Height * tsView.xy * 0.01;
                half2 uv3_Glitter01Tex = uv3 * _Glitter01Tex_ST.xy + _Glitter01Tex_ST.zw;
                half glitter01Freq = (fTime * _Glitter01FlowSpeed);
                half4 glitter01_1 = tex2Dlod(_Glitter01Tex, float4(((half3(glitter01Parallax, 0.0) + half3(uv3_Glitter01Tex, 0.0) + (tsView * 0.05 * _Glitter01OffsetSpeed) + glitter01Freq) * (_Glitter01OffsetSpeed * 0.5 + 1.0) * _Glitter01DotMaskSscale).xy, 0, 0.0));
                
                float2 uv3_Glitter01Tex2 = (uv3_Glitter01Tex + ((tsView).xy * -0.05 * _Glitter01OffsetSpeed) + glitter01Parallax) - half2(0.5, 0.5);
                half cosAngle = cos(3.14);
                half sinAngle = sin(3.14);
                uv3_Glitter01Tex2 = mul(uv3_Glitter01Tex2, float2x2(cosAngle, -sinAngle, sinAngle, cosAngle));
                half4 glitter01_2 = tex2Dlod(_Glitter01Tex, float4(((uv3_Glitter01Tex2 + half2(0.5, 0.5) + glitter01Freq) * (1.0 - (_Glitter01OffsetSpeed / 3.14)) * _Glitter01DotMaskSscale), 0, 0.0));
                half3 glitter01 = lerp(NssPow(((_Glitter01Intensity * glitter01_1 * _Glitter01Color)).rgb, _Glitter01Power), float3(0, 0, 0), (1.0 - glitter01_2).rgb);
                glitter01 = (glitter01 * NssPow(fresnel, _Glitter01FresnelArea));

                half4 glitter01Color =(1.0).xxxx;
                glitter01Color = lerp(1, colorMap, _Glitter01Hue);
                glitter01Color = pow((max(0.01 , glitter01Color) + 0.2), 8.0);
                glitter01 = glitter01 * glitter01Color;
        
                // half4 glitter03 = 0.0;
        // #ifdef _PARALLAX_GLITTER03
        //         half2 uv3_Glitter03Tex = uv3 * _Glitter03Tex_ST.xy + _Glitter03Tex_ST.zw;
        //         glitter03 = (tex2Dlod(_Glitter03Tex, float4((uv3_Glitter03Tex + (_Glitter03Height * (tsView).xy * 0.01)), 0, 0.0)) * _Glitter03Intensity);
        // #endif
        
                // half4 GlitterAllLayer = glitter02 + half4(glitter01, 0.0) + glitter03;
                // GlitterAllLayer.rgb = clamp(GlitterAllLayer.rgb, 0.0, 1000.0);
        
                // return glitter01Color.xyz;
                return glitter01;
            }


            half4 frag (v2f i) : SV_TARGET
            {

            float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
            float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
            float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );
            half3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
            float3x3 worldToTangent = float3x3(tanToWorld0,tanToWorld1,tanToWorld2);

            //vDirTS

            half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
            half3 vDirTS = normalize(mul(vDirWS,worldToTangent));
            half3 nDirWS = i.normalWS;
            half NdotV = dot(nDirWS,vDirWS);

            half4 c;
            half3 basecolor = tex2D( _MainTex , i.uv);
            half3 GlitterColor = GetGlitterColor(i.uv3, vDirTS, NdotV);
            c.xyz =  GlitterColor ;
            
            return  c ;
            }
            ENDHLSL
        }
    }
}