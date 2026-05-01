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
if (_doseLevel > 0.1) exitWith {};
[{
    params ["_patient"];
    (_patient setVariable [QGVAR(AmiodaroneOverdose), false, true])
}, [_patient], 1200] call CBA_fnc_waitAndExecute;
private _hrAdjust = -50 + floor random ((-30 - -50) + 1);
[_patient, "BRADYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
[_patient, "AmiodaroneOverdose", 30, 1200, 0, 0, 0, 0.2] call EFUNC(vitals,addMedicationAdjustment);
