using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VisializeTesting : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]private AudioClip clip;
    [SerializeField]private float length = 100;
    [SerializeField]private int meshComplexity = 6;
    int stepModifier = 50000;
    void Start()
    {
        Generate();
        //DebugAudio();
    }

    private void Generate()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        //get audio clip info
        float[] samples = new float[clip.samples * clip.channels];
        int step = 1 + clip.samples * clip.channels/stepModifier;
        Debug.Log(step);
        clip.GetData(samples, 0);
        float modifier = length/samples.Length;
        //generate mesh
        List<Vector3> vertices = new List<Vector3>();
        List<int> triangles = new List<int>();
        //start point
        vertices.Add(Vector3.zero);
        //points in the middle
        for (int i = step/2; i < samples.Length; i += step)
        {
            float avg = Mathf.Abs(GetArrayAverage(ref samples, i - step/2, i + step/2));
            if(i == step/2)
            {
                AddToMesh(avg, i* modifier, ref vertices, ref triangles, false);
                AddStartingTriangles(ref triangles);
            }else
                AddToMesh(avg, i* modifier, ref vertices, ref triangles);
        }
        //end point
        vertices.Add(Vector3.right * length);
        AddEndingTriangles(ref triangles, vertices.Count);

        mesh.vertices = vertices.ToArray();
        mesh.triangles = triangles.ToArray();
    }

    private void AddToMesh(float sampleValue, float xPos, ref List<Vector3> vertices, ref List<int> triangles, bool addTriangles = true)
    {
        float angle = 360f/meshComplexity;
        //add vertices
        for(int x = 0; x < meshComplexity; ++x)
        {
            vertices.Add(new Vector3(xPos, 0, 0) + Quaternion.Euler(angle * x, 0, 0) * Vector3.up * sampleValue);
        }
        //add triangles
        if(!addTriangles)
            return;
        int startIndex = vertices.Count - meshComplexity;
        for(int x = startIndex; x < startIndex + meshComplexity - 1; ++x)
        {
            triangles.Add(x - meshComplexity);
            triangles.Add(x);
            triangles.Add(x - meshComplexity + 1);

            triangles.Add(x - meshComplexity + 1);
            triangles.Add(x);
            triangles.Add(x + 1);
        }
        triangles.Add(startIndex - 1);
        triangles.Add(startIndex + meshComplexity - 1);
        triangles.Add(startIndex - meshComplexity);

        triangles.Add(startIndex - meshComplexity);
        triangles.Add(startIndex + meshComplexity - 1);
        triangles.Add(startIndex);

    }

    private void AddStartingTriangles(ref List<int> triangles)
    {
        for(int x = 0; x < meshComplexity - 1; ++x)
        {
            triangles.Add(0);
            triangles.Add(x);
            triangles.Add(x + 1);
        }
        triangles.Add(0);
        triangles.Add(meshComplexity);
        triangles.Add(1);
    }
    
    private void AddEndingTriangles(ref List<int> triangles, int verticesLength)
    {
        int lastIndex = verticesLength - 1;
        for(int x = lastIndex - meshComplexity; x < lastIndex - 1; ++x)
        {
            triangles.Add(lastIndex);
            triangles.Add(x);
            triangles.Add(x + 1);
        }
        triangles.Add(lastIndex);
        triangles.Add(lastIndex - 1);
        triangles.Add(lastIndex - meshComplexity);
    }

    private void DebugAudio()
    {
        float[] samples = new float[clip.samples * clip.channels];
        int step = 1 + clip.samples * clip.channels/stepModifier;
        Debug.Log(step);
        clip.GetData(samples, 0);
        float modifier = length/samples.Length;
        Vector3 lastPos = Vector3.zero;
        for (int i = step/2; i < samples.Length; i += step)
        {
            float avg = GetArrayAverage(ref samples, i - step/2, i + step/2);
            Debug.DrawLine(lastPos, new Vector3(i* modifier, avg, 0), Color.red, Mathf.Infinity);
            lastPos = new Vector3(i* modifier, avg, 0);
        }
    }


    private float GetArrayAverage(ref float[] array, int index1, int index2)
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

}
