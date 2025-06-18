using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamageAble
{
    public void OnDamaged(float dmg, Vector3 dir, bool KnockbackAble = false);
}
