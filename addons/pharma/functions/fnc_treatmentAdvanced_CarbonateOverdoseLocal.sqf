#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Checks for Carbonate Wakeup values to restore consciousness
 *
 * Arguments:
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *`
 * Example:
 * [player, cursorTarget] call kat_pharma_fnc_treatmentAdvanced_CarbonateOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "CarbonateOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 10 + floor random ((30 - 10) + 1);
    [_patient, "CarbonateOverdose", 5, 360, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "CarbonateOverdose") exitWith {
            _x set [3, (_x # 3) + 1.2];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
};
