using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class BrassBoss : MonoBehaviour, IDamageAble
{
    [Header("references")]
    Rigidbody rigid;
    Animator anim;
    NavMeshAgent agent;
    AudioSource AS;
    IObjectPool<PoolObject> BulletPoolManager;


    [Header("MonsterStates")]
    public float MaxHp;
    public float Hp = 10;

    public float speed = 6;

    public Transform DirectionIndicator;
    Vector3 moved_dir = Vector3.zero;

    public GameObject target;

    public float DetectRange = 6;

    public State currentState;
    public enum State
    {
        idle,
        move,
        attack,
        hit,
        skill,
        dead
    }
    public bool grounded = false;

    [Header("AttackStates")]
    public Transform AttackPreShowZone;

    public GameObject BulletPrefab;

    public ParticleSystem AttackEffect;

    public AudioClip AttackClip;

    public bool attacking = false;

    public float dmg = 1;

    public float AttackDistance;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    [Header("Skill1States")]
    public float Skill1dmg;

    public ParticleSystem Skill1Effect;

    public AudioClip Skill1Clip;

    public float Skill1Delay = 2f;
    float Skill1Timer = 0;

    [Header("Skill2States")]
    public bool Skill2Used = false;

    public GameObject Skill2Prefab;

    public AudioClip Skill2Clip;

    public Transform[] Skill2Points;

    public bool Skilling = false;


    private void Start()
    {
        MaxHp = Hp;

        BulletPoolManager = new ObjectPool<PoolObject>(OnCreateBullet, OnGetBullet, OnReleaseBullet, OnDestroyBullet, true, 20, 100);

        rigid = GetComponent<Rigidbody>();
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();
        AS = GetComponent<AudioSource>();

        Invoke("offZone", 0.1f);

        agent.speed = speed;
        currentState = State.idle;

        AttackEffect.Stop();
        Skill1Effect.Stop();

        IndicateDirection();
    }

    private void Update()
    {
        if (GameManager.Instance.isGameOver) return;

        switch (currentState)
        {
            case State.idle:
                Idle();
                break;
            case State.move:
                Move();
                break;
            case State.attack:
                Attack();
                break;
            case State.hit:
                break;
        }

        IndicateDirection();

        AnimationControl();

        CheckGrounded();
    }

    void IndicateDirection()
    {
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit = new RaycastHit();

        if (agent != null && DirectionIndicator)
        {
            if (agent.velocity == Vector3.zero)
            {
                DirectionIndicator.forward = moved_dir;
            }
            else
            {
                if (Physics.Raycast(ray, out hit, 5, LayerMask.GetMask("Ground")))
                {
                    DirectionIndicator.position = hit.point + Vector3.up * 0.1f;
                    DirectionIndicator.forward = -agent.velocity.normalized;
                    moved_dir = DirectionIndicator.forward;
                }
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
                    currentState = State.move;
                    break;
                }
            }
        }
        else
        {
            currentState = State.move;
        }
    }

    private void Move()
    {
        if (Vector3.Distance(target.transform.position, transform.position) < AttackDistance * 0.9f)
        {
            currentState = State.attack;
            agent.destination = transform.position;
            AttackTimer = AttackDelay;
            rigid.velocity = Vector3.zero;
        }
        else
        {
            agent.enabled = true;
            agent.destination = target.transform.position;
            if(Skill1Delay < Skill1Timer && !attacking)
            {
                StartCoroutine(Skill1Seq());
                Skill1Timer = 0;
            }
            else
            {
                Skill1Timer += Time.deltaTime;
            }
        }
    }

    void Attack()
    {
        if (Vector3.Distance(target.transform.position, transform.position) > AttackDistance && !attacking && grounded)
        {
            currentState = State.move;
            AttackPreShowZone.gameObject.SetActive(false);
            Skill1Timer = 0;
        }
        else
        {
            if (AttackTimer > AttackDelay && !attacking)
            {
                attacking = true;
                agent.destination = transform.position;
                StartCoroutine(Attack1Seq());
                
                AttackTimer = 0;
            }
            else
            {
                AttackTimer += Time.deltaTime;
                agent.destination = target.transform.position;
            }
        }
    }

    IEnumerator Attack1Seq()
    {
        preShowAttackZone(AttackDistance, transform.forward);
        yield return new WaitForSeconds(1f);
        offZone();
        Attack1Check();
        agent.destination = transform.position;
        attacking = false;
        AttackTimer = 0;
        currentState = State.move;
        
        yield return null;
    }

    IEnumerator Skill1Seq()
    {
        attacking = true;

        Skill1Effect.Play();
        yield return new WaitForSeconds(1f);
        Skill1Effect.Stop();
        AS.PlayOneShot(Skill1Clip);

        Vector3 dir = target.transform.position - transform.position;
        GameObject Note = BulletPoolManager.Get().gameObject;
        Note.transform.position = transform.position;
        Note.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
        Note.GetComponent<EnemyBullet>().dir = dir;
        Note.GetComponent<EnemyBullet>().liveTime = 3;
        Note.GetComponent<EnemyBullet>().speed = 1;
        Note.GetComponent<EnemyBullet>().panicTime = 3;
        Note.GetComponent<EnemyBullet>().isPanicBullet = true;
        Note.GetComponent<EnemyBullet>().isAcceleratable = true;

        yield return new WaitForSeconds(1f);
        attacking = false;
        AttackTimer = AttackDelay / 1.5f;
        currentState = State.move;

        yield return null;
    }

    IEnumerator Skill2Seq()
    {
        Skilling = true;
        AS.PlayOneShot(Skill2Clip);
        foreach (Transform t in Skill2Points)
        {
            GameObject Brasses = Instantiate(Skill2Prefab, t.position, Quaternion.identity);
        }
        Skill2Used = true;
        
        yield return new WaitForSeconds(2f);
        attacking = false;
        AttackTimer = AttackDelay / 1.5f;
        Skilling = false;
        yield return null;
    }

    void preShowAttackZone(float skillDistance, Vector3 Dir)
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

    public void Attack1Check()
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

    public void Attack1Off()
    {
        attacking = false;
    }

    void CheckGrounded()
    {
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit = new RaycastHit();

        if (Physics.Raycast(ray, out hit))
        {
            if (hit.collider.CompareTag("Ground") && rigid.velocity.y < 0 && hit.distance <= GetComponent<CapsuleCollider>().height * 0.55f && !grounded)
            {
                grounded = true;
            }
        }
    }

    public void OnDamaged(float dmg, Vector3 dir, bool N)
    {
        Hp -= dmg;

        if(Hp/MaxHp <= 0.5f && !Skill2Used)
        {
            Skill2Used = true;
            StartCoroutine(Skill2Seq());
        }
        else if (Hp > 0)
        {
            if (target == null)
            {
                target = FindAnyObjectByType<Player>().gameObject;
            }
            if (N && !Skilling)
            {
                StopAllCoroutines();
                offZone();
                attacking = false;
                StartCoroutine(OnDamagedSeq(-dir));
            }
        }
        else
        {
            StopAllCoroutines();
            offZone();
            StartCoroutine(DeathSeq());
        }
    }

    public IEnumerator OnDamagedSeq(Vector3 hitnormal)
    {
        if (currentState != State.hit)
        {
            grounded = false;
            agent.enabled = false;
            rigid.velocity = Vector3.zero;
            rigid.constraints = RigidbodyConstraints.FreezeRotation;
            rigid.AddForce(Vector3.up * 3, ForceMode.Impulse);
        }
        currentState = State.hit;
        yield return new WaitForSeconds(0.4f);
        yield return new WaitUntil(() => grounded);
        agent.enabled = true;
        rigid.constraints = RigidbodyConstraints.FreezeAll;
        currentState = State.move;
        yield return null;
    }


    public IEnumerator DeathSeq()
    {
        currentState = State.dead;
        agent.enabled = false;
        GameManager.Instance.GameisOver(true, true);
        yield return null;
    }

    void AnimationControl()
    {

    }



    PoolObject OnCreateBullet()
    {
        GameObject obj = Instantiate(BulletPrefab);
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

