

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
}

// ライトバッファ
struct LIGHT
{
	float4 Direction;
	float4 Diffuse;
	float4 Ambient;
};

cbuffer LightBuffer : register(b1)
{
	LIGHT Light;
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
	float dx = fbmabs2((inTexCoord - float2(0.002, 0.0)) * 0.05, 10) * 10.0
		- fbmabs2((inTexCoord + float2(0.002, 0.0)) * 0.05, 10) * 10.0;

	float dz = fbmabs2((inTexCoord - float2(0.0, 0.002)) * 0.05, 10) * 10.0
		- fbmabs2((inTexCoord + float2(0.0, 0.002)) * 0.05, 10) * 10.0;

	float3 normal;
	normal.xyz = cross(float3(0.0, dz, 0.004), float3(0.004, -dx, 0.0));
	normal.xyz = normalize(normal.xyz);

	//ライト
	float3 lightDir = float3(1.0, -1.0, 1.0);
	lightDir = normalize(lightDir);
	//float light = saturate(0.5 - dot(normal, lightDir) * 0.5);
    float light = 0.5 - dot(inNormal.xyz, light) * 0.5;
	outDiffuse.rgb *= light;

	//ライト入れた

	//色
	//float slope = 1.0 - dot(normal, float3 (0.0, 1.0, 0.0));
	float slope = 1.0 - dot(normal, inWorldPosition.xyz);
	float3 ret = lerp(float3 (1.0, 1.0, 1.0), float3 (0.7, 0.7, 1.0), smoothstep(0.0, 0.2, slope * slope));
	ret = lerp(ret, float3 (1.0, 1.0, 1.0), saturate(smoothstep(0.6, 0.8, slope)));
	outDiffuse.rgb = ret;

	//水中高さフォグ
	float waterFog = -(inWorldPosition.y + 2.0);
	waterFog = saturate(waterFog);
	outDiffuse.rgb = outDiffuse.rgb * (1.0 - waterFog) + float3(0.0, 0.1, 0.1) * waterFog;

	//霧
	float dist = distance(CameraPosition.xyz, inWorldPosition.xyz);
	dist *= 0.005;
	dist = saturate(dist);
	outDiffuse.rgb = outDiffuse.rgb * (1.0 - dist) + float3(0.0, 0.0, 0.0) * dist;

	//α
	outDiffuse.a = 1.0;
	//outDiffuse.a *= (1.0 - dist);

}
