// Upgrade NOTE: replaced 'defined DIRECT_SPEC_ON' with 'defined (DIRECT_SPEC_ON)'

#ifndef NSS_PBR_MODEL
#define NSS_PBR_MODEL


/*----------------模型材质输入---------------------------------*/
struct ShadingModelInput
{
	half4 albedo;
	half3 emissive;
	half3 normal;
	half3 tangent;
	half3 bTangent;
	half  roughness;
	half  metallic;
	half  ao;	
	half  specular;//默认是0.5， 反应了nonmetal的反射度
	half  specularNoise;
#ifdef _PBR_CLEARCOAT
	half clearCoat;
	half clearCoatRoughness;
#endif
};


/*----------------自定义输入---------------------------------*/
struct ShadingCustomInput
{
	half3 directMainLightDir;
	half3 directMainLightColor;

	half3 CameraDirLightColor;

	half3 indirectDiffuseColor;
	half3 indirectSpecularColor;

#ifdef _PBR_CLEARCOAT
	half3 indirectClearCoatSpecularColor;
#endif

	half shadowMask;
	half3 viewDir;
};



/*----------------Shading上下文---------------------------------*/
struct ShadingModelContext
{
	half3 H;
	half3 V;
	half3 L;

	half NdotL;
	half NdotV;
	half NdotH;
	half HdotV;
	half HdotL;
	half HdotT;
	half HdotB;

	half3 DiffuseColor;
	half3 SpecularColor;

#ifdef _PBR_CLEARCOAT
	half ClearCoat;
	half ClearCoatRoughness;
	half3 SpecPreEnvBrdf;
#endif
};


#ifdef _PBR_ANISOTROPIC
	half		_Anisotropy; //各向异性系数，0为没有各向异性
	half4		_AnisoSpecColor; //各向异性高光颜色
	half		_AnisotropySpecularShift;//各向异性高光偏移
#endif


ShadingModelContext CreateShadingModelContext(
	half3 lightDir,
	ShadingModelInput ModelInput,
	half3 ViewDir)
{
	ShadingModelContext context;

	context.L = lightDir;
	context.H = normalize(ViewDir + context.L);
	context.V = ViewDir;


#ifdef _FABRIC_YARN //织物对象统一abs(NDotL)
	context.NdotL = max(saturate(abs(dot(context.L, ModelInput.normal))), 0.00001);
#else
	context.NdotL = max(saturate(dot(context.L, ModelInput.normal)), 0.00001);
#endif

	//https://github.com/KhronosGroup/glTF-Sample-Viewer/issues/39
#if 1
	context.NdotV = max(abs(dot(ModelInput.normal, context.V)), 0.00001);//abs to reduce speculuar artifict, alse can see in unity/ue pbr shader
#else
	context.NdotV = max(saturate(dot(ModelInput.normal, context.V)), 0.00001);
#endif
	

	context.NdotH = max(saturate(dot(ModelInput.normal, context.H)), 0.00001);
	context.HdotV = max(saturate(dot(context.H, context.V)), 0.00001);
	context.HdotL = max(saturate(dot(context.H, context.L)), 0.00001);
	context.HdotT = dot(context.H, ModelInput.tangent); //不能saturate
	context.HdotB = dot(context.H, ModelInput.bTangent);//不能saturate

	float3 BaseColor = ModelInput.albedo.xyz;

	half DielectricSpecular = 0.08 * ModelInput.specular; //默认是 0.08 * ModelInput.specular(default = 0.5) = 0.04 与unity一致,默认非金属0.04 specular

	half DielectricDiffuse = 1 - DielectricSpecular;
	context.DiffuseColor = BaseColor * (1 - ModelInput.metallic) * DielectricDiffuse;//unity 默认非金属0.96 diffuse,待与ue对齐
#ifdef _PBR_CLEARCOAT
	context.ClearCoat = saturate(ModelInput.clearCoat);
	context.ClearCoatRoughness = clamp(ModelInput.clearCoatRoughness, 0.015625, 1.0);

	half RefractionScale = ((context.NdotV * 0.5 + 0.5) * context.NdotV - 1) * saturate(1.25 - 1.25 * ModelInput.roughness) + 1;
	ModelInput.specular *= lerp(1, RefractionScale, context.ClearCoat);

	float MetalSpec = 0.9;
	float3 AbsorptionColor = ModelInput.albedo.xyz * (1 / MetalSpec);
	float3 Absorption = AbsorptionColor * ((context.NdotV - 1) * 0.85 * (1 - lerp(AbsorptionColor, AbsorptionColor * AbsorptionColor, -0.78)) + 1);

	float F0 = 0.04;
	float Fc = NssPow5(1 - context.NdotV);
	float F = Fc + (1 - Fc) * F0;
	float LayerAttenuation = lerp(1, (1 - F), context.ClearCoat);

	BaseColor = lerp(ModelInput.albedo.xyz * LayerAttenuation, MetalSpec * Absorption * RefractionScale, ModelInput.metallic * context.ClearCoat);
	//BaseColor += Dither / 255.f;
	context.DiffuseColor = BaseColor - BaseColor * ModelInput.metallic;
#endif



	context.SpecularColor = lerp(DielectricSpecular, BaseColor, ModelInput.metallic);
#ifdef _PBR_CLEARCOAT
	context.SpecPreEnvBrdf = context.SpecularColor;
#endif

	half roughness = ModelInput.roughness;// *ModelInput.roughness;

#ifndef _PBR_ANISOTROPIC
	context.SpecularColor = EnvBRDFApprox(context.SpecularColor, roughness, context.NdotV);//ue mobile use env specular as specular
#endif

	return context;
}


