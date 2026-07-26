#include "..\script_component.hpp"
#pragma hemtt suppress pw3_padded_arg file
/*
 * Author: MiszczuZPolski
 * Ensures proper initial values reset on respawn
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Corpse <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [alive, body] call kat_misc_fnc_handleRespawn;
 *
 * Public: No
 */

params ["_unit","_dead"];
[_unit] call FUNC(fullHealLocal);

//[_unit] call FUNC(renalSystem);

