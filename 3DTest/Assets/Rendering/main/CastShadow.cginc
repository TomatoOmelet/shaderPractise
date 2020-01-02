
#if !defined(CastShadowDefined)
#define CastShadowDefined

#include "UnityCG.cginc"

#if defined(_RENDERING_FADE) && !defined(_RENDERING_TRANSPARENT)
	#define SHADOWS_SEMITRANSPARENT 1
#endif


#if defined(_RENDERING_CUTOUT) || SHADOWS_SEMITRANSPARENT
    #if!defined(_SMOOTHNESS_ALBEDO)
	    #define SHADOWS_NEED_UV 1
    #endif
#endif

float4 _Tint;
sampler2D _MainTexture;
float4 _MainTexture_ST;
float _AlphaCutoff;

sampler3D DitherMaskLOD;

struct VertexData{
    fixed4 position:POSITION;
    fixed3 normal: NORMAL;
    float2 uv : TEXCOORD0;
};

struct InterpolatorsVertex {
    float4 position : SV_POSITION;
    #if defined(SHADOWS_NEED_UV)
        float2 uv : TEXCOORD0;
    #endif
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD1;
    #endif
};

struct InterpolatorsFrag {
    #if SHADOWS_SEMITRANSPARENT
		UNITY_VPOS_TYPE vpos : VPOS;
	#else
		float4 positions : SV_POSITION;
	#endif

    #if defined(SHADOWS_NEED_UV)
        float2 uv : TEXCOORD0;
    #endif
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD1;
    #endif
};

InterpolatorsVertex ShadowVertex (VertexData v) {
    InterpolatorsVertex i;
    #if defined(SHADOWS_CUBE)
        i.position = UnityObjectToClipPos(v.position);
        i.lightVec =
            mul(unity_ObjectToWorld, v.position).xyz - _LightPositionRange.xyz;
    #else
        i.position = UnityClipSpaceShadowCasterPos(v.position, v.normal);
        i.position = UnityApplyLinearShadowBias(i.position);
    #endif
    
    #if SHADOWS_NEED_UV
		i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
	#endif
    return i;
}

float GetAlpha (InterpolatorsVertex i) {
	float alpha = _Tint.a;
	#if SHADOWS_NEED_UV
		alpha *= tex2D(_MainTexture, i.uv.xy).a;
	#endif
	return alpha;
}

float4 ShadowFrag (InterpolatorsVertex i) : SV_TARGET {
    float alpha = GetAlpha(i);
	#if defined(_RENDERING_CUTOUT)
		clip(alpha - _AlphaCutoff);
	#endif

    #if defined(SHADOWS_CUBE)
        float depth = length(i.lightVec) + unity_LightShadowBias.x;
        depth *= _LightPositionRange.w;
        return UnityEncodeCubeShadowDepth(depth);
    #else
        return 0;
    #endif
}

#endif