// divide PI should happpen in light input
half3 GetLightDiffuse(ShadingModelInput ModelInput, ShadingModelContext Context)
{
	half NdotL = Context.NdotL;
#ifdef _LIGHTNING_RAMP
	NdotL = tex2D(LightningRampMap, float2(NdotL, 0.2)).r;
#endif

//#if defined(_FABRIC_YARN) || defined(_FABRIC_SILK)
//	half diffuseTerm = max(Diffuse_Disney(ModelInput.roughness, Context.NdotV, NdotL, Context.HdotL), 0.001);
//#else
	half diffuseTerm = Diffuse_Lambert(NdotL);
//#endif


#ifdef _FABRIC_YARN
	return _DiffuseIntensity * diffuseTerm *Context.DiffuseColor;
#else
	return diffuseTerm *Context.DiffuseColor;
#endif

}

half3 GetEnvDiffuse(ShadingModelInput ModelInput, ShadingModelContext Context)
{
#ifdef _FABRIC_YARN
	return Context.DiffuseColor * ModelInput.ao;
#else
	return Context.DiffuseColor * ModelInput.ao;
#endif
	
}


// divide PI should happpen in light input
half3 GetLightSpecular(ShadingModelInput ModelInput, ShadingModelContext Context)
{
#ifdef _PBR_ANISOTROPIC
	// Anisotropic parameters: ax and ay are the roughness along the tangent and bitangent	
	// Kulla 2017, "Revisiting Physically Based Shading at Imageworks"
	float roughness      = ModelInput.roughness* ModelInput.roughness;
	half anisoXRoughness = max(roughness  * (1.0 + _Anisotropy), 0.001f);
	half anisoYRoughness = max(roughness  * (1.0 - _Anisotropy), 0.001f);

	half th = Context.HdotT + _AnisotropySpecularShift;
	th = clamp(th, -1, 1);

	half3 specular = GGX_Mobile_Anisotropic(anisoXRoughness, anisoYRoughness, Context.NdotH, th, Context.HdotB, Context.NdotL, Context.NdotV, Context.SpecularColor, Context.HdotV);

	#if defined(_FABRIC_SILK) || defined(_FABRIC_YARN)
		half anisoXRoughness2 = max(roughness  * (1.0 + _Anisotropy2), 0.001f);
		half anisoYRoughness2 = max(roughness  * (1.0 - _Anisotropy2), 0.001f);
		half th2              = Context.HdotT + _AnisotropySpecularShift2;
		th2                   = clamp(th2, -1, 1);	
		half3 secondarySpecular = GGX_Mobile_Anisotropic(anisoXRoughness2, anisoYRoughness2, Context.NdotH, th2, Context.HdotB, Context.NdotL, Context.NdotV, Context.SpecularColor, Context.HdotV);
		return  (specular * _AnisoSpecColor + secondarySpecular * _AnisoSpecColor2)* ModelInput.specularNoise * Context.NdotL;
	#else
		return  specular * _AnisoSpecColor  * ModelInput.specularNoise * Context.NdotL;
	#endif
#elif _PBR_CLOTH
	half3   specular = GGX_Mobile_Cloth(ModelInput.roughness, Context.NdotH, Context.NdotV, Context.SpecularColor);
	return  specular * Context.NdotL;
#else 
	half3 specular = GGX_Mobile(ModelInput.roughness, Context.NdotH, Context.H, ModelInput.normal);
	return specular * Context.SpecularColor * Context.NdotL;
#endif
}


