#include "..\script_component.hpp"
/*
 * Author: Mazinski.H, Edited by MiszczuZPolski and Cplhardcore
 * Applies Bradycardia randomly
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AmiodaroneLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "AmiodaroneBrady", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel > 0.01) exitWith {};
private _random = random 3;
if (_random <= 1) then {
    private _hrAdjust = -30 + floor random ((-10 - -30) + 1);
    [_patient, "BRADYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
    [_patient, "AmiodaroneBrady", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
};
