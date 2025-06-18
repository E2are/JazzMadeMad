using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Pool;

public class Player : MonoBehaviour, IDamageAble, IUsingGameData
{
    [Header("References")]
    Rigidbody rigid;
    Animator BodyAnim;
    Animator LegAnim;
    AudioSource AS;
    GameData GD;
    public GamePositionData GPD;
    public GhostGenerator CGG;

    public Transform CamPos;
    public Transform Orientation;
    public Canvas PlayerCanvas;

    [Header("PlayerHPStats")]
    public int MaxHP = 5;
    [SerializeField] int Hp = 3;
    public bool isInvincible = false;
    
    public float maxStamina = 100;
    [SerializeField] float Stamina = 100;
    public float StaminaGenerateMultiplier = 2;

    [SerializeField] bool Dead = false;
    public AudioClip DeathClip;
    [SerializeField] bool Hit = false;

    [Header("MovementStats")]
    public GameObject movedirSprite;
    public GameObject DashUnabledSign;
    public bool DashUnabled = false;
    float desiredMoveSpeed = 0;
    public float moveSpeed = 5;
    public float attackmoveSpeed = 4;
    public float slowedSpeed = 2;
    public float DashSpeed = 7;

    [Header("CameraStats")]
    float rotationY = 0;
    public float TurnSpeed = 3f;

    [Header("DashStats")]
    public KeyCode DashKey = KeyCode.Space;
    public bool dashing = false;
    Vector3 moved_dir = Vector3.zero;

    [Header("AttackStats")]
    public GameObject notePrefab;
    public IObjectPool<PoolObject> NotePoolManager;
    public float Dammage = 10;
    public float noteSpeed = 5;
    public float attackDelay = 0.5f;
    public float attackTimer = 0;

    [Header("SkillStats")]
    public AudioClip[] SkillConductSound;
    public AudioClip SkillSound;
    public Image CurrentSkillPage;
    public GameObject PreSkillKeyImages;
    [SerializeField] Image[] SkillKeyImages;
    
    public GameObject KeyInputImages;
    [SerializeField] Image[] InputImages;
    public Sprite[] KeyInputSprites;

    public bool ReadyToSkill = false;
    public int selectedSkillIndex = 0;

    public List<arrows> KeyInputs = new List<arrows>();
    float arrowXInput = 0;
    float arrowYInput = 0;

    public AttackData AttackData;
    public int inputCnt = 0;
    public int MaxinputCnt = 6;
    [Header("Skills")]
    public int skill1cnt = 3;
    public int skill2cnt = 4;
    public int skill3cnt = 6;
    public ParticleSystem skill4Effect;
    public enum arrows
    {
        up,
        down,
        right,
        left
    }
    [Header("SoundStatements")]
    public AudioClip[] SkillSwapClips;

    private void Awake()
    {
        AttackData.InitCommands();

        GD = Json.LoadJsonFile<GameData>(Application.dataPath, "GameData");

        InputImages = KeyInputImages.GetComponentsInChildren<Image>();
        SkillKeyImages = PreSkillKeyImages.GetComponentsInChildren<Image>();

        NotePoolManager = new ObjectPool<PoolObject>(OnCreateBullet, OnGetBullet, OnReleaseBullet, OnDestroyBullet, true, 100, 1000);
    }

    void Start()
    {
        rigid = GetComponent<Rigidbody>();
        BodyAnim = transform.GetChild(0).GetComponent<Animator>();
        LegAnim = transform.GetChild(1).GetComponent<Animator>();
        AS = GetComponent<AudioSource>();

        desiredMoveSpeed = moveSpeed;

        InitSkillCommandImages();

        KeyInputImages.SetActive(ReadyToSkill);
        DashUnabledSign.SetActive(false);

        PlayerUIManager.Instance.UpdateHP(Hp);
    }

