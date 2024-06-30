#ifndef NSS_FOG_INCLUDE
#define NSS_FOG_INCLUDE

#include "Env/NssOceanCommonProperties.cginc"
#include "Env/NssWaveCommon.cginc"
#include "../include/QSM_BASE_MACRO.cginc"


// ------------------------------------------------------------------
//  NSS Fog helpers
//
//  #pragma multi_compile _ NSS_FOG_NORMAL NSS_FOG_SEA  // 启用NssFog
//  NSS_FOG_COORDS(texcoordindex)  Declares the fog data interpolator.
//  NSS_TRANSFER_FOG(outputStruct, worldPos, cameraWorldPos)  Outputs fog data from the vertex shader.
//  NSS_TRANSFER_FOG_MS(outputStruct, modelPos, cameraWorldPos)
//  NSS_APPLY_FOG(outputStruct,col)  Applies fog to color "col". Automatically applies black fog when in forward-additive pass.
//  NSS_CALC_FOG(outputStruct,col)  Calculate fog color. Automatically applies black fog when in forward-additive pass.


//#   define NSS_FOG_NORMAL 1

#if defined(NSS_FOG_NORMAL) || defined(NSS_FOG_SEA)
//#if NSS_FOG_NORMAL
    half4 _NssFogColor;
    half _NssFogDensity;
    float _NssFogNearDistance;
    float _NssFogFarDistance;
	float _NssFogCamUnderWater;
    real _HasOceanTopDepthTex;

    half _NssHFogZero; /* 高度雾起始高度，默认值0 */
    half _NssHFogHeightFalloff; /* 高度雾衰减，范围0.001-2，默认值0.1 */ 
    float _NssHFogHeight; /* 高度雾起始高度，默认值0 */     
    half _NssHFogDensity; /* 高度雾密度，范围0-2，默认值0 */     
    half _NssHFogMaxOpacity; /* 高度雾最大不透明度，范围0-1，默认值0 */ 
    float _NssHFogStartDistance; /* 高度雾起始距离，默认值0 */ 
    half4 _NssHFogColor;  /* 高度雾颜色，默认值(0.447,0.638,1.0) */ 
    half _NssFogInscatteringExponent;/* 散射指数，范围1-64,默认值4 */
    float _NssFogInscatteringStartDistance;/* 散射距摄像机起始距离，范围>0,默认值100 */
    half4 _NssFogInscatteringColor;  /* 散射颜色，范围0-2，默认值(0.25,0.25,0.125) */


   // #define NSS_FOG_LINEAR_FOG_FACTOR(distance, beginDis, endDis, fogDensity) ((fogDensity) * ((distance) - (beginDis)) / ((endDis) - (beginDis)))

	#define NSS_FOG_LINEAR_FOG_FACTOR(distance, beginDis, endDis, fogDensity) min(fogDensity, ((distance) - (beginDis)) / ((endDis) - (beginDis)))
    #define NSS_FOG_LINEAR_FOG_FACTOR_NOMIN(distance, beginDis, endDis)  ((distance) - (beginDis)) / ((endDis) - (beginDis))

    #if defined(NSS_FOG_NORMAL)
        // ---------------------------------------------------------------------------------------
        //  普通雾
        #define NSS_FOG_COORDS(idx) float3 nssFogCoord : TEXCOORD##idx;
#ifdef _ONLY_DISTANCE_FOG
		#define NSS_TRANSFER_FOG(o, worldPos, camWorldPos) \
            float nssFog_Distance = - UnityMulPos(UNITY_MATRIX_V, worldPos).z; /* distance */ \
            /*o.nssFogCoord = NSS_FOG_LINEAR_FOG_FACTOR(nssFog_Distance, _NssFogNearDistance, _NssFogFarDistance, _NssFogDensity);*/ /* Linear FogFactor */ \
            /* 大气雾 */ \
            float fogblendDist = NSS_FOG_LINEAR_FOG_FACTOR_NOMIN(nssFog_Distance, _NssFogNearDistance, _NssFogFarDistance);  \
			o.nssFogCoord.x =  saturate(min( _NssFogDensity,fogblendDist)); \
            //o.nssFogCoord.y =  saturate(ExpFogFactor); \
            //o.nssFogCoord.z =  saturate(DirectionalInscattering  );
