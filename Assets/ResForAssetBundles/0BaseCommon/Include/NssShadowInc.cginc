#ifndef NSS_SHADOW_INCLUDED
#define  NSS_SHADOW_INCLUDED

#ifdef _MAIN_LIGHT_SHADOWS
	float4 _MainLightShadowmapTexture_TexelSize;
	#define SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

	#if defined(UNITY_NO_SCREENSPACE_SHADOWS)
		//TEXTURE2D_SHADOW(_MainLightShadowmapTexture);SAMPLER_CMP(sampler_MainLightShadowmapTexture);
		#define SAMPLE_SHADOW(tex, coord) SAMPLE_TEXTURE2D_SHADOW(tex , sampler##tex ,  coord)
	#else
		UNITY_DECLARE_SCREENSPACE_SHADOWMAP(_MainLightShadowmapTexture);
		#define SAMPLE_SHADOW(tex, coord) UNITY_SAMPLE_SCREEN_SHADOW(tex,coord)
	#endif


	float4 NssCombineShadowcoordComponents(float2 baseUV, float2 deltaUV, float depth, float3 receiverPlaneDepthBias)
	{
		float4 uv = float4(baseUV + deltaUV, depth + receiverPlaneDepthBias.z, 1.0f);
		uv.z += dot(deltaUV, receiverPlaneDepthBias.xy);
		return uv;
	}

	float NssInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(float triangleHeight)
	{
		return triangleHeight - 0.5;
	}

	
	void  NssInternalGetAreaPerTexel_3TexelsWideTriangleFilter(float offset, out float4 computedArea, out float4 computedAreaUncut)
	{
		//Compute the exterior areas
		float offset01SquaredHalved = (offset + 0.5) * (offset + 0.5) * 0.5;
		computedAreaUncut.x = computedArea.x = offset01SquaredHalved - offset;
		computedAreaUncut.w = computedArea.w = offset01SquaredHalved;

		//Compute the middle areas
		//For Y : We find the area in Y of as if the left section of the isoceles triangle would
		//intersect the axis between Y and Z (ie where offset = 0).
		computedAreaUncut.y = NssInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(1.5 - offset);
		//This area is superior to the one we are looking for if (offset < 0) thus we need to
		//subtract the area of the triangle defined by (0,1.5-offset), (0,1.5+offset), (-offset,1.5).
		float clampedOffsetLeft = min(offset, 0);
		float areaOfSmallLeftTriangle = clampedOffsetLeft * clampedOffsetLeft;
		computedArea.y = computedAreaUncut.y - areaOfSmallLeftTriangle;

		//We do the same for the Z but with the right part of the isoceles triangle
		computedAreaUncut.z = NssInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(1.5 + offset);
		float clampedOffsetRight = max(offset, 0);
		float areaOfSmallRightTriangle = clampedOffsetRight * clampedOffsetRight;
		computedArea.z = computedAreaUncut.z - areaOfSmallRightTriangle;
	}

	void NssInternalGetWeightPerTexel_3TexelsWideTriangleFilter(float offset, out float4 computedWeight)
	{
		float4 dummy;
		NssInternalGetAreaPerTexel_3TexelsWideTriangleFilter(offset, computedWeight, dummy);
		computedWeight *= 0.44444;//0.44 == 1/(the triangle area)
	}


	half NssSampleShadowmap_PCF3x3(float4 coord, float3 receiverPlaneDepthBias)
	{
		half shadow = 1;

		// tent base is 3x3 base thus covering from 9 to 12 texels, thus we need 4 bilinear PCF fetches
		float2 tentCenterInTexelSpace = coord.xy * _MainLightShadowmapTexture_TexelSize.zw;
		float2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
		float2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

		// find the weight of each texel based
		float4 texelsWeightsU, texelsWeightsV;
		NssInternalGetWeightPerTexel_3TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU);
		NssInternalGetWeightPerTexel_3TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV);

		// each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
		float2 fetchesWeightsU = texelsWeightsU.xz + texelsWeightsU.yw;
		float2 fetchesWeightsV = texelsWeightsV.xz + texelsWeightsV.yw;

		// move the PCF bilinear fetches to respect texels weights
		float2 fetchesOffsetsU = texelsWeightsU.yw / fetchesWeightsU.xy + float2(-1.5, 0.5);
		float2 fetchesOffsetsV = texelsWeightsV.yw / fetchesWeightsV.xy + float2(-1.5, 0.5);
		fetchesOffsetsU *= _MainLightShadowmapTexture_TexelSize.xx;
		fetchesOffsetsV *= _MainLightShadowmapTexture_TexelSize.yy;

		// fetch !
		float2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * _MainLightShadowmapTexture_TexelSize.xy;
		shadow = fetchesWeightsU.x * fetchesWeightsV.x * SAMPLE_SHADOW(_MainLightShadowmapTexture, NssCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
		shadow += fetchesWeightsU.y * fetchesWeightsV.x * SAMPLE_SHADOW(_MainLightShadowmapTexture, NssCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
		shadow += fetchesWeightsU.x * fetchesWeightsV.y * SAMPLE_SHADOW(_MainLightShadowmapTexture, NssCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
		shadow += fetchesWeightsU.y * fetchesWeightsV.y * SAMPLE_SHADOW(_MainLightShadowmapTexture, NssCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));

		return shadow;
	}
#endif
#endif
