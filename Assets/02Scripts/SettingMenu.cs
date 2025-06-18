using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

public class SettingMenu : MonoBehaviour
{
    SoundData soundData;

    public bool isSettingMenuOpened = false;

    public GameObject settingMenuGameObject;

    [Header("Screen")]
    FullScreenMode screenMode;
    List<Resolution> resolutions = new List<Resolution>();
    public TMP_Dropdown resolutionDropDown;
    public Toggle FullScreenBtn;
    public int selectedindex = 0;

    [Header("Sound")]
    public AudioMixer audioMixer;
    public Slider MasterSlider;
    public Slider BGMSlider;
    public Slider SFXSlider;

    public void OpenSettingMenu()
    {
        isSettingMenuOpened = true;
        settingMenuGameObject.SetActive(isSettingMenuOpened);
    }
    public void CloseSettingMenu()
    {
        isSettingMenuOpened = false;
        settingMenuGameObject.SetActive(isSettingMenuOpened);
    }

    
    void Awake()
    {
        soundData = Json.LoadJsonFile<SoundData>(Application.dataPath, "SoundData"); 
    }

    private void Start()
    {
        InitUI();

        settingMenuGameObject.SetActive(false);
    }

    public void InitUI()
    {
        resolutions.Clear();
        for (int i = 0; i < Screen.resolutions.Length; i++)
        {
            resolutions.Add(Screen.resolutions[i]);
        }
        resolutionDropDown.options.Clear();

        int optionnum = 0;
        foreach (Resolution resolution in resolutions)
        {
            TMP_Dropdown.OptionData option = new TMP_Dropdown.OptionData();
            option.text = resolution.width + " x " + resolution.height + " " + resolution.refreshRateRatio + "h2";
            resolutionDropDown.options.Add(option);

            if (resolution.width == Screen.width && resolution.height == Screen.height)
                resolutionDropDown.value = optionnum;
            optionnum++;
        }
        resolutionDropDown.RefreshShownValue();

        FullScreenBtn.isOn = Screen.fullScreenMode == (FullScreenMode.FullScreenWindow) ? true : false;

        MasterSlider.value = soundData.MasterVolume;
        BGMSlider.value = soundData.BGMVolume;
        SFXSlider.value = soundData.SFXVolume;

        audioMixer.SetFloat("Master", Mathf.Log10(MasterSlider.value) * 20);
        audioMixer.SetFloat("BGM", Mathf.Log10(BGMSlider.value) * 20);
        audioMixer.SetFloat("SFX", Mathf.Log10(SFXSlider.value) * 20);

        
    }

    //다이나믹 적용
    public void DropDownBoxOptionChange(int num)
    {
        selectedindex = num;
    }

    //다이나믹 적용
    public void FullScreenSet(bool isFull)
    {
        screenMode = isFull ? FullScreenMode.FullScreenWindow : FullScreenMode.Windowed;
    }

    public void OkBtnCheck()
    {
        soundData.MasterVolume = MasterSlider.value;
        soundData.BGMVolume = BGMSlider.value;
        soundData.SFXVolume = SFXSlider.value;

        string soundjson = Json.ObjectToJson(soundData);
        Json.CreateJsonFile(Application.dataPath, "SoundData", soundjson);
        Screen.SetResolution(resolutions[selectedindex].width, resolutions[selectedindex].height, screenMode);
    }
    
    public void SetMasterVolume()
    {
        audioMixer.SetFloat("Master", Mathf.Log10(MasterSlider.value) * 20);
    }

    public void SetBGMVolume()
    {
        audioMixer.SetFloat("BGM", Mathf.Log10(BGMSlider.value) * 20);
    }

    public void SetSFXVolume()
    {
        audioMixer.SetFloat("SFX", Mathf.Log10(SFXSlider.value) * 20);
    }
}
