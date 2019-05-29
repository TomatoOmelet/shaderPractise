Shader "Unlit/IttaiNo1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1("Color1", Color) = (0,0,0,0)
        _Color2("Color2", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color1;
            fixed4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex += fixed4(sin(_Time.y), sin(_Time.y/2), 0, 0)/5;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //fixed temp = fmod(i.uv.x + i.uv.y + _Time.y, 1);
                fixed3 col1 = sin(_Color1 + fixed3(_Time.y, _Time.y/2, _Time.y/3) + 1)/4 + 0.25;
                fixed3 col2 = sin(_Color2 + fixed3(_Time.y, _Time.y/2, _Time.y/3) + 1)/4 + 0.25;
                fixed temp = (sin(i.vertex.x + i.vertex.y) + 1)/2;
                col.xyz = col1 * (1 - temp) + col2 * temp;
                //col.xyz = sin(col.xyz + fixed3(1,1,1) * _Time.y)/2 + fixed3(0.5, 0.5, 0.5);
                return col;
            }
            ENDCG
        }
    }
}
