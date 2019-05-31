// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custome/Rendering/Texture Splatting"
{

    Properties
    {
        _Splatting("Texture", 2D) = "white"{}
        [NoScaleOffset]_Texture1("Texture", 2D) = "white"{}
        [NoScaleOffset]_Texture2("Texture", 2D) = "white"{}
        [NoScaleOffset]_Texture3("Texture", 2D) = "white"{}
        [NoScaleOffset]_Texture4("Texture", 2D) = "white"{}
    }

    SubShader{

        Pass{
            CGPROGRAM
                
            #pragma vertex MyVertex
            #pragma fragment MyFrag
            #include "UnityCG.cginc"

            sampler2D _Splatting, _Texture1, _Texture2, _Texture3, _Texture4;
            float4 _Splatting_ST;

            struct VertexData{
                float4 obPos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct InterpolationData{
                float4 position : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 uvSplat : TEXCOORD2;
            };

            InterpolationData MyVertex(VertexData v)
            {
                InterpolationData i;
                i.localPos = v.obPos.xyz;
                i.position = UnityObjectToClipPos(v.obPos);
                i.uv = TRANSFORM_TEX(v.uv, _Splatting);
                i.uvSplat = v.uv;
                return i;
            }

            float4 MyFrag(InterpolationData i) : SV_TARGET
            {
                float4 splat = tex2D(_Splatting, i.uvSplat);
                return tex2D(_Texture1, i.uv) * splat.r + tex2D(_Texture2, i.uv)* splat.g +
                       tex2D(_Texture3, i.uv) * splat.b + tex2D(_Texture4, i.uv) * (1 - splat.r - splat.g - splat.b);
            }

            ENDCG
        }

    }
}