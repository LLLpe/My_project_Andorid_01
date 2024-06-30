#ifndef UNIVERSAL_LEGACY_COMMON_INCLUDED
#define UNIVERSAL_LEGACY_COMMON_INCLUDED
#if defined(SHADER_TARGET_SURFACE_ANALYSIS)
// surface shader analysis is complicated, and is done via two compilers:
// - Mojoshader for source level analysis (to find out structs/functions with their members & parameters).
//   This step can understand DX9 style HLSL syntax.
// - HLSL compiler for "what actually got read & written to" (taking dead code etc into account), via a dummy
//   compilation and reflection of the shader. This step can understand DX9 & DX11 HLSL syntax.
// Neither of these compilers are "Cg", but we used to use Cg in the past for this; keep the macro
// name intact in case some user-written shaders depend on it being that.
#define UNITY_COMPILER_CG
#elif defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_GLES)
#define UNITY_COMPILER_HLSL
#define UNITY_COMPILER_HLSLCC
#elif defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE)
#define UNITY_COMPILER_HLSL
#else
#define UNITY_COMPILER_CG
#endif
#if defined(UNITY_COMPILER_HLSL)
#pragma warning (disable : 3205) // conversion of larger type to smaller
#pragma warning (disable : 3568) // unknown pragma ignored
#pragma warning (disable : 3571) // "pow(f,e) will not work for negative f"; however in majority of our calls to pow we know f is not negative
#pragma warning (disable : 3206) // implicit truncation of vector type
#endif
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
struct UnityLight
{
    half3 color;
    half3 dir;
    half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it.
};

struct UnityIndirect
{
    half3 diffuse;
    half3 specular;
};

struct UnityGI
{
    UnityLight light;
    UnityIndirect indirect;
};

struct UnityGIInput
{
    UnityLight light; // pixel light, sent from the engine

    float3 worldPos;
    half3 worldViewDir;
    half atten;
    half3 ambient;

    // interpolated lightmap UVs are passed as full float precision data to fragment shaders
    // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
    // also be full float precision to avoid data loss before sampling a texture.
    float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV

#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
    float4 boxMin[2];
#endif
#ifdef UNITY_SPECCUBE_BOX_PROJECTION
    float4 boxMax[2];
    float4 probePosition[2];
#endif
    // HDR cubemap properties, use to decompress HDR texture
    float4 probeHDR[2];
};
#if defined(HANDLE_SHADOWS_BLENDING_IN_GI) // handles shadows in the depths of the GI function for performance reasons
#   define UNITY_SHADOW_COORDS(idx1) SHADOW_COORDS(idx1)
#   define UNITY_TRANSFER_SHADOW(a, coord) TRANSFER_SHADOW(a)
#   define UNITY_SHADOW_ATTENUATION(a, worldPos) SHADOW_ATTENUATION(a)
#elif defined(SHADOWS_SCREEN) && !defined(LIGHTMAP_ON) && !defined(UNITY_NO_SCREENSPACE_SHADOWS) // no lightmap uv thus store screenPos instead
// can happen if we have two directional lights. main light gets handled in GI code, but 2nd dir light can have shadow screen and mask.
// - Disabled on ES2 because WebGL 1.0 seems to have junk in .w (even though it shouldn't)
#   if defined(SHADOWS_SHADOWMASK) && !defined(SHADER_API_GLES)
#       define UNITY_SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
#       define UNITY_TRANSFER_SHADOW(a, coord) {a._ShadowCoord.xy = coord * unity_LightmapST.xy + unity_LightmapST.zw; a._ShadowCoord.zw = ComputeScreenPos(a.pos).xy;}
#       define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(a._ShadowCoord.xy, worldPos, float4(a._ShadowCoord.zw, 0.0, UNITY_SHADOW_W(a.pos.w)));
#   else
#       define UNITY_SHADOW_COORDS(idx1) SHADOW_COORDS(idx1)
#       define UNITY_TRANSFER_SHADOW(a, coord) TRANSFER_SHADOW(a)
#       define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(0, worldPos, a._ShadowCoord)
#   endif
#else
#   define UNITY_SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
#   if defined(SHADOWS_SHADOWMASK)
#       define UNITY_TRANSFER_SHADOW(a, coord) a._ShadowCoord.xy = coord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#       if (defined(SHADOWS_DEPTH) || defined(SHADOWS_SCREEN) || defined(SHADOWS_CUBE) || UNITY_LIGHT_PROBE_PROXY_VOLUME)
#           define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(a._ShadowCoord.xy, worldPos, UNITY_READ_SHADOW_COORDS(a))
#       else
#           define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(a._ShadowCoord.xy, 0, 0)
#       endif
#   else
#       if !defined(UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS)
#           define UNITY_TRANSFER_SHADOW(a, coord)
#       else
#           define UNITY_TRANSFER_SHADOW(a, coord) TRANSFER_SHADOW(a)
#       endif
#       if (defined(SHADOWS_DEPTH) || defined(SHADOWS_SCREEN) || defined(SHADOWS_CUBE))
#           define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(0, worldPos, UNITY_READ_SHADOW_COORDS(a))
#       else
#           if UNITY_LIGHT_PROBE_PROXY_VOLUME
#               define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(0, worldPos, UNITY_READ_SHADOW_COORDS(a))
#           else
#               define UNITY_SHADOW_ATTENUATION(a, worldPos) UnityComputeForwardShadows(0, 0, 0)
#           endif
#       endif
#   endif
#endif
#   define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) fixed destName = UNITY_SHADOW_ATTENUATION(input, worldPos);
#   define LIGHT_ATTENUATION(a) SHADOW_ATTENUATION(a)
#   define DECLARE_LIGHT_COORDS(idx)
#   define COMPUTE_LIGHT_COORDS(a)

