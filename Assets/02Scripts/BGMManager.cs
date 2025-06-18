using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BGMManager : MonoBehaviour
{
    public static BGMManager Instance;

    public float originVolume = 0.8f;
    public AudioSource AS;

    private void Start()
    {
        AS = GetComponent<AudioSource>();

        if(Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
        }
    }

    public void ChangeBGM(AudioClip DesiredClip,bool isLoop)
    {
        StartCoroutine(BGMChangeSeq(DesiredClip, isLoop));
    }

    IEnumerator BGMChangeSeq(AudioClip DesiredClip, bool isLoop)
    {
        while(AS.volume >= 0.05f)
        {
            AS.volume -= 0.01f;
            yield return null;
        }
        AS.volume = 0;
        AS.clip = DesiredClip;
        AS.loop = isLoop;
        AS.Play();
        while(AS.volume < originVolume)
        {
            AS.volume +=  0.01f;
            yield return null;
        }
        AS.volume = originVolume;
        yield return null;
    }
}
