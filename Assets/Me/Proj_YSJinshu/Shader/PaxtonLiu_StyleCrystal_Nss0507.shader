Shader "Test/StyleCrystal_Paxton0507"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "black"{}
        _lightMap("CrystalMask&Spec(R) Gloss(G) ", 2D) = "white" {}
        _NormalMap("Normal贴图"  ,2D) = "bump"{}
        _NormalIntensity("法线强度",Range(0,1)) = 1
        // _NormalDetil("细节法线贴图"  ,2D) = "bump"{}
        // _NormalDetilIntensity("细节法线强度", Range( 0 , 2)) = 1
        _CommonSpecColor("高光强度",Range(0,1)) = 1

        [Space(20)]
	    [Header(Shadow)]
        [Space(10)]
        _ShadowThreshold     ("阴影范围"  ,Range( 0.2 , 0.8)) = 0.75
        _ShadowHardness      ("阴影硬度"  ,Range( 5, 15)) = 10
		_ShadowMultColor("阴影颜色01", COLOR) = (1, 1, 1, 1.0)

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

        
            half3 _ShadowMultColor;
            half _CommonSpecColor;
            

            half _NormalIntensity;
            half _ShadowThreshold;
            half _ShadowHardness;
            
            half3 _SpecColor;
            half _SpecSmooth;
            half _SpecSmooth2;
            half _SpecSize;
            half _SpecSize2;
            half3 _LOffset;
            half3 _LOffset2;
            

            half3 _CrystalColor;
            half _IOR;
            half _CrystalOffset;
            half _CrystalBlend;
            half _DiffInt;
            half _CrystalContra;

            half _Reflectfreq;
            half3 _ReflectColor;
            
            // half _NormalDetilIntensity;
            
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
             }
            
            v2f vert (appdata v)
            {
                v2f o ;
                VertexPositionInputs posnInputs = GetVertexPositionInputs(v.vertex);
                o.posCS = posnInputs.positionCS;
                o.posWS = posnInputs.positionWS;
                
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
                half3 nDirTS = UnpackNormalScale(tex2D(_NormalMap,uv_nDir) , _NormalIntensity);
                // nDirTS = lerp(float3(0,0,1),nDirTS,_NormalIntensity);
                
                half3 Refract = refract(vDirTS,nDirTS,pow(_IOR ,2));
                half2 Refract_xy = Refract.xy/Refract.z; 

                // float2 uv_nDirTSD = (i.uv + Refract_xy ) * _NormalDetil_ST.xy + _NormalDetil_ST.zw;
                // half3 nDirTSD = UnpackNormal(tex2D(_NormalDetil,uv_nDirTSD));
                // nDirTSD = lerp(float3(0,0,1),nDirTSD,_NormalDetilIntensity);
                
                //混合
                // float3 nDirTSBlend = normalize(nDirTS + nDirTSD);
                half3 nDirWS = normalize(mul(nDirTS,tangent2World));
                half3 normalVS = mul(UNITY_MATRIX_V, nDirWS).xyz;
                half3 normalVS_uv;
                normalVS_uv.xy = normalize(normalVS).xy * 0.5 + 0.5;
                half3 uv_Matcap =  normalVS_uv ;
                
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
                half4 mainTex  = tex2D(_MainTex, i.uv).rgba ;
                half4 lightMap = tex2D(_lightMap,i.uv);
                half ao = i.vertex_color.r;
            	
                //shadow
                half lambert_term = halfLambert * ao ; //shadow_control就是上面所说的阴影倾向权重
                half toon_diffuse = saturate((lambert_term - _ShadowThreshold) * _ShadowHardness);  //色阶化处理得到亮暗部分mask
            	half3 diffuseColor = lerp(_ShadowMultColor * mainTex.xyz, mainTex.xyz, toon_diffuse) ;

                //BlinnPhong
                half var_Spec = lightMap.r - 0.03 ;
                half3 specular = pow(max(0,NdotHOffSet),lightMap.g * 100) * var_Spec * _CommonSpecColor ;
                specular = clamp(specular , 0 , 1);
                half3 BlinnPhong = diffuseColor + specular;

                half CrystalMask = step(0.98 , lightMap.r );

                //高光点2
                half SpecSize = 1 - _SpecSize;
                half SpecSize2 = 1 - _SpecSize2;
                half HardSpec_term = smoothstep( SpecSize * var_Spec, clamp((SpecSize + _SpecSmooth),0,1) , NdotHOffSet  );
                half HardSpec_term2 = smoothstep( SpecSize2 * var_Spec, clamp((SpecSize2 + _SpecSmooth2),0,1) , NdotHOffSet2  );
                HardSpec_term += HardSpec_term2 ;
                HardSpec_term *= _SpecColor;


                //动漫水晶
                float2 uv_CrystalMap = i.uv * _CrystalMap_ST.xy + _CrystalMap_ST.zw;
                half3 CrystalCol = NPR_Crystal(vDirTS,float3(0,0,1),_IOR,_CrystalMap ,uv_CrystalMap , 1 , _CrystalContra, _CrystalColor);
                CrystalCol = lerp(mainTex , mainTex * _DiffInt + CrystalCol * _CrystalBlend * 2,_CrystalBlend ) ;

                //MatCap菲涅尔
                half3 Fresnel = NPR_RimLight_Base(NdotV,_RimColor);

                //Matcap环境镜面反射
                half4 var_ReflectMap  = tex2D(_ReflectMap,  uv_Matcap.xy * _Reflectfreq );
                half envReflect = var_ReflectMap.r * var_Spec   ;
                half3 encRefCol = envReflect *_ReflectColor ;
                CrystalCol +=encRefCol + Fresnel + HardSpec_term ;             

                
                half4 finalcol = 1;
                finalcol.rgb = lerp(BlinnPhong , CrystalCol , CrystalMask) ;

                // finalcol.rgb = CrystalCol;
                return NSS_OUTPUT_COLOR_SPACE_CHARACTER(half4(finalcol.rgb,1.0));
            }
            ENDHLSL
        }
    }
}
