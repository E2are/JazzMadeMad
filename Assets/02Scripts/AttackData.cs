using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Assets/Data", menuName = "AttackData")]
public class AttackData : ScriptableObject
{
    public GameObject HalfTImePrefab;
    public GameObject LaserPrefab;

    public Sprite Skill1Sprite;
    public Player.arrows[] Attack1Commands;

    public Sprite Skill2Sprite;
    public Player.arrows[] Attack2Commands;

    public Sprite Skill3Sprite;
    public Player.arrows[] Attack3Commands;

    public Sprite Skill4Sprite;
    public Player.arrows[] Attack4Commands;
    
    public Sprite Skill5Sprite;
    public Player.arrows[] Attack5Commands;
    
    public Sprite Skill6Sprite;
    public Player.arrows[] Attack6Commands;

    public List<Sprite> PageSprites = new List<Sprite>();
    public Dictionary<int, int> SkillIndexs = new Dictionary<int, int>();
    public List<Player.arrows[]> Commands = new List<Player.arrows[]>();

    public void InitCommands()
    {
        int Enabledskillcnt = 0;
        GameData GD = Json.LoadJsonFile<GameData>(Application.dataPath, "GameData");
        Commands.Clear();
        PageSprites.Clear();
        SkillIndexs.Clear();

        Commands.Add(Attack1Commands);
        PageSprites.Add(Skill1Sprite);
        SkillIndexs.Add(Enabledskillcnt++, 0);
        
        if (GD.BeatonBosses[0])
        {
            Commands.Add(Attack2Commands);
            PageSprites.Add(Skill2Sprite);
            SkillIndexs.Add(Enabledskillcnt++, 1);
        }
        if (GD.BeatonBosses[1])
        {
            Commands.Add(Attack3Commands);
            PageSprites.Add(Skill3Sprite);
            SkillIndexs.Add(Enabledskillcnt++, 2);
        }
        if (GD.BeatonBosses[2])
        {
            Commands.Add(Attack4Commands);
            PageSprites.Add(Skill4Sprite);
            SkillIndexs.Add(Enabledskillcnt++, 3);
        }
        
        if (GD.BeatonBosses[3])
        {
            Commands.Add(Attack5Commands);
            PageSprites.Add(Skill5Sprite);
            SkillIndexs.Add(Enabledskillcnt++, 4);
        }
        
        if (GD.BeatonBosses[4])
        {
            Commands.Add(Attack6Commands);
            PageSprites.Add(Skill6Sprite);
            SkillIndexs.Add(Enabledskillcnt++, 5);
        }
    }
}
