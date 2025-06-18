using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class CutSceneDirector : MonoBehaviour
{
    PlayableDirector PD;
    CutSceneTrigger[] CutSceneTriggers;

    private void Start()
    {
        PD = GetComponent<PlayableDirector>();
        CutSceneTriggers = FindObjectsOfType<CutSceneTrigger>();

        foreach (CutSceneTrigger trigger in CutSceneTriggers)
        {
            trigger.SetDirector(this);
        }
    }

    public void Update()
    {
        if (Input.GetKeyDown(KeyCode.Return) && PD.state == PlayState.Playing)
        {
            PD.time = PD.playableAsset.duration - 0.001f;
            GameManager.Instance.CutSceneIsPlaying = false;
        }
    }

    public void CutSceneIsOver()
    {
        GameManager.Instance.CutSceneIsPlaying = false;
    }

    public void PlayCutScene(TimelineAsset CutScene)
    {
        PD.playableAsset = CutScene;
        GameManager.Instance.CutSceneIsPlaying = true;
        PD.Play();
    }
}
