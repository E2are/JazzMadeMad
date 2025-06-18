using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeeThroughSync : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position");
    public static int SizeID = Shader.PropertyToID("_Size");

    public Material WallMaterial;
    public Material HitedWallmaterial;
    public Camera Camera;
    public LayerMask Mask;

    public float SeeSize = 5;

    private void Start()
    {
        Camera = FindAnyObjectByType<Camera>();
    }

    private void Update()
    {
        if (WallMaterial == null || Camera == null)
        {
            return;
        }

        var dir = Camera.transform.position - transform.position;
        var ray = new Ray(transform.position, dir.normalized);
        var hit = new RaycastHit();

        if (Physics.Raycast(ray, out hit, 3000, Mask))
        {
            if(HitedWallmaterial == null && hit.collider.GetComponent<MeshRenderer>() != null)
            HitedWallmaterial = hit.collider.GetComponent<MeshRenderer>().material;
            if(HitedWallmaterial != WallMaterial && hit.collider.GetComponent<MeshRenderer>() != null)
            hit.collider.GetComponent<MeshRenderer>().material = WallMaterial;
            WallMaterial.SetFloat(SizeID, SeeSize);
        }
        else if(Physics.SphereCast(ray,0.5f,out hit, 3000, Mask) && HitedWallmaterial != null)
        {
            hit.collider.GetComponent<MeshRenderer>().material = HitedWallmaterial;
            HitedWallmaterial = null;
            WallMaterial.SetFloat(SizeID, 0);
        }
        else
        {
            WallMaterial.SetFloat(SizeID, 0); 
        }

        var view = Camera.WorldToViewportPoint(transform.position);
        WallMaterial.SetVector(PosID, view);
    }
}
