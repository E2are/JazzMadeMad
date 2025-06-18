using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class WoodwindBoss : MonoBehaviour, IDamageAble
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
    public GameObject BulletPrefab;

    public AudioClip AttackClip;

    public bool attacking = false;

    public float dmg = 1;

    public int shotAmount = 10;

    public float AttackDistance;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    [Header("Skill1States")]
    public AudioClip Skill1Clip;

    public float Skill1dmg;

    public float Skill1Delay = 2f;
    float Skill1Timer = 0;

    [Header("Skill2States")]
    public bool Skill2Used = false;

    float Skill2Timer=0;
    float Skill2Delay;
    public float Skill2MinDelay;
    public float Skill2MaxDelay;

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

        IndicateDirection();

        Skill2Delay = Random.Range(Skill2MinDelay,Skill2MaxDelay);
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

        if (Skill2Used)
        {
            if (Skill2Timer > Skill2Delay)
            {
                GameObject Bullet = BulletPoolManager.Get().gameObject;
                int index = Random.Range(0, Skill2Points.Length);
                Bullet.transform.position = Skill2Points[index].position + Vector3.up;
                Bullet.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
                Bullet.GetComponent<EnemyBullet>().dir = (target.transform.position - (Skill2Points[index].position + Vector3.up)).normalized;
                Bullet.GetComponent<EnemyBullet>().liveTime = 3;
                Bullet.GetComponent<EnemyBullet>().speed = 5;
                Bullet.GetComponent<EnemyBullet>().transform.localScale = Vector3.one * 2;

                Skill2Delay = Random.Range(Skill2MinDelay,Skill2MaxDelay);
                Skill2Timer = 0;
            }
            else
            {
                Skill2Timer += Time.deltaTime;
            }
        }

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
        }
    }

    void Attack()
    {
        if (Vector3.Distance(target.transform.position, transform.position) > AttackDistance && !attacking && grounded)
        {
            currentState = State.move;
        }
        else
        {
            if (AttackTimer > AttackDelay && !attacking)
            {
                attacking = true;
                StopAllCoroutines();
                StartCoroutine(Attack1Seq());
                AttackTimer = 0;
            }
            else
            {
                AttackTimer += Time.deltaTime;
            }
        }
    }


    IEnumerator Attack1Seq()
    {
        yield return new WaitForSeconds(1f);
        AS.PlayOneShot(AttackClip);
        Attack1Check();

        StartCoroutine(Skill1Seq());
        attacking = false;
        AttackTimer = AttackDelay / 1.5f;
        currentState = State.move;
        yield return null;
    }

    IEnumerator Skill1Seq()
    {
        attacking = true;
        yield return new WaitForSeconds(1f);        
        AS.PlayOneShot(Skill1Clip);

        Skill1Check();

        yield return new WaitForSeconds(1f);
        attacking = false;
        AttackTimer = AttackDelay / 1.5f;
        currentState = State.move;

        yield return null;
    }

    IEnumerator Skill2Seq()
    {
        Skill2Used = true;
        Skilling = true;
        AS.PlayOneShot(Skill2Clip);
        foreach (Transform t in Skill2Points)
        {
            GameObject Brasses = Instantiate(Skill2Prefab, t.position, Quaternion.identity);
        }

        yield return new WaitForSeconds(2f);
        attacking = false;
        AttackTimer = AttackDelay / 1.5f;
        Skilling = false;
        yield return null;
    }


    public void Attack1Check()
    {
        for (int i = -1; i < 2; i++)
        {
            GameObject HalfTime = BulletPoolManager.Get().gameObject;
            HalfTime.transform.position = transform.position;
            HalfTime.transform.rotation = Quaternion.identity;
            HalfTime.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
            HalfTime.GetComponent<EnemyBullet>().dir = (target.transform.position - transform.position).normalized;
            HalfTime.GetComponent<EnemyBullet>().liveTime = 3;
            HalfTime.GetComponent<EnemyBullet>().speed = 5;
            HalfTime.GetComponent<EnemyBullet>().dmg = dmg;
            HalfTime.transform.localRotation = Quaternion.Euler(0, 20 * i, 0);
            HalfTime.transform.localScale = Vector3.one * 2;
        }
    }

    public void Skill1Check()
    {
        GameObject HalfTime = BulletPoolManager.Get().gameObject;
        HalfTime.transform.position = transform.position + Vector3.up;
        HalfTime.transform.rotation = Quaternion.identity;
        HalfTime.GetComponent<EnemyBullet>().dir = (target.transform.position - transform.position).normalized;
        HalfTime.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
        HalfTime.GetComponent<EnemyBullet>().liveTime = 5;
        HalfTime.GetComponent<EnemyBullet>().speed = 1;
        HalfTime.GetComponent<EnemyBullet>().dmg = dmg;

        HalfTime.GetComponent<EnemyBullet>().isAcceleratable = true;
        HalfTime.transform.localScale = Vector3.one * 5;
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

        if (Hp < MaxHp * 0.5f && !Skill2Used)
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
            if (N)
            {
                attacking = false;
                StopAllCoroutines();
                StartCoroutine(OnDamagedSeq(-dir));
            }
        }
        
        else
        {
            StopAllCoroutines();
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

