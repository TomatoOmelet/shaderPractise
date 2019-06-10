Shader "custome/Rendering/MultipleLight"
{
    Properties
    {
        _Color("_Tint", Color) = (1, 1, 1, 1)
        //_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
        [Gamma]_Metalic("Metalic", Range(0, 1)) = 0
        _MainTexture("Albedo", 2D) = "white"{}
        _Smoothness("Smoothness", range(0.01,1)) = 0.01
    }

    SubShader
    {
        Pass{
            Tags{
                        "LightMode" = "ForwardBase"
                    }
                CGPROGRAM
                
                #include "Light.cginc"
                #pragma vertex MyVertex
                #pragma fragment MyFrag
                #pragma target 3.0

                ENDCG
        }

        Pass{
            Tags{
                        "LightMode" = "ForwardAdd"
                    }
                Blend One One
                Zwrite Off
                CGPROGRAM
                #pragma multi_compile DIRECTIONAL POINT SPOT

                #include "Light.cginc"
                #pragma vertex MyVertex
                #pragma fragment MyFrag
                #pragma target 3.0

                ENDCG
        }
    }

}
