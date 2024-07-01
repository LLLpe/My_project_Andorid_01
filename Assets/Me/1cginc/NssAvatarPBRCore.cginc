#ifndef NSS_AVATAR_PBR_CORE
#define NSS_AVATAR_PBR_CORE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LegacyCommon.hlsl"
#include "QSM_PBR_CORE.cginc"
#include "NssAvatarExtBRDF.cginc"
#include "NssLighting.cginc"

//-------------------------------
//-----------   SH  -------------
//-------------------------------
float3 _SH_0;
float3 _SH_1;
float3 _SH_2;
float3 _SH_3;
float3 _SH_4;
float3 _SH_5;
float3 _SH_6;
float3 _SH_7;
float3 _SH_8;

#define SHBasic0(normal) 0.2821
#define SHBasic1(normal) (-0.4886) * normal.y
#define SHBasic2(normal) 0.4886 * normal.z
#define SHBasic3(normal) (-0.4886) * normal.x
#define SHBasic4(normal) 1.09254 * normal.x * normal.y
#define SHBasic5(normal) (-1.09254) * normal.z * normal.y
#define SHBasic6(normal) (0.94617 * normal.z * normal.z - 0.31539)
#define SHBasic7(normal) (-1.09254) * normal.z * normal.x
#define SHBasic8(normal) 0.54627 * (normal.x * normal.x - normal.y * normal.y)

half3 GetSHLightintIrradiance(float3 normal)
{
    half3 SH = half3(0, 0, 0);
    SH += _SH_0 * SHBasic0(normal);
    SH += _SH_1 * SHBasic1(normal);
    SH += _SH_2 * SHBasic2(normal);
    SH += _SH_3 * SHBasic3(normal);
    SH += _SH_4 * SHBasic4(normal);
    SH += _SH_5 * SHBasic5(normal);
    SH += _SH_6 * SHBasic6(normal);
    SH += _SH_7 * SHBasic7(normal);
    SH += _SH_8 * SHBasic8(normal);

    return SH;
}

//Skin IBL SSS
half3 GetSkinSHLightintIrradiance(float3 normal, float3 D0, float3 D1, float3 D2)
{
    half3 L0 = _SH_0 * SHBasic0(normal) *  D0 * 3.5449;
    half3 L1 = (_SH_1 * SHBasic1(normal) + _SH_2 * SHBasic2(normal) + _SH_3 * SHBasic3(normal)) * D1 * 2.0466;
    half3 L2 = (_SH_4 * SHBasic4(normal) + _SH_5 * SHBasic5(normal) + _SH_6 * SHBasic6(normal) + _SH_7 * SHBasic7(normal) + _SH_8 * SHBasic8(normal)) * D2 * 1.585;

    return L0 + L1 + L2;
}

//SH wraped irradiance for cloth
half3 GetWrapedSHLightintIrradiance(float3 normal)
{
    half3 l0 = _SH_0 * SHBasic0(normal);// *1.000657/1.0 approximate *1

    half3 l1 = _SH_1 * SHBasic1(normal);
    l1 += _SH_2 * SHBasic2(normal);
    l1 += _SH_3 * SHBasic3(normal);
    //l1 *= 0.9012;//0.9012;//w==0.2 //w==0.5 0.75 
    l1 *= 0.851;
    //l1 *= 0.75;

    half3 l2 = _SH_4 * SHBasic4(normal);
    l2 += _SH_5 * SHBasic5(normal);
    l2 += _SH_6 * SHBasic6(normal);
    l2 += _SH_7 * SHBasic7(normal);
    l2 += _SH_8 * SHBasic8(normal);
    //l2 *= 0.8135;//0.2
    l2 *= 0.6432;//0.3
    //l2 *= 0.252;//0.5

    return l0 + l1 + l2;
}

//---------------------------------------------
//-----------Shading info structure------------
//---------------------------------------------

struct Context
{
    half3 H;
    half3 N;
    half3 V;

