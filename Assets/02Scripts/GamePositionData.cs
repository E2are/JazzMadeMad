using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Assets/Data", menuName = "GamePositionData")]
public class GamePositionData : ScriptableObject
{
    public Vector3[] BossStagePositions = new Vector3[5];
    public Vector3[] AfterBossPositions = new Vector3[6];
}
