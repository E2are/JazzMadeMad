using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using System;

public class KeyConfigController : MonoBehaviour
{
    KeyCode mOriginKeyCode;
    [SerializeField] private string mKeyBindingName;

    [SerializeField] private Image mKeyButtonImage;
    Coroutine mKeyButtonColorCor;

    [SerializeField] TextMeshProUGUI mKeyButtonText;

    private void OnEnable()
    {
        if(KeyManager.Instance != null)
        mOriginKeyCode = KeyManager.Instance.GetKeyCode(mKeyBindingName);

        mKeyButtonText.text = (mOriginKeyCode).ToString();
    }
    private void Awake()
    {
        if(KeyManager.Instance != null)
        mOriginKeyCode = KeyManager.Instance.GetKeyCode(mKeyBindingName);

        mKeyButtonText.text = (mOriginKeyCode).ToString();
    }
    
    public void Btn_ModifyKey()
    {
        mKeyButtonText.text = " ";

        StartCoroutine(CorAssignKey());
    }

    IEnumerator CorAssignKey()
    {
        while (true)
        {
            if (Input.anyKeyDown)
            {
                foreach(KeyCode code in Enum.GetValues(typeof(KeyCode)))
                {
                    if (Input.GetKey(code))
                    {
                        if(mKeyButtonColorCor != null) { StopCoroutine(mKeyButtonColorCor); }

                        if (KeyManager.Instance.CheckKey(code, mOriginKeyCode))
                        {
                            KeyManager.Instance.AssignKey(code, mKeyBindingName);
                            mOriginKeyCode = code;

                            mKeyButtonText.text = (code).ToString();

                            mKeyButtonColorCor = StartCoroutine(CorChangeButtonColor(Color.green));
                        }
                        else
                        {
                            mKeyButtonText.text = (mOriginKeyCode).ToString();

                            mKeyButtonColorCor = StartCoroutine(CorChangeButtonColor(Color.red));
                        }
                    }
                }

                yield break;
            }

            yield return null;
        }
    }

    private IEnumerator CorChangeButtonColor(Color targetColor, float colorSpeed = 2.0f)
    {
        float progress = 0;

        while (true)
        {
            mKeyButtonImage.color = Color.Lerp(mKeyButtonImage.color, targetColor, progress);
            progress += colorSpeed * Time.deltaTime;

            //progress가 1이면 > 보간 완료
            if (progress > 1)
            {
                progress = 0;

                //targetColor에서 다시 돌아오기
                while (true)
                {
                    mKeyButtonImage.color = Color.Lerp(mKeyButtonImage.color, Color.white, progress);
                    progress += colorSpeed * Time.deltaTime;

                    //색상 전환 완료
                    if (progress > 1)
                    {
                        yield break;
                    }

                    yield return null;
                }
            }

            yield return null;
        }
    }
}
