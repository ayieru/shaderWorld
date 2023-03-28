

//2D乱数
float random2(in float2 vec)
{
	return frac(sin(dot(vec.xy, float2(12.9898, 78.233))) * 4378.545);
}
float2 random22(in float2 vec)
{
	vec = float2(dot(vec, float2(127.1, 311.7)), dot(vec, float2(269.5, 183.3)));
	return frac(sin(vec) * (4378.545));
}

//3D乱数
float3 random33(in float3 vec)
{
	vec = float3(dot(vec, float3(127.1, 311.7, 311.9)), dot(vec, float3(269.5, 183.3, 482.1)), dot(vec, float3(334.5, 105.3, 482.1)));
	return frac(sin(vec) * (4378.545));
}

//ボロノイ図
float voronoi2(in float2 vec)
{
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);

	float value = 1.0;

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			float2 offset = float2(x, y);
			float2 position = random22(ivec + offset);
			float dist = distance(position + offset, fvec);
			value = min(value, dist);
		}
	}
	return value;
}

//バリューノイズ 2D
float valueNoise2(in float2 vec)
{
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);

	float a = random2(ivec + float2(0.0, 0.0));
	float b = random2(ivec + float2(1.0, 0.0));
	float c = random2(ivec + float2(0.0, 1.0));
	float d = random2(ivec + float2(1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);

	return lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);
}

//バーリンノイズ 2D
float perlinNoise2(in float2 vec)
{
	float2 ivec = floor(vec);
	float2 fvec = frac(vec);

	float a = dot(random22(ivec + float2(0.0, 0.0)) * 2.0 - 1.0, fvec - float2(0.0, 0.0));
	float b = dot(random22(ivec + float2(1.0, 0.0)) * 2.0 - 1.0, fvec - float2(1.0, 0.0));
	float c = dot(random22(ivec + float2(0.0, 1.0)) * 2.0 - 1.0, fvec - float2(0.0, 1.0));
	float d = dot(random22(ivec + float2(1.0, 1.0)) * 2.0 - 1.0, fvec - float2(1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);

	return lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);
}

//フラクタルパーリンノイズ
float fbm2(in float2 vec, int octave, float offset = 0.0)
{
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0; i < octave; i++)
	{
		value += amplitude * perlinNoise2(vec + offset);
		vec *= 2.0;
		amplitude *= 0.5;
	}

	return value;
}

float fbmabs2(in float2 vec, int octave)
{
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0; i < octave; i++)
	{
		value += amplitude * abs(perlinNoise2(vec));
		vec *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

//3D
float perlinNoise3(in float3 vec)
{
	float3 ivec = floor(vec);
	float3 fvec = frac(vec);

	float a = dot(random33(ivec + float3(0.0, 0.0, 0.0)) * 2.0 - 1.0, fvec - float3(0.0, 0.0, 0.0));
	float b = dot(random33(ivec + float3(1.0, 0.0, 0.0)) * 2.0 - 1.0, fvec - float3(1.0, 0.0, 0.0));
	float c = dot(random33(ivec + float3(0.0, 1.0, 0.0)) * 2.0 - 1.0, fvec - float3(0.0, 1.0, 0.0));
	float d = dot(random33(ivec + float3(1.0, 1.0, 0.0)) * 2.0 - 1.0, fvec - float3(1.0, 1.0, 0.0));

	float e = dot(random33(ivec + float3(0.0, 0.0, 1.0)) * 2.0 - 1.0, fvec - float3(0.0, 0.0, 1.0));
	float f = dot(random33(ivec + float3(1.0, 0.0, 1.0)) * 2.0 - 1.0, fvec - float3(1.0, 0.0, 1.0));
	float g = dot(random33(ivec + float3(0.0, 1.0, 1.0)) * 2.0 - 1.0, fvec - float3(0.0, 1.0, 1.0));
	float h = dot(random33(ivec + float3(1.0, 1.0, 1.0)) * 2.0 - 1.0, fvec - float3(1.0, 1.0, 1.0));

	fvec = smoothstep(0.0, 1.0, fvec);

	float v1 = lerp(lerp(a, b, fvec.x), lerp(c, d, fvec.x), fvec.y);
	float v2 = lerp(lerp(e, f, fvec.x), lerp(g, h, fvec.x), fvec.y);
	float v3 = lerp(v1, v2, fvec.z);

	return v3;
}

//フラクタルパーリンノイズ
float fbm3(in float3 vec, int octave)
{
	float value = 0.0;
	float amplitude = 1.0;

	for (int i = 0; i < octave; i++)
	{
		value += amplitude * perlinNoise3(vec);
		vec *= 2.0;
		amplitude *= 0.5;
	}

	return value;
}

//ネヴュラノイズ
float nebula1(float3 uv)
{
	float n1 = fbm3(uv * 2.9 - 1000.0, 2);
	float n2 = fbm3(uv + n1 * 0.05, 2);
	return n2;
}

float nebula2(float3 uv)
{
	float n1 = fbm3(uv * 1.3 + 115.0, 5);
	float n2 = fbm3(uv + n1 * 0.35, 5);
	return fbm3(uv + n2 * 0.17, 5);
}

float nebula3(float3 uv)
{
	float n1 = fbm3(uv * 3.0, 5);
	float n2 = fbm3(uv + n1 * 0.15, 5);
	return n2;
}

float3 nebula(float3 uv)
{
	uv *= 10.0;
	return nebula1(uv * 0.5) * float3(1.0, 0.0, 0.0) +
		nebula2(uv * 0.4) * float3(0.0, 1.0, 0.0) +
		nebula3(uv * 0.6) * float3(0.0, 0.0, 1.0);

}
