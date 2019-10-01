Shader "custome/Rendering/LightForComplexMaterials"
{
    Properties
    {
        _Tint("Tint Color", Color) = (1, 1, 1, 1)
        //_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
        _MainTexture("Albedo", 2D) = "white"{}
        _NormalMap("Normal Map", 2D) = "white"{}
        _BumpScale("Metalic", Range(0, 1)) = 0
        [NoScaleOffset]_MetallicTexture("Metallic Map", 2D) = "white"{}
        [Gamma]_Metalic("Metalic", Range(0, 1)) = 0
        _Smoothness("Smoothness", range(0.01,1)) = 0.01

        [NoScaleOffset] _EmissionMap ("Emission", 2D) = "black" {}
		_Emission ("Emission Color", Color) = (0, 0, 0)

        _DetailTex ("Detail Albedo", 2D) = "gray" {}
        _DetailNormalMap("Detailed Normal Map", 2D) = "white"{}
        _DetailBumpScale("Metalic", Range(0, 1)) = 0
    }

    CustomEditor "MyLightingShaderGUI"

    SubShader
    {
        Pass{
            Tags{
                        "LightMode" = "ForwardBase"
                    }
                CGPROGRAM
                #pragma multi_compile _ SHADOWS_SCREEN
                #pragma multi_compile _ VERTEXLIGHT_ON
                #pragma shader_feature _METALLIC_MAP
                #pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
                #pragma shader_feature _EMISSION_MAP
                #define FORWARD_BASE_PASS
                #include "LightForComplexMaterials.cginc"
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
                #pragma multi_compile_fwdadd_fullshadows
                #pragma shader_feature _METALLIC_MAP
                #pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
                #include "LightForComplexMaterials.cginc"
                #pragma vertex MyVertex
                #pragma fragment MyFrag
                #pragma target 3.0
                

                ENDCG
        }

        Pass{
            Tags{
                    "LightMode" = "ShadowCaster"
            }

            CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile_shadowcaster
            
            #pragma vertex ShadowVertex
            #pragma fragment ShadowFrag

            #include "CastShadow.cginc"

            ENDCG
        }
    }

}
