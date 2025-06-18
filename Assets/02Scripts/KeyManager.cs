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

        //�� ������ ����� Ű �����͵�//
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

        Debug.Log(GetType() + " �ʱ�ȭ");

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
        //����1. ���� �Ҵ�� Ű�� ���� Ű�� �����ϵ��� �� ���� ������� �����Ѵ�.
        if (currentKey == key) { return true; }

        //1�� Ű �˻�. 
        //Ű�� �Ʒ��� Ű�� ����Ѵ�.
        if
        (
            key >= KeyCode.A && key <= KeyCode.Z || //97 ~ 122   A~Z
            key >= KeyCode.UpArrow && key <= KeyCode.LeftArrow || //UpArrow ~ LeftArrow
            key >= KeyCode.Alpha0 && key <= KeyCode.Alpha9 || //48 ~ 57    ���� 0~9
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

        //2�� Ű �˻�. 
        //1�� Ű �˻縦 ������ Ű �� ���� ���ǹ� Ű�� ������ �� ����.
        if
        (
            //�̵� Ű WASD
            key == KeyCode.W ||
            key == KeyCode.A ||
            key == KeyCode.S ||
            key == KeyCode.D
        ) { return false; }

        //3�� Ű �˻�.
        //���� ������ Ű�� �� �̹� �Ҵ�� Ű�� �ִ°��� ������ �� ����.
        foreach (KeyValuePair<string, KeyCode> keyPair in mKeyDictionary)
        {
            if (key == keyPair.Value)
            {
                return false;
            }
        }

        //��� Ű �˻縦 ����ϸ� �ش� Ű�� ������ ������ Ű.
        return true;
    }

    public void AssignKey(KeyCode key, string keyName) 
    {
        mKeyDictionary[keyName] = key;
    }
}
