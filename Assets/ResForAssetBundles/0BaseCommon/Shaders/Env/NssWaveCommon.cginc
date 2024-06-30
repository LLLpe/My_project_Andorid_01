#ifndef NSS_WAVECOMMON_INCLUDED
#define NSS_WAVECOMMON_INCLUDED

#include "../../Include/QSM_BASE_MACRO.cginc"

///////////////////////////////////////////////////////////////////////////////
//                           Nss Wave										//
///////////////////////////////////////////////////////////////////////////////


half4 _WaveAParams;
half4 _WaveBParams;
half4 _WaveCParams;
half4 _WaveDParams;
half4 _Amplitudes;
half4 _Steepness;
//sampler2D _MainTex;
half _ElapsedTime;
uniform float4x4 _depthCamVP;
float _depthCamHeight;
float _depthCamNearPlane;
float _depthCamFarPlane;
half _OverlapCoefficient;

uniform uint 	_WaveCount; // how many waves, set via the water component
float 			_GlobalTime; // global scene time
sampler2D _TopDepthTex;

//base wave info textures
sampler2D _MainWaveDirTex;
sampler2D _MainWaveParamTex;
sampler2D _ViceWaveParamTex;

//最大限制20个customWave
float4x4 _CustomWave[20];
int _CustomWaveCount;

struct Wave
{
	half amplitude;
	half direction;
	half wavelength;
	half2 origin;
	half omni;
};


struct WaveStruct
{
	float3 position;
	float3 normal;
	half vertexRelativeHeight;
};


float decodeRGB(float4 rgba)
{
	return rgba.x + rgba.y / 255.0 + rgba.z / 255.0 / 255.0;
}



float NssSampleHeightMap(float3 wpos)
{
	float4 depthCamClipPos = UnityMulPos(_depthCamVP, float4(wpos, 1));
	float3 depthCamSSPos = (depthCamClipPos.xyz / depthCamClipPos.w + 1.0) * 0.5;
	float wPosY = abs(decodeRGB(tex2Dlod(_TopDepthTex, float4(depthCamSSPos.xy, 0, 0))));
	wPosY = _depthCamHeight + _depthCamNearPlane + wPosY * (_depthCamFarPlane - _depthCamNearPlane);
	return wPosY;
}

float NssSampleHeightMapOuputDepthCamSSPos(float3 wpos, inout float3 depthCamSSPos)
{
	float4 depthCamClipPos = UnityMulPos(_depthCamVP, float4(wpos, 1));
	depthCamSSPos = (depthCamClipPos.xyz / depthCamClipPos.w + 1.0) * 0.5;
	float wPosY = abs(decodeRGB(tex2Dlod(_TopDepthTex, float4(depthCamSSPos.xy, 0, 0))));
	wPosY = _depthCamHeight + _depthCamNearPlane + wPosY * (_depthCamFarPlane - _depthCamNearPlane);
	return wPosY;
}
#ifndef PI
    #define PI            3.14159265359f
#endif
float3 NssGerstnerWave(float2 P, half4 WaveParams, float t, half amplitude, half steepness, inout float3 normal)
{
	float3 wavePos = float3(0, 0, 0);
	float2 d = normalize(WaveParams.xy);

	float k = 2 * PI / WaveParams.w;
	float f = dot(k*d, P) - WaveParams.z *t;


	wavePos.x = steepness * d.x* amplitude * cos(f);
	wavePos.y = amplitude * sin(f);
	wavePos.z = steepness * d.y*  amplitude * cos(f);

	float WA = k * amplitude;

	normal.xz -= d.xy * WA* cos(f);
	normal.y -= steepness * WA* sin(f);
	return wavePos;
}

//WaveParams: speed, amplitude, steepness, wave length
float3 NssGerstnerWaveFlowByPhase(half4 WaveParams, float t, half phase, half2 dir,inout float3 normal, float mainWaveNormalPower)
{
	float3 wavePos = float3(0, 0, 0);

	//方便策划调参
	WaveParams.w = 4000 / WaveParams.w;
	float Y0 = WaveParams.y * sin(WaveParams.w * phase + t * WaveParams.x );
	wavePos.y += Y0;

	float3 unitDir = normalize(float3(-dir.x, 0, -dir.y));
	float3 up = float3(0, 1, 0);
	float3 right = normalize(cross(up, unitDir));
	up = cross(unitDir, right);
	float derivative = -WaveParams.y  * cos(WaveParams.w * phase + t * WaveParams.x) * 0.32;//0.32为pixel对应长度的比例系数，后边要暴露为可调参数
	float3 derivativeVec = normalize(derivative * up + unitDir);
	float3 tmpNormal = cross(derivativeVec, right);
	normal = lerp(normal, tmpNormal, mainWaveNormalPower);

	return wavePos;	
}

