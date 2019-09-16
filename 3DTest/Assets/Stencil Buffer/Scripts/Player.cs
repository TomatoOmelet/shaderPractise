using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField]private float speed;
    [SerializeField]private Camera mainCamera;
    private List<GameObject> objectsBeforePlayer = new List<GameObject>();
    [SerializeField]private float checkRadius = 2;
    [SerializeField]private Material normalMaterial;
    [SerializeField]private Material stencilMaterial;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GetComponent<Rigidbody>().velocity = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical")) * speed;
        //get objects that may appear cover player
        Vector3 direction = transform.position - mainCamera.transform.position;
        float distance = direction.magnitude;
        RaycastHit[] results = Physics.SphereCastAll(mainCamera.transform.position, checkRadius, direction, distance, ~9);
        //check all results
        //see if there are objects that are not covering players anymore
        List<GameObject> toRemove = new List<GameObject>();
        foreach(GameObject ob in objectsBeforePlayer)
        {
            if(!RayCastContains(ob, ref results))
                toRemove.Add(ob);
        }
        foreach(GameObject ob in toRemove)
            RemoveFromList(ob);
        //add new
        foreach(RaycastHit result in results)
        {
            if(!objectsBeforePlayer.Contains(result.collider.gameObject))
                AddToList(result.collider.gameObject);
        }
    }

    bool RayCastContains(GameObject ob, ref RaycastHit[] results)
    {
        foreach(RaycastHit result in results)
        {
            if(ob == result.collider.gameObject)
                return true;
        }
        return false;
    }

    void AddToList(GameObject go)
    {
        go.GetComponent<Renderer>().sharedMaterial = stencilMaterial;
        objectsBeforePlayer.Add(go);
    }

    void RemoveFromList(GameObject go)
    {
        go.GetComponent<Renderer>().sharedMaterial = normalMaterial;
        objectsBeforePlayer.Remove(go);
    }

}