    void Update()
    {
        if (Dead  || GameManager.Instance.CutSceneIsPlaying || GameManager.Instance.Paused)
        {
            return;
        }

        if(Stamina < maxStamina)
        {
            Stamina += Time.deltaTime * StaminaGenerateMultiplier;
        }

        if(!GameManager.Instance.GD.isBossStage)
        TurnCamera();

        if(!dashing && !Hit)
        Move();

        if(!Hit)
        Dash();

        Attack();

        StateHandler();
    }

    public void InitPlayer(int PosIndex, bool isBossStage)
    {
        if (!isBossStage)
        {
            transform.position = GPD.AfterBossPositions[PosIndex];
        }
        else
        {
            transform.position = GPD.BossStagePositions[PosIndex-1];
        }
    }

    void Move()
    {
        float XInput = Input.GetAxisRaw("Horizontal");
        float YInput = Input.GetAxisRaw("Vertical");

        Vector3 move_dir = Orientation.forward * YInput + Orientation.right * XInput;

        Ray ray = new Ray(transform.position+ Vector3.up * 0.2f, move_dir);
        bool wallhit = Physics.SphereCast(ray, 0.3f, GetComponent<CapsuleCollider>().radius * 1.2f, LayerMask.GetMask("Ground", "Wall"));

        LegAnim.SetFloat("X", XInput);
        LegAnim.SetFloat("Y", YInput);
        BodyAnim.SetFloat("X", XInput);
        BodyAnim.SetFloat("Y", YInput);

        if((XInput != 0 || YInput != 0) &&!wallhit)
        {
            LegAnim.SetBool("walking", true);
            BodyAnim.SetBool("walking", true);
        }
        else
        {
            LegAnim.SetBool("walking", false);
            BodyAnim.SetBool("walking", false);
        }
        
        if (XInput != 0 || YInput != 0)
        {
            movedirSprite.transform.forward = -move_dir.normalized;
        }

        if (!wallhit)
        {
            transform.Translate(move_dir * desiredMoveSpeed * Time.deltaTime);
        }

        /*rigid.AddForce(move_dir.normalized *  moveSpeed,ForceMode.Force);

        if(rigid.velocity.magnitude > desiredMoveSpeed)
        {
            rigid.velocity = move_dir.normalized * desiredMoveSpeed;
        }*/
    }

    void TurnCamera()
    {
        if (Input.GetKey(KeyManager.Instance.GetKeyCode("TurnCameraLeft")))
        {
            rotationY += Time.deltaTime * TurnSpeed;
        }

        if (Input.GetKey(KeyManager.Instance.GetKeyCode("TurnCameraRight")))
        {
            rotationY -= Time.deltaTime * TurnSpeed;
        }

        if(Input.GetKeyDown(KeyManager.Instance.GetKeyCode("ResetCamera")))
        {
            rotationY = 0;
        }

        Orientation.transform.localRotation = Quaternion.Slerp(Orientation.localRotation,Quaternion.Euler(0, rotationY, 0),Time.deltaTime * 3f);

        BodyAnim.transform.forward = Orientation.forward;
        LegAnim.transform.forward = Orientation.forward;
    }

    void Dash()
    {
        float XInput = Input.GetAxisRaw("Horizontal");
        float YInput = Input.GetAxisRaw("Vertical");

        BodyAnim.SetFloat("BodySpeed", 2);
        LegAnim.SetFloat("LegSpeed", 2);

        if ((XInput != 0 || YInput != 0) && !dashing) 
        {
            moved_dir = new Vector3(XInput, 0, YInput).normalized;
        }

        if(Input.GetKeyDown(DashKey) && !dashing && Stamina >= 20 && !DashUnabled) 
        {
            Stamina -= 20;
            dashing = true;
            CGG.doGenerate = true;
            Invoke("DashOff", 0.5f);
        }

        if (dashing && !DashUnabled)
        {
            Ray ray = new Ray(transform.position + Vector3.up * 0.2f, (Orientation.right * moved_dir.x + Orientation.forward * moved_dir.z));
            if (!Physics.SphereCast(ray,0.3f, GetComponent<CapsuleCollider>().radius * 1.2f, LayerMask.GetMask("Ground", "Wall")))
            {
                LegAnim.SetFloat("X", moved_dir.x);
                LegAnim.SetFloat("Y", moved_dir.z);
                BodyAnim.SetFloat("X", moved_dir.x);
                BodyAnim.SetFloat("Y", moved_dir.z);

                LegAnim.SetBool("walking", true);
                BodyAnim.SetBool("walking", true);
                transform.Translate((Orientation.right * moved_dir.x + Orientation.forward * moved_dir.z) * DashSpeed * Time.deltaTime);
            }
        }
    }

