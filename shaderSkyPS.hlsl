

#include "shaderNoise.hlsl"

Texture2D		g_Texture : register(t0);
SamplerState	g_SamplerState : register(s0);

// 定数バッファ
cbuffer ConstatntBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;

    float4 CameraPosition;
    float4 Parameter;

}

//=============================================================================
// ピクセルシェーダ
//=============================================================================
void main( in  float4 inPosition		: SV_POSITION,
            in float4 inWorldPosition   : POSITION0,
			in  float4 inNormal			: NORMAL0,
			in  float4 inDiffuse		: COLOR0,
			in  float2 inTexCoord		: TEXCOORD0,

			out float4 outDiffuse		: SV_Target )
{
	float offset = Parameter.x * 0.2;

	//プロシージャル雲
	//float noise = fbm2(inTexCoord + fbm2(inTexCoord, 5), 5, offset);
	float noise = fbm2(inTexCoord * 0.5, 8,offset);
	noise += 0.8;
	noise = saturate(noise);

	outDiffuse.a = 0.1;
	/*
	if (noise < 0.5)
	{
		noise = noise * 2.0;
		outDiffuse.rgb = float3(1.0, 1.0, 1.0) * (1.0 - noise)
			+ float3(1.0, 1.0, 1.0) * noise;
	}
	else
	{
		noise = (noise - 0.5) * 2.0;
		outDiffuse.rgb = float3(1.0, 1.0, 1.0) * (1.0 - noise)
			           + float3(0.0, 0.0, 0.0) * noise;
	}*/

	float dx = fbm2((inTexCoord - float2(0.02, 0.0)) * 0.5, 3, offset) * 5
		- fbm2((inTexCoord + float2(0.02, 0.0)) * 0.5, 3, offset) * 5;

	float dz = fbm2((inTexCoord - float2(0.0, 0.02)) * 0.5, 3, offset) * 5
		- fbm2((inTexCoord + float2(0.0, 0.02)) * 0.5, 3, offset) * 5;

	float3 normal;
	normal.xyz = cross(float3(0.0, dz, 0.04), float3(0.04, -dx, 0.0));
	normal.xyz = normalize(normal.xyz);
	normal.y *= -1.0;

	float3 lightDir = float3(1.0, -1.0, 1.0);
	lightDir = normalize(lightDir);
	float light = saturate(0.5 - dot(normal, lightDir) * 0.5);
	outDiffuse.rgb = light;

	////フォグ（霧）
	float dist = distance(CameraPosition.xyz, inWorldPosition.xyz);
	dist *= 0.005;
	dist = saturate(dist);
	outDiffuse.rgb = outDiffuse.rgb * (1.0 - dist)+ float3(1.0, 1.0, 1.0) * dist;

	outDiffuse.a *= (1.0 - dist);

}
