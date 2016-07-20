
#include "Noise Shaders/SimplexNoise3D.cginc"

int	_NumFrequencies;

float _EdgeWidth;
float _FringeSize;
float _NoiseScale;
float _DistanceThreshold;

float3 _EdgeColor;
float4 _StartEffectPos;

sampler2D _RandomTexture;

float hash(float n)
{ 
	return frac(sin(n)*753.5453123); 
}

static const float3x3 mm = float3x3(0.00, 0.80, 0.60,
									-0.80, 0.36, -0.48,
									-0.60, -0.48, 0.64);

float noise(float3 x)
{
	float3 p = floor(x);
	float3 f = frac(x);
	f = f*f*(3.0 - 2.0*f);

	float n = p.x + p.y * 157.0 + 113.0 * p.z;
	return	lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
					  lerp(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
				 lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
					  lerp(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float fastnoise(float3 x)
{
	float3 p = floor(x);
	float3 f = frac(x);
	f = f*f*(3.0 - 2.0*f);

	float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
	uv = (uv + 0.5) / 256.0;
	uv.y = 1 - uv.y;
	float2 rg = tex2Dbias(_RandomTexture, float4(uv,0,-100)).yx;
	//float2 rg = tex2D(_RandomTexture, (uv + 0.5) / 256.0).yx;
	return lerp(rg.x, rg.y, f.z);
}

float getNoiseCheap(float3 pos)
{
	float3 q = 8 * pos;

	//float f = 0.5000*noise(q);
	/*q = mul(mm, q )* 2.01;	
	f += 0.2500*noise(q);
	q = mul(mm, q )* 2.02;
	f += 0.1250*noise(q); 
	q = mul(mm, q )* 2.03;
	f += 0.0625*noise(q); */

	float f = 0.5000*fastnoise(q);
	q = mul(mm, q)* 2.01;
	f += 0.2500*fastnoise(q);
	q = mul(mm, q)* 2.02;
	f += 0.1250*fastnoise(q);
	q = mul(mm, q)* 2.03;
	f += 0.0625*fastnoise(q);

	return f;
}

float getNoise(float3 pos)
{
	pos *= _NoiseScale;

	float o = 0.5; //_NoiseOffset
	float s = 1; //_NoiseStartScale
	float w = 0.25; //_NoiseStartWeight;

	for (int i = 0; i < _NumFrequencies; i++)
	{
		float3 coord = float3(pos * s);
		o += snoise(coord) * w;

		s *= 2.00; //_NoiseScaleIncrease;
		w *= 0.5; // _NoiseWeigthIncrease;
	}

	return o.x;
}