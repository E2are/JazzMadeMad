using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    public Player player;
    public GameData GD;
    public GamePositionData GPD;

    public bool Paused = false;
    public GameObject PauseMenu;

    public bool CutSceneIsPlaying = false;

    [SerializeField]
    Canvas WinCanvas;
    public AudioClip WinClip;
    [SerializeField]
    Canvas LoseCanvas;
    public AudioClip LoseClip;

    public bool isGameOver = false;

    public List<IUsingGameData> DataUsers = new List<IUsingGameData>();

    private void Awake()
    {
        if(Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
        }
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        if (File.Exists(path))
            GD = Json.LoadJsonFile<GameData>(Application.dataPath, "GameData");

        if (player == null)
        {
            player = FindAnyObjectByType<Player>();
        }

        if (player != null)
            Invoke("InitPlayer", 0.01f);

        if (WinCanvas)
        {
            WinCanvas.gameObject.SetActive(false);
        }

        if (LoseCanvas)
        {
            LoseCanvas.gameObject.SetActive(false);
        }

        Time.timeScale = 1;
    }

    private void OnLevelWasLoaded(int level)
    {
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        if (File.Exists(path))
            GD = Json.LoadJsonFile<GameData>(Application.dataPath, "GameData");

        DataUsers.Clear();

        if (GameObject.Find("Menu") != null&& PauseMenu == null)
        {
            PauseMenu = GameObject.Find("Menu").transform.GetChild(0).gameObject;
            PauseMenu.SetActive(false);
        }

        if (player == null)
        {
            player = FindAnyObjectByType<Player>();
        }

        if (player != null)
            Invoke("InitPlayer",0.01f);
    }

    void InitPlayer()
    {
        player.InitPlayer(GD.selectedBossIndex, GD.isBossStage);
    }

    private void OnApplicationQuit()
    {
        SaveGameData();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape) && !isGameOver)
        {
            if(Paused)
            {
                ClosePauseMenu();
            }
            else
            {
                OpenPauseMenu();
            }
        }
    }

    public void SetSelectedBossIndex(int index)
    {
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        if (File.Exists(path))
            GD.selectedBossIndex = index;
    }

    public void setStageType(bool IsBossStage)
    {
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        if (File.Exists(path))
            GD.isBossStage = IsBossStage;
        SaveGameData();
    }

    public void GameisOver(bool IsStageBeaten, bool IsBossStage = false)
    {
        if (IsStageBeaten)
        {
            if(IsBossStage)
            {
                Time.timeScale = 0;
                BGMManager.Instance.ChangeBGM(WinClip,false);
                GD.BeatonBosses[GD.selectedBossIndex-1] = true;
                SaveGameData();
                ActivateWinScreen();
            }
        }
        else
        {
            Time.timeScale = 0;
            BGMManager.Instance.ChangeBGM(LoseClip,false);
            isGameOver = true;
            ActivateLoseScreen();
        }
    }

    void ActivateWinScreen()
    {
        WinCanvas.gameObject.SetActive(true);
    }
    
    void ActivateLoseScreen()
    {
        LoseCanvas.gameObject.SetActive(true);
    }

    public void OpenPauseMenu()
    {
        Time.timeScale = 0;
        Paused = true;
        PauseMenu.SetActive(true);
    }
    
    public void ClosePauseMenu()
    {
        Time.timeScale = 1;
        Paused = false;
        PauseMenu.SetActive(false);
    }

    public void InitEveryGameData()
    {
        foreach(IUsingGameData gData in DataUsers)
        {
            gData.InitData();
        }
    }

    public void SaveGameData()
    {
        string GD = Json.ObjectToJson(this.GD);
        Json.CreateJsonFile(Application.dataPath, "GameData", GD);
    }
}
