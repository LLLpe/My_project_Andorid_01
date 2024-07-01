Shader "Test/StyleFeature_Paxton"
{
    Properties
    {
    	// [KeywordEnum(Body,Face)] _ShaderEnum("Shader类型", int) = 0
        [MainTexture]_MainTex("Color" , 2D) = "black"{}
        _IOR0("IOR",Range(0,1)) = 0.05
        _Color("颜色01", COLOR) = (1.00, 1.00, 1.00, 1.00)
        _lightMap("lightMap 水晶Mask G:Gloss B: 高光Mask "  ,2D) = "white"{}
        _CommonSpecColor("高光颜色"  ,COLOR) = (0, 0, 0, 0)
    	// _RampTexSpec("RampTexSpec",2D) = "white"{}
        _NormalMap("Normal贴图"  ,2D) = "bump"{}
        _NormalIntensity("法线强度",Range(0,1)) = 1
        _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 1
//        [Maincolor]_ColorTint("Tint" , color) = (1,1,1,1)
//        _AlbedoInt("_AlbedoInt" , Range( 0 , 4)) = 1
		// _Color2("_Color2", COLOR) = (1, 1, 1, 1)
		// _Color3("_Color3", COLOR) = (1, 1, 1, 1)
		// _Color4("_Color4", COLOR) = (1, 1, 1, 1)
		// _Color5("_Color5", COLOR) = (1, 1, 1, 1)
        
        [Space(20)]
	    [Header(Shadow)]
        [Space(10)]
        //        _ShadowRampToggle("_ShadowRampToggle", Float) = 0
        _ShadowThreshold     ("阴影范围"  ,Range( 0.2 , 0.8)) = 0.75
        _ShadowHardness      ("阴影硬度"  ,Range( 5, 15)) = 10
        //		_ShadowRampWidth("_ShadowRampWidth", Float) = 1
        //		_LightArea("_LightArea", Range(0, 1)) = 0.5
		_ShadowMultColor("阴影颜色01", COLOR) = (1, 1, 1, 1.0)
		// _ShadowMultColor2("_ShadowMultColor2", COLOR) = (0.53405, 0.35817, 0.34012, 1.0)
		// _ShadowMultColor3("_ShadowMultColor3", COLOR) = (0.7816, 0.7816, 0.7816, 1.0)
		// _ShadowMultColor4("_ShadowMultColor4", COLOR) = (0.78741, 0.44799, 0.52252, 1.0)
		// _ShadowMultColor5("_ShadowMultColor5", COLOR) = (0.78741, 0.44799, 0.52252, 1.0)
    	
        [Space(20)]
        [Header(Metal)]
        [Space(10)]
        _MetalMap("MetalFactor",2D) = "Black"{}
        _MetalIntensity("金属度强度", Range( 0 , 1)) = 1


        
        
        [Space(20)]
        [Header(Crystal)]
        [Space(10)]
        _CrystalMap("水晶贴图",2D) = "black"{}
        [HDR]_CrystalColor("水晶颜色" , color) = (1,1,1,1)
        _IOR("IOR",Range(0,1)) = 0.3
        _CrystalOffset("水晶纹理偏移",Range(0,1)) = 0
        _CrystalBlend("混合度",Range(0,1)) = 0.75
        _DiffInt("颜色混合强度",Range(0,1)) = 0.5
        _CrystalContra("对比度",Range(0,1)) = 1
        
        [Space(20)]
        [Header(CrystalHardSpec)]
        [Space(10)]
        [HDR]_SpecColor("高光颜色"  ,COLOR) = (0, 0, 0, 0)
        _SpecSize("高光大小"  ,Range( 0 , 0.5)) = 0.2
        _SpecSmooth("高光过渡"  ,Range( 0 , 0.1)) = 0.0
        _LOffset("高光偏移",Float) = (0,0,0,0)
        _SpecSize2("高光大小2"  ,Range( 0 , 0.5)) = 0.2
        _SpecSmooth2("高光过渡"  ,Range( 0 , 0.1)) = 0.0
        _LOffset2("高光偏移2",Float) = (0,0,0,0)

        [Space(20)]
        [Header(Reflection)]
        [Space(10)]
        [NoScaleOffset]_ReflectMap("反射贴图",2D) = "black"{}
        [HDR]_ReflectColor("颜色",COLOR) = (1, 1, 1, 1)
        _Reflectfreq("反射频率",Range( 0 , 1)) = 1
        
        
        [Space(20)]
        [Header(RimColor)]
        [Space(10)]
        [HDR]_RimColor("边缘光颜色" , color) = (1,1,1,1)
        _RimRadius("边缘光范围", Range( 0 , 5)) = 1
        _RimIntensity("边缘光硬度", Range( 0 , 0.5)) = 0




    }
    

    HLSLINCLUDE	
    #include "Assets/ResForAssetBundles/0BaseCommon/Include/QSM_COLORSPACE_CORE.cginc"		
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

   ENDHLSL

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

            

            struct appdata
            {
                half3 vertex : POSITION;
                half2 uv : TEXCOORD0;
                half3 normalOS : NORMAL;
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
            half _IOR0;

            half3 _CommonSpecColor;

            half4 _Color;
			half4 _Color2;
			half4 _Color3;
			half4 _Color4;
			half4 _Color5;

            float3 _ShadowMultColor;
			float3 _ShadowMultColor2;
			float3 _ShadowMultColor3;
			float3 _ShadowMultColor4;
			float3 _ShadowMultColor5;
            
			half _MetalIntensity;
            half _Bump;
            half _Routhness;

            half _Matelness;
            half _NormalIntensity;
            half _env_specInt;
            half _ShadowThreshold;
            half _ShadowHardness;
            
            half3 _SpecColor;
            half _HardSpecInt;
            half _SpecSmooth;
            half _SpecSmooth2;
            half _SpecSize;
            half _SpecSize2;
            half _HardSpecInt2;
            // half _SpecSize2;
            // half _specHardness2;
            half3 _LOffset;
            half3 _LOffset2;
            
            half3 _SpecDarkColor;
            half _SpecIntensity;
            half3 _RimLightDir;
            half3 _RimLightColor;
            half _SmoothstepMin;
            half _SmoothstepMax;
            half3 _HardSpecCol;
            half3 _HardSpecCol2;

            half3 _CrystalColor;
            half _IOR;
            half _CrystalOffset;
            // half _CrystalInt;
            half _CrystalBlend;
            half _DiffInt;
            half _CrystalContra;

            half _Reflectfreq;
            half3 _ReflectColor;
            
            half _NormalDetilIntensity;
            
            half3 _RimColor;
            half _RimRadius;
            half _RimIntensity;

            // half _A;
            // half _B;
            
			CBUFFER_END

            sampler2D _MainTex; half4 _MainTex_ST;
            half4 _ColorTint;
            sampler2D _MetalMap;
            // sampler2D _RimMap;
            sampler2D _NormalMap;half4 _NormalMap_ST;
            sampler2D _NormalDetil;half4 _NormalDetil_ST;
            sampler2D _RampTex;
            sampler2D _RampTexSpec;
            sampler2D _lightMap; half4 _lightMap_ST;
            sampler2D _BaseMap; 
            sampler2D _SSSMap; 
            sampler2D _ILMMap; 
             
            sampler2D _CrystalMap; half4 _CrystalMap_ST;
            sampler2D _ReflectMap; 
            
            
            
            
            
           

            half3 NPR_Base_Ramp (half NdotL,sampler2D RampTex, half4 lightMap, half RampRange)
            {
                half halfLambert = smoothstep(0,0.5,NdotL) * lightMap.g * 2;
                //halfLambert = smoothstep(0,0.5,NdotL) * 1;
                 //halfLambert = NdotL * 0.5 + 0.5;
                 //halfLambert = NdotL;

                /* 
                Skin = 1.0
                Silk = 0.7
                Metal = 0.5
                Soft = 0.3
                Hand = 0.0
                */
                
                    return tex2D(RampTex ,half2(halfLambert, RampRange)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
                    return halfLambert; 
                    return NdotL; 
                    //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
            }
            
            half3 NPR_Base_Specular(half NdotL,half NdotH ,sampler2D RampTex,half3 baseColor,half metallic, half specular,half3 MetalFactor)
            {
                half Ks = 0.04;
                half  SpecularPow = exp2(0.5 * metallic * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
                half  SpecularNorm = (SpecularPow+8.0) / 8.0;
                half3 SpecularColor =  baseColor * specular;
                 SpecularColor = lerp(half3(0.3, 0.3, 0.3), baseColor,  0.1) * specular;
                half SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));
                 
                 half halfLambert = max(0,NdotL * 0.5 + 0.5);
                half SpecRamp = tex2D(RampTex ,half2(halfLambert, 0.2)).rgb;
                 
                 MetalFactor *= lerp(_MetalIntensity * 5,_MetalIntensity  * 10, metallic) * specular * 0.3 ;
                half3 MetalSpecColor = MetalFactor * baseColor * step(0.95,metallic);
                return MetalSpecColor * 1 ;
                return MetalFactor;

            }

            half3 NPR_Specular2(half NdotL,half NdotH ,sampler2D RampTex,half3 baseColor,half metallic, half specular,half3 MetalFactor)
            {
                half Ks = 0.04;
                half  SpecularPow = exp2(0.5 * metallic * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
                half  SpecularNorm = (SpecularPow+8.0) / 8.0;
                half3 SpecularColor =  baseColor * specular;
                 SpecularColor = lerp(half3(0.3, 0.3, 0.3), baseColor,  0) *specular;
                half SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));
                 
                 half halfLambert = max(0,NdotL * 0.5 + 0.5);
                half SpecRamp = tex2D(RampTex ,half2(halfLambert, 0.2)).rgb;
                //原神的金属贴图（这里我使用了一种拟合曲线来模拟）
                // half MetalDir = normalize(mul(UNITY_MATRIX_V,normalDir));
                // half MetalRadius = saturate(1 - MetalDir) * saturate(1 + MetalDir);
                // half MetalFactor = saturate(step(0.5,MetalRadius)+0.25) * 0.5 * saturate(step(0.15,MetalRadius) + 0.25)  ;
                //简单方法是直接采样
                 MetalFactor *= lerp(_MetalIntensity * 5,_MetalIntensity  * 10, metallic) ;
                half3 MetalColor = MetalFactor * baseColor * step(0.95,metallic);
                return MetalColor * SpecularColor ;
                return SpecularColor.b ;
                return MetalColor;
                //return SpecularColor * (SpecularContrib  * NdotL* Ks * lightMap.g + MetalColor) ;
                return SpecRamp;
            }
            

            half3 NPR_Crystal(half3 VDirTS,half3 NDirTS,half IOR,sampler2D CrystalMap,float2 uv,
                half CrystalInt,half CrystalContra ,half3 _CrystalColor)
             {
                 //NDirTS = float3(0,0,1);
                 half3 Refract = refract(VDirTS,NDirTS,pow(IOR ,2));
                 half2 Refract_xy = Refract.xy/Refract.z; 
                 float2  Crystaluv1 = uv * float2(1,1) + Refract_xy;
                 float2  Crystaluv2 = uv * float2(1 + _CrystalOffset , 1 + _CrystalOffset) + Refract_xy;
                 half CrystalCol1 = tex2D(CrystalMap,Crystaluv1).r * CrystalInt ;
                 half CrystalCol2 = lerp(0.5, tex2D(CrystalMap,Crystaluv2).r , CrystalContra) *CrystalInt;
                 half CrystalCol = CrystalCol1 * CrystalCol2;
                 return CrystalCol * _CrystalColor;
             }

             float3 NPR_RimLight_Base(float NdotV,float3 RimColor)
             {
                half3 F = saturate(1 -NdotV );
                F = clamp(pow(F, _RimRadius)  ,0 , 1)  ;
                F = smoothstep( _RimIntensity , 1 - _RimIntensity , F ) * RimColor;
                return F;
                //  return ( smoothstep(1 - NdotV,_RimRadius , clamp_RimRadius + _RimIntensity,))  * RimColor;
             }
            
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
                
				half4 normal = half4(v.normalOS,0);
				half4 normalWS = half4(o.normalWS,0);
				half3 normalVS = mul(UNITY_MATRIX_V, normalWS).xyz;
				o.normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;

                o.tangentWS = normalize(mul(UNITY_MATRIX_M, half4(v.tangent.xyz, 0.0)).xyz);
                 o.binormalWS = normalize(cross(o.normalWS, o.tangentWS) * v.tangent.w); // tangent.w is specific to Unity
                o.uv = TRANSFORM_TEX(v.uv ,_MainTex);
                 o.vertex_color = v.color;

                return o;
            }
                
            half4 frag (v2f i) : SV_TARGET
            {
                float3 tanToWorld0 = float3( i.tangentWS.x, i.binormalWS.x, i.normalWS.x );
				float3 tanToWorld1 = float3( i.tangentWS.y, i.binormalWS.y, i.normalWS.y );
                float3 tanToWorld2 = float3( i.tangentWS.z, i.binormalWS.z, i.normalWS.z );
                float3x3 worldToTangent = float3x3(tanToWorld0,tanToWorld1,tanToWorld2);
                float3x3 tangent2World = half3x3(i.tangentWS,i.binormalWS ,i.normalWS);
                
                half4 shadowCoord = TransformWorldToShadowCoord(i.posWS);
                Light light = GetMainLight(shadowCoord);
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 vDirWSOffst = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz + _LOffset);
                half3 vDirTS = normalize(mul(vDirWS,worldToTangent));
                
                float2 uv_nDir = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                half3 nDirTS = UnpackNormal(tex2D(_NormalMap,uv_nDir));
                // half3 nDirTS = tex2D(_NormalMap,uv_nDir);
                nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);
                
                half3 Refract = refract(vDirTS,nDirTS,pow(_IOR ,2));
                half2 Refract_xy = Refract.xy/Refract.z; 

                float2 uv_nDirTSD = (i.uv + Refract_xy ) * _NormalDetil_ST.xy + _NormalDetil_ST.zw;
                half3 nDirTSD = UnpackNormal(tex2D(_NormalDetil,uv_nDirTSD));
                // half3 nDirTSD = tex2D(_NormalDetil,uv_nDirTSD);
                nDirTSD = lerp(float3(0,0,1),nDirTSD,_NormalDetilIntensity);
                
                //混合
                // nDirTS = nDirTS * float3(2,2,2) + float3(-1, -1, 0);
                // nDirTSD = nDirTSD * float3(-2,-2,2) + float3(1, 1, -1);
                // float3 nDirTSBlend = nDirTS * dot(nDirTS,nDirTSD)/nDirTS.z - nDirTSD;
                float3 nDirTSBlend = normalize(nDirTS + nDirTSD);

                half3 nDirWS = normalize(mul(nDirTSBlend,tangent2World));

                half3 normalVS = mul(UNITY_MATRIX_V, nDirWS).xyz;
                half3 normalVS_uv;
                normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                half3 uv_Matcap =  normalVS_uv ;
                //uv_Matcap.xy += nDirTS.xy * _Bump;
                
                half NdotL = dot(nDirWS,normalize(light.direction));
                NdotL = max(0,NdotL);
                half NdotV = dot(nDirWS,vDirWS);
                half NdotVOffSet = dot(nDirWS,vDirWSOffst);
                half NdotH = dot(nDirWS,normalize(light.direction + vDirWS));
                half NdotHOffSet = dot(nDirWS,normalize(light.direction + vDirWS + _LOffset));
                half NdotHOffSet2 = dot(nDirWS,normalize(light.direction + vDirWS + _LOffset2));
                NdotH = max(0,NdotH);
                half halfLambert = smoothstep(0,0.5,NdotL);
                
                
                // sample the texture
                // half2 uv_mainTex = i.uv + Refract_xy0;
                half4 mainTex  = tex2D(_MainTex, i.uv).rgba ;
                half4 lightMap = tex2D(_lightMap,i.uv);
                half ao = i.vertex_color.r;
            	
                //shadow范围
                half lambert_term = halfLambert * ao ; //shadow_control就是上面所说的阴影倾向权重
                half toon_diffuse = saturate((lambert_term - _ShadowThreshold) * _ShadowHardness);  //色阶化处理得到亮暗部分mask

            	//shadow颜色
                half rampLayer = lightMap.a;
				half tightsLayer = step(abs(rampLayer - 0.7), 0.015); //5
				half softLayer = (1.0 - tightsLayer) * step(abs(rampLayer - 0.3), 0.015);//4
				half metalLayer = (1.0 - softLayer) * step(abs(rampLayer - 0.5), 0.015); //3
				half skinLayer = (1.0 - metalLayer) * step(abs(rampLayer - 0.9), 0.015); //2
				half hardLayer = saturate(1.0 - (tightsLayer + softLayer + metalLayer + skinLayer));//1

				mainTex.xyz *= (_Color.xyz * hardLayer + _Color2.xyz * skinLayer + _Color3.xyz * metalLayer + _Color4.xyz * softLayer + _Color5 * tightsLayer);
				float3 shadowRamp = (_ShadowMultColor.xyz * hardLayer + _ShadowMultColor2.xyz * skinLayer + _ShadowMultColor3.xyz * metalLayer + _ShadowMultColor4.xyz * softLayer + _ShadowMultColor5.xyz * tightsLayer);
                
                

            	half brightScale = 1;
            	half brightArea = brightScale;
                half var_Spec = lightMap.r ;
            	
            	half3 diffuseColor = lerp(shadowRamp * mainTex.xyz, mainTex.xyz, toon_diffuse) * _Color;
                half3 specular = pow(max(0,NdotHOffSet),lightMap.g * 100) * var_Spec * _CommonSpecColor ;
                specular = clamp(specular , 0 , 1);
                //高光点
                // half a = step( _B + 0.1, lightMap.r ) ;
                // half MetaMask = step(0.95,lightMap.r);

                //分Mask
                // half MetaMask = step(abs(lightMap.r - 1), 0.1);
                // half CrystalMask = step(0.98,lightMap.r );//4
                half MetaMask = step(abs(lightMap.r - 1), 0.1);
                half CrystalMask = (1.0 - MetaMask) * step(abs(lightMap.r - 0.8), 0.015);//4

                // half CrystalMask =  step(abs(lightMap.r - _B), 0.015);//4
                // float CrystalMask =  step(MetaMask , abs(lightMap.r - _B)) ;//4
                //  CrystalMask *=  a;//4
                //  CrystalMask0-= CrystalMask;

                // // half HardSpec_term = smoothstep(0.1,1-_specHardness,lightMap.b * pow(NdotV,200* (1 - _SpecSize)) * step(0.95,lightMap.r) ) ;
                // half3 Var_SpecRamp = tex2D(_RampTexSpec ,pow(NdotH,10) );
                // half HardSpec_term = lightMap.b * Var_SpecRamp.r * step(0.95,lightMap.r)  ;
            	// // half HardSpec_term2 = smoothstep(0.1,1-_specHardness2,lightMap.b * pow(NdotV,800* (1 - _SpecSize2 )) * step(0.95,lightMap.r) ) ;
            	// half HardSpec_term2 = lightMap.b * Var_SpecRamp.g * step(0.95,lightMap.r)  ;
                // // HardSpec_term2 = saturate(HardSpec_term2 * 10 );
                // half HardSpec = HardSpec_term * _HardSpecInt * _HardSpecCol  + HardSpec_term2 * _HardSpecInt2 * _HardSpecCol2;
                // HardSpec *= NdotL ;

                //高光点2
                half SpecSize = 1 - _SpecSize;
                half SpecSize2 = 1 - _SpecSize2;
                half HardSpec_term = smoothstep( SpecSize * var_Spec, clamp((SpecSize + _SpecSmooth),0,1) , clamp(pow(NdotHOffSet , 1 ),0,1)  );
                half HardSpec_term2 = smoothstep( SpecSize2 * var_Spec, clamp((SpecSize2 + _SpecSmooth2),0,1) ,clamp(pow(NdotHOffSet2 , 1 ),0,1)  );
                HardSpec_term += HardSpec_term2 ;
                HardSpec_term *= _SpecColor ;

                
                //YS金属
                half metalFact = tex2D(_MetalMap,uv_Matcap).r;
                half3 SpecularColor = lerp(half3(0.3, 0.3, 0.3), diffuseColor,  0.1) * var_Spec;
                 metalFact *= SpecularColor *  MetaMask * 10 ;
                half3 MetalSpecColor = metalFact * diffuseColor ;


                //动漫水晶
                float2 uv_CrystalMap = i.uv * _CrystalMap_ST.xy + _CrystalMap_ST.zw;
                half3 CrystalCol = NPR_Crystal(vDirTS,float3(0,0,1),_IOR,_CrystalMap ,uv_CrystalMap , 1 , _CrystalContra, _CrystalColor);
                CrystalCol = lerp(mainTex , mainTex * _DiffInt + CrystalCol * _CrystalBlend * 2,_CrystalBlend ) ;


                //MatCap菲涅尔
                half3 Fresnel = NPR_RimLight_Base(NdotV,_RimColor);


                //Matcap环境镜面反射
                half4 var_ReflectMap  = tex2D(_ReflectMap,  uv_Matcap.xy * _Reflectfreq );
                half envReflect = var_ReflectMap.r  ;
                half3 encRefCol = envReflect *_ReflectColor ;
                CrystalCol +=encRefCol + Fresnel + HardSpec_term ;

                
                half3 NPRMetaSpec = lerp(diffuseColor , MetalSpecColor, _MetalIntensity);//进行混合
            	NPRMetaSpec += HardSpec_term;

                
                
                //rimdark
                half rimdark_term = smoothstep(_SmoothstepMin,_SmoothstepMax,NdotV);
                rimdark_term = lerp( 1 ,rimdark_term, 1- toon_diffuse);
                half3 GBVSrim2 = rimdark_term * _RimLightColor;

                half4 finalcol = 1;
                half3 BlinnPhong = diffuseColor + specular;
                // finalcol.rgb = lerp(BlinnPhong, NPRMetaSpec , MetaMask);
                finalcol.rgb = lerp(BlinnPhong , CrystalCol , CrystalMask) ;

                finalcol.rgb = CrystalCol;
                // return NdotL * CrystalCol.x;
                // return MetaMask;
                // return CrystalMask;
                // return half4(0,CrystalMask ,0 , 1);
                // return half4(diffuseColor.r,diffuseColor.r,diffuseColor.r,1.0);
                return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalcol.rgb,1.0));
            }
            ENDHLSL
        }
    }
}
