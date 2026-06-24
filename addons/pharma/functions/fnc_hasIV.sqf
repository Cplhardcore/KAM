#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Checks if any IV bags are present
 * Note: Patient may not be local
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * Check IV Condition <BOOLEAN>
 *
 * Example:
 * [player, cursorObject, "LeftLeg", "saline"] call kat_pharma_fnc_hasIV;
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _return = false;
if (_partIndex >= 0 && (_IVarray select _partIndex) > 0) then {
    _return = true;
};


_return
