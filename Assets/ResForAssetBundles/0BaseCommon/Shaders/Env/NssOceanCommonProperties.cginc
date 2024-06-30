#ifndef NSS_OCEANCOMMON_PROPERTIES_INCLUDED
#define NSS_OCEANCOMMON_PROPERTIES_INCLUDED

//half _BumpScale;
//half _MaxDepth;
half _MaxWaveHeight;
int _DebugPass;
half4 _depthCamZParams;
float4x4 _InvViewProjection;
half _DepthScale;
half _WaterDepthTilling;
half2 _WaterDepthOffset;
// Surface textures
sampler2D _AbsorptionScatteringRamp;
sampler2D _SurfaceMap;
// Screen Effects textures
sampler2D _WaterDepthMap;
sampler2D _CameraDepthTexture;
sampler2D _CameraOpaqueTexture;
sampler2D _VehicleFoamRT;
sampler2D _PlanarReflectionTexture;
samplerCUBE _CubemapTexture;


sampler2D _PixelFFT;
#define ONE_OVER_PI 0.31831
#define ONE_OVER_TWO_PI 0.159155

//Foam
sampler2D _FoamMap;
half _FoamTexTilling;
half4 _FoamColorTop;
half4 _FoamColorBottom;
half _FoamStrength;
half _MinFoamHeight;
sampler2D _FoamRamp;
half _ShoreDistance;
half _ShoreWaveSpeed;

half4 _TailFoamColor;
half _TailFoamStrength;
half _WakeNormalStrength;
half _WakeVertexOffsetStrength;

//Fog
half4 _OceanFogColorShallow;
half4 _OceanFogColorDeep;
half _OceanFogDensity;
half _OceanFogSoftIntersectionFactor;

half _GlobalOceanHeight;

half _OceanBedFogHeightFalloff;
half _OceanBedFogNear;
half _OceanBedFogFar;

half4 _OceanBedFogColorNear;
half4 _OceanBedFogColorFar;
half _OceanBedFogDisDensityMax;


sampler2D _PlanarReflectionRT;

#endif
