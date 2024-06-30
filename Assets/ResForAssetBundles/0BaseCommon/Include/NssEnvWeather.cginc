#ifndef NSS_ENV_WEATHER
#define  NSS_ENV_WEATHER
//-----------------------------------
// 非天气赛道下使用天气的部分效果
//-----------------------------------

//胎印效果
#ifdef _TIRE_TRACK
sampler2D _SSNTex;
sampler2D _TireTrackMask;

//混合胎印的法线
half3 MixTireTrackNormal(float3 normalWorld, half2 screenPos, half2 uv,out half occlusion)
{
    //法线偏移效果
	half4 SSN = tex2D(_SSNTex, screenPos);
	half4 mask = tex2D(_TireTrackMask, uv);
	half4 normalTireTrack = 2 * SSN - 1;
	normalTireTrack.a = SSN.a * mask.r;	
	

	half3 mix = normalize(normalWorld + normalTireTrack.xyz * normalTireTrack.a);
	//胎印ao效果，* 0.5 减弱效果
	occlusion = 1 - length(mix - normalWorld) * normalTireTrack.a * 0.5;	
	
	return mix;
}
#endif

#endif
