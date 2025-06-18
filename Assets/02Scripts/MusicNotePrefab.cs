using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;

public class MusicNotePrefab : PoolObject
{
    [Header("BulletType")]
    public bool isKnockableBullet = false;
    public bool isPierceAble = false;
    public float pierceDelay;
    [SerializeField] float pierceTimer;

    [Header("BulletStates")]
    public float dmg = 5;
    public float liveTime = 3;
    public int pierceTime = 3;
    public AudioClip hitClip;
    public GameObject[] HitEffects;
    public float pitch = 1;

    public Vector3 dir;
    public float speed = 10;

    private void Update()
    {
        transform.Translate(dir * speed * Time.deltaTime);
        if(liveTime < 0)
        {
            PoolManager.Release(this);
        }
        else
        {
            liveTime -= Time.deltaTime;
        }

        if(isPierceAble )
        {
            pierceTimer += Time.deltaTime;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(!other.gameObject.CompareTag("Player")&&!other.gameObject.CompareTag("Bullet")&&!isPierceAble)
        {
            IDamageAble hited = other.GetComponent<IDamageAble>();
            if(hited != null)
            {
                hited.OnDamaged(dmg, dir, isKnockableBullet);
            }

            foreach (GameObject HitEffect in HitEffects)
            {
                GameObject Effect = Instantiate(HitEffect);
                if(Effect.GetComponent<AudioSource>() != null)
                {
                    Effect.GetComponent<AudioSource>().PlayOneShot(hitClip);
                    Effect.GetComponent<AudioSource>().pitch = pitch;
                }
                Effect.transform.localScale = transform.localScale / 2;
                Ray ray = new Ray(transform.position, (other.transform.position - transform.position).normalized);
                RaycastHit hit = new RaycastHit();
                if (Physics.Raycast(ray, out hit, 0.2f))
                {
                    Effect.transform.up = hit.normal;
                    Effect.transform.position = hit.point + hit.normal / 5;
                }
                else
                {
                    Effect.transform.position = transform.position;
                }
            }

            PoolManager.Release(this);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (!other.gameObject.CompareTag("Player") && !other.gameObject.CompareTag("Bullet") && isPierceAble && pierceTimer > pierceDelay)
        {
            IDamageAble hited = other.GetComponent<IDamageAble>();
            if (hited != null)
            {
                hited.OnDamaged(dmg, dir, isKnockableBullet);
            }

            foreach (GameObject HitEffect in HitEffects)
            {
                GameObject Effect = Instantiate(HitEffect);
                if (Effect.GetComponent<AudioSource>() != null)
                {
                    Effect.GetComponent<AudioSource>().PlayOneShot(hitClip);
                    Effect.GetComponent<AudioSource>().pitch = pitch;
                }
                Effect.transform.localScale = transform.localScale / 2;
                Ray ray = new Ray(transform.position, (other.transform.position - transform.position).normalized);
                RaycastHit hit = new RaycastHit();
                if (Physics.Raycast(ray, out hit, 0.2f))
                {
                    Effect.transform.up = hit.normal;
                    Effect.transform.position = hit.point + hit.normal / 5;
                }
                else
                {
                    Effect.transform.position = transform.position;
                }
            }
            pierceTime--;
            pierceTimer = 0;

            if (pierceTime <= 0)
            {
                PoolManager.Release(this);
            }
        }
    }
}
