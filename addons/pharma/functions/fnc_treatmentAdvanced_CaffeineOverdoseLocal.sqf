#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_CaffeineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "CaffeineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel > 0.01) exitWith {};
private _hrAdjust = 20 + floor random ((30 - 10) + 1);
[_patient, "CaffeineOverdose", 5, 600, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);