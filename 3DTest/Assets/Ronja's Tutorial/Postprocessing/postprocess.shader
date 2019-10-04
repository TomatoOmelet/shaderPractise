Shader "Ronja/Postprocessing"{
    //show values to edit in inspector
    Properties{
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        [Header(Wave)]
        _WaveDistance("Distance from Player", float) = 10
        _WaveTrail("Length of trail", Range(5,10)) = 0
        _WaveColor("Wave Color", Color) = (0,0,0,1)
    }

    SubShader{
        // markers that specify that we don't need culling 
        // or reading/writing to the depth buffer
        Cull Off
        ZWrite Off 
        ZTest Always

        Pass{
            CGPROGRAM
            //include useful shader functions
            #include "UnityCG.cginc"

            //define vertex and fragment shader
            #pragma vertex vert
            #pragma fragment frag

            //texture and transforms of the texture
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _WaveDistance, _WaveTrail;
            float4 _WaveColor;

            //the object data that's put into the vertex shader
            struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            //the data that's used to generate fragments and can be read by the fragment shader
            struct v2f{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //the vertex shader
            v2f vert(appdata v){
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //the fragment shader
            fixed4 frag(v2f i) : SV_TARGET{
                //get source color from texture
                fixed depth = tex2D(_CameraDepthTexture, i.uv).r;
                depth = Linear01Depth(depth) * _ProjectionParams.z;
                float4 col = tex2D(_MainTex, i.uv);
                if(depth >= _ProjectionParams.z)
                    return col;

                float waveFront = step(depth, _WaveDistance);
                float waveTrail = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);
                float wave = waveFront * waveTrail;
                
                col = lerp(col, _WaveColor, wave);

                return col;
            }

            ENDCG
        }
    }
}
