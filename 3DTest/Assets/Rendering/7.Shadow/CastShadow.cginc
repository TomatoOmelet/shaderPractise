
#if !defined(CastShadowDefined)
#define CastShadowDefined

#include "UnityCG.cginc"

struct VertexData{
    fixed4 position:POSITION;
    fixed3 normal: NORMAL;
};


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