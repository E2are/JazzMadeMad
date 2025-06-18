using UnityEngine;

namespace SciFiAOE{
public class CameraController : MonoBehaviour
{
    [SerializeField] float RotationSpeed = 1;
    private bool Rotate;
    private float RotateValue ;

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.R))
            {
                Rotate = !Rotate;
            }


        //VerticalValue = -Input.GetAxis("Mouse Y")* MouseSensitivity * Time.deltaTime;
        //HorizontalValue = Input.GetAxis("Mouse X")* MouseSensitivity * Time.deltaTime;

        if(Rotate)
            {
            RotateValue= RotationSpeed *100* Time.deltaTime;
            }
        else 
            {
                RotateValue = 0;
            }
        
        transform.eulerAngles += new Vector3 (0,-RotateValue,0)*RotationSpeed ;
    }

}

}