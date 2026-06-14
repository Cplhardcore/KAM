#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Naloxone.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_NaloxoneOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "SuccinylcholineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = -30 + floor random ((-10 - -30) + 1);
    [_patient, "SuccinylcholineOverdose", 20, 300, _hrAdjust, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] call EFUNC(vitals,addMedicationAdjustment);
};
