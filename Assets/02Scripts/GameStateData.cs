using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

public class Json : MonoBehaviour
{
    private void Awake()
    {
        SoundData SD = new SoundData(true);
        string soundData = ObjectToJson(SD);
        string SoundDatapath = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "SoundData"));
        if(!File.Exists(SoundDatapath))
        CreateJsonFile(Application.dataPath, "SoundData", soundData);
    }

    public void CreateNewGameData()
    {
        GameData gD = new GameData(true);
        string jsonData = ObjectToJson(gD);
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        CreateJsonFile(Application.dataPath, "GameData", jsonData);
    }

    public static string ObjectToJson(object obj)
    {
        return JsonUtility.ToJson(obj,true);
    }

    public static T JsonToObject<T>(string json)
    {
        return JsonUtility.FromJson<T>(json);
    }

    public static void CreateJsonFile(string createPath, string fileName, string jsonData)
    {
        FileStream fileStream = new FileStream(string.Format("{0}/{1}.json", createPath, fileName), FileMode.Create);
        byte[] data = Encoding.UTF8.GetBytes(jsonData);
        fileStream.Write(data, 0, data.Length);
        fileStream.Close();
    }

    public static T LoadJsonFile<T>(string loadPath, string fileName)
    {
        FileStream fileStream = new FileStream(string.Format("{0}/{1}.json", loadPath, fileName), FileMode.Open);
        
        byte[] data = new byte[fileStream.Length];
        fileStream.Read(data, 0, data.Length);
        fileStream.Close();
        string jsonData = Encoding.UTF8.GetString(data);
        return JsonUtility.FromJson<T>(jsonData);
    }
}

public class GameData
{
    public bool isBossStage;
    public int selectedBossIndex;

    public enum Boss { 
        Trumpet,
        Saxophone,
        Piano,
        Double_Bass,
        Drum
    }
    public bool[] BeatonBosses = new bool[5];
    public GameData()
    {
        
    }

    public GameData(bool isSet)
    {
        if (isSet)
        {
            for (int i = 0;i<BeatonBosses.Length;i++)
            {
                BeatonBosses[i] = false;
            }
        }
    }
}

public class SoundData
{
    public float MasterVolume;
    public float BGMVolume;
    public float SFXVolume;

    public int resolutionVal;

    public SoundData()
    {

    }

    public SoundData(bool isSet)
    {
        if (isSet)
        {
            MasterVolume = 1;
            BGMVolume = 1;
            SFXVolume = 1;
        }
    }
}