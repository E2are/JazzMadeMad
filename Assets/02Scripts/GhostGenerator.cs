using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;

public class GhostGenerator : MonoBehaviour
{
    public IObjectPool<PoolObject> GhostPoolManager;

    public GameObject GhostPrefab;
    public GameObject[] Characters;
    public bool doGenerate = false;
    public float generateDelay = 0.5f;
    float genTimer = 0;
    public float DelTime = 1f;

    public void Start()
    {
        genTimer = generateDelay;

        GhostPoolManager = new ObjectPool<PoolObject>(CreateObject, OnGetObj, OnReleaseObj, OnDestroyObj, true, 1000, 1000);
    }

    public void Update()
    {
        if (doGenerate)
        {
            if (genTimer < generateDelay)
            {
                genTimer += Time.deltaTime;
            }
            else
            {
                genTimer = 0;
                foreach (GameObject Character in Characters) {
                    GameObject Ghost = GhostPoolManager.Get().gameObject;

                    Ghost.transform.position = transform.position;
                    Ghost.transform.rotation = transform.rotation;
                    Ghost.GetComponent<PoolObject>().SetManager(GhostPoolManager);
                    Ghost.GetComponent<SpriteRenderer>().sprite = Character.GetComponent<SpriteRenderer>().sprite;
                    Ghost.transform.localScale = Character.transform.localScale;
                    Ghost.GetComponent<SpriteRenderer>().flipX = Character.GetComponent<SpriteRenderer>().flipX;
                }
            }
        }
    }

    private PoolObject CreateObject()
    {
        PoolObject Object = Instantiate(GhostPrefab).GetComponent<PoolObject>();
        Object.SetManager(GhostPoolManager);
        return Object;
    }

    void OnGetObj(PoolObject Obj)
    {
        Obj.gameObject.SetActive(true);
    }

    void OnReleaseObj(PoolObject Obj)
    {
        Obj.gameObject.SetActive(false);
    }

    void OnDestroyObj(PoolObject Obj)
    {
        Destroy(Obj.gameObject);
    }
}
