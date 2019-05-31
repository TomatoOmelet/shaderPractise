// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/Rendering/First Lighting Shader"
{

    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTexture("Texture", 2D) = "white"{}
    }

    SubShader{

        Pass{
            CGPROGRAM
                
            #pragma vertex MyVertex
            #pragma fragment MyFrag
            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            struct VertexData{
                float4 obPos : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct InterpolationData{
                float4 position : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            InterpolationData MyVertex(VertexData v)
            {
                InterpolationData i;
                i.localPos = v.obPos.xyz;
                i.position = UnityObjectToClipPos(v.obPos);
                i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                i.normal = mul(unity_ObjectToWorld, float4(v.normal, 0));
                i.normal = normalize(i.normal);
                return i;
            }

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                return float4(i.normal * 0.5 + 0.5, 1);
            }

            ENDCG
        }

    }
}