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

    //Ŭ������ json���Ϸ� ��ȯ ���ش�.
    public static string ObjectToJson(object GB)
    {
        return JsonConvert.SerializeObject(GB, Formatting.Indented);
    }

    //Json�� TextAsset�� �޾� <T>�� �Է��� Ŭ����ó�� �̿��� �� �ְ� ���ش�.
    public static T JsonToObject<T>(string JsonData)
    {
        return JsonConvert.DeserializeObject<T>(JsonData);
    }

    //��ο� ���� �̸����� Json�� ã�Ƴ���.
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

