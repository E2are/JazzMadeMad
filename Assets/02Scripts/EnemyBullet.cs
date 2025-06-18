using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyBullet : PoolObject
{
    [Header("Options")]
    public bool isDestroy;
    public bool isAcceleratable = false;
    public bool isPanicBullet = false;
    public float panicTime = 3;
    [Header("BulletStates")]
    public float dmg = 1;
    public float liveTime = 3;
    public AudioClip hitClip;
    public GameObject[] HitEffects;
    public float pitch = 1;

    public Vector3 dir;
    public float speed = 10;

    private void Update()
    {
        transform.Translate(dir * speed * Time.deltaTime * 2);

        if(isAcceleratable)
        {
            speed += Time.deltaTime;
        }

        if (liveTime < 0)
        {
            if (isDestroy)
            {
                Destroy(gameObject);
            }
            else
            {
                PoolManager.Release(this);
            }
        }
        else
        {
            liveTime -= Time.deltaTime;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.gameObject.CompareTag("Enemy") && !other.gameObject.CompareTag("Bullet"))
        {
            if (!isPanicBullet)
            {
                IDamageAble hited = other.GetComponent<IDamageAble>();
                if (hited != null)
                {
                    hited.OnDamaged(dmg, dir);
                }
            }
            else
            {
                Player player = other.GetComponent<Player>();
                if (player)
                {
                    player.DisableDash(panicTime);
                }
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
            if (isDestroy)
            {
                Destroy(gameObject);
            }
            else
            {
                PoolManager.Release(this);
            }
        }
    }
}
