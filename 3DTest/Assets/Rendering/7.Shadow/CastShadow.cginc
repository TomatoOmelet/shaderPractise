// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(CastShadowDefined)
#define CastShadowDefined

#include "UnityCG.cginc"

struct VertexData{
    float4 position:POSITION;
};


float4 ShadowVertex(VertexData v) : SV_POSITION
{
    return UnityObjectToClipPos(v.position);
}

fixed4 ShadowFrag(): SV_TARGET
{
    return 0;
}

#endif