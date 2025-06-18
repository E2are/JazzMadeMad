using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;

public class PoolObject : MonoBehaviour
{
    public IObjectPool<PoolObject> PoolManager { get; set; }

    public float offTime = 0;
    float Timer = 0;

    private void OnEnable()
    {
        Timer = offTime;
    }

    private void Update()
    {
        if(Timer < 0)
        {
            PoolManager.Release(this);    
        }
        else
        {
            Timer -= Time.deltaTime;
        }
    }

    public void SetManager(IObjectPool<PoolObject> poolManager)
    {
        PoolManager = poolManager;
    }
}
