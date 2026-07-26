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
private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _imagingStatus = _patient getVariable [QGVAR(imaging), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _hasImaging = (_imagingStatus select _partIndex) > 0;
_hasImaging
