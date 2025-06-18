using System.Collections.Generic;
using UnityEngine;

namespace SciFiAOE{

[ExecuteInEditMode]
public class VFXScaler : MonoBehaviour
{
    
    private List<Transform> childsTransform = new List<Transform>();
    private List<Vector3>  scaleFactor = new List<Vector3>();
    private List<Vector3>  appliedScale = new List<Vector3>();
    void Start() 
    {
        // Invoke the Collect function upon attaching the script to the effect prefab
        Collect();
    }
    void Update() 
    {
        for(int i = 0;i<childsTransform.Count; i++)
        {
            // Ensure that all child objects have their scales set to match the scale of the effect prefab (parent) multiplied by the scale factor, maintaining uniform scale across all instances
            appliedScale[i] = new Vector3(transform.localScale.x*scaleFactor[i].x,transform.localScale.y*scaleFactor[i].y,transform.localScale.z*scaleFactor[i].z);
            childsTransform[i].localScale = appliedScale[i];
        }
    }

    // Iterate through all the child objects of the effect prefab and add them to the childTransform list
    void CollectFunc(Transform parentTransform)
    {
        foreach (Transform child in parentTransform)
        {
            childsTransform.Add(child.transform);
            if (child.transform.childCount > 0)
            {
                CollectFunc(child);
                
            }
        }

    }
    
    void Collect(){
        // Clear all lists before adding elements to prevent duplication
        ClearLists();
        // Append the transforms of all child objects to the childTransform list
        CollectFunc(transform);

        for (int i = 0; i < childsTransform.Count; i++)
        {
            // Determine the scale factor by dividing each child's scale by the scale of the effect prefab
            scaleFactor.Add(new Vector3 (childsTransform[i].localScale.x/transform.localScale.x,childsTransform[i].localScale.y/transform.localScale.y,childsTransform[i].localScale.z/transform.localScale.z));
            
            // Set the elements of the appliedScale list to match the number of child objects
            appliedScale.Add(Vector3.one);
        }

    }
    void ClearLists()
    {
        // Clearing all lists to ensure they are empty
        childsTransform.Clear();
        scaleFactor.Clear();
        appliedScale.Clear();
    }
}
}