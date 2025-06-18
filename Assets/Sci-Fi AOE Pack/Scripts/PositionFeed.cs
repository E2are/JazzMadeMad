using UnityEngine;


namespace SciFiAOE{
    
[ExecuteAlways]

public class PositionFeed : MonoBehaviour
{
    // The formationobject material
    [SerializeField] Material FormationMaterial;
    
    // the object that hold the objectformation system
    [SerializeField] GameObject FormationSystem;

    void Start()
    {
        FormationMaterial =  FormationSystem.GetComponent<Renderer>().sharedMaterial;
    }
    void Update()
    {
        
        // Sending the effect object position to the shader
        FormationMaterial.SetVector("_Position",transform.position);
    }
}

}