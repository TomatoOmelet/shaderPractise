using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VisializeTesting : MonoBehaviour
{
    // Start is called before the first frame update
    float length = 100;
    void Start()
    {
        AudioSource audioSource = GetComponent<AudioSource>();
        float[] samples = new float[audioSource.clip.samples * audioSource.clip.channels];
        audioSource.clip.GetData(samples, 0);
        float modifier = length/samples.Length;

        for (int i = 0; i < samples.Length; i += 100)
        {
            samples[i] = samples[i];
            Debug.DrawLine(Vector3.zero + new Vector3(i * modifier, 0, 0), Vector3.zero + new Vector3(i* modifier, samples[i] * 2, 0), Color.red, Mathf.Infinity);
        }
        
        audioSource.clip.SetData(samples, 0);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
