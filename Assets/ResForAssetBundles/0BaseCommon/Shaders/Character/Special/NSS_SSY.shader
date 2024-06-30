Shader "QF/Character/Special/NSS_SSY"
{
	Properties{
		
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RimPower ("Rim Power", Range(1,8)) = 5
		_MaskTex ("Mask (R轮廓光,G流光,B光泽度)", 2D) = "white" {}
		
		_SpecColor ("Spec Color", color) = (0,0,0,0)
		_SpecPower ("Spec Power", Range(1,60.0)) = 15
		_SpecMultiplier("Spec Multiplier", float) = 1
		
		_RampMap ("Ramp Map", 2D) = "white" {}
		
		_ShadowColor("Shadow Color", Color)=(0,0,0,0)
		_LightTex("轮廓光 (RGB)", 2D) = "white" {}	
		_LightColor ("Spec Color", color) = (0,0,0,0)
		_NormalTex("Normal", 2D) = "bump" {}
		
		_ReflectTex ("Reflect(RGB)", 2D) = "white" {}
		_ReflectColor ("Reflect Color", Color) = (1,1,1,1)
		_ReflectPower ("Reflect Power", Range(0.1,5.0)) = 1
		_ReflectionMultiplier ("Reflection Multiplier", Float) = 2.0
				
		_ChangeColor("Change Color", Color) = (1, 1, 1, 1)
		
		_RimTex("Flow(G)", 2D) = "black" {}
		
		_GlowCol ("GlowCol", Color) = (0, 0, 0, 0)
		_GlowPow ("GlowPow/GlowScale", Vector) = (1,1,1,1)
		
		_UvPan("UvPan",vector) = (0, 0, 0, 0)
		_UVPanCol ("UVPanCol", Color) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

			half _Scroll2X;
			half _Scroll2Y;
			half _MMultiplier;
			
			
			
			half3 _NoiseColor;
			//half3 _SpecColor;
			
CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			half _RimPower;
real4 _SpecColor;
			half _SpecPower;
			half _SpecMultiplier;
			float4 _RampMap_ST;
			half4 _ShadowColor;
			half4 _LightColor;
			half3 _ReflectColor;
			half _ReflectPower;
			half _ReflectionMultiplier;
			half4 _ChangeColor;
			float4 _GlowCol;
            half4 _GlowPow;
            half4 _UvPan;
            half4 _UVPanCol;
CBUFFER_END
			half4 _GlobalRimColor2;
			
            half _GlowScale;
            
            sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _LightTex;
			sampler2D _NormalTex;
			sampler2D _ReflectTex;
			sampler2D _RampMap;	
			sampler2D _RimTex;		

			struct VertexInput 
			{
				float4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
                half4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 normalWorld : TEXCOORD1;
				half3 binormalWorld : TEXCOORD2;
				half3 tangentWorld : TEXCOORD3;
				half3 viewDir : TEXCOORD4;
				half3 lightDir : TEXCOORD5;
				half3 rim : TEXCOORD7;
			}; 
			
			v2f vert (VertexInput v)
			{
				v2f o;
				Light light = GetMainLight();
				o.pos = TransformObjectToHClip(v.vertex);
				o.uv = v.texcoord.xy;
				o.viewDir = normalize((GetCameraPositionWS() - TransformObjectToWorld(v.vertex.xyz)));
				o.lightDir = normalize(_MainLightPosition.xyz);
			
				o.normalWorld = mul(UNITY_MATRIX_M,half4(v.normal, 0.0)).xyz;
				o.tangentWorld = mul(UNITY_MATRIX_M, half4(v.tangent.xyz,0)).xyz;
				o.binormalWorld = cross(o.normalWorld, o.tangentWorld) * v.tangent.w;
				
				half NdotL = dot(o.normalWorld, o.lightDir);
				
				o.rim.xy = TRANSFORM_TEX(v.texcoord.xy, _RampMap);
				o.rim.y += _Time.z  * _UvPan.y * -2;
				o.rim.x += _Time.z  * _UvPan.x * -2;	

				half rimCoe = clamp(1 - dot(o.viewDir, o.normalWorld), 0.02, 0.98);
				o.rim.z = rimCoe * saturate(NdotL * 0.5 + 0.5);				
				
				return o;
			}

			half3 CalcLight(half3 albedo, half3 normal, half3 lightDir, half3 viewDir, half3 gloss, real shadow)
			{
				//NoL ∈ [0.02, 0.98]
				half diff = dot(normal, lightDir) * 0.49 + 0.49;
				
				half3 n2 = normalize(reflect(-viewDir, normal));
				//[0, 1]
				float nh = max(0, dot(n2, lightDir)* 0.5+0.5);

				float spec = pow(nh, _SpecPower) * gloss.r * _SpecMultiplier * shadow * 2;

				//dir specular
				half3 color = _SpecColor.rgb * spec * albedo;
				color +=albedo;

				half ramp = tex2D(_RampMap, half2(diff, 0.5)).r;
				half rimCoe=saturate(1 - dot(viewDir, normal));
				half rim = saturate (pow ((diff *rimCoe),_RimPower)*(1+_RimPower));
				
				half3 rimColor = rim * _GlobalRimColor2;

				color = lerp (color*color,color,ramp)+rimColor;

				//lerp color and shadow
				if(shadow >= 0)
				{
					half3 darkColor = albedo * _ShadowColor.rgb;// * _ShadowColor.a;
					return lerp(darkColor, color, shadow);
				}
				else
					return color;
			}		
			
			half4 frag (v2f i) : SV_Target
			{
				half3 normalTS = normalize(UnpackNormal(tex2D(_NormalTex, i.uv.xy)));
				half3x3 tbn = half3x3(i.tangentWorld, i.binormalWorld, i.normalWorld);
				half3 normalWS = mul(normalTS, tbn);

				half3 normalVS = normalize(mul(UNITY_MATRIX_V, half4(normalWS, 0)).xyz);
				half2 litTexUV = normalVS.xy * 0.5 + 0.5;
				
				half4 Light = tex2D(_LightTex, litTexUV) * 1.2;
				half4 Base = tex2D(_MainTex, i.uv.xy);
				half4 Mask = tex2D(_MaskTex, i.uv.xy);
				half4 Flow = tex2D(_RimTex, i.rim.xy) * _UVPanCol;

				half3 albedo = Base.rgb + (Light.rgb*Mask.r);
				
				half2 uvReflect = litTexUV;
				
				half3 reflectColor = tex2D(_ReflectTex, uvReflect).rgb*_ReflectColor;
				
				//在diffuse 和 spec 中 插值
				albedo= lerp ( albedo ,albedo * reflectColor * _ReflectPower *_ReflectionMultiplier,Mask.b);

				half3 gloss = Mask.rgb;
				half shadow = 1;
				half3 viewDir = normalize(i.viewDir);
				half3 lightDir = normalize(i.lightDir);

				half3 color = CalcLight(albedo, normalWS, lightDir, viewDir, gloss, shadow);
				color += pow(i.rim.z,_GlowPow.x)*_GlowCol*_GlowPow.y;

				half4 finalC = half4(color * _ChangeColor.xyz + Flow.g * Mask.g, 1);			

				return finalC;
			}
			ENDHLSL
		}
	}
}
