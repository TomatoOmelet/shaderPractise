#if !defined(LightInclude)
#define LightInclude

#include "AutoLight.cginc"
#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityPBSLighting.cginc"

#endif

float4 _Color;//, _SpecularTint;
sampler2D _MainTexture;
float4 _MainTexture_ST;
float _Smoothness, _Metalic;

struct VertexData{
    float4 obPos : POSITION;
    float3 normal: NORMAL;
    float2 uv : TEXCOORD0;
};

struct InterpolationData{
    float4 position : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 normal : TEXCOORD2;
};

InterpolationData MyVertex(VertexData v)
{
    InterpolationData i;
    i.worldPos = mul(unity_ObjectToWorld ,v.obPos);
    i.position = UnityObjectToClipPos(v.obPos);
    i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
    i.normal = UnityObjectToWorldNormal(v.normal);
    return i;
}

UnityLight CreateLight(InterpolationData i)
{
    UnityLight light;
    
    float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
    //float attenuation; = 10/(1 + dot(lightVec, lightVec));
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
    #if defined(POINT)|| defined(SPOT)
        light.dir = normalize(lightVec);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(light.color, light.dir);
    return light;
}

float4 MyFrag(InterpolationData i) : SV_TARGET
{
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    i.normal = normalize(i.normal);    
    //float3 halfVector = normalize(lightDir + viewDir);
    
    float3 albedo = tex2D(_MainTexture, i.uv).rgb * _Color.rgb;
    float3 spectularTint = albedo * _Metalic;
    //float4 spectular = float4(lightCol * spectularTint.rgb, 1) *pow(DotClamped(halfVector, i.normal), _Smoothness*10);

    float oneMinusReflectivity = 1 - _Metalic;
    albedo = DiffuseAndSpecularFromMetallic(albedo, _Metalic, spectularTint, oneMinusReflectivity);//= EnergyConservationBetweenDiffuseAndSpecular(albedo, spectular.rgb ,oneMinusReflectivity);
    //float4 diffuse = float4(albedo * lightCol * DotClamped(i.normal, lightDir), 1);

    UnityIndirect indirect;
    indirect.diffuse = 0;
    indirect.specular = 0;
    
    return UNITY_BRDF_PBS(albedo, spectularTint,
                            oneMinusReflectivity, _Smoothness,
                            i.normal, viewDir,
                            CreateLight(i), indirect);//spectular + diffuse;
}

