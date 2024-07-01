#ifndef NSS_PBR_LIGHTING
#define NSS_PBR_LIGHTING

#include "UE_PBR_Model.cginc"
#include "UE_Lighting_Lib.cginc"

//单个方向主光+ 可选相机光的光照模型

half4 PBR_Shading(ShadingModelInput modelInput, ShadingCustomInput CustomInput, ShadingModelContext context)
{
	half3 finalColor;
	
	half3 directDiffuse  = GetLightDiffuse(modelInput, context)  * CustomInput.directMainLightColor;
	half3 directSpecular = GetLightSpecular(modelInput, context) * CustomInput.directMainLightColor;

#ifdef _CAMERA_DIR_LIGHT
	ShadingModelContext context2 = CreateShadingModelContext(CustomInput.viewDir, modelInput, CustomInput.viewDir);
	context2.HdotV = 1;//https://km.woa.com/articles/show/524596?from=iSearch ,相机光源光照简化，编译器会自动指令优化
	context2.HdotL = 1;
	context2.NdotV = context.NdotH;
	directDiffuse += GetLightDiffuse(modelInput, context2)   * CustomInput.CameraDirLightColor;
	#ifdef _SWITCH_CAMERA_SPECULAR //只允许一盏高光
		directSpecular = GetLightSpecular(modelInput, context2) * CustomInput.CameraDirLightColor;
	#endif
#endif

	half3 indirectDiffuse  = GetEnvDiffuse(modelInput, context) * CustomInput.indirectDiffuseColor;
	half3 inDirectSpecular = GetEnvSpecular(modelInput, context) * CustomInput.indirectSpecularColor;

#ifdef _LOW_COST
	finalColor = directDiffuse + indirectDiffuse + inDirectSpecular + modelInput.emissive;
#else
	finalColor = directDiffuse + directSpecular + indirectDiffuse + inDirectSpecular  + modelInput.emissive;
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
	return half4(finalColor, modelInput.albedo.w);
}

//仅单个方向主光的光照模型，暂用于点光源
half4 PBR_Shading_Direct(ShadingModelInput modelInput, ShadingCustomInput CustomInput)
{
	half4 finalColor;

	ShadingModelContext context = CreateShadingModelContext(CustomInput.directMainLightDir, modelInput, CustomInput.viewDir);

	half3 directDiffuse = GetLightDiffuse(modelInput, context)   * CustomInput.directMainLightColor;
	half3 directSpecular = GetLightSpecular(modelInput, context) * CustomInput.directMainLightColor;


#ifdef _LOW_COST
	finalColor.xyz = directDiffuse;
#elif _MIDIUM_COST
	finalColor.xyz = directDiffuse;
#else
	finalColor.xyz = directDiffuse + directSpecular;
#endif

	return finalColor;
}


//单个方向主光的ClearCoat光照模型
half4 PBR_Shading_ClearCoat(ShadingModelInput modelInput, ShadingCustomInput CustomInput)
{
	half4 finalColor;

	ShadingModelContext context = CreateShadingModelContext(CustomInput.directMainLightDir, modelInput, CustomInput.viewDir);
	half3 lightDiffuse = 0, lightSpecular = 0;
#ifdef _PBR_CLEARCOAT
	GetClearCoatLight(modelInput, context, lightDiffuse, lightSpecular);	
#else
	lightDiffuse = GetLightDiffuse(modelInput, context) ;
	lightSpecular = GetLightSpecular(modelInput, context);
#endif
	half3 directDiffuse = lightDiffuse   * CustomInput.directMainLightColor;
	half3 directSpecular = lightSpecular * CustomInput.directMainLightColor;

	half3 indirectDiffuse = GetEnvDiffuse(modelInput, context) * CustomInput.indirectDiffuseColor;
	
#ifdef _PBR_CLEARCOAT
	half F = EnvBRDFApprox(0.04, context.ClearCoatRoughness, context.NdotV).x;
	F *= modelInput.clearCoat;
	half LayerAttenuation = (1 - F);
	half2 AB = EnvBRDFApproxLazarov(modelInput.roughness, context.NdotV);		 

	half3 inDirectSpecular = CustomInput.indirectSpecularColor * LayerAttenuation * (context.SpecPreEnvBrdf * AB.x + AB.y * saturate(50 * context.SpecPreEnvBrdf.g) * (1 - context.ClearCoat));;
	inDirectSpecular += CustomInput.indirectClearCoatSpecularColor * F;
	inDirectSpecular *= modelInput.ao;
#else  
	half3 inDirectSpecular = GetEnvSpecular(modelInput, context) * CustomInput.indirectSpecularColor;
#endif


#ifdef _LOW_COST
	finalColor.xyz = directDiffuse + modelInput.emissive;
#elif _MIDIUM_COST
	finalColor.xyz = directDiffuse + indirectDiffuse + inDirectSpecular + modelInput.emissive;
#else
	finalColor.xyz = directDiffuse + indirectDiffuse + directSpecular + inDirectSpecular + modelInput.emissive;
#endif

	return finalColor;
}


#endif