// ---- Shadows off
#if defined (_MAIN_LIGHT_SHADOWS)
#ifndef READ_SHADOW_COORDS
#define READ_SHADOW_COORDS(a) a._ShadowCoord
#endif
#define SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
#define SHADOW_ATTENUATION(a) UnitySampleShadowmap(a._ShadowCoord)
#define TRANSFER_SHADOW(a) a._ShadowCoord = mul( unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
#else

#define SHADOW_COORDS(idx1)
#define TRANSFER_SHADOW(a)
#define SHADOW_ATTENUATION(a) 1.0
#define READ_SHADOW_COORDS(a) 0
#endif
#define LIGHTING_COORDS(idx1, idx2) DECLARE_LIGHT_COORDS(idx1) SHADOW_COORDS(idx2)

#define unityShadowCoord float
#define unityShadowCoord2 float2
#define unityShadowCoord3 float3
#define unityShadowCoord4 float4
#define unityShadowCoord4x4 float4x4
float3 _LightDirection;
// float4 UnityClipSpaceShadowCasterPos(float4 vertex, float3 normal)
// {
//     float3 positionWS = TransformObjectToWorld(vertex.xyz);
//     float3 normalWS = TransformObjectToWorldNormal(normal.xyz);
//     float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
// #if UNITY_REVERSED_Z
//     positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
// #else
//     positionCS.z = lerp(max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE), min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE), _UseGlesReservedZ);
// #endif
//     return positionCS;
// }
// Legacy, not used anymore; kept around to not break existing user shaders
float4 UnityClipSpaceShadowCasterPos(float3 vertex, float3 normal)
{
    return UnityClipSpaceShadowCasterPos(float4(vertex, 1), normal);
}


// float4 UnityApplyLinearShadowBias(float4 clipPos)

// {
//     // For point lights that support depth cube map, the bias is applied in the fragment shader sampling the shadow map.
//     // This is because the legacy behaviour for point light shadow map cannot be implemented by offseting the vertex position
//     // in the vertex shader generating the shadow map.
// #if !(defined(SHADOWS_CUBE) && defined(SHADOWS_CUBE_IN_DEPTH_TEX))
// #if defined(UNITY_REVERSED_Z)
//     // We use max/min instead of clamp to ensure proper handling of the rare case
//     // where both numerator and denominator are zero and the fraction becomes NaN.
//     clipPos.z += max(-1, min(_ShadowBias.x / clipPos.w, 0));
// #else
//     clipPos.z += lerp(saturate(_ShadowBias.x / clipPos.w), max(-1, min(_ShadowBias.x / clipPos.w, 0)), _UseGlesReservedZ);
// #endif
// #endif

