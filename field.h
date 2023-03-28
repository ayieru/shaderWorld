#pragma once

#include "shader.h"



class CField : public CGameObject
{
private:


	ID3D11Buffer*	m_VertexBuffer = NULL;
	ID3D11Buffer*	m_IndexBuffer = NULL;
	CTexture*		m_Texture = NULL;


	static const int FIELD_X = 256;
	static const int FIELD_Z = 256;

	VERTEX_3D m_Vertex[FIELD_X * FIELD_Z];


	CShader*		m_Shader;

	float			m_LightRotation;

public:
	void Init();
	void Uninit();
	void Update();
	void Draw();


};