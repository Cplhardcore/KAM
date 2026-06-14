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
private _doseLevel = ([_patient, "RocuroniumOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 20 + floor random ((50 - 20) + 1);
    [_patient, "RocuroniumOverdose", 10, 600, _hrAdjust, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] call EFUNC(vitals,addMedicationAdjustment);
};

