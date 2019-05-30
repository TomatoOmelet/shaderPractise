// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/Rendering/Textured With Detail"
{

    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTexture("Texture", 2D) = "white"{}
        _DetailedTex("Detailed Texture", 2D) = "gray"{}
    }

    SubShader{

        Pass{
            CGPROGRAM
                
            #pragma vertex MyVertex
            #pragma fragment MyFrag
            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTexture;
            sampler2D _DetailedTex;
            float4 _MainTexture_ST;
            float4 _DetailedTex_ST;

            struct VertexData{
                float4 obPos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct InterpolationData{
                float4 position : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            InterpolationData MyVertex(VertexData v)
            {
                InterpolationData i;
                i.localPos = v.obPos.xyz;
                i.position = UnityObjectToClipPos(v.obPos);
                i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                i.uv2 = TRANSFORM_TEX(v.uv, _DetailedTex);
                return i;
            }

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                float4 color = tex2D(_MainTexture, i.uv);
                color *= tex2D(_DetailedTex, i.uv2) * unity_ColorSpaceDouble;
                return color;
            }

            ENDCG
        }

    }
}