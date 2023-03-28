
#include "shaderNoise.hlsl"

// 定数バッファ
cbuffer ConstatntBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;

    float4 CameraPosition;
    float4 Parameter;

}

//大気色と合成
//レイマーチング

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
void main(in float4 inPosition : SV_POSITION,
            in float4 inWorldPosition : POSITION0,
			in float4 inNormal : NORMAL0,
			in float4 inDiffuse : COLOR0,
			in float2 inTexCoord : TEXCOORD0,

			out float4 outDiffuse : SV_Target)
{

    float3 diffuse = 0.0;

    //大気距離
    float dist = distance(inWorldPosition, CameraPosition);

    //視線ベクトル
    float3 eye = inWorldPosition - CameraPosition;
    eye = normalize(eye);

    //ミー散乱
    float m;
    m = saturate(-dot(Light.Direction.xyz, eye));
    m = pow(m, 50);

    diffuse += m * dist * 0.003;

    //レイリー散乱
    float3 vy = float3(0.0, 1.0, 0.0);
    float atm = saturate(1.0 - dot(-Light.Direction.xyz, vy));
    float3 rcolor = 1.0 - float3(0.5, 0.8, 1.0) * atm * 1.0;

    float ld = 0.5 - dot(Light.Direction.xyz, eye) * 0.5;
    diffuse += rcolor * dist * ld * float3(0.5, 0.8, 1.0) * 0.004;

    outDiffuse.rgb = diffuse;
    outDiffuse.a = 1.0;

    //outDiffuse.rgb *= (voronoi2(inTexCoord) + 1.0) ;

}
