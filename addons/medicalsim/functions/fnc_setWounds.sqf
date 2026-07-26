#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Applies wounds to body parts. Gives avulsions only.

	Parameter(s):
		0: Unit to apply wound to <OBJECT>
        1: Damage done to each body part <ARRAY>

	Returns:
		Nothing

	Examples:
		{_player, [[2, "LeftLeg"]]} call afl_common_fnc_setPneumothorax;
*/

params ["_unit", "_allDamages", "_damageType", "_directDamage"];
TRACE_2("setWounds",_unit,_allDamages);
if (_directDamage) exitWith {
	{
		private _damageToAdd = _x select 0;
		private _bodyPart = _x select 1;
		[QACEGVAR(medical,woundReceived), [_unit, [[_damageToAdd, _bodyPart, _damageToAdd]], _unit, _damageType]] call CBA_fnc_localEvent;
	} forEach _allDamages;	
};
[_unit, _allDamages, _damageType, "", true, false] call ACEFUNC(medical_damage,woundsHandlerBase); 