using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrassBoss_Brass : MonoBehaviour
{
    AudioSource AS;
    public Transform AttackPreShowZone;
    public ParticleSystem AttackEffect;
    public AudioClip AttackClip;
    public int dmg;
    public float AttackminDelay;
    public float AttackmaxDelay;
    public float Attackdelay;
    float Timer = 0;
    public float AttackDistance;

    private void Start()
    {
        AS = GetComponent<AudioSource>();
        Attackdelay = Random.Range(AttackminDelay, AttackmaxDelay);
    }

    private void Update()
    {
        if(Timer > Attackdelay)
        {
            StartCoroutine(Attack1Seq());
            Timer = 0;
            Attackdelay = Random.Range(AttackminDelay, AttackmaxDelay);
        }
        else
        {
            Timer += Time.deltaTime;
        }
    }

    IEnumerator Attack1Seq()
    {
        preShowAttackZone(AttackDistance);
        yield return new WaitForSeconds(1f);
        offZone();
        CheckAttack1();
        yield return null;
    }

    void CheckAttack1()
    {
        Collider[] hit = Physics.OverlapSphere(transform.position, AttackDistance, LayerMask.GetMask("Player"));

        AS.PlayOneShot(AttackClip);

        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hits;
        if (Physics.Raycast(ray, out hits, 200, LayerMask.GetMask("Ground")))
        {
            AttackEffect.transform.position = hits.point + Vector3.up * 0.1f;
            AttackEffect.Play();
        }

        foreach (Collider C in hit)
        {
            IDamageAble hited = C.GetComponent<IDamageAble>();
            if (hited != null)
            {
                hited.OnDamaged(dmg, transform.forward);
            }
        }
    }

    void preShowAttackZone(float skillDistance)
    {
        AttackPreShowZone.gameObject.SetActive(true);
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, 200, LayerMask.GetMask("Ground")))
        {
            AttackPreShowZone.position = hit.point + Vector3.up * 0.1f;
        }
        AttackPreShowZone.localScale = Vector3.one * skillDistance;
        AttackPreShowZone.up = Vector3.forward;
        AttackPreShowZone.localEulerAngles = new Vector3(0, AttackPreShowZone.localEulerAngles.y, AttackPreShowZone.localEulerAngles.z);
    }

    void offZone()
    {
        AttackPreShowZone.gameObject.SetActive(false);
    }
}
