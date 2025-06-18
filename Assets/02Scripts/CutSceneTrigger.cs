using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

public class CutSceneTrigger : MonoBehaviour
{
    [SerializeField] int SceneIndex = 0;

    public TimelineAsset CutSceneSource;

    public CutSceneDirector CutSceneDirector;

    private void Start()
    {
        
    }

    public void SetDirector( CutSceneDirector director)
    {
        CutSceneDirector = director;
    }

    void PlayCutScene()
    {
        CutSceneDirector.PlayCutScene(CutSceneSource);
        gameObject.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            PlayCutScene();
        }
    }
}
