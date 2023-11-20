
// Vertex Shader
struct VS_INPUT
{
	float2 vPosition : POSITION;
	float2 vUVCoords : TEXCOORD0;
};

struct PS_INPUT
{
	float4 vPosition : SV_POSITION;
	float2 vUVCoords : TEXCOORD0;
};

cbuffer SceneConstantBuffer : register(b0)
{
	float4x4 g_MVPMatrix;
};

cbuffer SceneConstantBuffer : register(b1)
{
	float4x4 g_TrackedCameraMatrix;
};


SamplerState g_SamplerState : register(s0);
Texture2D g_Texture : register(t0);


PS_INPUT VSMain(VS_INPUT i)
{
	PS_INPUT o;

	// Input z set to the far plane.
	float4 worldCoords = mul(g_TrackedCameraMatrix, float4(i.vPosition, 1.0, 1.0));
	o.vPosition = mul(g_MVPMatrix, worldCoords);

	// Set depth to 0 to prevent far plane clipping
	o.vPosition.z = 0;

#ifdef VULKAN
	o.vPosition.y = -o.vPosition.y;
#endif

	o.vUVCoords = i.vUVCoords;

	return o;
}

float4 PSMain(PS_INPUT i) : SV_TARGET
{
	// Fetch sample 0
	float4 vColor = g_Texture.Sample(g_SamplerState, i.vUVCoords);

	return vColor;
}