// #if defined(UNITY_REVERSED_Z)
//     float clamped = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
// #else
//     float clamped = lerp(max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE), min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE), _UseGlesReservedZ);
// #endif
//     clipPos.z = lerp(clipPos.z, clamped, 1);
//     return clipPos;
// }


#if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
// Rendering into point light (cubemap) shadows
#define V2F_SHADOW_CASTER_NOPOS float3 vec : TEXCOORD0;
#define TRANSFER_SHADOW_CASTER_NOPOS_LEGACY(o,opos) o.vec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz; opos = TransformObjectToHClip(v.vertex);
#define TRANSFER_SHADOW_CASTER_NOPOS(o,opos) o.vec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz; opos = TransformObjectToHClip(v.vertex);
#define SHADOW_CASTER_FRAGMENT(i) return UnityEncodeCubeShadowDepth ((length(i.vec) + _ShadowBias.x) * _LightPositionRange.w);

#else
// Rendering into directional or spot light shadows
#define V2F_SHADOW_CASTER_NOPOS
// Let embedding code know that V2F_SHADOW_CASTER_NOPOS is empty; so that it can workaround
// empty structs that could possibly be produced.
#define V2F_SHADOW_CASTER_NOPOS_IS_EMPTY
#define TRANSFER_SHADOW_CASTER_NOPOS_LEGACY(o,opos) \
        opos = TransformObjectToHClip(v.vertex.xyz); \
        opos = UnityApplyLinearShadowBias(opos);
#define TRANSFER_SHADOW_CASTER_NOPOS(o,opos) \
        opos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal); 
#define SHADOW_CASTER_FRAGMENT(i) return 0;
#endif

// On D3D reading screen space coordinates from fragment shader requires SM3.0
#define UNITY_POSITION(pos) float4 pos : SV_POSITION
// Declare all data needed for shadow caster pass output (any shadow directions/depths/distances as needed),
// plus clip space position.
#define V2F_SHADOW_CASTER V2F_SHADOW_CASTER_NOPOS UNITY_POSITION(pos)

// Vertex shader part, with support for normal offset shadows. Requires
// position and normal to be present in the vertex input.
#define TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) TRANSFER_SHADOW_CASTER_NOPOS(o,o.pos)

// Vertex shader part, legacy. No support for normal offset shadows - because
// that would require vertex normals, which might not be present in user-written shaders.
#define TRANSFER_SHADOW_CASTER(o) TRANSFER_SHADOW_CASTER_NOPOS_LEGACY(o,o.pos)

