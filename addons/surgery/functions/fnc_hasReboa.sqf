#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Local call for removing REBOA.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, cursorObject, "LeftLeg"] call kat_surgery_fnc_reboaRemoveLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];
private _reboaStatus = _patient getVariable [QGVAR(reboa), [false, false]];
private _hasReboa = ((_reboaStatus select 0) || (_reboaStatus select 1));
_hasReboa