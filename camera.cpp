
#include "main.h"
#include "renderer.h"
#include "game_object.h"
#include "camera.h"
#include "input.h"



CCamera* CCamera::m_Instance = nullptr;


void CCamera::Init()
{

	m_Position = XMFLOAT3( 0.0f, 5.0f, 0.0f );
	m_Rotation = XMFLOAT3( 0.0f, 0.0f, 0.0f );


	m_Viewport.left = 0;
	m_Viewport.top = 0;
	m_Viewport.right = SCREEN_WIDTH;
	m_Viewport.bottom = SCREEN_HEIGHT;

}


void CCamera::Uninit()
{


}


void CCamera::Update()
{


	XMFLOAT3 left, front;

	left.x = cosf( m_Rotation.y );
	left.z = -sinf( m_Rotation.y );

	front.x = sinf( m_Rotation.y );
	front.z = cosf( m_Rotation.y );

	if (CInput::GetKeyPress('H'))
	{
		m_Position.x -= left.x * 0.1f;
		m_Position.z -= left.z * 0.1f;
	}
	if (CInput::GetKeyPress('K'))
	{
		m_Position.x += left.x * 0.1f;
		m_Position.z += left.z * 0.1f;
	}

	if (CInput::GetKeyPress('U'))
	{
		m_Position.x += front.x * 0.1f;
		m_Position.z += front.z * 0.1f;
	}
	if (CInput::GetKeyPress('J'))
	{
		m_Position.x -= front.x * 0.1f;
		m_Position.z -= front.z * 0.1f;
	}

	if (CInput::GetKeyPress('T'))
		m_Position.y += 0.05f;
	if (CInput::GetKeyPress('G'))
		m_Position.y -= 0.05f;

	if (CInput::GetKeyPress('Y'))
		m_Rotation.y -= 0.05f;
	if (CInput::GetKeyPress('I'))
		m_Rotation.y += 0.05f;

	if (CInput::GetKeyPress('O'))
		m_Rotation.x -= 0.05f;
	if (CInput::GetKeyPress('L'))
		m_Rotation.x += 0.05f;

}



void CCamera::Draw()
{



	// ビューポート設定
	D3D11_VIEWPORT dxViewport;
	dxViewport.Width = (float)(m_Viewport.right - m_Viewport.left);
	dxViewport.Height = (float)(m_Viewport.bottom - m_Viewport.top);
	dxViewport.MinDepth = 0.0f;
	dxViewport.MaxDepth = 1.0f;
	dxViewport.TopLeftX = (float)m_Viewport.left;
	dxViewport.TopLeftY = (float)m_Viewport.top;

	CRenderer::GetDeviceContext()->RSSetViewports(1, &dxViewport);



	// ビューマトリクス設定
	XMMATRIX invViewMatrix = XMMatrixRotationRollPitchYaw(m_Rotation.x, m_Rotation.y, m_Rotation.z);
	invViewMatrix *= XMMatrixTranslation(m_Position.x, m_Position.y, m_Position.z);

	XMVECTOR det;
	XMMATRIX viewMatrix = XMMatrixInverse(&det, invViewMatrix);

	DirectX::XMStoreFloat4x4(&m_InvViewMatrix, invViewMatrix);
	DirectX::XMStoreFloat4x4(&m_ViewMatrix, viewMatrix);

	//CRenderer::SetViewMatrix(&m_ViewMatrix);



	// プロジェクションマトリクス設定
	XMMATRIX projectionMatrix = XMMatrixPerspectiveFovLH(1.2f, dxViewport.Width / dxViewport.Height, 0.1f, 1000.0f);

	DirectX::XMStoreFloat4x4(&m_ProjectionMatrix, projectionMatrix);

	//CRenderer::SetProjectionMatrix(&m_ProjectionMatrix);


}



void CCamera::DrawShadow()
{



	// ビューポート設定
	D3D11_VIEWPORT dxViewport;
	dxViewport.Width = (float)(m_Viewport.right - m_Viewport.left);
	dxViewport.Height = (float)(m_Viewport.bottom - m_Viewport.top);
	dxViewport.MinDepth = 0.0f;
	dxViewport.MaxDepth = 1.0f;
	dxViewport.TopLeftX = (float)m_Viewport.left;
	dxViewport.TopLeftY = (float)m_Viewport.top;

	CRenderer::GetDeviceContext()->RSSetViewports(1, &dxViewport);



	// ビューマトリクス設定
	XMMATRIX invViewMatrix = XMMatrixRotationRollPitchYaw(m_Rotation.x, m_Rotation.y, m_Rotation.z);
	invViewMatrix *= XMMatrixTranslation(m_Position.x, m_Position.y, m_Position.z);

	XMVECTOR det;
	XMMATRIX viewMatrix = XMMatrixInverse(&det, invViewMatrix);

	DirectX::XMStoreFloat4x4(&m_InvViewMatrix, invViewMatrix);
	DirectX::XMStoreFloat4x4(&m_ViewMatrix, viewMatrix);

	//CRenderer::SetViewMatrix(&m_ViewMatrix);



	// プロジェクションマトリクス設定
	XMMATRIX projectionMatrix = XMMatrixPerspectiveFovLH(1.0f, dxViewport.Width / dxViewport.Height, 1.0f, 10.0f);

	DirectX::XMStoreFloat4x4(&m_ProjectionMatrix, projectionMatrix);

	//CRenderer::SetProjectionMatrix(&m_ProjectionMatrix);


}

