#include "..\script_component.hpp"
#pragma hemtt suppress pw3_padded_arg file
/*
 * Author: Katalam, Miss Heda
 * Initializes unit variables.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_init;
 *
 * Public: No
 */

params ["_unit", ["_isRespawn", true]];

if (!local _unit) exitWith {};

[_unit] call FUNC(fullHealLocal);

[_unit] call FUNC(renalSystem);