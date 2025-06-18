using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class LoadSceneManager : MonoBehaviour
{
    public Animator LoadAnimator;
    public void LoadScene(string SceneName)
    {
        if (!LoadAnimator.GetCurrentAnimatorStateInfo(0).IsName("TS_5_Outlined_Reveal"))
            StartCoroutine(LoadSceneSeq(SceneName));
    }

    public void SetIndex(int Index)
    {
        if(GameManager.Instance != null)
            GameManager.Instance.SetSelectedBossIndex(Index);
    }

    public void SetStageType(bool isBossStage)
    {
        if (GameManager.Instance != null)
            GameManager.Instance.setStageType(isBossStage);
    }

    IEnumerator LoadSceneSeq(string SceneName)
    {
        if (LoadAnimator != null)
        {
            LoadAnimator.SetTrigger("Reveal");
            LoadAnimator.SetBool("AnimFullyLoaded",false);
            LoadAnimator.GetComponent<GraphicRaycaster>().enabled = true;

            yield return new WaitUntil( () => LoadAnimator.GetBool("AnimFullyLoaded"));
        }
        LoadingScene.LoadScene(SceneName);
    }

    public void QuitApplication()
    {
        Application.Quit();
    }
}