struct appdata_base {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct appdata_full {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 texcoord2 : TEXCOORD2;
    float4 texcoord3 : TEXCOORD3;
    real4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct appdata_tan {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#define TANGENT_SPACE_ROTATION \
    float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; \
    float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal )

#define SCALED_NORMAL v.normal

// Encoding/decoding [0..1) floats into 8 bit/channel RGBA. Note that 1.0 will not be encoded properly.
inline float4 EncodeFloatRGBA(float v)
{
    float4 kEncodeMul = float4(1.0, 255.0, 65025.0, 16581375.0);
    float kEncodeBit = 1.0 / 255.0;
    float4 enc = kEncodeMul * v;
    enc = frac(enc);
    enc -= enc.yzww * kEncodeBit;
    return enc;
}
inline float DecodeFloatRGBA(float4 enc)
{
    float4 kDecodeDot = float4(1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0);
    return dot(enc, kDecodeDot);
}
inline float4 ComputeGrabScreenPos(float4 pos) {
#if UNITY_UV_STARTS_AT_TOP
    float scale = -1.0;
#else
    float scale = 1.0;
#endif
    float4 o = pos * 0.5f;
    o.xy = float2(o.x, o.y * scale) + o.w;
#ifdef UNITY_SINGLE_PASS_STEREO
    o.xy = TransformStereoScreenSpaceTex(o.xy, pos.w);
#endif
    o.zw = pos.zw;
    return o;
}
#define UNITY_NO_SCREENSPACE_SHADOWS 1

#ifdef UNITY_COLORSPACE_GAMMA
#define unity_ColorSpaceGrey real4(0.5, 0.5, 0.5, 0.5)
#define unity_ColorSpaceDouble real4(2.0, 2.0, 2.0, 2.0)
#define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
#define unity_ColorSpaceLuminance half4(0.22, 0.707, 0.071, 0.0) // Legacy: alpha is set to 0.0 to specify gamma mode
#else // Linear values
#define unity_ColorSpaceGrey real4(0.214041144, 0.214041144, 0.214041144, 0.5)
#define unity_ColorSpaceDouble real4(4.59479380, 4.59479380, 4.59479380, 2.0)
#define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)
#define unity_ColorSpaceLuminance half4(0.0396819152, 0.458021790, 0.00609653955, 1.0) // Legacy: alpha is set to 1.0 to specify linear mode
#endif

inline half3 DecodeLightmap(real4 color)
{
    half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);
    return DecodeLightmap(color, decodeInstructions);
}
#define TRANSFER_VERTEX_TO_FRAGMENT(a)  TRANSFER_SHADOW(a)

float2 TransformWViewToHClip(float2 positionVS)
{
    return mul((float2x2)GetViewToHClipMatrix(), positionVS);
}

//real4 _SpecColor;
//
half3x3 CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
    // For odd-negative scale transforms we need to flip the sign
    half sign = tangentSign * unity_WorldTransformParams.w;
    half3 binormal = cross(normal, tangent) * sign;
    return half3x3(tangent, binormal, normal);
}

inline float2 UnityStereoScreenSpaceUVAdjustInternal(float2 uv, float4 scaleAndOffset)
{
    return uv.xy * scaleAndOffset.xy + scaleAndOffset.zw;
}

inline float4 UnityStereoScreenSpaceUVAdjustInternal(float4 uv, float4 scaleAndOffset)
{
    return float4(UnityStereoScreenSpaceUVAdjustInternal(uv.xy, scaleAndOffset), UnityStereoScreenSpaceUVAdjustInternal(uv.zw, scaleAndOffset));
}

#define UnityStereoScreenSpaceUVAdjust(x, y) UnityStereoScreenSpaceUVAdjustInternal(x, y)

struct appdata_img
{
    float4 vertex : POSITION;
    half2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct v2f_img
{
    float4 pos : SV_POSITION;
    half2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
};
#define COMPUTE_EYEDEPTH(o) o = -TransformWorldToView( v.vertex ).z
// real UnityApplyDitherCrossFadeValue(half2 vpos)
// {
//     float p = GenerateHashedRandomFloat(vpos);
//     real sgn = unity_LODFade.x > 0 ? 1.0f : -1.0f;
//     return (1 - step(0, (unity_LODFade.x - p * sgn)));
// }

#define UNITY_DIRBASIS \
const half3x3 unity_DirBasis = half3x3( \
  half3( 0.81649658,  0.0,        0.57735027), \
  half3(-0.40824830,  0.70710678, 0.57735027), \
  half3(-0.40824830, -0.70710678, 0.57735027) \
);

#define UNITY_SHOULD_SAMPLE_SH !LIGHTMAP_ON


v2f_img vert_img(appdata_img v)
{
    v2f_img o;
    ZERO_INITIALIZE(v2f_img, o);
    UNITY_SETUP_INSTANCE_ID(v);

    o.pos = TransformObjectToHClip(v.vertex);
    o.uv = v.texcoord;
    return o;
}

struct SurfaceOutput {
    real3 Albedo;
    real3 Normal;
    real3 Emission;
    half Specular;
    real Gloss;
    real Alpha;
};
#define COMPUTE_VIEW_NORMAL normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal))
#if !defined(DIRLIGHTMAP_OFF) && !defined(DIRLIGHTMAP_COMBINED)
#define DIRLIGHTMAP_OFF 1
#endif

#if !defined(LIGHTMAP_OFF) && !defined(LIGHTMAP_ON)
#define LIGHTMAP_OFF 1
#endif
inline half Luminance_GrayScale(half3 rgb)
{
    return dot(rgb, unity_ColorSpaceLuminance.rgb);
}
#endif