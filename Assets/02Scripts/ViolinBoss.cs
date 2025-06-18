using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class ViolinBoss : MonoBehaviour, IDamageAble
{
    [Header("references")]
    Rigidbody rigid;
    Animator anim;
    SpriteRenderer SR;
    GameObject Appearence;
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

    public GameObject AttackPrefab;

    public ParticleSystem AttackEffect;

    public AudioClip AttackClip;

    public bool attacking = false;

    public float dmg = 1;

    public int shotCnt = 10;

    public Vector3 AttackRange = Vector3.one * 2;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    [Header("Skill1States")]
    public LineRenderer Skill1LR;

    public GameObject Skill1Effect;

    public AudioClip Skill1Clip;
    public AudioClip Skill2Clip;

    public ParticleSystem[] Skill1Effects;

    public float Skill1Dmg = 1;

    public float Skill1Distance = 4;

    /*[Header("Skill2States")]*/


    private void Start()
    {
        MaxHp = Hp;

        BulletPoolManager = new ObjectPool<PoolObject>(OnCreateBullet, OnGetBullet, OnReleaseBullet, OnDestroyBullet, true, 12, 100);

        rigid = GetComponent<Rigidbody>();
        anim = GetComponentInChildren<Animator>();
        agent = GetComponent<NavMeshAgent>();
        Skill1LR = GetComponent<LineRenderer>();
        Skill1Effects = Skill1Effect.GetComponentsInChildren<ParticleSystem>();
        AS = GetComponent<AudioSource>();

        Appearence = anim.gameObject;
        SR = Appearence.GetComponent<SpriteRenderer>();

        Skill1LR.positionCount = 0;

        foreach (ParticleSystem i in Skill1Effects)
        {
            i.Stop();
        }

        Invoke("offZone", 0.1f);

        agent.speed = speed;
        currentState = State.idle;

        AttackEffect.Stop();

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
        }

        Appearence.transform.forward = Vector3.forward;

        if (!attacking && agent.velocity.x != 0)
            SR.flipX = 0 >= agent.velocity.x ? true : false;
        else if (!attacking)
            SR.flipX = target.transform.position.x <= transform.position.x ? true : false;
        SR.sortingOrder = target.transform.position.z <= transform.position.z ? -1 : 3;

        IndicateDirection();

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
            anim.SetBool("Move", true);
        }
    }

    private void Move()
    {
        if (Vector3.Distance(target.transform.position, transform.position) < AttackRange.z * 0.9f)
        {
            currentState = State.attack;
            agent.destination = transform.position;
            AttackTimer = AttackDelay;
            rigid.velocity = Vector3.zero;
            agent.enabled = false;
            anim.SetBool("Move", false);
        }
        else
        {
            agent.enabled = true;
            agent.destination = target.transform.position;
        }
    }

    void Attack()
    {
        if (Vector3.Distance(target.transform.position, transform.position) > AttackRange.z && !attacking && grounded)
        {
            currentState = State.move;
            anim.SetBool("Move", true);
            AttackPreShowZone.gameObject.SetActive(false);
            agent.enabled = true;
        }
        else
        {
            if (AttackTimer > AttackDelay && !attacking)
            {
                attacking = true;
                StopAllCoroutines();
                if (Hp > MaxHp / 2)
                {
                    anim.SetBool("Attacking", true);
                    StartCoroutine(Attack1Seq());
                }
                else
                {
                    anim.SetBool("Attacking", true);
                    StartCoroutine(Skill2Seq());
                }
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
        AttackEffect.Play();
        for (int i = 0; i < shotCnt; i++)
        {
            Vector3 dir = target.transform.position - transform.position;
            if (i % 2 == 0)
            {
                AS.PlayOneShot(AttackClip);
                for (int j = -2; j < 3; j++)
                {
                    GameObject Bullet = BulletPoolManager.Get().gameObject;
                    Bullet.transform.position = transform.position;
                    Bullet.transform.localRotation = Quaternion.Euler(0, j * 5, 0);
                    Bullet.GetComponent<EnemyBullet>().dir = (dir).normalized;
                    Bullet.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
                    Bullet.GetComponent<EnemyBullet>().dmg = dmg;
                    Bullet.GetComponent<EnemyBullet>().speed = 5;
                    Bullet.GetComponent<EnemyBullet>().liveTime = 3;
                }
                yield return new WaitForSeconds(0.5f);
            }
            else
            {
                for (int j = -1; j < 2; j += 2)
                {
                    GameObject Bullet = BulletPoolManager.Get().gameObject;
                    Bullet.transform.position = transform.position;
                    Bullet.transform.localRotation = Quaternion.Euler(0, j * 20, 0);
                    Bullet.GetComponent<EnemyBullet>().dir = (dir).normalized;
                    Bullet.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
                    Bullet.GetComponent<EnemyBullet>().dmg = dmg;
                    Bullet.GetComponent<EnemyBullet>().speed = 5;
                    Bullet.GetComponent<EnemyBullet>().liveTime = 3;
                }
                yield return new WaitForSeconds(1.5f);
            }
            yield return null;
        }
        AttackEffect.Stop();
        
        if (Vector3.Distance(target.transform.position, transform.position) > AttackRange.z / 2)
        {
            StartCoroutine(Skill1Seq());
        }
        else
        {
            attacking = false;
            anim.SetBool("Attacking", false);
            AttackTimer = AttackDelay / 1.5f;
        }
        yield return null;
    }

    IEnumerator Skill1Seq()
    {
        foreach (ParticleSystem i in Skill1Effects)
        {
            i.Stop();
        }
        Skill1LR.positionCount = 2;
        Skill1LR.SetPosition(0, transform.position);

        Vector3 dir = target.transform.position - transform.position;
        Ray ray = new Ray(transform.position, dir.normalized);
        RaycastHit hit = new RaycastHit();

        Skill1LR.SetPosition(1, transform.position + dir * 30);

        yield return new WaitForSeconds(0.8f);

        AS.pitch = 1f;
        AS.PlayOneShot(Skill1Clip);

        Skill1LR.positionCount = 0;

        Skill1Effect.transform.up = dir;
        Skill1Effect.transform.position = transform.position+dir*0.1f;
        foreach (ParticleSystem i in Skill1Effects)
        {
            i.Play();
        }
        while (Skill1Effects[0].isPlaying)
        {
            if (Physics.SphereCast(ray, 0.5f, out hit, 30, LayerMask.GetMask("Player", "Ground", "Wall")))
            {
                Player hitplayer = hit.collider.GetComponent<Player>();
                if (hitplayer != null)
                {
                    hitplayer.DisableDash(5);
                }
            }
            yield return null;
        }
        foreach (ParticleSystem i in Skill1Effects)
        {
            i.Stop();
        }

        attacking = false;
        anim.SetBool("Attacking", false);
        AttackTimer = AttackDelay / 1.5f;
        yield return null;
    }

    IEnumerator Skill2Seq()
    {
        AS.PlayOneShot(Skill2Clip);
        for (int j = 1; j < 4; j++)
        {
            Vector3 dir = (target.transform.position - transform.position).normalized;
            dir = new Vector3(dir.x, 0, dir.z);
            for (int i = -9; i < 9; i++)
            {
                float angle = (Mathf.PI * 2) * i / (18);

                GameObject MixTime = BulletPoolManager.Get().gameObject;
                MixTime.transform.position = transform.position;
                MixTime.transform.rotation = Quaternion.identity;
                MixTime.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
                MixTime.GetComponent<EnemyBullet>().liveTime = 3;
                MixTime.GetComponent<EnemyBullet>().dir = dir;
                MixTime.GetComponent<EnemyBullet>().speed = 5;
                MixTime.GetComponent<EnemyBullet>().isAcceleratable = true;

                MixTime.transform.localRotation = Quaternion.Euler(0, angle*55, 0);
                MixTime.transform.localScale = Vector3.one * 2;
            }
            yield return new WaitForSeconds(0.5f);
        }

        if (Vector3.Distance(target.transform.position, transform.position) > AttackRange.z / 2)
        {
            StartCoroutine(Skill1Seq());
        }
        else
        {
            attacking = false;
            anim.SetBool("Attacking", false);
            AttackTimer = AttackDelay / 1.5f;
        }
        yield return null;
    }

    void offZone()
    {
        AttackPreShowZone.gameObject.SetActive(false);
        /*SkillPreShowZone.gameObject.SetActive(false);*/
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

        if (Hp > 0)
        {
            if (target == null)
            {
                target = FindAnyObjectByType<Player>().gameObject;
            }

            /*attacking = false;
            StartCoroutine(OnDamagedSeq(-dir));
            */
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

    PoolObject OnCreateBullet()
    {
        GameObject obj = Instantiate(AttackPrefab);
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

