using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

public class MyLightingShaderGUI : ShaderGUI
{
    enum SmoothnessSource{
        Uniform, Albedo, Metallic 
    }

    enum RenderingMode {
		Opaque, Cutout
	}
    bool shouldShowAlphaCutoff;
    Material target;
    MaterialEditor editor;
    MaterialProperty[] properties;
    static ColorPickerHDRConfig emissionConfig = new ColorPickerHDRConfig(0f, 99f, 1f / 99f, 3f);

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties) {

        this.editor = editor;
        this.properties = properties;
        target = editor.target as Material;
        DoRenderingMode();
        DoMain();
        DoSecondary();
    }

    private void DoMain()
    {
        GUILayout.Label("Main Maps", EditorStyles.boldLabel);
        //draw albedo
        MaterialProperty mainTex = FindProperty("_MainTexture", properties);
        editor.TexturePropertySingleLine(MakeLabel(mainTex, "Aldobe (RGB)"), mainTex, FindProperty("_Tint"));
        EditorGUI.indentLevel += 2;
        editor.TextureScaleOffsetProperty(mainTex);
        EditorGUI.indentLevel -= 2;
        DoNormal("_NormalMap", "_BumpScale");
        DoMetallic();
        DoSmoothness();
        DoEmission();
        if(shouldShowAlphaCutoff)
            DoAlphaCutoff();
    }

    void DoAlphaCutoff () {
        
		MaterialProperty slider = FindProperty("_AlphaCutoff");
        if(slider != null)
        {
            EditorGUI.indentLevel += 2;
            editor.ShaderProperty(slider, MakeLabel(slider));
            EditorGUI.indentLevel -= 2;
        }
	}

    void DoRenderingMode () {
		RenderingMode mode = RenderingMode.Opaque;
        shouldShowAlphaCutoff = false;
		if (IsKeywordEnabled("_RENDERING_CUTOUT")) {
			mode = RenderingMode.Cutout;
            shouldShowAlphaCutoff = true;
		}

		EditorGUI.BeginChangeCheck();
		mode = (RenderingMode)EditorGUILayout.EnumPopup(
			MakeLabel("Rendering Mode"), mode
		);
		if (EditorGUI.EndChangeCheck()) {
			RecordAction("Rendering Mode");
			SetKeyword("_RENDERING_CUTOUT", mode == RenderingMode.Cutout);
            
			RenderQueue queue = (mode == RenderingMode.Opaque ? RenderQueue.Geometry : RenderQueue.AlphaTest);
            string renderType = (mode == RenderingMode.Opaque ? "" : "TransparentCutout");
			foreach (Material m in editor.targets) {
				m.renderQueue = (int)queue;
                m.SetOverrideTag("RenderType", renderType);
			}

		}
	}

    private void DoNormal(string normalMapName, string bumpnessScaleName)
    {
        MaterialProperty normalMap = FindProperty(normalMapName);//"_NormalMap");
        MaterialProperty bumpness = FindProperty(bumpnessScaleName);//"_BumpScale");
        editor.TexturePropertySingleLine(MakeLabel(normalMap), normalMap, normalMap.textureValue? bumpness:null);
        if(!normalMap.textureValue)
        {
            bumpness.floatValue = 0;
        }
    }

    private void DoMetallic()
    {
        MaterialProperty metallicTex = FindProperty("_MetallicTexture");
        MaterialProperty metallic = FindProperty("_Metalic");
        
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(metallic), metallicTex,
                                        metallicTex.textureValue == null? metallic: null);
        if(EditorGUI.EndChangeCheck())
        {
            SetKeyword("_METALLIC_MAP", metallicTex.textureValue);
        }
    }

    private void DoEmission()
    {
        MaterialProperty emissionTex = FindProperty("_EmissionMap");
        MaterialProperty emission = FindProperty("_Emission");
        
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertyWithHDRColor(MakeLabel(emissionTex), emissionTex, emission, emissionConfig, false);

        if(EditorGUI.EndChangeCheck())
        {
            SetKeyword("_EMISSION_MAP", emissionTex.textureValue);
        }
    }


    private void DoSmoothness()
    {
        SmoothnessSource source = SmoothnessSource.Uniform;
        if(IsKeywordEnabled("_SMOOTHNESS_ALBEDO"))
            source = SmoothnessSource.Albedo;
        else if(IsKeywordEnabled("_SMOOTHNESS_METALLIC"))
            source = SmoothnessSource.Metallic;
        EditorGUI.indentLevel += 2;
        MaterialProperty smoothness = FindProperty("_Smoothness");
        editor.ShaderProperty(smoothness, MakeLabel(smoothness));
        EditorGUI.indentLevel += 1;
        EditorGUI.BeginChangeCheck();
        source = (SmoothnessSource)EditorGUILayout.EnumPopup(MakeLabel("Source"), source);
        if(EditorGUI.EndChangeCheck())
        {
            RecordAction("Smoothness Source");
            SetKeyword("_SMOOTHNESS_ALBEDO", source == SmoothnessSource.Albedo);
            SetKeyword("_SMOOTHNESS_METALLIC", source == SmoothnessSource.Metallic);
        }
        EditorGUI.indentLevel -= 3;
    }

    private void DoSecondary()
    {
        GUILayout.Label("Secondary Maps", EditorStyles.boldLabel);
        MaterialProperty detailedTex = FindProperty("_DetailTex");
        editor.TexturePropertySingleLine(MakeLabel(detailedTex), detailedTex);
        EditorGUI.indentLevel += 2;
        editor.TextureScaleOffsetProperty(detailedTex);
        EditorGUI.indentLevel -= 2;
        DoNormal("_DetailNormalMap", "_DetailBumpScale");
    }

    private void RecordAction(string label)
    {
        editor.RegisterPropertyChangeUndo(label);
    }

    private void SetKeyword(string keyword, bool state)
    {
        if(state)
        {
            target.EnableKeyword(keyword);
        }else{
            target.DisableKeyword(keyword);
        }
    }

    private bool IsKeywordEnabled(string keyword)
    {
        return target.IsKeywordEnabled(keyword);
    }


    private MaterialProperty FindProperty(string propertyName)
    {
        return FindProperty(propertyName, properties);
    }

    static GUIContent staticLabel = new GUIContent();
    static GUIContent MakeLabel(string labelName, string toolkit = null)
    {
        staticLabel.text = labelName;
        staticLabel.tooltip = toolkit;
        return staticLabel;
    } 

    static GUIContent MakeLabel(MaterialProperty property, string toolkit = null)
    {
        return MakeLabel(property.displayName, toolkit);
    } 
}
