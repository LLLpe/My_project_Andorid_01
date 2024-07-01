#ifndef NSS_AVATAR_EXT_BRDF
#define NSS_AVATAR_EXT_BRDF

float D_Beckmann1( float a2, float NoH )
{
    float NoH2 = NoH * NoH;
    return exp( (NoH2 - 1) / (saturate(a2 * NoH2) + 0.001) ) / ( saturate(PI * a2 * NoH2 * NoH2) + 0.001 );
}

half3 BRDF_Beckmann(half NdotH, half roughness, half3 F)
{
    half a2 = roughness * roughness;
    half D = D_Beckmann1(a2, NdotH);

    //half Vis = 1;//Vis_Implicit();//Vis_Schlick(roughness, NdotV, NdotL);

    half3 nominator = D * F;// * Vis;
    //half denominator = 4.0 * NdotV * NdotL + 0.00001; 					

    return nominator * 0.25;// / denominator;
}


//使用隐式Visible项NoL * NoV
half3 BRDF_GGX_SMITH(half NdotL, half NdotV, half NdotH, half roughness, half3 F)
{
    half D = min(D_GGX_USER_DEFINE_UE4_NSS(roughness, NdotH), 60000);

    //half Vis = 1;//Vis_Implicit();//Vis_Schlick(roughness, NdotV, NdotL);

    half3 nominator = D * F;// * Vis;
    //half denominator = 4.0 * NdotV * NdotL + 0.00001; 					

    return nominator * 0.25;// / denominator;
}

//使用隐式Visible项NoL * NoV
half3 BRDF_Velvet(half roughness, half NoH, half3 F) 
{
    // Ashikhmin 2007, "Distribution-based BRDFs"
	half a2 = roughness * roughness;
	half cos2h = NoH * NoH;
	half sin2h = max(1.0 - cos2h, 0.0078125); // 2^(-14/2), so sin2h^2 > 0 in fp16
	half sin4h = sin2h * sin2h;
	half cot2 = -cos2h / (a2 * sin2h);
	return 0.25 / (PI * (4.0 * a2 + 1.0) * sin4h) * (4.0 * exp(cot2) + sin4h) * F;
}

half D_GGX_USER_DEFINE_Anisotropic( half at, half ab, half NoH, half3 h, half3 t, half3 b) 
{
    half XoH = dot( t, h );
    half YoH = dot( b, h );
    half d = XoH*XoH / (at*at) + YoH*YoH / (ab*ab) + NoH*NoH;
    return 1 / (PI * at*ab * d*d );
}

half G1_EPIC_NOTE(half NdotV, half roughness)
{
    //reduction
    half r = (roughness + 1.0);
    half k = (r * r) * 0.125;

    half denom = NdotV * (1.0 - k) + k;

    return NdotV / (denom + 0.00001);
}

//s2013-pbs-epic-note
half V_Smith_EPIC_NOTE(float NdotL, float NdotV, float roughness)
{
    half ggx2  = G1_EPIC_NOTE(NdotV, roughness);
    half ggx1  = G1_EPIC_NOTE(NdotL, roughness);

    return ggx1 * ggx2;
}

half3 BRDF_GGX_Anisotropic(half3 H, half3 T, half3 B, half NdotH, half NdotL, half NdotV, half roughness, half anisotropy,half3 F)//BRDF_GGX_Anisotropic
{
    half aspect = lerp(0.2, 0.001, sqrt(anisotropy));//pow(1.0 - anisotropy);//sqrt(1.0 - anisotropy * 0.9999);
    half anisoXRoughness = max(0.01, roughness / aspect);
    half anisoYRoughness = max(0.01, roughness * aspect);     

    half D = D_GGX_USER_DEFINE_Anisotropic(anisoXRoughness , anisoYRoughness, NdotH, H, T, B);

    half Vis = V_Smith_EPIC_NOTE(NdotL, NdotV, roughness);

    half3 nominator    = D * Vis * F;
    half denominator = 4.0 * NdotV * NdotL + 0.00001;

    return nominator / denominator;
}

#endif
