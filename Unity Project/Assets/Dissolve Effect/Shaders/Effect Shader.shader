Shader "Custom/Effect Shader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			//Blend SrcAlpha OneMinusSrcAlpha
			//Blend One OneMinusSrcAlpha // Premultiplied transparency
			//Blend One One // Additive
			//Blend OneMinusDstColor One // Soft Additive
			//Blend DstColor Zero // Multiplicative
			//Blend DstColor SrcColor // 2x Multiplicative

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Cutout.cginc"
			
			float4x4 _InverseView;
			sampler2D _SrcColorTexture;
			sampler2D _DstColorTexture;
			sampler2D_float _SrcDepthTexture;
			sampler2D_float _DstDepthTexture;

			//*****************************//
			
			float4 getWorldPos(float depth, float2 uv)
			{
				float vz = LinearEyeDepth(depth);
				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float3 vpos = float3((uv * 2 - 1) / p11_22, -1) * vz;
				return mul(_InverseView, float4(vpos, 1));
			}

			//*****************************//

			float4 frag(v2f_img i) : COLOR
			{
				float srcDepth = tex2D(_SrcDepthTexture, i.uv);
				float4 srcColor = tex2D(_SrcColorTexture, i.uv);

				float dstDepth = tex2D(_DstDepthTexture, i.uv);
				float4 dstColor = tex2D(_DstColorTexture, i.uv);

				if (srcDepth == dstDepth && srcDepth == 1) discard;

				//******** src *********//
				float4 srcWorldPos = getWorldPos(srcDepth, i.uv);				
				float srcNoise = getNoise(srcWorldPos.xyz);
				float srcDist = distance(_StartEffectPos.xyz, srcWorldPos.xyz);
				float srcThreshold = saturate((_DistanceThreshold - srcDist) * (1 / _FringeSize));	

				//******** dst *********//				
				float4 dstWorldPos = getWorldPos(dstDepth, i.uv);
				float dstNoise = getNoise(dstWorldPos.xyz);
				float dstDist = distance(_StartEffectPos.xyz, dstWorldPos.xyz);
				float dstThreshold = saturate((_DistanceThreshold - dstDist) * (1 / _FringeSize));				
								
				//******** up *********//
				float upDepth = (srcDepth < dstDepth) ? srcDepth : dstDepth;
				float upNoise = (srcDepth < dstDepth) ? srcNoise : dstNoise;
				float upThreshold = (srcDepth < dstDepth) ? srcThreshold : dstThreshold;
				float4 upColor = (srcDepth < dstDepth) ? srcColor : dstColor;

				//******** down *********//
				float downDepth = (srcDepth < dstDepth) ? dstDepth : srcDepth;
				float downNoise = (srcDepth < dstDepth) ? dstNoise : srcNoise;
				float downThreshold = (srcDepth < dstDepth) ? dstThreshold : srcThreshold;
				float4 downColor = (srcDepth < dstDepth) ? dstColor : srcColor;
				
				//***********************//

				float4 outColor = float4(1, 1, 1, 1);

				if(abs(srcDepth - dstDepth) < 0.0001)				
				{
					outColor = (srcNoise < srcThreshold) ? dstColor : srcColor;
				}
				else
				{
					outColor = downColor;
					outColor = (srcDepth < dstDepth ? upNoise > upThreshold : upNoise < upThreshold) ? upColor : outColor;
				}

				return outColor;

				/*else if(false)
				{
					bool test = (srcDepth > dstDepth);

					float upDepth = (srcDepth < dstDepth) ? srcDepth : dstDepth;
					float upNoise = (srcDepth < dstDepth) ? srcNoise : dstNoise;
					float upThreshold = (srcDepth < dstDepth) ? srcThreshold : dstThreshold;
					float4 upColor = (srcDepth < dstDepth) ? srcColor : dstColor;

					float downDepth = (srcDepth < dstDepth) ? dstDepth : srcDepth;
					float downNoise = (srcDepth < dstDepth) ? dstNoise : srcNoise;
					float downThreshold = (srcDepth < dstDepth) ? dstThreshold : srcThreshold;
					float4 downColor = (srcDepth < dstDepth) ? dstColor : srcColor;

					if (downDepth != 1)
					{
						if (test)
						{
							if (downNoise >= downThreshold)
							{
								if (downNoise < downThreshold + width)
									outColor = float4(_EdgeColor, 1);
								else
									outColor = downColor;
							}
							else
							{
								outColor = upColor;
							}
						}
						else
						{
							if (downNoise < downThreshold)
							{
								if (downNoise > downThreshold - width)
									outColor = float4(_EdgeColor, 1);
								else
									outColor = downColor;
							}
							else
							{
								outColor = upColor;
							}
						}
					}

					if (test)
					{
						if (upNoise < upThreshold)
						{
							if (upNoise > upThreshold - width)
								outColor = float4(1, 0, 0, 1);
							else
								outColor = upColor;
						}
					}
					else
					{
						if (upNoise > upThreshold)
						{
							float progress = 1 - (upNoise - (upThreshold - width)) / width;

							if (upNoise < upThreshold + width)
								outColor = float4(1,0,0,1);
							else
								outColor = upColor;
						}
					}
				}		*/						
			}
			ENDCG
		}

		Pass
		{
			//Blend SrcAlpha OneMinusSrcAlpha
			//Blend One OneMinusSrcAlpha // Premultiplied transparency
			Blend One One // Additive
			//Blend OneMinusDstColor One // Soft Additive
			//Blend DstColor Zero // Multiplicative
			//Blend DstColor SrcColor // 2x Multiplicative

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col = 1 - col;
				return col; //float4(1,0,0, col.x);
			}

			ENDCG
		}

	}
}