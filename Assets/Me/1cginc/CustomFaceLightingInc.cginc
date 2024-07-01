#ifndef CUSTOM_FACE_LIGHTING
#define CUSTOM_FACE_LIGHTING
half4 _MainLightDir;
half3 _CustomMainLightColor;
half4 _VirutualLightDir;
half3 _VirtualLightColor;

half4 _VirutualLightDirVice;
half3 _VirtualLightColorVice;

//SH lighting power
half _EnvLightingPower;

//
//Light in view space originaland and we transform it to world sapce.
//
half3 GetBackLightDir()
{
     return mul(_VirutualLightDirVice, UNITY_MATRIX_V).xyz;
    //return _VirutualLightDirVice.xyz;//mul(_VirutualLightDirVice, UNITY_MATRIX_V).xyz;
}

half3 GetMainLightDir()
{
    return mul(_MainLightDir, UNITY_MATRIX_V).xyz;
    //return mul(UNITY_MATRIX_M, mul(UNITY_MATRIX_T_MV, -_MainLightDir)).xyz;
}

#endif
