using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Postprocessing : MonoBehaviour
{
    public Material postProcessingMaterial;
    public float waveSpeed;
    public bool waveOn;
    private float waveDistance;
    public float waveBound;
    private Camera mainCam;

    void Start()
    {
        waveDistance = 0;
        mainCam = GetComponent<Camera>();
        mainCam.depthTextureMode |= DepthTextureMode.Depth;
    }

    void Update()
    {
        if(waveOn)
        {
            waveDistance += waveSpeed;
            if(waveDistance > waveBound)
                waveDistance = 0;
        }
        else
            waveDistance = 0;
        
        
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination){
        postProcessingMaterial.SetFloat("_WaveDistance", waveDistance);
		Graphics.Blit(source, destination, postProcessingMaterial);
	}
}
