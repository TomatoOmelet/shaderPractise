using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TangentSpaceVisualizer : MonoBehaviour
{
    public float offset = 0.01f;
    public float scale = 0.1f;
    void OnDrawGizmos()
    {
        MeshFilter filter = GetComponent<MeshFilter>();
        if(filter)
        {
            Mesh mesh = filter.sharedMesh;
            if(mesh)
            {
                DrawTangentSpace(mesh);
            }
        }
    }

    void DrawTangentSpace(Mesh mesh)
    {
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;
        for(int x = 0; x < vertices.Length; ++x)
        {
            DrawTangentSpace(transform.TransformPoint(vertices[x]),
                            transform.TransformDirection(normals[x]),
                            transform.TransformDirection(tangents[x]),
                            tangents[x].w);
        }
    }

    void DrawTangentSpace(Vector3 vertex, Vector3 normal, Vector3 tangent, float binormalSign)
    {
        vertex += offset * normal;
        Gizmos.color = Color.green;
        Gizmos.DrawLine(vertex, vertex + normal * scale);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(vertex, vertex + tangent * scale);
        Gizmos.color = Color.blue;
        Vector3 binormal = Vector3.Cross(normal, tangent) * binormalSign;
        Gizmos.DrawLine(vertex, vertex + binormal * scale);
    }
}
