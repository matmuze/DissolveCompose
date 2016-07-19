Shader "Custom/CutoutShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}

	CGINCLUDE
	#pragma multi_compile SRC DST
	ENDCG

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		
		ZWrite On ZTest LEqual Cull Back
		//LOD 200

//		Pass
//		{
//			Name "ShadowCaster"
//			Tags{ "LightMode" = "ShadowCaster" }
//			
//			//Fog{ Mode Off }
//			ZWrite On ZTest LEqual Cull Back
//			//Offset 1, 1
//			
//			CGPROGRAM
//			#pragma vertex vert
//			#pragma fragment frag
//			#pragma fragmentoption ARB_precision_hint_fastest
//			#pragma multi_compile_shadowcaster
//			
//			#include "UnityCG.cginc"
//			#include "AutoLight.cginc"
//			#include "Cutout.cginc"
//
//			struct v2f
//			{
//				V2F_SHADOW_CASTER;
//				float3 worldPos : TEXCOORD0;
//				float clip : SV_ClipDistance0;
//			};
//			
//			v2f vert(appdata_full v)
//			{
//				v2f o;
//				TRANSFER_SHADOW_CASTER(o);
//				o.worldPos = mul(_Object2World, v.vertex);
//				o.clip = 1;
//				return o;
//			}		
//			
//			float4 frag(v2f i) : COLOR
//			{
//				float srcNoise = getNoise(i.worldPos);
//				float srcDist = distance(_StartEffectPos.xyz, i.worldPos);
//				float srcThreshold = saturate((_DistanceThreshold - srcDist) * (1 / _FringeSize));
//
////#if SRC
////				//clip(srcNoise < srcThreshold ? -1 : 1);
////#elif DST
////				//clip(srcNoise > srcThreshold ? -1 : 1);
////#endif
//				return 0;
//				SHADOW_CASTER_FRAGMENT(i);					
//			}
//			ENDCG
//		}
			
		CGPROGRAM
		#pragma target 3.0	
		#pragma surface surf Standard /*fullforwardshadows*/ 
				
		#include "Cutout.cginc"
		
		fixed4 _Color;
		half _Metallic;
		half _Glossiness;
		sampler2D _MainTex;
		
		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		
			float srcNoise = getNoise(IN.worldPos);
			float srcDist = distance(_StartEffectPos.xyz, IN.worldPos);
			float srcThreshold = saturate((_DistanceThreshold - srcDist) * (1 / _FringeSize));
		
#if SRC
			clip(srcNoise < srcThreshold ? -1 : 1);
			o.Albedo = (srcNoise > srcThreshold && srcNoise < srcThreshold + _EdgeWidth / 2) ? float3(0, 0, 0) : c.rgb;
			o.Emission = (srcNoise > srcThreshold && srcNoise < srcThreshold + _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
#elif DST
			clip(srcNoise > srcThreshold ? -1 : 1);
			o.Albedo = (srcNoise < srcThreshold && srcNoise > srcThreshold - _EdgeWidth / 2) ? float3(0, 0, 0) : c.rgb;
			o.Emission = (srcNoise < srcThreshold && srcNoise > srcThreshold - _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
#endif
		}
		
		ENDCG
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent" }

		ZWrite On ZTest LEqual Cull Back
		//LOD 200		

		CGPROGRAM
		#pragma target 3.0	
		#pragma surface surf Standard /*fullforwardshadows*/ alpha:blend

		#include "Cutout.cginc"

		fixed4 _Color;
		half _Metallic;
		half _Glossiness;
		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			float srcNoise = getNoise(IN.worldPos);
			float srcDist = distance(_StartEffectPos.xyz, IN.worldPos);
			float srcThreshold = saturate((_DistanceThreshold - srcDist) * (1 / _FringeSize));			

	#if SRC
			clip(srcNoise < srcThreshold ? -1 : 1);
			o.Albedo = (srcNoise > srcThreshold && srcNoise < srcThreshold + _EdgeWidth / 2) ? float3(0, 0, 0) : c.rgb;
			o.Emission = (srcNoise > srcThreshold && srcNoise < srcThreshold + _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
	#elif DST
			clip(srcNoise > srcThreshold ? -1 : 1);
			o.Albedo = (srcNoise < srcThreshold && srcNoise > srcThreshold - _EdgeWidth / 2) ? float3(0, 0, 0) : c.rgb;
			o.Emission = (srcNoise < srcThreshold && srcNoise > srcThreshold - _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
	#endif
		}

		ENDCG
	}

	FallBack "Diffuse"
}