using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;


public class KeyData
{
    public string KeyName;

    public KeyCode KeyCode;

    public KeyData(string KeyName, KeyCode KeyCode)
    {
        this.KeyName = KeyName;
        this.KeyCode = KeyCode;
    }
}

public class KeyManager : MonoBehaviour
{
    public static KeyManager Instance;

    public Dictionary<string, KeyCode> mKeyDictionary;

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
        mKeyDictionary = new Dictionary<string, KeyCode>();

        Debug.Log((int)KeyCode.UpArrow);
        Debug.Log((int)KeyCode.DownArrow);
        Debug.Log((int)KeyCode.LeftArrow);
        Debug.Log((int)KeyCode.RightArrow);

        LoadOptionData();
    }

    void LoadOptionData()
    {
        string KeyConfigDatapath = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "KeyConfigData"));
        if (File.Exists(KeyConfigDatapath))
        {
            string FromJson = File.ReadAllText(KeyConfigDatapath);

            List<KeyData> KeyData = NewtonJson.JsonToObject<List<KeyData>>(FromJson);

            foreach(KeyData keyData in KeyData)
            {
                mKeyDictionary.Add(keyData.KeyName, keyData.KeyCode);
            }
        }
        else
        {
            ResetOptionData();
        }
    }

    private void ResetOptionData()
    {
        mKeyDictionary.Clear();

        //씬 내에서 사용할 키 데이터들//
        mKeyDictionary.Add("CommandUp", KeyCode.UpArrow); 
        mKeyDictionary.Add("CommandDown", KeyCode.DownArrow); 
        mKeyDictionary.Add("CommandLeft", KeyCode.LeftArrow); 
        mKeyDictionary.Add("CommandRight", KeyCode.RightArrow);

        mKeyDictionary.Add("NextSkill", KeyCode.E); 
        mKeyDictionary.Add("PrevSkill", KeyCode.Q); 
        mKeyDictionary.Add("StartSkill", KeyCode.LeftControl); 
        mKeyDictionary.Add("UseSkill", KeyCode.Return); 

        mKeyDictionary.Add("TurnCameraRight", KeyCode.Z); 
        mKeyDictionary.Add("TurnCameraLeft", KeyCode.C); 
        mKeyDictionary.Add("ResetCamera", KeyCode.X); 

        Debug.Log(GetType() + " 초기화");

        SaveOptionData();
    }

    public void SaveOptionData()
    {
        List<KeyData> keys = new List<KeyData>();

        foreach(KeyValuePair<string,KeyCode> keyname in mKeyDictionary)
        {
            keys.Add(new KeyData(keyname.Key, keyname.Value));
        }

        string jsonData = NewtonJson.ObjectToJson(keys);
       
        NewtonJson.CreateJsonFile(Application.dataPath, "KeyConfigData", jsonData);
    }

    public KeyCode GetKeyCode(string key)
    {
        return mKeyDictionary[key];
    }

    public bool CheckKey(KeyCode key, KeyCode currentKey)
    {
        //예외1. 현재 할당된 키에 같은 키로 설정하도록 한 경우는 허용으로 리턴한다.
        if (currentKey == key) { return true; }

        //1차 키 검사. 
        //키는 아래의 키만 허용한다.
        if
        (
            key >= KeyCode.A && key <= KeyCode.Z || //97 ~ 122   A~Z
            key >= KeyCode.UpArrow && key <= KeyCode.LeftArrow || //UpArrow ~ LeftArrow
            key >= KeyCode.Alpha0 && key <= KeyCode.Alpha9 || //48 ~ 57    알파 0~9
            key == KeyCode.Return || //Enter
            key == KeyCode.LeftControl || //LeftControl
            key == KeyCode.Quote || //39
            key == KeyCode.Comma || //44
            key == KeyCode.Period || //46
            key == KeyCode.Slash || //47
            key == KeyCode.Semicolon || //59
            key == KeyCode.LeftBracket || //91
            key == KeyCode.RightBracket || //93
            key == KeyCode.Minus || //45
            key == KeyCode.Equals || //61
            key == KeyCode.BackQuote //96
        ) { }
        else { return false; }

        //2차 키 검사. 
        //1차 키 검사를 포함한 키 중 다음 조건문 키는 설정할 수 없다.
        if
        (
            //이동 키 WASD
            key == KeyCode.W ||
            key == KeyCode.A ||
            key == KeyCode.S ||
            key == KeyCode.D
        ) { return false; }

        //3차 키 검사.
        //현재 설정된 키들 중 이미 할당된 키가 있는경우는 설정할 수 없다.
        foreach (KeyValuePair<string, KeyCode> keyPair in mKeyDictionary)
        {
            if (key == keyPair.Value)
            {
                return false;
            }
        }

        //모든 키 검사를 통과하면 해당 키는 설정이 가능한 키.
        return true;
    }

    public void AssignKey(KeyCode key, string keyName) 
    {
        mKeyDictionary[keyName] = key;
    }
}
