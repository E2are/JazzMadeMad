using UnityEngine.Rendering;
using UnityEngine;

namespace SciFiAOE{
public class ObjectFormation : MonoBehaviour
{
    // Formation particle system.
    [SerializeField] Transform _formationSystemTransform;
    [SerializeField] ParticleSystem _formationSystem;
    
    // Formation Object prefab activating time.
    [SerializeField] float formationTime = 90.6f;

    // Formation Object Prefab.
    [SerializeField] GameObject formationObjPrefab;

    // The instantiated object.
    private GameObject formationObj;

        [System.Obsolete]
        void Start()
    {

        // Instantiate formation object and set it's position and rotation to it's particle system position and rotation.
        formationObj = Instantiate(formationObjPrefab,_formationSystemTransform.position,Quaternion.Euler(_formationSystemTransform.eulerAngles),_formationSystemTransform);
        
        // set formation object scale to match it's particle system start size.
        formationObj.transform.localScale = new Vector3(_formationSystem.startSize,_formationSystem.startSize,_formationSystem.startSize);

        // Activating the formation object.
        formationObj.SetActive(false);    

        // Disable Shadows Casting.
        formationObj.GetComponentInChildren<MeshRenderer>().shadowCastingMode = ShadowCastingMode.Off;
        
    }


    void Update()
    {
        // Activating Formation object when it's particle system reach certain percentage.
        if(_formationSystem.time/_formationSystem.startLifetime*100 >= formationTime){formationObj.SetActive(true); }
    }
}
}