    public void DashOff()
    {
        BodyAnim.SetFloat("BodySpeed", 1);
        LegAnim.SetFloat("LegSpeed", 1);

        CGG.doGenerate = false;
        dashing = false;
    }

    void Attack()
    {
        arrowXInput = Input.GetAxisRaw("HorizontalArrow");
        arrowYInput = Input.GetAxisRaw("VerticalArrow");

        BodyAnim.SetFloat("ArrowX", arrowXInput);
        BodyAnim.SetFloat("ArrowY",arrowYInput);

        if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("StartSkill")))
        {
            if (ReadyToSkill)
            {
                foreach (Image key in InputImages)
                {
                    key.sprite = KeyInputSprites[0];
                }
                KeyInputs.Clear();
                inputCnt = 0;
            }
            ReadyToSkill = !ReadyToSkill;
            BodyAnim.SetBool("conducting",ReadyToSkill);
            LegAnim.SetBool("conducting", ReadyToSkill);
            KeyInputImages.SetActive(ReadyToSkill);
        }

        if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("NextSkill")))
        {
            selectedSkillIndex++;
            if(selectedSkillIndex > AttackData.Commands.Count - 1)
            {
                selectedSkillIndex = 0;
            }
            CurrentSkillPage.sprite = AttackData.PageSprites[selectedSkillIndex];
            InitSkillCommandImages();
            /*ClearInputs();*/
            AS.PlayOneShot(SkillSwapClips[Random.Range(0, SkillSwapClips.Length)]);
        }

        if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("PrevSkill")))
        {
            selectedSkillIndex--;
            if (selectedSkillIndex < 0)
            {
                selectedSkillIndex = AttackData.Commands.Count - 1;
            }
            CurrentSkillPage.sprite = AttackData.PageSprites[selectedSkillIndex];
            InitSkillCommandImages();
            /*ClearInputs();*/
            AS.PlayOneShot(SkillSwapClips[Random.Range(0, SkillSwapClips.Length)]);
        }

        if (ReadyToSkill)
        {
            BodyAnim.SetFloat("BodySpeed", attackmoveSpeed / 5);
            LegAnim.SetFloat("LegSpeed", attackmoveSpeed / 5);

            if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("CommandUp")))
            {
                KeyInputs.Add(arrows.up);
                BodyAnim.SetTrigger("Conduct");
                if (inputCnt >= MaxinputCnt)
                {
                    ClearInputs();
                    return;
                }
                InputImages[inputCnt++].sprite = KeyInputSprites[1];
            }
            if(Input.GetKeyDown(KeyManager.Instance.GetKeyCode("CommandDown")))
            {
                KeyInputs.Add(arrows.down);
                BodyAnim.SetTrigger("Conduct");
                if (inputCnt >= MaxinputCnt)
                {
                    ClearInputs();
                    return;
                }
                InputImages[inputCnt++].sprite = KeyInputSprites[2];
            }
            if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("CommandRight")))
            {
                KeyInputs.Add(arrows.right);
                BodyAnim.SetTrigger("Conduct");
                if (inputCnt >= MaxinputCnt)
                {
                    ClearInputs();
                    return;
                }
                InputImages[inputCnt++].sprite = KeyInputSprites[3];
            }
            if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("CommandLeft")))
            {
                KeyInputs.Add(arrows.left);
                BodyAnim.SetTrigger("Conduct");
                if (inputCnt >= MaxinputCnt)
                {
                    ClearInputs();
                    return;
                }
                InputImages[inputCnt++].sprite = KeyInputSprites[4];
            }

            if (Input.GetKeyDown(KeyManager.Instance.GetKeyCode("UseSkill")) && !Hit)
            {
                foreach(Image key in InputImages)
                {
                    key.sprite = KeyInputSprites[0];
                }

                if(AttackData.Commands[selectedSkillIndex].Length != inputCnt)
                {
                    KeyInputs.Clear();
                    inputCnt = 0;
                    ReadyToSkill = false;
                    KeyInputImages.SetActive(ReadyToSkill);
                    return;
                }

                bool correctInput = true;
                for (int i = 0;i < inputCnt; i++)
                {
                    if (AttackData.Commands[selectedSkillIndex][i] != KeyInputs[i])correctInput = false;
                }

                if(correctInput)
                {
                    AttackStart(AttackData.SkillIndexs[selectedSkillIndex]);
                }

                KeyInputs.Clear();
                inputCnt = 0;
                ReadyToSkill = false;
                KeyInputImages.SetActive(ReadyToSkill);
                attackTimer = 0;
            }
        }
        else if(!dashing)
        {
            BodyAnim.SetFloat("BodySpeed", 1);
            LegAnim.SetFloat("LegSpeed", 1);

            if ((arrowXInput != 0 || arrowYInput != 0) && attackDelay < attackTimer)
            {
                attackTimer = 0;
                Vector3 fireDirection = (Orientation.forward * Input.GetAxisRaw("VerticalArrow") + Orientation.right * Input.GetAxisRaw("HorizontalArrow")).normalized;
                GameObject MusicNote = NotePoolManager.Get().gameObject;
                MusicNote.transform.position = transform.position + fireDirection * 0.2f;
                MusicNote.transform.localScale = Vector3.one * 2;
                MusicNote.transform.rotation = Quaternion.identity;
                MusicNote.GetComponent<MusicNotePrefab>().dir = fireDirection;
                MusicNote.GetComponent<MusicNotePrefab>().liveTime = 3;
                MusicNote.GetComponent<MusicNotePrefab>().dmg = Dammage;
                MusicNote.GetComponent<MusicNotePrefab>().isKnockableBullet = false;
            }
            else
            {
                attackTimer += Time.deltaTime;
            }
        }
    }

    public void AttackStart(int attackIndex = 0)
    {
        AS.PlayOneShot(SkillSound);
        StopAllCoroutines();
        switch (attackIndex)
        {
            case 0:
                StartCoroutine(Skill_HalfTime());
                break;
            case 1:
                StartCoroutine(Skill_Violin());
                break;
            case 2:
                StartCoroutine(Skill_Drum());
                break;
            case 3:
                StartCoroutine(Skill_Brass());
                break;
            case 4:
                StartCoroutine(Skill_Windwood());
                break;
            case 5:
                StartCoroutine(Skill_Piano());
                break;
        }
    }

    void InitSkillCommandImages()
    {
        foreach (Image key in SkillKeyImages)
        {
            key.sprite = KeyInputSprites[0];
        }
        for (int i = 0; i < AttackData.Commands[selectedSkillIndex].Length; i++)
        {
            SkillKeyImages[i].sprite = KeyInputSprites[(int)(AttackData.Commands[selectedSkillIndex][i]) + 1];
        }
    }

    void ClearInputs()
    {
        inputCnt = 0;
        KeyInputs.Clear();
        foreach (Image key in InputImages)
        {
            key.sprite = KeyInputSprites[0];
        }
    }

    IEnumerator Skill_HalfTime()
    {
        for (int i = -1; i < 2; i++)
        {
            GameObject HalfTime = NotePoolManager.Get().gameObject;
            HalfTime.transform.position = transform.position;
            HalfTime.transform.rotation = Quaternion.identity;
            HalfTime.GetComponent<MusicNotePrefab>().dir = (Orientation.right * moved_dir.x + Orientation.forward * moved_dir.z);
            HalfTime.GetComponent<MusicNotePrefab>().liveTime = 3;
            HalfTime.GetComponent<MusicNotePrefab>().dmg = Dammage;

            HalfTime.GetComponent<MusicNotePrefab>().isKnockableBullet = false;

            HalfTime.GetComponent<MusicNotePrefab>().isPierceAble = false;

            HalfTime.transform.localRotation = Quaternion.Euler(0, 10 * i,0);
            HalfTime.transform.localScale = Vector3.one * 2;
        }
        yield return null;
    }

    IEnumerator Skill_Violin()
    {
        Vector3 shootDir = (Orientation.right * moved_dir.x + Orientation.forward * moved_dir.z);
        for (int i = 0; i < 4; i++)
        {
            for (int j = -1; j < 2; j+=2)
            {
                GameObject HalfTime = NotePoolManager.Get().gameObject;
                HalfTime.transform.position = transform.position;
                HalfTime.transform.rotation = Quaternion.identity;
                HalfTime.transform.position = new Vector3(HalfTime.transform.position.x + Random.Range(-0.6f, 0.6f), HalfTime.transform.position.y, transform.transform.position.z + Random.Range(-0.6f, 0.6f));
                HalfTime.GetComponent<MusicNotePrefab>().dir = shootDir;
                HalfTime.GetComponent<MusicNotePrefab>().pitch = Random.Range(0.8f,1.2f);
                HalfTime.GetComponent<MusicNotePrefab>().liveTime = 3;
                HalfTime.GetComponent<MusicNotePrefab>().dmg = Dammage;

                HalfTime.GetComponent<MusicNotePrefab>().isKnockableBullet = false;

                HalfTime.GetComponent<MusicNotePrefab>().isPierceAble = false;

                HalfTime.transform.localScale = Vector3.one;
                yield return new WaitForSeconds(0.025f);
            }
            yield return new WaitForSeconds(0.1f);
        }
        yield return null;
    }

    IEnumerator Skill_Drum()
    {
        for (int j = 0; j < skill3cnt; j += 2)
        {
            for (int i = 0; i < skill3cnt*2; i++)
            {
                float angle = (Mathf.PI * 2) * i / (skill3cnt*2);

                GameObject MixTime = NotePoolManager.Get().gameObject;
                MixTime.transform.position = transform.position;
                MixTime.transform.rotation = Quaternion.identity;
                MixTime.GetComponent<MusicNotePrefab>().liveTime = 3;
                MixTime.GetComponent<MusicNotePrefab>().dmg = Dammage;
                MixTime.GetComponent<MusicNotePrefab>().dir = new Vector3(Mathf.Cos(angle), 0, Mathf.Sin(angle));

                MixTime.GetComponent<MusicNotePrefab>().isKnockableBullet = false;

                MixTime.GetComponent<MusicNotePrefab>().isPierceAble = false;

                MixTime.transform.localScale = Vector3.one * 2;
            }
            yield return new WaitForSeconds(0.3f);
        }
        yield return null;
    }
    
    IEnumerator Skill_Brass()
    {
        Collider[] hits = Physics.OverlapSphere(transform.position, 3, LayerMask.GetMask("Enemy"));
        skill4Effect.transform.position = transform.position;
        skill4Effect.Play();
        foreach (Collider hit in hits)
        {
            IDamageAble hited = hit.GetComponent<IDamageAble>();
            if (hited != null)
            {
                hited.OnDamaged(Dammage * 3, Vector3.zero, true);
            }
        }
        yield return null;
    }

    IEnumerator Skill_Windwood()
    {
        GameObject HalfTime = NotePoolManager.Get().gameObject;
        HalfTime.transform.position = transform.position + Vector3.up;
        HalfTime.transform.rotation = Quaternion.identity;
        HalfTime.GetComponent<MusicNotePrefab>().dir = (Orientation.right * moved_dir.x + Orientation.forward * moved_dir.z);
        HalfTime.GetComponent<MusicNotePrefab>().liveTime = 3;
        HalfTime.GetComponent<MusicNotePrefab>().dmg = Dammage;
        
        HalfTime.GetComponent<MusicNotePrefab>().isKnockableBullet = false;

        HalfTime.GetComponent<MusicNotePrefab>().isPierceAble = true;
        HalfTime.GetComponent<MusicNotePrefab>().pierceTime = 3;
        HalfTime.GetComponent<MusicNotePrefab>().pierceDelay = 0.1f;

        HalfTime.transform.localScale = Vector3.one * 4;
        yield return null;
    }
    
    IEnumerator Skill_Piano()
    {
        Collider[] col = Physics.OverlapSphere(transform.position, 15, LayerMask.GetMask("Enemy"));
        foreach(Collider c in col)
        {
            IDamageAble hited = c.GetComponent<IDamageAble>();
            if(hited != null)
            {
                hited.OnDamaged(Dammage * 3, Vector3.zero);
                Ray ray = new Ray(c.transform.position, Vector3.down);
                RaycastHit hit = new RaycastHit();
                if(Physics.Raycast(ray, out hit, 10, LayerMask.GetMask("Ground", "Wall"))){
                    Instantiate(AttackData.LaserPrefab, hit.point, Quaternion.identity);
                }
            }
        }
        
        yield return null;
    }
     
    public void OnDamaged(float dmg, Vector3 dir, bool N)
    {
        if(!Hit && !isInvincible)
        Hp -= (int)dmg;
        PlayerUIManager.Instance.UpdateHP(Hp);
        if (Hp > 0)
        {
            if (!Hit && !isInvincible)
            {
                StartCoroutine(HitSeq());
                isInvincible = true;
                Invoke(nameof(hitoff), 2);
            }
        }
        else if (!Dead)
        {
            Dead = true;
            GameManager.Instance.GameisOver(false);
            StartCoroutine(DeathSeq());
        }
    }

    IEnumerator HitSeq()
    {
        Hit = true;
        BodyAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 0.7f);
        LegAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 0.7f);
        rigid.AddForce(Vector3.up * 3, ForceMode.Impulse);
        yield return new WaitForSeconds(0.6f);
        Hit = false;
        yield return new WaitForSeconds(1.4f);
        BodyAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 1f);
        LegAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 1f);
    }

    void hitoff()
    {
        isInvincible = false;
        BodyAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 1f);
        LegAnim.GetComponent<SpriteRenderer>().color = new Color(255, 255, 255, 1f);
    }

    IEnumerator DeathSeq()
    {
        PlayerCanvas.gameObject.SetActive(false);
        AS.PlayOneShot(DeathClip);
        yield return null;
    }

    void StateHandler()
    {
        if (ReadyToSkill)
        {
            desiredMoveSpeed = attackmoveSpeed;
        }
        else if (DashUnabled)
        {
            desiredMoveSpeed = slowedSpeed;
        }
        else
        {
            desiredMoveSpeed = moveSpeed;
        }
    }

    public float getStamina()
    {
        return Stamina;
    }

    public void InitData()
    {
        AttackData.InitCommands();
    }

    public void SetDataManager()
    {
        GameManager.Instance.DataUsers.Add(this);
    }

    public void DisableDash(float ApplyTime)
    {
        DashUnabled = true;
        DashUnabledSign.SetActive(true);
        CancelInvoke("EnableDash");
        Invoke("EnableDash", ApplyTime);
    }

    void EnableDash()
    {
        DashUnabledSign.SetActive(false);
        DashUnabled = false;
    }

    private PoolObject OnCreateBullet()
    {
        PoolObject Object = Instantiate(AttackData.HalfTImePrefab).GetComponent<PoolObject>();
        Object.SetManager(NotePoolManager);
        return Object;
    }

    void OnGetBullet(PoolObject Obj)
    {
        Obj.gameObject.SetActive(true);
    }

    void OnReleaseBullet(PoolObject Obj)
    {
        Obj.gameObject.SetActive(false);
    }

    void OnDestroyBullet(PoolObject Obj)
    {
        Destroy(Obj.gameObject);
    }
}
