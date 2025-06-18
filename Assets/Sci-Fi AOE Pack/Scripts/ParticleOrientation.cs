using UnityEngine;

namespace SciFiAOE{

public class ParticleOrientation : MonoBehaviour
{
    // Camera transform variable.
    [SerializeField] Transform _cameraTransform;
    
    void Start()
    {
        if(_cameraTransform == null)
            {
                // Get the camera transfomr automatically if not provided from the inspector.
                _cameraTransform = Camera.main.transform;
            }

        // get rotation information to face the camera.
        Quaternion rotation = Quaternion.LookRotation(_cameraTransform.position-transform.position);

        // set the object rotation to face the camera.
        transform.rotation = new Quaternion(0,rotation.y,0,rotation.w);

    }


}

}
