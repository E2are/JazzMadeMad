using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

public class NewtonJson : MonoBehaviour
{
    public static void CreateJsonFile(string createpath, string fileName, string jsonData)
    {
        FileStream fileStream = new FileStream(string.Format("{0}/{1}.json", createpath, fileName), FileMode.Create);
        byte[] data = Encoding.UTF8.GetBytes(jsonData);
        fileStream.Write(data, 0, data.Length);
        fileStream.Close();
    }

    //클래스를 json파일로 전환 해준다.
    public static string ObjectToJson(object GB)
    {
        return JsonConvert.SerializeObject(GB, Formatting.Indented);
    }

    //Json인 TextAsset을 받아 <T>에 입력한 클래스처럼 이용할 수 있게 해준다.
    public static T JsonToObject<T>(string JsonData)
    {
        return JsonConvert.DeserializeObject<T>(JsonData);
    }

    //경로와 파일 이름으로 Json을 찾아낸다.
    public static T LoadJsonFile<T>(string loadPath, string fname)
    {
        FileStream fileStream = new FileStream(string.Format("{0}/{1}.json", loadPath, fname), FileMode.Open);
        byte[] data = new byte[fileStream.Length];
        fileStream.Read(data, 0, data.Length);
        fileStream.Close();

        string JsonData = Encoding.UTF8.GetString(data);
        return JsonConvert.DeserializeObject<T>(JsonData);
    }
}

