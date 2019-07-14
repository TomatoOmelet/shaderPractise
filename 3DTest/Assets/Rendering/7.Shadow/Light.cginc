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
    #if defined(VERTEXLIGHT_ON)
        float3 vertexColor : TEXCOORD3;
    #endif
};

void CalculateVertexLight(inout InterpolationData i)
{
    #if defined(VERTEXLIGHT_ON)
        // float3 lightPos = float3(unity_4LightPosX0.x, unity_4LightPosY0.x,unity_4LightPosZ0.x);
        // float3 lightVec = lightPos - i.worldPos;
        // float3 lightDir = normalize(lightVec);
        // float ndotl = DotClamped(lightDir, i.normal);
        // float attenuation = 1/(1 + dot(lightVec, lightVec) * unity_4LightAtten0.x);
        // i.vertexColor = unity_LightColor[0].rgb * attenuation * ndotl;
        i.vertexColor = Shade4PointLights(
            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
            unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
            unity_4LightAtten0, i.worldPos, i.normal 
        );
    #endif
}

InterpolationData MyVertex(VertexData v)
{
    InterpolationData i;
    i.worldPos = mul(unity_ObjectToWorld ,v.obPos);
    i.position = UnityObjectToClipPos(v.obPos);
    i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
    i.normal = UnityObjectToWorldNormal(v.normal);
    CalculateVertexLight(i);
    return i;
}

UnityLight CreateLight(InterpolationData i)
{
    UnityLight light;
    
    float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
    //float attenuation; = 10/(1 + dot(lightVec, lightVec));
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
    #if defined(POINT)|| defined(SPOT) || defined(POINT_COOKIE)
        light.dir = normalize(lightVec);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(light.color, light.dir);
    return light;
}

UnityIndirect CreateIndirectLight(InterpolationData i)
{
    UnityIndirect indirect;
    indirect.diffuse = 0;
    indirect.specular = 0;
    #if defined(VERTEXLIGHT_ON)
        indirect.diffuse = i.vertexColor;
    #endif
    
    #if defined(FORWARD_BASE_PASS)
        indirect.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
    #endif

    return indirect;
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
  
    return UNITY_BRDF_PBS(albedo, spectularTint,
                            oneMinusReflectivity, _Smoothness,
                            i.normal, viewDir,
                            CreateLight(i), CreateIndirectLight(i));//spectular + diffuse;
}

