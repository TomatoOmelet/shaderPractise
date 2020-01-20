using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VisializeTesting : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]AudioClip clip;
    [SerializeField]float length = 100;
    int stepModifier = 51000;
    void Start()
    {
        Generate();
    }

    private void Generate()
    {
        float[] samples = new float[clip.samples * clip.channels];
        int step = 1 + clip.samples * clip.channels/stepModifier;
        Debug.Log(step);
        clip.GetData(samples, 0);
        float modifier = length/samples.Length;
        Vector3 lastPos = Vector3.zero;
        for (int i = step/2; i < samples.Length; i += step)
        {
            float avg = Average(ref samples, i - step/2, i + step/2);
            Debug.DrawLine(lastPos, new Vector3(i* modifier, avg, 0), Color.red, Mathf.Infinity);
            lastPos = new Vector3(i* modifier, avg, 0);
        }
    }

    private float Average(ref float[] array, int index1, int index2)
    {
        if(index1 < 0) index1 = 0;
        if(index2 >= array.Length) index2 = array.Length - 1;
        if(index1 > index2)
        {
            Debug.LogError("Average: the second index needs to be larger than the first one.");
        }
        float sum = 0;
        sum += array[index1];
        for(int i = index1 + 1; i < index2; ++i)
        {
            sum += array[i];
        }
        return sum/(index2 - index1 + 1);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
