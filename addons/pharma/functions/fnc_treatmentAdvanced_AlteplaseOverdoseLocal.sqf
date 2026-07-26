#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Alteplase
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AlteplaseOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];

private _doseLevel = ([_patient, "AlteplaseOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 10 + floor random ((25 - 10) + 1);
    [_patient, "AlteplaseOverdose", 30, 600, _hrAdjust, 0, 0, 0.2] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "AlteplaseOverdose") exitWith {
            _x set [3, (_x # 3) + 1.2];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
};
private _bloodlevels = GET_BODY_FLUID(_patient);
_bloodlevels set [0, ((_bloodlevels select 0) - 5) max 0];
_bloodlevels set [5, ((_bloodlevels select 5) - 10) max 0];
_patient setVariable [QEGVAR(circulation,bodyFluid), _bloodlevels, true];
