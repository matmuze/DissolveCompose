// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/WorldPosShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		//Tags { "RenderType" = "WorldPos" }
		//LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex);
				return o;
			}

			float4x4 _InverseView;

			float4 frag(v2f i) : SV_Target
			{
				/*float2 uv = i.vertex.xy / _ScreenParams.xy;
				float vz = LinearEyeDepth(i.vertex.z);
				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float3 vpos = float3((uv * 2 - 1) / p11_22, -1) * vz;
				float4 wpos = mul(_InverseView, float4(vpos, 1));*/

				//return float4(uv, 0,1);
				//return float4(wpos.xyz, 1);

				return float4(i.worldPos.xyz, 1);
			}
			ENDCG
		}
	}	
}
