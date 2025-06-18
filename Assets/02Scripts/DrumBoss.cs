using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class DrumBoss : MonoBehaviour, IDamageAble
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

    public GameObject AttackEffect;

    public AudioClip AttackClip;

    public float dmg = 1;

    public Vector3 AttackRange = Vector3.one * 2;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    [Header("Skill1States")]
    public Transform SkillPreShowZone;

    public GameObject SkillPrefab;

    public GameObject Skill1Effect;

    public AudioClip Skill1JumpClip;
    public AudioClip Skill1StompClip;

    public float Skill1Dmg = 1;

    public float Skill1Distance = 4;

    public bool attacking = false;

    [Header("Skill2States")]
    public Transform PreShowSpawnZonePrefab;

    public GameObject SpawnEnemyPrefab;
    public int spawnCnt = 3;
    public int SpawnEnemyHp = 5;
    public float SpawnDistance = 3;
    public bool Skilling = false;

    public AudioClip Skill2Clip;


    private void Start()
    {
        MaxHp = Hp;

        BulletPoolManager = new ObjectPool<PoolObject>(OnCreateBullet, OnGetBullet, OnReleaseBullet, OnDestroyBullet, true, 12, 100);

        rigid = GetComponent<Rigidbody>();
        anim = transform.GetChild(0).GetComponentInChildren<Animator>();
        agent = GetComponent<NavMeshAgent>();
        AS = GetComponent<AudioSource>();

        Appearence = anim.gameObject;
        SR = Appearence.GetComponent<SpriteRenderer>();

        Invoke("offZone", 0.1f);

        agent.speed = speed;
        currentState = State.idle;

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
            case State.skill:
                break;
        }

        Appearence.transform.forward = Vector3.forward;

        if (!attacking && agent.velocity.x != 0)
            SR.flipX = 0 <= agent.velocity.x ? true : false;
        else if (!attacking)
            SR.flipX = target.transform.position.x >= transform.position.x ? true : false;
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
                if (Physics.Raycast(ray, out hit,5,LayerMask.GetMask("Ground")))
                {
                    DirectionIndicator.position = hit.point + Vector3.up * 0.2f;
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
            anim.SetBool("moving", true);
        }
    }

    private void Move()
    {
        if (Vector3.Distance(target.transform.position, transform.position) < AttackRange.z * 0.7f)
        {
            currentState = State.attack;
            agent.enabled = true;
            agent.destination = transform.position;
            AttackTimer = AttackDelay;
            rigid.velocity = Vector3.zero;
            agent.enabled = false;
            anim.SetBool("moving", false);
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
            anim.SetBool("moving", true);
            agent.enabled = true;
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
        anim.SetBool("attacking", true);
        Vector3 Dir = (target.transform.position - transform.position).normalized;
        preShowAttackZone(AttackRange, Dir);
        yield return new WaitForSeconds(1f);
        Attack1Check(Dir,Quaternion.LookRotation(Dir));
        anim.SetTrigger("atk");
        offZone();
        yield return new WaitForSeconds(0.5f);
        if (Vector3.Distance(target.transform.position, transform.position) < Skill1Distance * 3.5f)
        {
            yield return new WaitForSeconds(0.5f);
            StartCoroutine(Skill1Seq());
        }
        else
        {
            anim.SetBool("attacking", false);
            AttackTimer = AttackDelay / 3;
            rigid.velocity = Vector3.zero;
            currentState = State.move;
            anim.SetBool("moving", true);
            attacking = false;
        }
        yield return null;
    }

    bool mopSpawned = false;
    IEnumerator Skill1Seq()
    {
        anim.SetBool("attacking", true);
        anim.Play("DrumBoss_StompAttackStart",0,0);
        yield return new WaitForSeconds(0.2f);
        attacking = true;
        AS.PlayOneShot(Skill1JumpClip);
        Vector3 Dir = (target.transform.position - transform.position).normalized;
        Vector3 Destination = target.transform.position + Vector3.up * 0.1f;
        float timer = 0;
        while (timer < 1f)
        {
            timer += Time.deltaTime;
            transform.position = Vector3.Lerp(transform.position, Destination + Vector3.up, timer);
            preShowSkillZone(Skill1Distance, Dir);
            IndicateDirection();
            yield return null;
        }
        anim.Play("DrumBoss_Stomping", 0, 0);
        while (timer < 1f)
        {
            timer += Time.deltaTime;
            transform.position = Vector3.Lerp(transform.position, Destination, timer);
            yield return null;
        }
        anim.Play("DrumBoss_StompAttackEnd", 0, 0);
        transform.position = Destination;
        Skill1Check(Dir,Quaternion.LookRotation(Dir));
        offZone();
        yield return new WaitForSeconds(1f);
        if (Hp/MaxHp <= 0.5f && !mopSpawned)
        {
            StartCoroutine(Skill2Seq());
        }
        else
        {
            anim.SetBool("attacking", false);
            attacking = false;
            rigid.velocity = Vector3.zero;
            currentState = State.move;
            anim.SetBool("moving", true);
            AttackTimer = AttackDelay / 2;
        }
        mopSpawned = !mopSpawned;
        yield return null;
    }

    IEnumerator Skill2Seq()
    {
        Skilling = true;
        AS.PlayOneShot(Skill2Clip);
        anim.Play("DrumBoss_SpawnStart", 0);
        yield return new WaitForSeconds(0.1f);
        anim.Play("DrumBoss_Spawning", 0);
        List<GameObject> list = new List<GameObject>();
        for (int i = 0; i < spawnCnt; i++)
        {
            Vector3 spawnPoint = Random.insideUnitSphere * SpawnDistance + transform.position;

            NavMeshHit hit;

            NavMesh.SamplePosition(spawnPoint, out hit, SpawnDistance, NavMesh.AllAreas);

            GameObject SpawnZoneShow = Instantiate(PreShowSpawnZonePrefab.gameObject, hit.position + Vector3.up * 0.1f, Quaternion.identity);
            list.Add(SpawnZoneShow);
            yield return null;
        }
        yield return new WaitForSeconds(2f);
        anim.Play("DrumBoss_SpawnEnd", 0);
        for (int i = 0; i < spawnCnt; i++)
        {
            GameObject spawnedEnemy = Instantiate(SpawnEnemyPrefab, transform.position + Vector3.up * 0.4f, Quaternion.identity);
            spawnedEnemy.GetComponent<MiniEnemyDrum>().Hp = SpawnEnemyHp;
            spawnedEnemy.GetComponent<MiniEnemyDrum>().target = target;
            spawnedEnemy.GetComponent<IDamageAble>().OnDamaged(0, list[i].transform.position + Vector3.up * 0.4f - transform.position);
            Destroy(list[i]);
            yield return new WaitForSeconds(0.1f);
        }
        yield return new WaitForSeconds(1f);
        attacking = false;
        Skilling = false;
        rigid.velocity = Vector3.zero;
        currentState = State.move;
        anim.SetBool("moving", true);
    }

    void preShowAttackZone(Vector3 AttackZone, Vector3 Dir)
    {
        AttackPreShowZone.gameObject.SetActive(true);
        Ray ray = new Ray(transform.position + Dir * AttackRange.z / 2, Vector3.down);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, 200, LayerMask.GetMask("Ground")))
        {
            AttackPreShowZone.position = hit.point + Vector3.up * 0.2f;
        }
        AttackPreShowZone.localScale = new Vector3(AttackZone.x, AttackZone.y, AttackZone.z);
        AttackPreShowZone.forward = Dir;
        AttackPreShowZone.localEulerAngles = new Vector3(0, AttackPreShowZone.localEulerAngles.y, AttackPreShowZone.localEulerAngles.z);
    }
    
    void preShowSkillZone(float skillDistance, Vector3 Dir)
    {
        SkillPreShowZone.gameObject.SetActive(true);
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, 200, LayerMask.GetMask("Ground")))
        {
            SkillPreShowZone.position = hit.point + Vector3.up * 0.2f;
        }
        SkillPreShowZone.localScale = Vector3.one * skillDistance;
        SkillPreShowZone.up = Vector3.forward;
        SkillPreShowZone.localEulerAngles = new Vector3(0, SkillPreShowZone.localEulerAngles.y, SkillPreShowZone.localEulerAngles.z);
    }

    void offZone()
    {
        AttackPreShowZone.gameObject.SetActive(false);
        SkillPreShowZone.gameObject.SetActive(false);
    }

    public void Attack1Check(Vector3 moveDir, Quaternion rotation)
    {
        Collider[] hit = Physics.OverlapBox(transform.position + moveDir * AttackRange.z/2, AttackRange/2, rotation, LayerMask.GetMask("Player"));

        AS.PlayOneShot(AttackClip);

        Ray ray = new Ray(transform.position + moveDir, Vector3.down);
        RaycastHit hits;
        if (Physics.Raycast(ray, out hits, 200, LayerMask.GetMask("Ground")))
        {
            GameObject Effect = Instantiate(AttackEffect, transform.position + moveDir, Quaternion.identity);
            Effect.transform.position = hits.point + Vector3.up * 0.1f;
            Effect.transform.forward = hits.normal;
            Effect.transform.localScale = Vector3.one * 2;
        }
        

        foreach (Collider c in hit)
        {
            IDamageAble IDmg = c.GetComponent<IDamageAble>();
            if (IDmg != null)
            {
                IDmg.OnDamaged(dmg, moveDir);
            }
        }
    }
    
    public void Skill1Check(Vector3 moveDir, Quaternion rotation)
    {
        Camera.main.GetComponent<CinemachineImpulseSource>().GenerateImpulseAtPositionWithVelocity(Vector3.down, Vector3.one * -1);
        AS.PlayOneShot(Skill1StompClip);

        Collider[] hit = Physics.OverlapSphere(transform.position, Skill1Distance, LayerMask.GetMask("Player"));

        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hits;
        if (Physics.Raycast(ray, out hits, 200, LayerMask.GetMask("Ground")))
        {
            GameObject Effect = Instantiate(Skill1Effect, transform.position, Quaternion.identity);
            Effect.transform.position = hits.point + Vector3.up * 0.1f;
            Effect.transform.forward = hits.normal;
            Effect.transform.localScale = Vector3.one * 3f;
        }

        Vector3 dir = (target.transform.position - transform.position).normalized;
        dir = new Vector3(dir.x, 0, dir.z);
        for (int i = 0; i < 5; i++)
        {
            float angle = (Mathf.PI * 2) * i / (5);

            GameObject MixTime = BulletPoolManager.Get().gameObject;
            MixTime.transform.position = transform.position;
            MixTime.transform.rotation = Quaternion.identity;
            MixTime.GetComponent<EnemyBullet>().SetManager(BulletPoolManager);
            MixTime.GetComponent<EnemyBullet>().speed = 5;
            MixTime.GetComponent<EnemyBullet>().liveTime = 3;
            MixTime.GetComponent<EnemyBullet>().dir = dir;

            MixTime.transform.localRotation = Quaternion.Euler(0, angle * 60, 0);
            MixTime.transform.localScale = Vector3.one * 2;
        }

        foreach (Collider c in hit)
        {
            IDamageAble IDmg = c.GetComponent<IDamageAble>();
            if (IDmg != null)
            {
                IDmg.OnDamaged(dmg, moveDir);
            }
        }
    }

    public void Skill2Check()
    {
        for (int i = 0; i < spawnCnt; i++)
        {

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
            anim.Play("DrumBoss_Stomping", 0, 0);
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
