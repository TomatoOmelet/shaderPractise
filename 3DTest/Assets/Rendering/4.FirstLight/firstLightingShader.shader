// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/Rendering/First Lighting Shader"
{

    Properties
    {
        _Color("_Tint", Color) = (1, 1, 1, 1)
        //_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
        [Gamma]_Metalic("Metalic", Range(0, 1)) = 0
        _MainTexture("Albedo", 2D) = "white"{}
        _Smoothness("Smoothness", range(0.01,1)) = 0.01
    }

    SubShader{

        Pass{
            Tags{
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
                
            #pragma vertex MyVertex
            #pragma fragment MyFrag
            #pragma target 3.0
            #include "UnityStandardBRDF.cginc"
            #include "UnityStandardUtils.cginc"
            #include "UnityPBSLighting.cginc"

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

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                i.normal = normalize(i.normal);

                float3 reflectDir = reflect(-lightDir, i.normal);
                float3 lightCol = _LightColor0.rgb;
                
                //float3 halfVector = normalize(lightDir + viewDir);
                
                float3 albedo = tex2D(_MainTexture, i.uv).rgb * _Color.rgb;
                float3 spectularTint = albedo * _Metalic;
                //float4 spectular = float4(lightCol * spectularTint.rgb, 1) *pow(DotClamped(halfVector, i.normal), _Smoothness*10);

                float oneMinusReflectivity = 1 - _Metalic;
                albedo = DiffuseAndSpecularFromMetallic(albedo, _Metalic, spectularTint, oneMinusReflectivity);//= EnergyConservationBetweenDiffuseAndSpecular(albedo, spectular.rgb ,oneMinusReflectivity);
                //float4 diffuse = float4(albedo * lightCol * DotClamped(i.normal, lightDir), 1);

                UnityLight light;
                light.color = lightCol;
                light.dir = lightDir;
                light.ndotl = DotClamped(lightCol, lightDir);

                UnityIndirect indirect;
                indirect.diffuse = 0;
                indirect.specular = 0;
                
                return UNITY_BRDF_PBS(albedo, spectularTint,
                                      oneMinusReflectivity, _Smoothness,
                                      i.normal, viewDir,
                                      light, indirect);//spectular + diffuse;
                
            }

            ENDCG
        }

    }
}