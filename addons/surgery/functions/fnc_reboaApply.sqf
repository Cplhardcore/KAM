#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Applies the REBOA function.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, cursorObject] call kat_surgery_reboaApply
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodypart"];

[QGVAR(reboaApply), [_medic, _patient, _bodypart], _patient] call CBA_fnc_targetEvent;