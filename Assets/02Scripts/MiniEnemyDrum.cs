using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using static Cinemachine.CinemachinePathBase;

public class MiniEnemyDrum : MonoBehaviour, IDamageAble
{
    [Header("references")]
    Rigidbody rigid;
    Animator anim;
    SpriteRenderer SR;
    GameObject Appearence;
    NavMeshAgent agent;
    AudioSource AS;

    [Header("MonsterStates")]
    public float Hp = 10;

    public float speed = 6;
    public Transform DirectionIndicator;

    public GameObject target;

    public float DetectRange = 6;

    public State currentState;
    public enum State
    {
        idle,
        move,
        attack,
        hit,
        dead
    }
    public bool grounded = false;

    [Header("AttackStates")]
    public GameObject BulletPrefab;

    public int dmg = 1;
    public AudioClip AttackClip;

    public int AttackDistance = 4;

    public float AttackDelay = 1f;

    float AttackTimer = 0;

    public bool attacking = false;

    private void Awake()
    { 
        rigid = GetComponent<Rigidbody>();
        anim = GetComponentInChildren<Animator>();
        SR = GetComponentInChildren<SpriteRenderer>();
        Appearence = anim.gameObject;
        agent = GetComponent<NavMeshAgent>();
        AS = GetComponent<AudioSource>();

        agent.speed = speed;
        currentState = State.hit;

        IndicateDirection();

        anim.Play("MiniDrum_Spawn",0,0);
    }

    private void Update()
    {
        if (GameManager.Instance.isGameOver) Destroy(gameObject);

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
        if(currentState != State.dead)
        IndicateDirection();
        CheckGrounded();

        Appearence.transform.forward = Vector3.forward;

        if (!attacking && agent.velocity.x != 0)
            SR.flipX = 0 <= agent.velocity.x ? true : false;
        else if (!attacking)
            SR.flipX = target.transform.position.x >= transform.position.x ? true : false;
        SR.sortingOrder = target.transform.position.z <= transform.position.z ? -1 : 3;

    }

    void IndicateDirection()
    {
        Ray ray = new Ray(transform.position, Vector3.down);
        RaycastHit hit = new RaycastHit();

        if (agent != null && DirectionIndicator)
        {
            if (agent.velocity == Vector3.zero)
            {
                if (target)
                    DirectionIndicator.forward = (target.transform.position - transform.position).normalized;
            }
            else
            {
                if (Physics.Raycast(ray, out hit))
                {
                    DirectionIndicator.position = hit.point + Vector3.up * 0.1f;
                    DirectionIndicator.forward = -agent.velocity.normalized;
                }
            }
        }
    }

    void Idle()
    {
        Collider[] Detects = Physics.OverlapSphere(transform.position, DetectRange);

        if(target == null)
        {
            foreach(Collider c in Detects)
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
        if(Vector3.Distance(target.transform.position, transform.position) < AttackDistance * 0.9f)
        {
            currentState = State.attack;
            anim.SetBool("Moving", false);
            agent.destination = transform.position;
            AttackTimer = AttackDelay;
        }
        else 
        {
            anim.SetBool("Moving", true);
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
                StartCoroutine(AttackSeq());
                
                attacking = true;
                AttackTimer = 0;
            }
            else
            {
                AttackTimer += Time.deltaTime;
            }
        }
    }

    IEnumerator AttackSeq()
    {
        yield return new WaitForSeconds(1f);
        anim.SetTrigger("Attack");
        AttackCheck();
        yield return new WaitForSeconds(1f);
        attacking = false;
        yield return null;
    }

    public void AttackCheck()
    {
        GameObject bullet = Instantiate(BulletPrefab,transform.position, Quaternion.identity);
        bullet.GetComponent<EnemyBullet>().dir = (target.transform.position - transform.position).normalized;
        bullet.GetComponent<EnemyBullet>().speed = 5;
        bullet.GetComponent<EnemyBullet>().isDestroy = true;
    }

    public void AttackOff()
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
                rigid.velocity = Vector3.zero;
                grounded = true;
            }
        }
    }

    public IEnumerator OnDamagedSeq(Vector3 hitnormal)
    {

        grounded = false;
        agent.enabled = false;
        GetComponent<CapsuleCollider>().enabled = false;
        rigid.velocity = Vector3.zero;
        rigid.constraints = RigidbodyConstraints.FreezeRotation;
        rigid.AddForce(Vector3.up * 6 + hitnormal, ForceMode.Impulse);

        currentState = State.hit;
        yield return new WaitForSeconds(0.4f);
        yield return new WaitUntil(() => grounded);
        agent.enabled = true;
        GetComponent<CapsuleCollider>().enabled = true;
        rigid.constraints = RigidbodyConstraints.FreezeAll;
        currentState = State.move;
        yield return null;
    }

    public IEnumerator DeathSeq()
    {
        currentState = State.dead;
        GetComponent<CapsuleCollider>().enabled = false;
        agent.enabled = false;
        rigid.constraints = RigidbodyConstraints.FreezeRotation;
        rigid.velocity = Vector3.zero;
        rigid.AddForce(Vector3.up * 6, ForceMode.Impulse);
        yield return new WaitForSeconds(1f);
        Destroy(this.gameObject);
    }

    public void OnDamaged(float dmg, Vector3 dir, bool N)
    {
        Hp -= dmg;

        if (Hp > 0)
        {
            StartCoroutine(OnDamagedSeq(dir));
        }
        else
        {
            StopAllCoroutines();
            StartCoroutine(DeathSeq());
        }
    }
}
