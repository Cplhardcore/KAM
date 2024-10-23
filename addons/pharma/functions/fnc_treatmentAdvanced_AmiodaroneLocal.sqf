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

private _random = random 3;
if (_random <= 1) then {
    private _hrValue = [-40, -30, -50];
    private _hrAdjust = selectRandom _hrValue;
    [_patient, "BRADYCARDIA", 120, 1200, _hrAdjust, "", "", "", "", ""] call EFUNC(vitals,addMedicationAdjustment);
};
