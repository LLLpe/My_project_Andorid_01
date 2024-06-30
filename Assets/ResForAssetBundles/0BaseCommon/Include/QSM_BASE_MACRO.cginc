#ifndef QSM_BASE_MACRO
#define QSM_BASE_MACRO
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  
#include "LegacyCommon.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

//触发一次shader重新编译
float4 FAST_MUL_POS(float4x4 M, float3 v)
{
	float4x4 Mt = transpose(M);
	float4 r1 = Mt[0].xyzw * v.xxxx + Mt[3].xyzw;
	r1 = Mt[1].xyzw * v.yyyy + r1.xyzw;
	r1 = Mt[2].xyzw * v.zzzz + r1.xyzw;
	return r1;
}

float4 FastObjectToClipPos(float3 v)
{
	float4x4 Mt = transpose(UNITY_MATRIX_M);
	float4x4 VPt = transpose(unity_MatrixVP);
	float3 r1 = Mt[0].xyz * v.xxx + Mt[3].xyz;
	r1 = Mt[1].xyz * v.yyy + r1.xyz;
	r1 = Mt[2].xyz * v.zzz + r1.xyz;
	float4 r2 = VPt[0].xyzw * r1.xxxx + VPt[3].xyzw;
	r2 = VPt[1].xyzw * r1.yyyy + r2.xyzw;
	r2 = VPt[2].xyzw * r1.zzzz + r2.xyzw;
	return r2;
}

float3 FastObjectToViewPos(float3 v)
{
	float4x4 Mt = transpose(UNITY_MATRIX_M);
	float4x4 Vt = transpose(unity_MatrixV);
	float3 r1 = Mt[0].xyz * v.xxx + Mt[3].xyz;
	r1 = Mt[1].xyz * v.yyy + r1.xyz;
	r1 = Mt[2].xyz * v.zzz + r1.xyz;
	float3 r2 = Vt[0].xyz * r1.xxx + Vt[3].xyz;
	r2 = Vt[1].xyz * r1.yyy + r2.xyz;
	r2 = Vt[2].xyz * r1.zzz + r2.xyz;
	return r2;
}
#undef TransformObjectToHClip
#define TransformObjectToHClip FastObjectToClipPos

#undef TransformWorldToView
#define TransformWorldToView FastObjectToViewPos

#undef UnityMulPos
#define UnityMulPos FAST_MUL_POS



#endif // QSM_BASE_MACRO
