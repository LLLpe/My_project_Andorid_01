#ifndef  CUSTOM_LIGHTING_INCLUDE
#define  CUSTOM_LIGHTING_INCLUDE

#ifndef SHADERGRAPH_PREVIEW
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif
#endif

struct CustomLightingData
{
    half3 normalWS;
    half3 albedo;
    half3 vDirWS;
    half smoothness;
    half4 shadowCoord;
    half3 posWS;
    half ao;
    half3 bakedGI; //Lighting

};

half GetSmoothnessPower(half smoothness)
{
    return exp2(10 * ( 1 - smoothness ));
}

#ifndef SHADERGRAPH_PREVIEW

half3 CustomLightHandling(CustomLightingData d , Light light)
{
    half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation); //灯光 + 阴影
    half diffuse = saturate(dot(d.normalWS,light.direction));
    half specularDot = saturate(dot(d.normalWS,normalize(light.direction + d.vDirWS)));
    half specular = pow(specularDot,GetSmoothnessPower(d.smoothness) ) * diffuse;
    //half specular = specularDot * diffuse;
    
    half3 color = d.albedo * radiance * (diffuse + specular);

    return  color;
}
#endif


half3 CaculateCustomLighting(CustomLightingData d){
#ifdef SHADERGRAPH_PREVIEW
    half3 lightDir = half3(0.5, 0.5, 0);
    half intensity = saturate(dot(d.normalWS, lightDir)) +
        pow(saturate(dot(d.normalWS,normalize(lightDir + d.vDirWS))),GetSmoothnessPower(d.smoothness) );
    return d.albedo * intensity;
#else
    
    Light mainLight = GetMainLight(d.shadowCoord,d.posWS,1);//第三个参数为ShadowMask
    //Light mainLight = GetMainLight();//第三个参数为ShadowMask
    half3 color = 0;
    color += CustomLightHandling(d, mainLight);
    #ifdef _ADDITIONAL_LIGHTS
        uint numAdditionalLights = GetAdditionalLightsCount();
        for (uint lightI = 0; lightI < numAdditionalLights; lightI++) {
        Light light = GetAdditionalLight(lightI, d.posWS, 1);
        color += CustomLightHandling(d, light);
        }
    #endif
    
    return color ;
#endif
}

void CaculateCustomLighting_half(half3 PosWS,half3 Albedo,half3 Normal ,half Smoothness,
    half3  VDirWS,half Ao, half2 LightmapUV, out half3 Color)
{
    CustomLightingData d;
    d.albedo = Albedo;
    d.normalWS = Normal;
    d.smoothness = Smoothness;
    d.vDirWS = VDirWS;
    d.posWS = PosWS;
    d.ao = Ao;

#ifdef SHADERGRAPH_PREVIEW
    d.shadowCoord = 0;
    d.bakedGI = 0;
#else
    half4 posCS = TransformWorldToHClip(PosWS);
    //两种阴影方式需要的shadowcoord不一样
    #if SHADOWS_SCREEN
        d.shadowCoord = ComputeScreenPos(posCS);
    #else
        d.shadowCoord = TransformWorldToShadowCoord(PosWS);
    #endif
#endif
    
    Color = CaculateCustomLighting(d);
 }

#endif
