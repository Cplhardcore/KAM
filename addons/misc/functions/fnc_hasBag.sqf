#include "..\script_component.hpp"
/*
 * Author: cplhardcore
 * Drop Bag function
 *
 * Arguments:
 * 0: Bool Array <ARRAY>
 *
 * Return Value:
 * Ammo count <INT>
 *
 * Example:
 * [[true,true,true,true,false,false,false,false]] call kat_misc_fnc_FAK_arrayToAmmo;
 *
 * Public: No
 */
 
params ["_unit"];
private _hasBag = (backpack _unit != "");
_hasBag