float3 NssBaseWave(float3 worldPos, float2 uv, float time, inout float3 normal)
{
	uv.y = 1 - uv.y;
	float4 decodedPhase = tex2Dlod(_MainWaveDirTex, float4(uv,0, 0)).xyzw;
	float phase = decodedPhase.x + decodedPhase.y * 255;
	float2 dir = decodedPhase.zw * 2 - 1;

	float4 mainWaveParam = tex2Dlod(_MainWaveParamTex, float4(uv.xy, 0, 0)).xyzw * 4;//speed, amplitude, steepness, wave length
	float4 viceWaveParam = tex2Dlod(_ViceWaveParamTex, float4(uv.xy, 0, 0)).xyzw * 4;//speed, amplitude, steepness, wave length
	
	// WaveParams: speed, amplitude, steepness, wave length
	float4 WaveAParams = float4(_WaveAParams.z, _Amplitudes.x, _Steepness.x, _WaveAParams.w) * mainWaveParam.rgba;
	// WaveParams: dirXZ, speed, wave length
	float4 WaveBParams = float4(_WaveBParams.xy, _WaveBParams.zw * viceWaveParam.xw);
	float4 WaveCParams = float4(_WaveCParams.xy, _WaveCParams.zw * viceWaveParam.xw);
	float4 WaveDParams = float4(_WaveDParams.xy, _WaveDParams.zw * viceWaveParam.xw);
	float3 ViceAmplitudes = _Amplitudes.yzw * viceWaveParam.y;
	float3 ViceSteepness = _Steepness.yzw * viceWaveParam.z;

	float3 GerstnerPos = float3(0, 0, 0);
	GerstnerPos += NssGerstnerWave(worldPos.xz, WaveBParams, time, ViceAmplitudes.x, ViceSteepness.x, normal);
	GerstnerPos += NssGerstnerWave(worldPos.xz, WaveCParams, time, ViceAmplitudes.y, ViceSteepness.y, normal);
	GerstnerPos += NssGerstnerWave(worldPos.xz, WaveDParams, time, ViceAmplitudes.z, ViceSteepness.z, normal);
	float mainWaveNormalPower = _Amplitudes.x / (_Amplitudes.x + ViceAmplitudes.x + ViceAmplitudes.y + ViceAmplitudes.z);
	GerstnerPos += NssGerstnerWaveFlowByPhase(WaveAParams, time, phase, dir, normal, mainWaveNormalPower);
	
	return GerstnerPos;
}

float3 NssCustomWaveKernel(float3 w_pos, float3 wavePos, float3 dir, float3 right, half halfWidth, half halfLength, half height,half4 WaveShapeParam)//
{
	float3 customWavePos = float3(0, 0, 0);
	float3 vec = w_pos - wavePos;
	half absW = abs(dot(vec, right));
	half l = dot(vec, dir);

	if (absW < halfWidth && abs(l) < halfLength)
	{
		half power = sin(saturate(1 - (absW - WaveShapeParam.z) / (halfWidth - WaveShapeParam.z)) * 1.57);
		l = 3.14 * (l/halfLength);

		half tmp = l < 0 ? WaveShapeParam.w : WaveShapeParam.w + WaveShapeParam.y;

		half yOffset = 0.5 * cos(l) + 0.5;
		half offset = (yOffset * WaveShapeParam.x - sin(l) * tmp) * power;

		customWavePos += dir * offset;
		customWavePos.y += yOffset * height * power;
	}

	return customWavePos;
}

float3 NssCustomWave(float3 w_pos, inout half3 normal)
{
	float sampleStep = 1;
	float3 offset = float3(0, 0, 0);
	float3 rightPointOffset = float3(0, 0, 0);
	float3 downPointOffset = float3(0, 0, 0);
	float3 rightPoint = w_pos.xyz + float3(sampleStep, 0, 0);
	float3 downPoint = w_pos.xyz + float3(0, 0, -sampleStep);
	
	for (int i = 0; i < _CustomWaveCount; i++)
	{
		float3 curPos = _CustomWave[i][0].xyz;
		float3 dir = _CustomWave[i][1].xyz;
		float3 right = _CustomWave[i][2].xyz;
		half halfWidth = _CustomWave[i][0].w;
		half halfLength = _CustomWave[i][1].w;
		half height = _CustomWave[i][2].w;
		half4 WaveShapeParam = _CustomWave[i][3].xyzw;	

		offset += NssCustomWaveKernel(w_pos, curPos, dir, right, halfWidth, halfLength, height, WaveShapeParam);
		rightPointOffset += NssCustomWaveKernel(rightPoint, curPos, dir, right, halfWidth, halfLength, height, WaveShapeParam);
		downPointOffset += NssCustomWaveKernel(downPoint, curPos, dir, right, halfWidth, halfLength, height, WaveShapeParam);
	}

	rightPointOffset += float3(sampleStep, 0, 0);
	downPointOffset += float3(0, 0, -sampleStep);

	normal = normalize(cross((offset - downPointOffset),(rightPointOffset - offset)));

	return offset;
}

