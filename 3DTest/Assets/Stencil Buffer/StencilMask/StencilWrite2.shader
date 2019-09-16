Shader "Unlit/StencilWrite2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        ColorMask 0
        ZWrite Off
        
        Stencil{
                Ref 0
                Comp Always
                Pass Replace
            }

        Pass
        {
        }
    }
}
