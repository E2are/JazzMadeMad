using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerUIManager : MonoBehaviour
{
    public static PlayerUIManager Instance;

    public Player player;

    public GameObject[] HPUIs;

    public Slider StaminaSlider;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(this);
    }

    private void Update()
    {
        StaminaSlider.value = player.getStamina()/player.maxStamina;
    }

    public void UpdateHP(int HP)
    {
        if (HPUIs.Length != 0 && HP >= 0)
        {
            for (int i = 0; i < HP; i++)
            {
                HPUIs[i].GetComponent<Image>().color = Color.white;
            }
            for (int i = HP; i < HPUIs.Length; i++)
            {
                HPUIs[i].GetComponent<Image>().color = Color.black;
            }
        }
    }
}