WaveStruct CalculateWave(float3 worldPos, inout half3 normal, half time)
{
	WaveStruct waveOut;
	float3 wavePos = float3(0, 0, 0);


	//Heightmap here
	float3 depthCamSSPos = float3(0, 0, 0);
	half wPosY = NssSampleHeightMapOuputDepthCamSSPos(worldPos, depthCamSSPos);
	wavePos.y = wPosY;

	//Gerstner wave here
	float3 GerstnerPos = NssBaseWave(worldPos, depthCamSSPos.xy, time, normal);

	//Custom wave here
	half3 customWaveNormal = float3(0, 1, 0);
	float3 customWavePos = NssCustomWave(worldPos, customWaveNormal);
	wavePos.xyz += saturate(1 - customWavePos.y * _OverlapCoefficient) * GerstnerPos;
	wavePos.xyz += customWavePos;

	//blend between gertner wave normal and custom wave normal
	float t= wavePos.y / (wavePos.y + customWavePos.y + 0.001);
	normal = lerp(customWaveNormal, normalize(normal), t);
	
	waveOut.position = wavePos;
	waveOut.normal = normal;
//	waveOut.normal = half3(0, 1, 1);
	waveOut.vertexRelativeHeight = GerstnerPos.y;
	return waveOut;
}
WaveStruct CalculateWaveNoCustom(float3 worldPos, inout half3 normal, half time)
{
	WaveStruct waveOut;
	float3 wavePos = float3(0, 0, 0);

	//Heightmap here
	float3 depthCamSSPos = float3(0, 0, 0);
	half wPosY = NssSampleHeightMapOuputDepthCamSSPos(worldPos, depthCamSSPos);
	wavePos.y = wPosY;

	//Gerstner wave here
	float3 GerstnerPos = NssBaseWave(worldPos, depthCamSSPos.xy, time, normal);
	wavePos.xyz += GerstnerPos;

	waveOut.position = wavePos;
	waveOut.normal = normal;

	//	waveOut.normal = half3(0, 1, 1);

	waveOut.vertexRelativeHeight = GerstnerPos.y;
	return waveOut;
}



WaveStruct GerstnerWave(half2 pos, float waveCountMulti, half amplitude, half direction, half wavelength, half omni, half2 omniPos)
{
	WaveStruct waveOut;

	////////////////////////////////wave value calculations//////////////////////////
	half3 wave = 0; // wave vector
	half w = 6.28318 / wavelength; // 2pi over wavelength(hardcoded)
	half wSpeed = sqrt(9.8 * w); // frequency of the wave based off wavelength
	half peak = 1; // peak value, 1 is the sharpest peaks
	half qi = peak / (amplitude * w * _WaveCount);

	direction = radians(direction); // convert the incoming degrees to radians, for directional waves
	half2 dirWaveInput = half2(sin(direction), cos(direction)) * (1 - omni);
	half2 omniWaveInput = (pos - omniPos) * omni;

	half2 windDir = normalize(dirWaveInput + omniWaveInput); // calculate wind direction
	half dir = dot(windDir, pos - (omniPos * omni)); // calculate a gradient along the wind direction

	////////////////////////////position output calculations/////////////////////////
	half calc = dir * w + -_GlobalTime * wSpeed; // the wave calculation
	half cosCalc = cos(calc); // cosine version(used for horizontal undulation)
	half sinCalc = sin(calc); // sin version(used for vertical undulation)

	// calculate the offsets for the current point
	wave.xz = qi * amplitude * windDir.xy * cosCalc;
	wave.y = ((sinCalc * amplitude)) * waveCountMulti;// the height is divided by the number of waves

	////////////////////////////normal output calculations/////////////////////////
	half wa = w * amplitude;
	// normal vector
	half3 n = half3(-(windDir.xy * wa * cosCalc),
		1 - (qi * wa * sinCalc));

	////////////////////////////////assign to output///////////////////////////////
	waveOut.position = wave * saturate(amplitude * 10000);
	waveOut.normal = (n * waveCountMulti);
	waveOut.vertexRelativeHeight = waveOut.position.y / amplitude;

	return waveOut;
}


#endif // GERSTNER_WAVES_INCLUDED



