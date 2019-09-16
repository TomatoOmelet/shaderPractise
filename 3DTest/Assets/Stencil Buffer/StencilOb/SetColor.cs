using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetColor : MonoBehaviour
{
    public Color32 color;
    private MaterialPropertyBlock materialPropertyBlock;
    private Renderer rendererComponent;
    // Start is called before the first frame update
    void Start()
    {
        rendererComponent = GetComponent<Renderer>();
        materialPropertyBlock= new MaterialPropertyBlock();
    }

    void Update()
    {
        rendererComponent.GetPropertyBlock(materialPropertyBlock);
        materialPropertyBlock.SetColor("_Color", color);
        rendererComponent.SetPropertyBlock(materialPropertyBlock);
    }
}
