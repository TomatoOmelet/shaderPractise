#if !defined(LightForComplexMaterialsInclude)
#define LightForComplexMaterialsInclude

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"

#endif

float4 _Tint;//, _SpecularTint;
sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;
sampler2D _MainTexture, _DetailTex;
float4 _MainTexture_ST, _DetailTex_ST;
sampler2D _MetallicTexture;
float _Smoothness, _Metalic;

struct VertexData{
    float4 vertex : POSITION;
    float3 normal: NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT;
};

struct InterpolationData{
    float4 pos : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float4 uv : TEXCOORD1;
    float3 normal : TEXCOORD2;
    #if defined(BINORMAL_PER_FRAGMENT)
		float4 tangent : TEXCOORD4;
	#else
		float3 tangent : TEXCOORD4;
		float3 binormal : TEXCOORD6;
	#endif
    SHADOW_COORDS(5)

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

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

InterpolationData MyVertex(VertexData v)
{
    InterpolationData i;
    i.worldPos = mul(unity_ObjectToWorld ,v.vertex);
    i.pos = UnityObjectToClipPos(v.vertex);
    i.uv.xy = TRANSFORM_TEX(v.uv, _MainTexture);
    i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
    i.normal = UnityObjectToWorldNormal(v.normal);

    #if defined(BINORMAL_PER_FRAGMENT)
		i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	#else
		i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
		i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
	#endif

    TRANSFER_SHADOW(i);
    CalculateVertexLight(i);
    return i;
}

UnityLight CreateLight(InterpolationData i)
{
    UnityLight light;
    
    float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;

    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

    #if defined(POINT)|| defined(SPOT) || defined(POINT_COOKIE)
        light.dir = normalize(lightVec);
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(light.color, light.dir);
    return light;
}

//handling box projection for the reflection probe
float3 BoxProjection(float3 direction, float3 position, float4 cubemapPosition, float3 boxMin, float3 boxMax)
{
    #if UNITY_SPECCUBE_BOX_PROJECTION
        UNITY_BRANCH
        if(cubemapPosition.w > 0){
            float3 factor = ((direction > 0? boxMax : boxMin) - position)/direction;
            float scale = min(min(factor.x, factor.y), factor.z);
            direction = direction * scale + (cubemapPosition - position);
        }
    #endif
    return direction;
}

float GetSmoothness(InterpolationData i)
{
    float smooth = 1;
    #if defined(_SMOOTHNESS_ALBEDO)
        smooth = tex2D(_MainTexture, i.uv).a * _Smoothness;
    #elif defined(_SMOOTHNESS_METALLIC)
        smooth = tex2D(_MetallicTexture, i.uv).a * _Smoothness;
    #endif
    return smooth * _Smoothness;
}

UnityIndirect CreateIndirectLight(InterpolationData i, float3 viewDir)
{
    UnityIndirect indirect;
    indirect.diffuse = 0;
    indirect.specular = 0;
    #if defined(VERTEXLIGHT_ON)
        indirect.diffuse = i.vertexColor;
    #endif
    
    #if defined(FORWARD_BASE_PASS)
        indirect.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
        float3 reflectDir = reflect(-viewDir, i.normal);
        Unity_GlossyEnvironmentData envData;
        envData.roughness = 1 - GetSmoothness(i);
        envData.reflUVW = BoxProjection(reflectDir, i.worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        //indirect.specular = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube0,unity_SpecCube0), unity_SpecCube0_HDR, envData);
        float3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
        #if UNITY_SPECCUBE_BLENDING
            float interpolater = unity_SpecCube0_BoxMin.w;
            UNITY_BRANCH
            if(interpolater < 0.999)
            {
                envData.reflUVW = BoxProjection(reflectDir, i.worldPos, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
                float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), unity_SpecCube1_HDR, envData);
                indirect.specular = lerp(probe1, probe0, interpolater);
            }else{
                indirect.specular = probe0;
            }
        #else
            indirect.specular = probe0;
        #endif
    #endif

    return indirect;
}

float GetMetallic(InterpolationData i)
{
    #if defined(_METALLIC_MAP)
        return tex2D(_MetallicTexture, i.uv).r;
    #else
        return _Metalic;
    #endif
}

void InitializeFragmentNormal(inout InterpolationData i) 
{
	float3 mainNormal =
		UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
	float3 detailNormal =
		UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif
	
	i.normal = normalize(
		tangentSpaceNormal.x * i.tangent +
		tangentSpaceNormal.y * binormal +
		tangentSpaceNormal.z * i.normal
	);
}

float4 MyFrag(InterpolationData i) : SV_TARGET
{
    float metalic = GetMetallic(i);
    float smoothness = GetSmoothness(i);
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    InitializeFragmentNormal(i);    
    //float3 halfVector = normalize(lightDir + viewDir);
    
    float3 albedo = tex2D(_MainTexture, i.uv).rgb * _Tint.rgb;
    float3 spectularTint = albedo * metalic;
    //float4 spectular = float4(lightCol * spectularTint.rgb, 1) *pow(DotClamped(halfVector, i.normal), smoothness*10);

    float oneMinusReflectivity = 1 - metalic;
    albedo = DiffuseAndSpecularFromMetallic(albedo, metalic, spectularTint, oneMinusReflectivity);//= EnergyConservationBetweenDiffuseAndSpecular(albedo, spectular.rgb ,oneMinusReflectivity);
    //float4 diffuse = float4(albedo * lightCol * DotClamped(i.normal, lightDir), 1);
  
    return UNITY_BRDF_PBS(albedo, spectularTint,
                            oneMinusReflectivity, smoothness,
                            i.normal, viewDir,
                            CreateLight(i), CreateIndirectLight(i, viewDir));//spectular + diffuse;
}

