// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/my first shader"
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
                float2 uv : TEXCOORD0;
            };

            struct InterpolationData{
                float4 position : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            InterpolationData MyVertex(VertexData v)
            {
                InterpolationData i;
                i.localPos = v.obPos.xyz;
                i.position = UnityObjectToClipPos(v.obPos);
                i.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                return i;
            }

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                return tex2D(_MainTexture, i.uv);
            }

            ENDCG
        }

    }
}