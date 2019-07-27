
#if !defined(CastShadowDefined)
#define CastShadowDefined

#include "UnityCG.cginc"

struct VertexData{
    fixed4 position:POSITION;
    fixed3 normal: NORMAL;
};

#if defined(SHADOWS_CUBE)
struct Interpolators {
    float4 position : SV_POSITION;
    float3 lightVec : TEXCOORD0;
};

Interpolators ShadowVertex (VertexData v) {
    Interpolators i;
    i.position = UnityObjectToClipPos(v.position);
    i.lightVec =
        mul(unity_ObjectToWorld, v.position).xyz - _LightPositionRange.xyz;
    return i;
}

float4 ShadowFrag (Interpolators i) : SV_TARGET {
    float depth = length(i.lightVec) + unity_LightShadowBias.x;
    depth *= _LightPositionRange.w;
    return UnityEncodeCubeShadowDepth(depth);
}
#else
fixed4 ShadowVertex(VertexData v) : SV_POSITION
{
    fixed4 pos = UnityClipSpaceShadowCasterPos(v.position, v.normal);
    return UnityApplyLinearShadowBias(pos);
}

fixed4 ShadowFrag(): SV_TARGET
{
    return 0;
}
#endif
#endif