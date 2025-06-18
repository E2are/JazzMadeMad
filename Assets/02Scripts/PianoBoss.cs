using Cinemachine;
using RayFire;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class PianoBoss : MonoBehaviour, IDamageAble
{
    [Header("references")]
    Rigidbody rigid;
    Animator anim;
    AudioSource AS;
    IObjectPool<PoolObject> BulletPoolManager;


    [Header("MonsterStates")]
    public float MaxHp;
    public float Hp = 10;
    public bool isBarrierActiavted = true;
    public GameObject Barrier;
    public GameObject BarrierEffect;
    public PianoPlug[] Speakers;
    public int UnenabledSpeakerCnt = 0;

    public Transform DirectionIndicator;
    Vector3 moved_dir = Vector3.zero;

    public GameObject target;

    public float DetectRange = 6;

    public State currentState;
    public enum State
    {
        idle,
        attack,
        hit,
        skill,
        dead
    }
    public bool grounded = false;

    [Header("AttackStates")]
    public GameObject AttackEffect;

    public AudioClip AttackClip;

    public float dmg = 1;

    int attackCnt = 0;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    [Header("Skill1States")]
    public Transform DangerZone;
    public Vector3 DangerZoneScale = Vector3.one;
    public GameObject SafeZonePrefab;

    public GameObject BoxPrefab;

    public GameObject SkillPrefab;

    public GameObject Skill1Effect;

    public float Skill1Dmg = 1;

    public float safeZoneRadius = 4;
    public int safeZoneCnt = 2;

    public bool attacking = false;

    [Header("Skill2States")]
    LineRenderer LR;
    public GameObject SkillEffectPrefab;
    public List<GameObject> SkillEffects = new List<GameObject>();

    public AudioClip Skill2Clip;


    private void Start()
    {
        MaxHp = Hp;

        BulletPoolManager = new ObjectPool<PoolObject>(OnCreateBullet, OnGetBullet, OnReleaseBullet, OnDestroyBullet, true, 12, 100);

        rigid = GetComponent<Rigidbody>();
        anim = GetComponent<Animator>();
        AS = GetComponent<AudioSource>();
        LR = GetComponent<LineRenderer>();

        Invoke("offZone", 0.1f);

        DangerZoneScale = DangerZone.localScale;

        currentState = State.idle;

        IndicateDirection();

        LR.positionCount = 0;
    }

    private void Update()
    {
        if (GameManager.Instance.isGameOver) return;

        switch (currentState)
        {
            case State.idle:
                Idle();
                break;
            case State.attack:
                Attack();
                break;
            case State.skill:
                break;
        }

        Barrier.SetActive(UnenabledSpeakerCnt < 2);

        IndicateDirection();

        AnimationControl();

        CheckGrounded();
    }

    void IndicateDirection()
    {
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit = new RaycastHit();

        if (DirectionIndicator)
        {
            if (Physics.Raycast(ray, out hit, 5, LayerMask.GetMask("Ground")))
            {
                DirectionIndicator.position = hit.point + Vector3.up * 0.2f;
                moved_dir = DirectionIndicator.forward;
            }

        }
    }

    void Idle()
    {
        Collider[] Detects = Physics.OverlapSphere(transform.position, DetectRange);

        if (target == null)
        {
            foreach (Collider c in Detects)
            {
                if (c.gameObject.CompareTag("Player"))
                {
                    target = c.gameObject;
                    currentState = State.attack;
                    AttackTimer = 0;
                    break;
                }
            }
        }
        else
        {
            currentState = State.attack;
            AttackTimer = 0;
        }
    }

    void Attack()
    {
        if (AttackTimer > AttackDelay && !attacking)
        {
            attacking = true;
            StartCoroutine(Attack1Seq());
            AttackTimer = 0;
        }
        else
        {
            AttackTimer += Time.deltaTime;
        }

    }

    IEnumerator Attack1Seq()
    {
        AS.PlayOneShot(AttackClip);
        attackCnt++;
        for (int i = 0; i < Speakers.Length; i++)
        {
            if (!Speakers[i].isBursted)
            {
                Attack1Check(Speakers[i].transform);
            }
        }

        if(UnenabledSpeakerCnt >= 2)
        {
            Attack1Check(transform);
        }

        yield return new WaitForSeconds(1f);
        AttackTimer = 0;
        if (attackCnt > 5)
        {
            attackCnt = 0;
            StartCoroutine(Skill1Seq());
        }
        else
        {
            rigid.velocity = Vector3.zero;
            attacking = false;
            yield return null;
        }
        yield return null;
    }

    IEnumerator Skill1Seq()
    {
        attacking = true;
        ShowDangerZone();
        List<Vector3> SafeZones = new List<Vector3>();
        List<GameObject> SafeZoneShower = new List<GameObject>();
        for (int i = 0; i < safeZoneCnt; i++)
        {
            Ray ray = new Ray(DangerZone.position + new Vector3((DangerZoneScale.x - safeZoneRadius - 2) * Random.Range(-1f, 1f) / 2, DangerZoneScale.y, (DangerZoneScale.z - safeZoneRadius - 2) * Random.Range(-1f, 1f)) / 2, Vector3.down);
            RaycastHit hit = new RaycastHit();

            if (Physics.SphereCast(ray, 1, out hit, 100, LayerMask.GetMask("Ground")))
            {
                SafeZones.Add(hit.point);
                GameObject SafeZone = Instantiate(SafeZonePrefab, hit.point + Vector3.up * 0.1f, Quaternion.Euler(90, 0, 0));
                SafeZone.transform.localScale = Vector3.one * safeZoneRadius;
                SafeZoneShower.Add(SafeZone);
            }
            yield return null;
        }
        yield return new WaitForSeconds(2f);
        Skill1Check(SafeZones);
        offZone();
        foreach (GameObject zone in SafeZoneShower)
        {
            Destroy(zone);
        }
        yield return new WaitForSeconds(1f);
        if (UnenabledSpeakerCnt >= 2)
        {
            Ray ray = new Ray(DangerZone.position + new Vector3((DangerZoneScale.x - safeZoneRadius - 2) * Random.Range(-1f, 1f) / 2, DangerZoneScale.y, (DangerZoneScale.z - safeZoneRadius - 2) * Random.Range(-1f, 1f)) / 2, Vector3.down);
            RaycastHit hit = new RaycastHit();
            if (Physics.SphereCast(ray, 1, out hit, 100, LayerMask.GetMask("Ground")))
            {
                GameObject Box = Instantiate(BoxPrefab, hit.point + Vector3.up * 10f, Quaternion.identity);
            }
            StartCoroutine(Skill2Seq());
        }
        else
        {
            attacking = false;
            rigid.velocity = Vector3.zero;
            currentState = State.attack;
            AttackTimer = 0;
        }
        yield return null;
    }

    IEnumerator Skill2Seq()
    {
        LR.positionCount = 2;
        float Timer = 0;
        Ray ray = new Ray(new Vector3((DangerZoneScale.x / 2) + 1f, target.transform.position.y, target.transform.position.z), Vector3.left);
        RaycastHit hit = new RaycastHit();
        AS.PlayOneShot(Skill2Clip);
        while (Timer < 3)
        {
            Timer += Time.deltaTime;
            LR.SetPosition(0, new Vector3((DangerZoneScale.x / 2), target.transform.position.y, target.transform.position.z));
            ray = new Ray(new Vector3((DangerZoneScale.x / 2) + 1f, target.transform.position.y, target.transform.position.z), Vector3.left);
            if (Physics.Raycast(ray, out hit, 100, LayerMask.GetMask("Wall", "Box", "Ground")))
            {
                LR.SetPosition(1, hit.point);
            }
            yield return null;
        }
        yield return new WaitForSeconds(1f);
        LR.positionCount = 0;
        GameObject Laser = Instantiate(SkillEffectPrefab, new Vector3(DangerZoneScale.x / 2, ray.origin.y, ray.origin.z), Quaternion.identity);
        SkillEffects.Add(Laser);
        
        float ShotPosz = Laser.transform.position.z;

        Timer = 0;
        while (Timer < 3.3f)
        {
            Timer += Time.deltaTime;
            ShotPosz = Mathf.Lerp(ShotPosz, target.transform.position.z, Time.deltaTime * 0.5f);
            ray = new Ray(new Vector3((DangerZoneScale.x / 2) + 1f, target.transform.position.y, ShotPosz), Vector3.left);
            if (Physics.Raycast(ray, out hit, 100, LayerMask.GetMask("Wall", "Box", "Ground")))
            {
                Laser.transform.position = hit.point;
                Laser.transform.up = hit.normal;
            }
            if (Physics.SphereCast(ray, 1, out hit, 100, LayerMask.GetMask("Wall", "Box", "Player")))
            {
                IDamageAble hited = hit.collider.GetComponent<IDamageAble>();
                if (hited != null)
                {
                    hited.OnDamaged(1, Vector3.zero, true);
                }
            }
            yield return null;
        }
        Laser.transform.parent = null;
        if (Physics.SphereCast(ray, 1, out hit, 100, LayerMask.GetMask("Box")))
        {
            IRayfirable fire = hit.collider.GetComponentInParent<IRayfirable>();
            if (fire != null)
            {
                fire.OnDemolish();
                Laser.GetComponent<RayfireBomb>().Explode(0);
            }
        }
        
        attacking = false;
        rigid.velocity = Vector3.zero;
        currentState = State.attack;
        yield return null;
    }
    public void Attack1Check(Transform ShotPos)
    {
        for (int i = -1; i < 2; i++)
        {
            GameObject HalfTime = BulletPoolManager.Get().gameObject;
            HalfTime.transform.position = ShotPos.position + Vector3.back;
            HalfTime.transform.rotation = Quaternion.identity;
            HalfTime.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
            HalfTime.GetComponent<EnemyBullet>().dir = (target.transform.position - ShotPos.position).normalized;
            HalfTime.GetComponent<EnemyBullet>().liveTime = 3;
            HalfTime.GetComponent<EnemyBullet>().speed = 5;
            HalfTime.GetComponent<EnemyBullet>().dmg = dmg;
            HalfTime.transform.localRotation = Quaternion.Euler(0, 20 * i, 0);
            HalfTime.transform.localScale = Vector3.one * 2;
        }
    }

    public void Skill1Check(List<Vector3> SafeZonePos)
    {
        bool TargetInSafeZone = false;
        for (int i = 0; i < SafeZonePos.Count; i++)
        {
            Collider[] hits = Physics.OverlapSphere(SafeZonePos[i], safeZoneRadius, LayerMask.GetMask("Player"));

            foreach (Collider hit in hits)
            {
                if (hit) TargetInSafeZone = true; break;
            }
        }
        if (!TargetInSafeZone)
        {
            target.GetComponent<IDamageAble>().OnDamaged(Skill1Dmg, Vector3.zero, true);
        }
    }

    public void Attack1Off()
    {
        attacking = false;
    }

    void preShowSkillZone(float skillDistance, Vector3 Dir)
    {

    }

    void ShowDangerZone()
    {
        DangerZone.gameObject.SetActive(true);
    }

    void offZone()
    {
        DangerZone.gameObject.SetActive(false);
    }

    public void OnBarrierDestroyed()
    {
        StartCoroutine(BarrierDestroySeq());
    }

    IEnumerator BarrierDestroySeq()
    {
        bool activate = false;
        CreativeLight CL = BarrierEffect.GetComponent<CreativeLight>();
        while(CL.fieldOfView < 160)
        {
            CL.fieldOfView += Time.deltaTime * 20;
            yield return null;
        }
        CL.fieldOfView = 160;
        for(int i = 0; i < 10; i++)
        {
            CL.gameObject.SetActive(activate);
            activate = !activate;
            yield return new WaitForSeconds(0.5f-i/20);
        }
        CL.gameObject.SetActive(false);
    }

    void CheckGrounded()
    {
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit = new RaycastHit();

        if (Physics.Raycast(ray, out hit))
        {
            if (hit.collider.CompareTag("Ground") && rigid.velocity.y <= 0 && hit.distance <= GetComponent<CapsuleCollider>().height * 0.55f + GetComponent<CapsuleCollider>().center.y && !grounded)
            {
                grounded = true;
            }
        }
    }

    public void OnDamaged(float dmg, Vector3 dir, bool N)
    {
        Hp -= dmg;

        if (Hp > 0)
        {
            if (target == null)
            {
                target = FindAnyObjectByType<Player>().gameObject;
            }
        }
        else
        {
            StopAllCoroutines();
            offZone();
            StartCoroutine(DeathSeq());
        }
    }

    public IEnumerator DeathSeq()
    {
        currentState = State.dead;
        GameManager.Instance.GameisOver(true, true);
        yield return null;
    }

    void AnimationControl()
    {

    }



    PoolObject OnCreateBullet()
    {
        GameObject obj = Instantiate(SkillPrefab);
        return obj.GetComponent<PoolObject>();
    }
    void OnGetBullet(PoolObject EB)
    {
        EB.gameObject.SetActive(true);
    }
    void OnReleaseBullet(PoolObject EB)
    {
        EB.gameObject.SetActive(false);
    }
    void OnDestroyBullet(PoolObject EB)
    {
        Destroy(EB.gameObject);
    }

}