#else
        #define NSS_TRANSFER_FOG(o, worldPos, camWorldPos) \
            float nssFog_Distance = - UnityMulPos(UNITY_MATRIX_V, worldPos).z; /* distance */ \
            /*o.nssFogCoord = NSS_FOG_LINEAR_FOG_FACTOR(nssFog_Distance, _NssFogNearDistance, _NssFogFarDistance, _NssFogDensity);*/ /* Linear FogFactor */ \
            /* 大气雾 */ \
            float fogblendDist = NSS_FOG_LINEAR_FOG_FACTOR_NOMIN(nssFog_Distance, _NssFogNearDistance, _NssFogFarDistance);  \
            /* 高度雾 */ \
            float ExpFogFactor = GetHeightFog (worldPos);\
            /* 大气散射 */ \
            float DirExp = pow(fogblendDist, 2); \
            float3 CameraToReceiverNormalized = normalize(-(GetCameraPositionWS() - worldPos));  \
            float DirectionalLightInscattering = pow(saturate(dot(CameraToReceiverNormalized, _SunDir)), _NssFogInscatteringExponent);/* 散射光大小，_SunColor * _NssFogInscatteringColor * 颜色 */    \
            float DirExponentialHeightLineIntegral = DirExp * max(nssFog_Distance - _NssFogInscatteringStartDistance, 0.0f); /* 散射光与摄像机开始距离  */ \
            float DirectionalInscatteringFogFactor = saturate(exp2(-DirExponentialHeightLineIntegral)); \
            float DirectionalInscattering = (DirectionalLightInscattering * (1 - DirectionalInscatteringFogFactor)); /* 正常应该不加saturate，因为工程没有hdr，所以可以截取，方便制作编码 */ \
            o.nssFogCoord.x =  saturate(min( _NssFogDensity,fogblendDist)); \
            o.nssFogCoord.y =  saturate(ExpFogFactor); \
            o.nssFogCoord.z =  saturate(DirectionalInscattering  );
