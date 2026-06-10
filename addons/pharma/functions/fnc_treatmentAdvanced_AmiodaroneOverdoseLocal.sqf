#include "..\script_component.hpp"
/*
 * Author: Mazinski.H, Edited by MiszczuZPolski and Cplhardcore
 * Handles the overdose effect Amiodarone
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AmiodaroneOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "AmiodaroneOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel > 0.01) exitWith {};
private _hrAdjust = -30 + floor random ((-10 - -30) + 1);
[_patient, "BRADYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
[_patient, "AmiodaroneOverdose", 30, 1200, 0, 0, 0, 0.2] call EFUNC(vitals,addMedicationAdjustment);
