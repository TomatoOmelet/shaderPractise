// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/Rendering/Bumpness"
{

    Properties
    {
        _Color("_Tint", Color) = (1, 1, 1, 1)
        //_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
        [Gamma]_Metalic("Metalic", Range(0, 1)) = 0
        _MainTexture("Albedo", 2D) = "white"{}
        [NoScaleOffset]_NormalMap("Normal", 2D) = "bump"{}
        _BumpScale("Bump Scale", range(0, 5)) = 1
        _DetailedTexture("Detail Texture", 2D) = "white"{}
        [NoScaleOffset]_DetailNormalMap("Detail Normal", 2D) = "bump"{}
        _DetailBumpScale("Detail Bump Scale", range(0, 5)) = 1
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
            sampler2D _MainTexture, _DetailedTexture, _NormalMap, _DetailNormalMap;
            float4 _MainTexture_ST, _DetailedTexture_ST;
            float _Smoothness, _Metalic, _BumpScale, _DetailBumpScale;

            struct VertexData{
                float4 obPos : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct InterpolationData{
                float4 position : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            InterpolationData MyVertex(VertexData v)
            {
                InterpolationData i;
                i.worldPos = mul(unity_ObjectToWorld ,v.obPos);
                i.position = UnityObjectToClipPos(v.obPos);
                i.uv.xy = TRANSFORM_TEX(v.uv, _MainTexture);
                i.uv.zw = TRANSFORM_TEX(v.uv, _DetailedTexture);
                i.normal = UnityObjectToWorldNormal(v.normal);
                return i;
            }

            void InitializeFragmentNormal(inout InterpolationData i)
            {
                //for RGB encoding
                //i.normal = tex2D(_NormalMap, i.uv).rgb * 2 - 1;
                //i.normal = i.normal.xzy;

                //for DXT5
                /*
                i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
                i.normal.xy *= _BumpScale;
                i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));*/
                float3 normal1 = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
                float3 normal2 = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
                i.normal = BlendNormals(normal1, normal2);
                //i.normal = float3(normal1.xy + normal2.xy, normal1.z * normal2.z);
                i.normal = i.normal.xzy;
            }

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                InitializeFragmentNormal(i);

                float3 reflectDir = reflect(-lightDir, i.normal);
                float3 lightCol = _LightColor0.rgb;
                
                //float3 halfVector = normalize(lightDir + viewDir);
                
                float3 albedo = tex2D(_MainTexture, i.uv.xy).rgb * _Color.rgb;
                albedo *= tex2D(_DetailedTexture, i.uv.wz) * unity_ColorSpaceDouble;
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