#endif
            // float nssFog_Distance = length((worldPos).xyz - (camWorldPos).xyz); /* distance */
        //#define INNER_NSS_CALC_FOG(o,col) float4(lerp((col).rgb, _NssFogColor.rgb, saturate(o.nssFogCoord)), (col).a)
        #define INNER_NSS_CALC_FOG(o,col) NssAtmosphericInscattering(o.nssFogCoord,col)

        #define INNER_NSS_CALC_FOG_SEA_TOP(o, col) (col)
        #define INNER_NSS_CALC_FOG_SEA_BOTTOM(o, col) (col)
        #define NSS_FOG_GET_SEA_TOP_DENSITY(o) 0
        #define NSS_FOG_GET_SEA_BOTTOM_DENSITY(o) 0

        float NssFogCalculateLineIntegralShared(float FogHeightFalloff, float RayDirectionZ, float RayOriginTerms)
        {
	        float Falloff = max(-127.0f, FogHeightFalloff * RayDirectionZ);    // if it's lower than -127.0, then exp2() goes crazy in OpenGL's GLSL.
	        float LineIntegral = (1.0f - exp2(-Falloff)) / Falloff;
	        float LineIntegralTaylor = log(2.0) - (0.5 * pow(log(2.0), 2)) * Falloff;		// Taylor expansion around 0

	        return RayOriginTerms * (abs(Falloff) > 0.01f ? LineIntegral : LineIntegralTaylor);
        }

        float GetHeightFog (float4 vpos)
        {
            float realHeight = _WorldSpaceCameraPos.y - _NssHFogZero;
            float FogDensity = exp2(-_NssHFogHeightFalloff * (realHeight - _NssHFogHeight))*_NssHFogDensity;
            half MinFogOpacity = 1 - _NssHFogMaxOpacity;
            float3 CameraToReceiver = vpos - _WorldSpaceCameraPos;
        	float CameraToReceiverLengthSqr = dot(CameraToReceiver, CameraToReceiver); 
	        float CameraToReceiverLengthInv = rsqrt(CameraToReceiverLengthSqr);
	        float CameraToReceiverLength = CameraToReceiverLengthSqr * CameraToReceiverLengthInv;
	        float3 CameraToReceiverNormalized = CameraToReceiver * CameraToReceiverLengthInv;
	
	        float RayOriginTerms = FogDensity;
	        float RayLength = CameraToReceiverLength;
	        float RayDirectionZ = CameraToReceiver.y;

            float ExcludeDistance = max(0, _NssHFogStartDistance);
            float ExcludeIntersectionTime = ExcludeDistance * CameraToReceiverLengthInv;
		    float CameraToExclusionIntersectionZ = ExcludeIntersectionTime * CameraToReceiver.y;
		    float ExclusionIntersectionZ = realHeight + CameraToExclusionIntersectionZ;
		    float ExclusionIntersectionToReceiverZ = CameraToReceiver.y - CameraToExclusionIntersectionZ;
	
		    RayLength = (1.0f - ExcludeIntersectionTime) * CameraToReceiverLength;
		    RayDirectionZ = ExclusionIntersectionToReceiverZ;
	
		    float Exponent = max(-127.0f, _NssHFogHeightFalloff * (ExclusionIntersectionZ - _NssHFogHeight));
		    RayOriginTerms = _NssHFogDensity * exp2(-Exponent);

            float ExponentialHeightLineIntegralShared = NssFogCalculateLineIntegralShared(_NssHFogHeightFalloff, RayDirectionZ, RayOriginTerms);
	        float ExponentialHeightLineIntegral = ExponentialHeightLineIntegralShared * RayLength;

            float ExpFogFactor = max(saturate(exp2(-ExponentialHeightLineIntegral)), MinFogOpacity);
            ExpFogFactor = 1 - ExpFogFactor;
            return ExpFogFactor;
        }

        half4 NssAtmosphericInscattering(float3 nssFogCoord, half4 inputColor)
        {      
#ifdef _ONLY_DISTANCE_FOG
		half4 vdiffuseCol = lerp(inputColor, _NssFogColor, nssFogCoord.x);
#else
               half4 InscatteringCol = half4 (_SunColor * _NssFogInscatteringColor *  nssFogCoord.z,1);
               half4 AFogColor =  _NssFogColor + InscatteringCol ;
               half4 HFogColor =  _NssHFogColor.rgbb + InscatteringCol ;
               half4 vdiffuseCol = lerp(inputColor, AFogColor,nssFogCoord.x);
               vdiffuseCol = lerp(vdiffuseCol, HFogColor,nssFogCoord.y);
#endif
               vdiffuseCol.a = inputColor.a ;
               return vdiffuseCol;

        }
    #elif defined(NSS_FOG_SEA)
        // ---------------------------------------------------------------------------------------
        //  支持海面的雾效
        #define NSSFOGCOORD_TYPE float4
        #define NSS_FOG_COORDS(idx) NSSFOGCOORD_TYPE nssFogCoord : TEXCOORD##idx;
        #define NSS_TRANSFER_FOG(o, worldPos, camWorldPos)  \
            float nssFog_Distance = - UnityMulPos(UNITY_MATRIX_V, worldPos).z; /* distance */ \
            float nssFog_SeaLevel = NssFog_GetSeaLevel(worldPos); \
            float nssFog_DensityA = exp2(-_OceanBedFogHeightFalloff * (camWorldPos.y - nssFog_SeaLevel))*_OceanFogDensity; \
            float nssFog_wOceanFogDensity = saturate(nssFog_DensityA);/* 摄像机上下位置变化产生雾浓度变化 */ \
            float nssFog_vOceanBedFogDisDensity = (nssFog_Distance - _OceanBedFogNear) / (_OceanBedFogFar - _OceanBedFogNear); \
            nssFog_vOceanBedFogDisDensity = 1 - (1 - saturate ( nssFog_vOceanBedFogDisDensity * (nssFog_wOceanFogDensity + 1))) * _NssFogCamUnderWater; \
            nssFog_vOceanBedFogDisDensity = min(nssFog_vOceanBedFogDisDensity, _OceanBedFogDisDensityMax); \
            o.nssFogCoord.x = NSS_FOG_LINEAR_FOG_FACTOR(nssFog_Distance, _NssFogNearDistance, _NssFogFarDistance, _NssFogDensity); /* Linear FogFactor */ \
            o.nssFogCoord.y = nssFog_wOceanFogDensity; \
            o.nssFogCoord.z = nssFog_SeaLevel - worldPos.y; /* 相对海平面高度 */ \
            o.nssFogCoord.w = nssFog_vOceanBedFogDisDensity;

        #define INNER_NSS_CALC_FOG(o,col) NssCalcFog_Sea(o.nssFogCoord, col)

        #define NSS_FOG_GET_SEA_TOP_DENSITY(o) saturate(o.nssFogCoord.x)
        #define NSS_FOG_GET_SEA_BOTTOM_DENSITY(o) saturate(o.nssFogCoord.w)
        #define INNER_NSS_CALC_FOG_SEA_TOP(o, col) NssCalcFog_SeaTop(o.nssFogCoord, col)
        #define INNER_NSS_CALC_FOG_SEA_BOTTOM(o, col) NssCalcFog_SeaBottom(o.nssFogCoord, col)

        half4 NssCalcFog_Sea(NSSFOGCOORD_TYPE nssFogCoord, half4 inputColor)
        {
			//_NssFogCamUnderWater = 0;
            float4 colorWithAirFog = float4(lerp(inputColor.rgb, _NssFogColor.rgb, saturate(nssFogCoord.x)), inputColor.a); // 计算出带空气雾的颜色

			float wOceanFogDensity = nssFogCoord.y;
            float vdeltaHeight = nssFogCoord.z;
            float vOceanBedFogDisDensity = nssFogCoord.w;

            float vfogParam = saturate(1 - exp2(-_OceanFogDensity * vdeltaHeight) + wOceanFogDensity);//海面看海底雾 //海面遮罩 back
            half4 vdiffuseCol = lerp(_OceanFogColorShallow  * colorWithAirFog, _OceanFogColorDeep, vfogParam);//海面看海底雾

            // vdiffuseCol = lerp(_OceanBedFogColorNear * colorWithAirFog, _OceanBedFogColorFar * vdiffuseCol, vOceanBedFogDisDensity);
            // float vSoftIntersect = saturate(_OceanFogSoftIntersectionFactor * vdeltaHeight);// * (1-i.vWSCP);//软边
            // vdiffuseCol = lerp(colorWithAirFog, vdiffuseCol, vSoftIntersect);//软边,海底有bug，为节省计算，暂时忽略

            half4 beddiffuseCol = lerp(_OceanBedFogColorNear * colorWithAirFog, _OceanBedFogColorFar, vOceanBedFogDisDensity);//i.vOceanBedFogDisDensity 提取出来，和海面底部a通道相加
            vdiffuseCol = lerp(vdiffuseCol,beddiffuseCol, _NssFogCamUnderWater);
			//return vdiffuseCol;

            float vSoftIntersect = saturate(_OceanFogSoftIntersectionFactor * vdeltaHeight);// * (1-i.vWSCP);//软边
            vdiffuseCol = lerp(colorWithAirFog, vdiffuseCol, saturate(vSoftIntersect * (wOceanFogDensity+1)));

            return vdiffuseCol;
        }

        half4 NssCalcFog_SeaTop(NSSFOGCOORD_TYPE nssFogCoord, half4 inputColor)
        {
            return half4(lerp(inputColor.rgb, _NssFogColor.rgb, saturate(nssFogCoord.x)), inputColor.a); // 计算出带空气雾的颜色
        }

        half4 NssCalcFog_SeaBottom(NSSFOGCOORD_TYPE nssFogCoord, half4 inputColor)
        {
            float4 colorWithAirFog = float4(lerp(inputColor.rgb, _NssFogColor.rgb, saturate(nssFogCoord.x)), inputColor.a); // 计算出带空气雾的颜色

            float wOceanFogDensity = nssFogCoord.y;
            float vdeltaHeight = nssFogCoord.z;
            float vOceanBedFogDisDensity = nssFogCoord.w;

            half4 beddiffuseCol = lerp(_OceanBedFogColorNear * colorWithAirFog, _OceanBedFogColorFar, vOceanBedFogDisDensity);//i.vOceanBedFogDisDensity 提取出来，和海面底部a通道相加
            float vSoftIntersect = saturate(_OceanFogSoftIntersectionFactor * vdeltaHeight);// * (1-i.vWSCP);//软边
            half4 vdiffuseCol = lerp(colorWithAirFog, beddiffuseCol, vSoftIntersect * (wOceanFogDensity + 1));

            return vdiffuseCol;
        }

        float NssFog_GetSeaLevel(float3 worldPos)
        {
            if(_HasOceanTopDepthTex > 0.5)
            {
                float waterHeight = NssSampleHeightMap(worldPos.xyz);//高度图，海面高度
                float deltaHeightMax = max(waterHeight, _GlobalOceanHeight);//高度雾距离计算
                return deltaHeightMax;
            }
            else
            {
                return _GlobalOceanHeight;
            }
        }
		float NssFog_GetSeaLevel(float4 worldPos)
        {
            if(_HasOceanTopDepthTex > 0.5)
            {
                float waterHeight = NssSampleHeightMap(worldPos.xyz);//高度图，海面高度
                float deltaHeightMax = max(waterHeight, _GlobalOceanHeight);//高度雾距离计算
                return deltaHeightMax;
            }
            else
            {
                return _GlobalOceanHeight;
            }
        }
    #endif
