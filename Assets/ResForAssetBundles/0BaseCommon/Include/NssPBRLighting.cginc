#ifndef NSS_PBR_LIGHTING
#define NSS_PBR_LIGHTING

#include "NssMathFunc.cginc"
#include "UE_PBR_Model.cginc"



//单个方向主光+ 相机光的光照模型

half4 PBR_Shading(ShadingModelInput modelInput, ShadingLightingInput LightInput, ShadingCameraInput CameraInput)
{
	half4 finalColor;
	
	ShadingModelContext context = CreateShadingModelContext(LightInput.directMainLightDir, modelInput, CameraInput.viewDir);

	half3 directDiffuse  = GetLightDiffuse(modelInput, context)  * LightInput.directMainLightColor;
	half3 directSpecular = GetLightSpecular(modelInput, context) * LightInput.directMainLightColor;

#ifdef _CAMERA_DIR_LIGHT
	ShadingModelContext context2 = CreateShadingModelContext(LightInput._CameraPointLightDir, modelInput, CameraInput.viewDir);
	context2.HdotV = 1;//https://km.woa.com/articles/show/524596?from=iSearch ,相机点光源光照简化，编译器会自动指令优化
	context2.HdotL = 1;
	context2.NdotV = context.NdotH;
	directDiffuse += GetLightDiffuse(modelInput, context2)   * LightInput._CameraPointLightColor;
	#ifdef _SWITCH_CAMERA_SPECULAR
		directSpecular = GetLightSpecular(modelInput, context2) *LightInput._CameraPointLightColor;
	#endif
#endif

	half3 indirectDiffuse  = GetEnvDiffuse(modelInput, context) * LightInput.indirectDiffuseColor;
	half3 inDirectSpecular = GetEnvSpecular(modelInput, context) * LightInput.indirectSpecularColor;

#ifdef _LOW_COST
	finalColor.xyz = directDiffuse + indirectDiffuse + inDirectSpecular + modelInput.emissive;
#else
	finalColor.xyz = directDiffuse + directSpecular + indirectDiffuse + inDirectSpecular  + modelInput.emissive;
#endif

#ifdef _DIFFUSE_VISUAL
	return half4(directDiffuse, 1);
#elif _SPECULAR_VISUAL
	return  half4(directSpecular, 1);
#elif _AMBIENT_DIFFUSE_VISUAL
	return  half4(indirectDiffuse, 1);
#elif _AMBIENT_SPECULAR_VISUAL
	return  half4(inDirectSpecular, 1);
#elif _EMISSIVE_VISUAL
	return  half4(modelInput.emissive, 1);
#endif
	return PrepareOutputColor(modelInput, finalColor);
}

//仅单个方向主光的光照模型，暂用于点光源
half4 PBR_Shading_Direct(ShadingModelInput modelInput, ShadingLightingInput LightInput, ShadingCameraInput CameraInput)
{
	half4 finalColor;

	ShadingModelContext context = CreateShadingModelContext(LightInput.directMainLightDir, modelInput, CameraInput.viewDir);

	half3 directDiffuse = GetLightDiffuse(modelInput, context)   * LightInput.directMainLightColor;
	half3 directSpecular = GetLightSpecular(modelInput, context) *  LightInput.directMainLightColor;


#ifdef _LOW_COST
	finalColor.xyz = directDiffuse;
#elif _MIDIUM_COST
	finalColor.xyz = directDiffuse;
#else
	finalColor.xyz = directDiffuse + directSpecular;
#endif

	return PrepareOutputColor(modelInput, finalColor);
}


//单个方向主光的ClearCoat光照模型
half4 PBR_Shading_ClearCoat(ShadingModelInput modelInput, ShadingLightingInput LightInput, ShadingCameraInput CameraInput)
{
	half4 finalColor;

	ShadingModelContext context = CreateShadingModelContext(LightInput.directMainLightDir, modelInput, CameraInput.viewDir);
	half3 lightDiffuse = 0, lightSpecular = 0;
#ifdef _PBR_CLEARCOAT
	GetClearCoatLight(modelInput, context, lightDiffuse, lightSpecular);	
#else
	lightDiffuse = GetLightDiffuse(modelInput, context) ;
	lightSpecular = GetLightSpecular(modelInput, context);
#endif
	half3 directDiffuse = lightDiffuse   * LightInput.directMainLightColor;
	half3 directSpecular = lightSpecular *  LightInput.directMainLightColor;

	half3 indirectDiffuse = GetEnvDiffuse(modelInput, context) * LightInput.indirectDiffuseColor;
	
#ifdef _PBR_CLEARCOAT
	half F = EnvBRDFApprox(0.04, context.ClearCoatRoughness, context.NdotV).x;
	F *= modelInput.clearCoat;
	half LayerAttenuation = (1 - F);
	half2 AB = EnvBRDFApproxLazarov(modelInput.roughness, context.NdotV);		 

	half3 inDirectSpecular =  LightInput.indirectSpecularColor * LayerAttenuation * (context.SpecPreEnvBrdf * AB.x + AB.y * saturate(50 * context.SpecPreEnvBrdf.g) * (1 - context.ClearCoat));;
	inDirectSpecular += LightInput.indirectClearCoatSpecularColor * F;
	inDirectSpecular *= modelInput.ao;
#else  
	half3 inDirectSpecular = GetEnvSpecular(modelInput, context) * LightInput.indirectSpecularColor;
#endif


#ifdef _LOW_COST
	finalColor.xyz = directDiffuse + modelInput.emissive;
#elif _MIDIUM_COST
	finalColor.xyz = directDiffuse + indirectDiffuse + inDirectSpecular + modelInput.emissive;
#else
	finalColor.xyz = directDiffuse + indirectDiffuse + directSpecular + inDirectSpecular + modelInput.emissive;
#endif

	return PrepareOutputColor(modelInput, finalColor);
}


#endif


