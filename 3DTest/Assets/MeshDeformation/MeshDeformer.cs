using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshDeformer : MonoBehaviour
{
    public MeshFilter meshFilter;
    private Mesh deformingMesh;
    private Vector3[] originalVertice, displacedVertice, vertexVelocities;
    public float springForce = 20f;
    public float damping = 5f;
    // Start is called before the first frame update
    void Start()
    {
        deformingMesh = meshFilter.mesh;
        originalVertice = deformingMesh.vertices;
        displacedVertice = new Vector3[originalVertice.Length];
        vertexVelocities = new Vector3[originalVertice.Length];
        //copy vertice
        for(int x = 0; x < originalVertice.Length; ++x)
            displacedVertice[x] = originalVertice[x];
    }

    // Update is called once per frame
    void Update()
    {
        for(int x = 0; x < displacedVertice.Length; ++x)
        {
            UpdateVertex(x);
        }
        meshFilter.mesh.vertices = displacedVertice;
        meshFilter.mesh.RecalculateNormals();
    }
    public void AddDeformingForce(Vector3 point, float force)
    {
        Debug.DrawLine(point, Camera.main.transform.position);
        for(int x = 0; x < displacedVertice.Length; ++x)
        {
            AddForceToVertex(x, point, force);
        }
    }

    public void AddForceToVertex(int index, Vector3 point, float force)
    {
        Vector3 pointToVertex = displacedVertice[index] - point;
		float attenuatedForce = force / (1f + pointToVertex.sqrMagnitude * pointToVertex.sqrMagnitude);
        float velocity = attenuatedForce * Time.deltaTime;
        vertexVelocities[index] += pointToVertex.normalized * velocity;
    }

    public void UpdateVertex(int index)
    {
        //Vector3 point = displacedVertice[index];
        //point += vertexVelocities[index] * Time.deltaTime;
        //displacedVertice[index] = point;
        Vector3 velocity = vertexVelocities[index];
        Vector3 displacement = displacedVertice[index] - originalVertice[index];
		velocity -= displacement * springForce * Time.deltaTime;
        velocity *= 1f - damping * Time.deltaTime;
		vertexVelocities[index] = velocity;
		displacedVertice[index] += velocity * Time.deltaTime;
    }

}
