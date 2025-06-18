using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;

public class TitleUIManager : MonoBehaviour
{
    public Button ContinueButton;
    void Start()
    {
        string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.json", Application.dataPath, "GameData"));
        if (!File.Exists(path))
        {
            ContinueButton.interactable = false;
        }
    }
}
