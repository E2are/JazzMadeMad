using UnityEngine;
using UnityEngine.UI;

namespace SciFiAOE{
public class ParticleSpawner : MonoBehaviour
{
    
    [SerializeField] GameObject[] _particleSystem;
    [SerializeField] int _particleIndex;
    private Vector3 _mousePos;
    [SerializeField] Text _particleName;

    void Update()
    {
        if(Input.GetMouseButtonDown(0))
            {
                Instantiate( _particleSystem[_particleIndex],new Vector3 (_mousePos.x,0,_mousePos.z),Quaternion.identity);
            }
        
        if(Input.GetKeyDown(KeyCode.Space))
            {
                Instantiate( _particleSystem[_particleIndex],Vector3.zero,Quaternion.identity);
            }
        
        
        
        MousePosition();
        SwithParticles();   
    }
    void MousePosition()
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            
            RaycastHit hit;
            
            if(Physics.Raycast(ray, out hit))
                {
                    _mousePos = hit.point;
                }
        }
    void SwithParticles()
        {
            if(Input.GetKeyDown(KeyCode.D) && _particleIndex < _particleSystem.Length)
                {
                    _particleIndex += 1;
                }
            if(Input.GetKeyDown(KeyCode.A) && _particleIndex > 0)
                {
                    _particleIndex -= 1;
                }
            if(_particleIndex == _particleSystem.Length)
                {
                    _particleIndex = 0;
                }

            
            _particleName.text = _particleSystem[_particleIndex].ToString();
        }

}

}
