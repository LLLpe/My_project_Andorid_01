#ifndef NSS_STATIC_SHADOWMAP_INC
#define NSS_STATIC_SHADOWMAP_INC

// ====================================================================
// 计算静态阴影
// ====================================================================
half _ShadowPower;
sampler2D _ShadowMap;


#if defined(STATIC_SHADOW)
//静态阴影的自定义参数

UNITY_INSTANCING_BUFFER_START(Props) 
    UNITY_DEFINE_INSTANCED_PROP(float4x4, _ShadowMapVP) 
UNITY_INSTANCING_BUFFER_END(Props)


//未使用A通道的解码float
inline float DecodeFloatRGB( float4 enc )
{
    float4 kDecodeDot = float4(1.0, 1/255.0, 1/65025.0, 0);
    return dot( enc, kDecodeDot );
}

//计算在贴图中的uv坐标和在相机空间中的深度
float2 CalcShadowUVAndVPSapceDepth(float3 worldPos, out float ndcZ)
{
    float4x4 vp = UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowMapVP);
	//vp矩阵最后一行是 0 0 0 1
	//所以用来存 start X, start Y, 1/Size
	
	half4 texRect = vp[3];
	
	//恢复正常矩阵
	vp[3] = half4(0,0,0,1);
	
	half4 ndcpos = UnityMulPos(vp,float4(worldPos,1));
    ndcpos.xyz = ndcpos.xyz / ndcpos.w;
    //从[-1,1]转换到[0,1]
    ndcpos.xy = ndcpos.xy * 0.5 + 0.5;
    
	ndcpos.xy = ndcpos.xy * texRect.zz +texRect.xy;
	ndcZ = ndcpos.z;
	return ndcpos.xy;
}

//计算阴影
half CalcShadowByNDC(half3 ndcpos)
{	
    half sampleDepth = DecodeFloatRGB(tex2D(_ShadowMap, ndcpos.xy));
     
    half depth = ndcpos.z;
    depth += 0.001;
 
    //计算静态阴影强度，简易软阴影
    half shadow = saturate((sampleDepth - depth)*_ShadowPower);        

    return shadow;
}

//计算阴影
half CalcShadow(float3 worldPos)
{	
    half3 ndc;
    ndc.xy =  CalcShadowUVAndVPSapceDepth(worldPos,ndc.z);

    return  CalcShadowByNDC(ndc);
}
//计算阴影
float GetStaticShadowCenterAtten()
{	
   float4x4 vp = UNITY_ACCESS_INSTANCED_PROP(Props, _ShadowMapVP);
	//vp矩阵最后一行是 0 0 0 1
	//所以用来存 start X, start Y, 1/Size, centerAtten
	
	return vp[3][3];
}

#endif
///=======================================================================================

#if defined(STATIC_SHADOW_SH)


UNITY_INSTANCING_BUFFER_START(NssSingleSHLight)
    UNITY_DEFINE_INSTANCED_PROP(float4x4, _SingleShLightA)
    UNITY_DEFINE_INSTANCED_PROP(float4x4, _SingleShLightB)
UNITY_INSTANCING_BUFFER_END(NssSingleSHLight)	


    half3 StaticSingleSH9(half4 normal)
	{
	
        float4x4 shA = UNITY_ACCESS_INSTANCED_PROP(NssSingleSHLight, _SingleShLightA);	
        float4x4 shB = UNITY_ACCESS_INSTANCED_PROP(NssSingleSHLight, _SingleShLightB);	
         // Linear (L1) + constant (L0) polynomial terms
        half3 x =  0;
        x.r = dot(shA[0],normal);
        x.g = dot(shA[1],normal);
        x.b = dot(shA[2],normal);
        
        half3 x1, x2;
        
        // 4 of the quadratic (L2) polynomials
        half4 vB = normal.xyzz * normal.yzzx;
        x1.r = dot(shB[0],vB);
        x1.g = dot(shB[1],vB);
        x1.b = dot(shB[2],vB);
    
        // Final (5th) quadratic (L2) polynomial
        half vC = normal.x*normal.x - normal.y*normal.y;
        x2 = shB[3].rgb * vC;
        
        half3 color = x + x1 + x2;
        
#ifdef UNITY_COLORSPACE_GAMMA
        color = LinearToGammaSpace (color);
#endif
        return (color);
	}


#endif

#endif
