using RayFire;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PianoBossBox : MonoBehaviour, IDamageAble,IRayfirable
{
    Rigidbody rigid;
    public float hp = 10;
    public float Mass = 1;
    public PhysicMaterial PhysicMat;
    void Start()
    {
        rigid = GetComponent<Rigidbody>();

        GetComponent<BoxCollider>().material = PhysicMat;
        rigid.mass = Mass;
    }
    public void OnDamaged(float dmg, Vector3 normal, bool N)
    {
        if (rigid && rigid.velocity.y <= 0)
        {
            rigid.AddForce((normal) * dmg, ForceMode.Impulse);
        }
        if(!N)
        hp -= dmg;
        if(hp <= 0)
        {
            rigid.AddForce(Vector3.up * 2, ForceMode.Impulse);
            Invoke("OnDemolish",0.2f);
        }
    }

    public void OnDemolish()
    {
        GetComponent<RayfireRigid>().Demolish();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.CompareTag("Player") && collision.transform.position.y < transform.position.y - GetComponent<BoxCollider>().size.y/2)
        {
            IDamageAble hit = collision.gameObject.GetComponent<IDamageAble>();
            if(hit != null)
            {
                hit.OnDamaged(1, Vector3.zero, false);
            }
            rigid.velocity = Vector3.zero;
            rigid.AddForce(Vector3.up * 5, ForceMode.Impulse);
            Invoke("OnDemolish", 0.2f);
        }
    }
}