#else // defined(NSS_FOG_NORMAL) || defined(NSS_FOG_SEA)
    // ---------------------------------------------------------------------------------------
    // //  旧版本雾效兼容
    // #define NSS_FOG_COORDS(idx) float3 nssFogCamDist : TEXCOORD##idx;
    // #define NSS_TRANSFER_FOG(o, worldPos, camWorldPos)  o.nssFogCamDist = CalcCamDist(mul(unity_WorldToObject, (worldPos)))
    // #define INNER_NSS_CALC_FOG(o,col) NssFog((o).nssFogCamDist, col)
    // 关闭雾效
    #define NSS_FOG_COORDS(idx)
    #define NSS_TRANSFER_FOG(o, worldPos, camWorldPos)
    #define INNER_NSS_CALC_FOG(o,col) (col)
    #define INNER_NSS_CALC_FOG_SEA_TOP(o, col) (col)
    #define INNER_NSS_CALC_FOG_SEA_BOTTOM(o, col) (col)
    #define NSS_FOG_GET_SEA_TOP_DENSITY(o) 0
    #define NSS_FOG_GET_SEA_BOTTOM_DENSITY(o) 0
#endif // end of defined(NSS_FOG_NORMAL) || defined(NSS_FOG_SEA)

#define NSS_TRANSFER_FOG_MS(outputStruct, modelPos, cameraWorldPos) NSS_TRANSFER_FOG(outputStruct, UnityMulPos(UNITY_MATRIX_M, modelPos), cameraWorldPos)

#ifdef UNITY_PASS_FORWARDADD
    #define NSS_APPLY_FOG(o,col) (col)
    #define NSS_CALC_FOG(o,col) (col)
    #define NSS_CALC_FOG_SEA_TOP(o, col) (col)
    #define NSS_CALC_FOG_SEA_BOTTOM(o, col) (col)
#else
    #define NSS_APPLY_FOG(o,col) (col) = (INNER_NSS_CALC_FOG(o,col))
    #define NSS_CALC_FOG(o,col) INNER_NSS_CALC_FOG(o,col)
    #define NSS_CALC_FOG_SEA_TOP(o, col) (col) = (INNER_NSS_CALC_FOG_SEA_TOP(o,col))
    #define NSS_CALC_FOG_SEA_BOTTOM(o, col) (col) = (INNER_NSS_CALC_FOG_SEA_BOTTOM(o,col))
#endif

#endif // end of NSS_FOG_INCLUDE
