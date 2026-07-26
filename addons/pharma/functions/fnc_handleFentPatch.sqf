#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Modified: Mazinski
 * Triggers the fentanyl visual effect and applies the opioid factor from Fentanyl.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "LeftLeg", 1] call kat_pharma_fnc_treatmentAdvanced_FentanylLocal;
 *
 * Public: No
 */

params ["_unit", "_deltaT"];
private _fentPatch = _unit getVariable [VAR_FENT_PATCH, [0,0,0,0,0,0,0,0,0,0,0,0]];
{
    private _fentPatchIndex = _fentPatch select _x;
    _fentPatch set [_x, ((_fentPatchIndex - ((0.002 * random [0.8, 1, 1.2]) * _deltaT)) max 0)];
} forEach _fentPatch;
private _adjustments = _unit getVariable [VAR_MEDICATIONS, []];
{
    _x params ["_oDmedication", "", "", "_timeInSystem"];
    if (_oDmedication isEqualTo "Fentanyl_Patch") exitWith {
        _x set [3, _timeInSystem + 1.5];
    };
} forEach _adjustments;
_unit setVariable [VAR_MEDICATIONS, _adjustments, true];
_unit setVariable [VAR_FENT_PATCH, _fentPatch, true];