using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundGen : MonoBehaviour
{
    public AudioSource AS;
    private void Start()
    {
        if(AS == null) AS = GetComponent<AudioSource>();
    }

    public void PlaySound(AudioClip clip)
    {
        AS.PlayOneShot(clip);
    }
}
