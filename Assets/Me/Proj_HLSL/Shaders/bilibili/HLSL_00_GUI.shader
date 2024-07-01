Shader "URP/HLSL_01_GUI"
{
    Properties
    {
        [MainTexture]_MainTex("Color" , 2D) = "white"{}
        _ColorTint("Tint" , color) = (1,1,1,1)
        _Specularint("Specular" , Range(0,1)) = 1
        _Smoothness("Smoorhness" , Range(0,1)) = 1
        _Metallicint("Metallic" , Range(0,1)) = 1
    }
    
    SubShader
    {

        Pass
        {
            
            Name "ForwardLit" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Pass specific tags. 
            HLSLPROGRAM
            
            #define _SPECULAR_COLOR 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CACADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
            #pragma vertex vert 
            #pragma fragment frag

           #include "MyForwardLitPass.hlsl"


            
            ENDHLSL
        }
        pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}
            
            HLSLPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            
            #include "MyLitShadowCasterPass.hlsl"
            
            ENDHLSL
            
            
        }

    }
    CustomEditor "MyTestShaderGUI"
}
