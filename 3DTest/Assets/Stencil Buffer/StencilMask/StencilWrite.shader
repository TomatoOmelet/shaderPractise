Shader "Unlit/StencilWrite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-2" }
        LOD 100
        ColorMask 0
        Blend Zero One
        ZWrite Off
        
        Stencil{
            Ref 1
            Comp Always
            Pass Replace
        }
        
        Pass
        {
        }
    }
}