    half NdotLOri;
    half NdotL;
    half NdotV;
    half NdotH;
    half HdotV;
    half HdotL;

#ifdef ROTATE_CUBEMAP
    half3x3 rotationAroundY;
#endif

#ifdef _ANISOTROPIC_ON
    half3 tangent;
    half3 bitangent;
#endif
};

struct MaterialInfo
{
    half4 albedo;
    half perceptualRoughness;
    half metallic;
    half ao;
    
    half3 F0;
};

Context CreateContext(
    half3 N,
    half3 L,
    half3 V
    )
{
    Context context;

//#if DOUBLE_FACE
    //处理单面对象
    half NoV = dot(N, V);
    if(NoV < 0)
    {
        N = -N;
    }
//#endif

#ifdef ROTATE_CUBEMAP
    context.rotationAroundY = half3x3(
        half3(1, 0, 0),
        half3(0, 1, 0),
        half3(0, 0, 1)
    );
#endif

#ifdef _ANISOTROPIC_ON
    context.tangent = half3(1, 0, 0);
    context.bitangent = half3(0, 1, 0);
#endif

    context.H = normalize(V + L);
    context.N = N;
    context.V = V;

    context.NdotLOri = dot(N, L);
    context.NdotL = max(saturate(context.NdotLOri), 0.00001);
    context.NdotV = max(saturate(dot(N, V)), 0.00001);
    context.NdotH = max(saturate(dot(N, context.H)), 0.00001);
    context.HdotV = max(saturate(dot(context.H, V)), 0.00001);
    context.HdotL = max(saturate(dot(context.H, L)), 0.00001);

    return context;
}

MaterialInfo CreateMaterialInfo(
    half4 albedo,
    half roughness,
    half metalness,
    half ao
    )
{
    MaterialInfo matInfo;

    matInfo.albedo = albedo;
    matInfo.perceptualRoughness = max(roughness, 0.04);
    matInfo.metallic = metalness;
    matInfo.ao = ao;
    matInfo.F0 = lerp(half3(0.04,0.04,0.04), albedo.xyz, metalness);

    return matInfo;
}

//------------------------------------
//-----------Lighting info------------
//------------------------------------

// #ifdef _UNITED_LIGHTING
// half3 _SunDir;
// half3 _SunColor;
// #endif

#ifndef _UNITED_LIGHTING
half _ReflectionCubeMipNum;
samplerCUBE _ReflectionCubeMap;
#endif

#ifdef _ANISOTROPIC_ON
half _Anisotropy;
#endif

// struct DirLight
// {
// 	half3 color;
// 	half3 dir;
// };

// struct IndirectLight
// {
//     half3 diffuse;
//     half3 specular;
// };

#ifdef _UNITED_LIGHTING
DirLight CreateLight()
{
    DirLight light;

    light.color = _SunColor.rgb;
    light.dir = _SunDir;

    return light;
}
#else
DirLight CreateLight(half3 color, half3 dir)
{
    DirLight light;

    light.color = color;
    light.dir = normalize(dir);

    return light;
}
#endif

UnityIndirect CreateIndirectLight(Context context, MaterialInfo matInfo, half3 SH)
{
    UnityIndirect indirectLight;

    indirectLight.diffuse = SH;

    #ifdef _ANISOTROPIC_ON
    half3 anisotropicTangent = cross(context.bitangent, context.V);
    half3 anisotropicNormal = cross(anisotropicTangent, context.bitangent);
    half3 bentNormal = normalize(lerp(context.N, anisotropicNormal, _Anisotropy));
    half3 reflectDir = reflect(-context.V, bentNormal);
    #else
    half3 reflectDir = reflect(-context.V, context.N);
    #endif

    #if defined(ROTATE_CUBEMAP) && !defined(_UNITED_LIGHTING)
    reflectDir = mul(context.rotationAroundY, reflectDir);
    #endif

    #ifdef _UNITED_LIGHTING
	// MM: came up with a surprisingly close approximation to what the #if 0'ed out code above does.
	half perceptualRoughness = matInfo.perceptualRoughness * (1.7 - 0.7*matInfo.perceptualRoughness);    
    half mip = perceptualRoughness * 6;//half LOD_STEPS = 6;
    half4 rgbm = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDir, mip);
    indirectLight.specular = DecodeHDREnvironment(rgbm, unity_SpecCube0_HDR);
    #else
    half mip = matInfo.perceptualRoughness * _ReflectionCubeMipNum;//To match the effect of SP.
    indirectLight.specular = glossCubeLookup(_ReflectionCubeMap, reflectDir, mip).rgb;//GammaToLinear_Fast()
    #endif

    return indirectLight;
}

