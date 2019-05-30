using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshDeformInput : MonoBehaviour
{
    public float force = 10;
    public float forceOffset = 0.1f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit result;
            if(Physics.Raycast(ray, out result))
            {
                MeshDeformer meshDeformer = result.collider.GetComponent<MeshDeformer>();
                if(meshDeformer)
                {
                    Vector3 mousePointOnMesh = result.point;
                    mousePointOnMesh += result.normal * forceOffset;
                    meshDeformer.AddDeformingForce(mousePointOnMesh, force);
                }
            }

        }
    }
}
