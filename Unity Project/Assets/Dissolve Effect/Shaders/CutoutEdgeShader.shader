Shader "Custom/CutoutEdgeShader"
{
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile SRC DST

			#include "Cutout.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORDS0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{		
				float srcNoise = getNoise(i.worldPos);
				float srcDist = distance(_StartEffectPos.xyz, i.worldPos);
				float srcThreshold = saturate((_DistanceThreshold - srcDist) * (1 / _FringeSize));
				
				float3 color = float3(1, 0, 0);

#if SRC
				clip(srcNoise < srcThreshold ? -1 : 1);
				color = (srcNoise > srcThreshold && srcNoise < srcThreshold + _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
#elif DST
				clip(srcNoise > srcThreshold ? -1 : 1);
				color = (srcNoise < srcThreshold && srcNoise > srcThreshold - _EdgeWidth / 2) ? _EdgeColor : float3(0, 0, 0);
#endif

				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
