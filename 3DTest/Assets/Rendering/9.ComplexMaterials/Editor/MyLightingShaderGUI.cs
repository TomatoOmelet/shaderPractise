using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MyLightingShaderGUI : ShaderGUI
{
    MaterialEditor editor;
    MaterialProperty[] properties;

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties) {
        this.editor = editor;
        this.properties = properties;
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
        DoNormal();
        DoMetallic();
        DoSmoothness();
    }

    private void DoNormal()
    {
        MaterialProperty normalMap = FindProperty("_NormalMap");
        editor.TexturePropertySingleLine(MakeLabel(normalMap), normalMap);
    }

    private void DoMetallic()
    {
        EditorGUI.indentLevel += 2;
        MaterialProperty metallic = FindProperty("_Metalic");
        editor.ShaderProperty(metallic, MakeLabel(metallic));
        EditorGUI.indentLevel -= 2;
    }

    private void DoSmoothness()
    {
        EditorGUI.indentLevel += 2;
        MaterialProperty smoothness = FindProperty("_Smoothness");
        editor.ShaderProperty(smoothness, MakeLabel(smoothness));
        EditorGUI.indentLevel -= 2;
    }

    private void DoSecondary()
    {
        GUILayout.Label("Secondary Maps", EditorStyles.boldLabel);
        MaterialProperty detailedTex = FindProperty("_DetailTex");
        editor.TexturePropertySingleLine(MakeLabel(detailedTex), detailedTex);
        EditorGUI.indentLevel += 2;
        editor.TextureScaleOffsetProperty(detailedTex);
        EditorGUI.indentLevel -= 2;
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