//----------------------------------------
//-----------PBR shading model------------
//----------------------------------------
#ifdef _CLOTH_ON
half _ScatterW;
half3 _ScatterColor;
#endif

//dir

half3 GetStandardDirLightRadiance(Context context, MaterialInfo matInfo, DirLight dirLight)
{
    half3 outRadiance = half3(0, 0, 0);
    #ifdef _CLOTH_ON
        half3 fresnel = F_Schlick_Fast(context.NdotV, matInfo.F0);
        half3 diffuse_brdf = Diffuse_Lambert(matInfo.albedo.xyz);
        half3 wrap = saturate((context.NdotLOri+_ScatterW)/((1+ _ScatterW) * (1+ _ScatterW)));
        half3 scatterLight = saturate(_ScatterColor + context.NdotL) * wrap;
        half3 diffuseColor = diffuse_brdf * scatterLight * dirLight.color.xyz * matInfo.ao * (1 - fresnel) * (1 - matInfo.metallic);
        
        half roughness = matInfo.perceptualRoughness * matInfo.perceptualRoughness;
        half3 spec_brdf = BRDF_Velvet(roughness, context.NdotH, fresnel);
        half3 specColor = spec_brdf * context.NdotL * dirLight.color.xyz;

        outRadiance = diffuseColor + specColor;
    #elif defined(_ANISOTROPIC_ON)
        half3 diffuse_brdf = matInfo.albedo.xyz;//Divide pi by radiance
        half3 fresnel = F_Schlick_Fast(context.NdotV, matInfo.F0);    
        half roughness = matInfo.perceptualRoughness * matInfo.perceptualRoughness;
        half3 spec_brdf = BRDF_GGX_Anisotropic(context.H, context.tangent, context.bitangent, context.NdotH, context.NdotL, context.NdotV, roughness, _Anisotropy, fresnel);

        outRadiance = half3((diffuse_brdf * matInfo.ao * (1 - fresnel) * (1 - matInfo.metallic)  + spec_brdf) * context.NdotL * dirLight.color.xyz);	
    #else
        half3 diffuse_brdf = matInfo.albedo.xyz;//Divide pi by radiance
        half3 fresnel = F_Schlick_Fast(context.NdotV, matInfo.F0);
        half roughness = matInfo.perceptualRoughness * matInfo.perceptualRoughness;
        half3 spec_brdf = BRDF_GGX_SMITH(context.NdotL, context.NdotV, context.NdotH, roughness, fresnel);

        outRadiance = half3((diffuse_brdf * matInfo.ao * (1 - fresnel) * (1 - matInfo.metallic)  + spec_brdf) * context.NdotL * dirLight.color.xyz);	
    #endif

    return outRadiance;			
}

//env

half3 GetStandardEnvRadiance(Context context, MaterialInfo matInfo, UnityIndirect indirectLight)
{
    half3 diffuse_brdf = matInfo.albedo.xyz;//Divide pi by SH-Irradiance map
    //half3 fresnel = F_Schlick_Fast(context.NdotV, matInfo.F0);
    half3 diffuse = diffuse_brdf * (1 - matInfo.metallic) * indirectLight.diffuse * matInfo.ao;// * (1 - fresnel) 

    half roughness = matInfo.perceptualRoughness * matInfo.perceptualRoughness;
    half3 specularBRDF = EnvBRDFApprox(matInfo.F0, roughness, context.NdotV);
    half3 spec = indirectLight.specular * specularBRDF;

    half3 envRadiance = diffuse + spec;

    return 	envRadiance;	
}
#endif
