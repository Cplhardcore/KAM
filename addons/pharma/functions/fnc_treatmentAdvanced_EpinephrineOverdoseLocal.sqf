#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Local function for Epi Overdose
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_patient, "LeftArm"] call kat_pharma_fnc_treatmentAdvanced_EACALocal;
 *
 * Public: No
 */

params ["_patient"];
private _hrValue = [40, 30, 50];
private _hrAdjust = selectRandom _hrValue;
[_patient, "TACHYCARDIA", 120, 1200, _hrAdjust, 0, 0] call ACEFUNC(medical_status,addMedicationAdjustment);