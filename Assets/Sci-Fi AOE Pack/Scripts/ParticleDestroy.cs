using UnityEngine;

namespace SciFiAOE{

public class ParticleDestroy : MonoBehaviour
{

    // Particle system that will provide the start life time.
    [SerializeField] ParticleSystem _particleSystem;
    
    // Particle system start life time.
    [SerializeField] float _lifeTime;

    // The delay that will be applied after the end of start life time before destroying the Particle system (the effect).
    [SerializeField] float _destroyDelay;
    void Start()
    {
        if(_particleSystem ==  null)
            {
                // Get the particle system componenet automatically if not provided from the inspector.
                _particleSystem =  GetComponentInChildren<ParticleSystem>();
            }
        
        // Get the system start life time.
        _lifeTime = _particleSystem.startLifetime;

        // Destroy the object that hold the particle system after it's life time + delay time.
        Destroy(this.gameObject,(_lifeTime+_destroyDelay));

        
    }

}

}