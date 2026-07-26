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
private _doseLevel = ([_unit, "Fentanyl_Patch", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.1) then {
    [_unit, "Fentanyl_Patch", 2, 5, 0, 0.6, 0, 0.6, 0, 1.02, 0.05, 0.1, -0.05, 0, 0.12, 0, 0, 1] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _unit getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "Fentanyl_Patch") exitWith {
            _x set [3, (_x # 3) + (1.2 * _deltaT)];
        };
    } forEach _medications;
};
_unit setVariable [VAR_FENT_PATCH, _fentPatch, true];