half3 GetEnvSpecular(ShadingModelInput ModelInput, ShadingModelContext Context)
{
#ifdef _PBR_ANISOTROPIC	
	#ifdef _SUPER_HIGH
		half3 AnisotropicDir = _Anisotropy >= 0.0f ? ModelInput.bTangent: ModelInput.tangent;
		half3 AnisotropicT = cross(AnisotropicDir, Context.V);
		half3 AnisotropicN = cross(AnisotropicT, AnisotropicDir);
	
		half AnisotropicStretch = abs(_Anisotropy) * saturate(5.0f * ModelInput.roughness);
		half3 bentNormal = normalize(lerp(ModelInput.normal, AnisotropicN, AnisotropicStretch));
	#else
		half3 anisotropicTangent = cross(ModelInput.bTangent, Context.V);
		half3 anisotropicNormal = cross(anisotropicTangent, ModelInput.tangent);
		half3 bentNormal = normalize(lerp(ModelInput.normal, anisotropicNormal, _Anisotropy));
	#endif
	half NdotV = saturate(dot(bentNormal, Context.V));//align with ue,ue bent normal at envbrdf while unity happenning in cube samplli
	return EnvBRDFApprox(Context.SpecularColor, ModelInput.roughness, NdotV) * ModelInput.ao;
#else
	return  Context.SpecularColor * ModelInput.ao;//other pbr model except anisotropic precaculated EnvBRDFApprox in Context.SpecularColor
#endif
}
#ifdef _PBR_CLEARCOAT
void GetClearCoatLight(ShadingModelInput ModelInput, ShadingModelContext Context, out half3 diffuse, out half3 specular)
{
	half ClearCoatRoughness = Context.ClearCoatRoughness;
	half VoH = saturate(dot(Context.V, Context.H));
	half NoL = Context.NdotL;
	half NoH = Context.NdotH;
	half F0 = 0.04;
	half Fc = NssPow5(1 - VoH);
	half F = Fc + (1 - Fc) * F0;
#if 0
	F *= Context.ClearCoat;
	half LayerAttenuation = 1 - F;

	// Vis_SmithJointApprox
	half a = ClearCoatRoughness * ClearCoatRoughness;
	half Vis_SmithV = NoL * (Context.NdotV * (1 - a) + a);
	half Vis_SmithL = Context.NdotV * (NoL * (1 - a) + a);
	float Vis = 0.5 * rcp(Vis_SmithV + Vis_SmithL);

	specular = F * Vis * D_GGX_Mobile(ClearCoatRoughness, NoH, Context.H, ModelInput.normal);
	specular += LayerAttenuation * Context.SpecularColor * GGX_Mobile(ModelInput.roughness, Context.NdotH, Context.H, ModelInput.normal);

	specular *= Context.NdotL;
	diffuse = Diffuse_Lambert(Context.NdotL)* LayerAttenuation * Context.DiffuseColor * ModelInput.ao;
#else
	half LayerAttenuation = 1 - F;
	LayerAttenuation *= LayerAttenuation;

	half a = ClearCoatRoughness * ClearCoatRoughness;
	half Vis_SmithV = NoL * (Context.NdotV * (1 - a) + a);
	half Vis_SmithL = Context.NdotV * (NoL * (1 - a) + a);
	float Vis = 0.5 * rcp(Vis_SmithV + Vis_SmithL);

	specular = NoL * Context.ClearCoat * F * Vis * D_GGX_Mobile(ClearCoatRoughness, Context.NdotH, Context.H, ModelInput.normal);

	half Eta = 0.66666667f;
	half RefractionBlendFactor = (0.63 - 0.22 * VoH) * VoH - 0.745;
	half RefractionProjectionTerm = RefractionBlendFactor * NoH;
	half BottomNoV = saturate(Eta * Context.NdotV - RefractionProjectionTerm);
	half BottomNoL = saturate(Eta * NoL - RefractionProjectionTerm);

	half3 Transmission = 0.0;
	if (BottomNoL > 0.0 && BottomNoV > 0.0)
	{

		half ThinDistance = (rcp(BottomNoV) + rcp(BottomNoL));
		half AbsorptionMix = ModelInput.metallic;

		Transmission = 1.0;
		if (AbsorptionMix > 0.0)
		{
			half3 TransmissionColor = ModelInput.albedo;
			half3 ExtinctionCoefficient = -log(TransmissionColor) * 0.5f;
			half3 OpticalDepth = ExtinctionCoefficient * max(ThinDistance - 2.0, 0.0);
			Transmission = saturate(exp(-OpticalDepth));
			Transmission = lerp(1.0, Transmission, AbsorptionMix);
		}
	}

	half3 CommonDiffuse = Context.DiffuseColor;
	half3 DefaultDiffuse = Diffuse_Lambert(NoL);
	half3 Refracted = (LayerAttenuation * BottomNoL) * Transmission;
	diffuse = CommonDiffuse * lerp(DefaultDiffuse, Refracted, Context.ClearCoat)  * ModelInput.ao;

	half3 CommonSpecular = Context.SpecularColor * GGX_Mobile(ModelInput.roughness, Context.NdotH, Context.H, ModelInput.normal);
	half3 DefaultSpecular = NoL;
	//half3 RefractedSpecular = LayerAttenuation * Transmission * BottomNoL;
	specular += CommonSpecular * lerp(DefaultSpecular, Refracted, Context.ClearCoat)  * ModelInput.ao;

#endif

}
#endif

#endif