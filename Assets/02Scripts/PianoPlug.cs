using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PianoPlug : MonoBehaviour, IDamageAble
{
    public PianoBoss PBoss;
    public float Hp = 100;
    public bool isBursted = false;
    public ParticleSystem[] BurstEffect;
    void Start()
    {
        PBoss = FindAnyObjectByType<PianoBoss>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnDamaged(float dmg, Vector3 hitnormal, bool N)
    {
        Hp -= dmg;

        if(Hp <= 0)
        {
            PBoss.UnenabledSpeakerCnt++;
            if(PBoss.UnenabledSpeakerCnt == PBoss.Speakers.Length)
            {
                PBoss.OnBarrierDestroyed();
            }
            isBursted = true;
            GetComponent<Collider>().enabled = false;
            foreach (ParticleSystem c in BurstEffect)
            {
                c.transform.position = transform.position + Vector3.back;
                c.Play();
            }
        }
    }
}
