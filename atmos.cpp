
#include "main.h"
#include "renderer.h"
#include "shader.h"

#include "game_object.h"
#include "atmos.h"
#include "texture.h"
#include "input.h"

#include "camera.h"



void CAtmos::Init()
{

	float sizeXZ = 300.0f;
	float sizeY = 100.0f;

	for (int z = 0; z < SKY_Z; z++)
	{
		for (int x = 0; x < SKY_X; x++)
		{
			m_Vertex[z * SKY_X + x].Position.x = sinf( (float)x / (SKY_X - 1) * XM_2PI ) * (sinf((float)z / (SKY_Z - 1) * XM_PI)) * sizeXZ;
			m_Vertex[z * SKY_X + x].Position.z = cosf( (float)x / (SKY_X - 1) * XM_2PI ) * (sinf((float)z / (SKY_Z - 1) * XM_PI)) * sizeXZ;
			m_Vertex[z * SKY_X + x].Position.y = cosf( (float)z / (SKY_Z - 1) * XM_PI) * sizeY;
			m_Vertex[z * SKY_X + x].Diffuse = XMFLOAT4(0.0f, 0.0f, 0.0f, 1.0f);
			m_Vertex[z * SKY_X + x].TexCoord = XMFLOAT2(x, z);
			m_Vertex[z * SKY_X + x].Normal.x = m_Vertex[z * SKY_X + x].Position.x / sizeXZ;
			m_Vertex[z * SKY_X + x].Normal.y = m_Vertex[z * SKY_X + x].Position.y / sizeXZ;
			m_Vertex[z * SKY_X + x].Normal.z = m_Vertex[z * SKY_X + x].Position.z / sizeY;
		}
	}


	{
		D3D11_BUFFER_DESC bd;
		ZeroMemory(&bd, sizeof(bd));
		bd.Usage = D3D11_USAGE_DEFAULT;
		bd.ByteWidth = sizeof(VERTEX_3D) * SKY_X * SKY_Z;
		bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
		bd.CPUAccessFlags = 0;

		D3D11_SUBRESOURCE_DATA sd;
		ZeroMemory(&sd, sizeof(sd));
		sd.pSysMem = m_Vertex;

		CRenderer::GetDevice()->CreateBuffer(&bd, &sd, &m_VertexBuffer);
	}


	unsigned int index[(SKY_X * 2 + 2) * (SKY_Z - 1) - 2];

	unsigned int i = 0;
	for (int z = 0; z < SKY_Z - 1; z++)
	{
		for (int x = 0; x < SKY_X; x++)
		{
			index[i] = (z + 1) * SKY_X + x;
			i++;
			index[i] = z * SKY_X + x;
			i++;
		}

		if (z == SKY_Z - 2)
			break;

		index[i] = z * SKY_X + SKY_X - 1;
		i++;
		index[i] = (z + 2) * SKY_X;
		i++;
	}


	{
		D3D11_BUFFER_DESC bd;
		ZeroMemory(&bd, sizeof(bd));
		bd.Usage = D3D11_USAGE_DEFAULT;
		bd.ByteWidth = sizeof(unsigned int) * ((SKY_X * 2 + 2) * (SKY_Z - 1) - 2);
		bd.BindFlags = D3D11_BIND_INDEX_BUFFER;
		bd.CPUAccessFlags = 0;

		D3D11_SUBRESOURCE_DATA sd;
		ZeroMemory(&sd, sizeof(sd));
		sd.pSysMem = index;

		CRenderer::GetDevice()->CreateBuffer(&bd, &sd, &m_IndexBuffer);
	}


	m_Shader = new CShader();
	m_Shader->Init("shaderAtmosVS.cso", "shaderAtmosPS.cso");



	m_Position = XMFLOAT3( 0.0f, 0.0f, 0.0f );
	m_Rotation = XMFLOAT3( 0.0f, 0.0f, 0.0f );
	m_Scale = XMFLOAT3( 1.0f, 1.0f, 1.0f );

}


void CAtmos::Uninit()
{

	m_VertexBuffer->Release();
	m_IndexBuffer->Release();

	m_Shader->Uninit();
	delete m_Shader;

}


void CAtmos::Update()
{
	if (CInput::GetKeyPress('W'))
		m_LightRotation += 0.01f;
	if (CInput::GetKeyPress('S'))
		m_LightRotation -= 0.01f;

}


void CAtmos::Draw()
{


	// 頂点バッファ設定
	UINT stride = sizeof(VERTEX_3D);
	UINT offset = 0;
	CRenderer::GetDeviceContext()->IASetVertexBuffers(0, 1, &m_VertexBuffer, &stride, &offset);

	// インデックスバッファ設定
	CRenderer::GetDeviceContext()->IASetIndexBuffer(m_IndexBuffer, DXGI_FORMAT_R32_UINT, 0);

	// マトリクス設定
	XMMATRIX world;
	world = XMMatrixScaling(m_Scale.x, m_Scale.y, m_Scale.z);
	world *= XMMatrixRotationRollPitchYaw(m_Rotation.x, m_Rotation.y, m_Rotation.z);
	world *= XMMatrixTranslation(m_Position.x, m_Position.y, m_Position.z);
	//CRenderer::SetWorldMatrix( &world );

	XMFLOAT4X4 worldf;
	DirectX::XMStoreFloat4x4(&worldf, world);

	m_Shader->SetWorldMatrix(&worldf);


	CCamera* camera = CCamera::GetInstance();
	m_Shader->SetViewMatrix(&camera->GetViewMatrix());
	m_Shader->SetProjectionMatrix(&camera->GetProjectionMatrix());
	m_Shader->SetCameraPosition(&camera->GetPosition());


	m_Shader->Set();


	LIGHT light;
	light.Direction = XMFLOAT4(0.0f, -cosf(m_LightRotation), sinf(m_LightRotation), 0.0f);
	light.Diffuse = COLOR(0.9f, 0.9f, 0.9f, 1.0f);
	light.Ambient = COLOR(0.1f, 0.1f, 0.1f, 1.0f);
	m_Shader->SetLight(light);


	// プリミティブトポロジ設定
	CRenderer::GetDeviceContext()->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP);

	// ポリゴン描画
	CRenderer::GetDeviceContext()->DrawIndexed(((SKY_X * 2 + 2) * (SKY_Z - 1) - 2), 0, 0);


}


