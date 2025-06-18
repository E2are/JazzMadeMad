using UnityEngine;


namespace SciFiAOE{
public class PrefabDestroy : MonoBehaviour
{
    // Object destroy time.
    [SerializeField]float destroyTime=3;
    void Start()
    {   
        // Destroy the object after the delay time.
        Destroy(gameObject,destroyTime);
    }

}
}