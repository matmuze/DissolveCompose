#include "Noise Shaders/SimplexNoise3D.cginc"

int	_NumFrequencies;

float _EdgeWidth;
float _FringeSize;
float _NoiseScale;
float _DistanceThreshold;

float3 _EdgeColor;
float4 _StartEffectPos;

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