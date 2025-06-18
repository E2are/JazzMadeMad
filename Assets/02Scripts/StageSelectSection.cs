using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageSelectSection : MonoBehaviour
{
    LoadSceneManager loadSceneManager;
    GameData GD;
    [SerializeField] bool isBossStage = true;
    [SerializeField] int BossIndex = 0;
    public string BossSceneName;
    bool PlayerEntered = false;
    public GameObject EnteredSign;
    public KeyCode StageEnterKey = KeyCode.Return;

    private void Start()
    {
        if (isBossStage)
        {
            GD = Json.LoadJsonFile<GameData>(Application.dataPath, "GameData");
            if (GD.BeatonBosses[BossIndex - 1])
            {
                GetComponent<Target>().enabled = false;
            }
        }

        EnteredSign.SetActive(false);

        loadSceneManager = FindObjectOfType<LoadSceneManager>();
    }

    private void Update()
    {
        if (PlayerEntered)
        {
            if (Input.GetKeyDown(StageEnterKey))
            {
                GameManager.Instance.SetSelectedBossIndex(BossIndex);
                GameManager.Instance.setStageType(true);
                loadSceneManager.LoadScene(BossSceneName);
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            PlayerEntered = true;
            EnteredSign.SetActive(true);
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            PlayerEntered = false;
            EnteredSign.SetActive(false);
        }
    }
}
