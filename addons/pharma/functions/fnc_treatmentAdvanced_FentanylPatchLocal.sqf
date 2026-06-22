#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Modified: Mazinski
 * Triggers the fentanyl visual effect and applies the opioid factor from Fentanyl.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "LeftLeg", 1] call kat_pharma_fnc_treatmentAdvanced_FentanylLocal;
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];
private _partIndex = ALL_BODY_PARTS find _bodyPart;
private _fentPatch = _patient getVariable [VAR_FENT_PATCH, [0,0,0,0,0,0,0,0,0,0,0,0]];
[_patient, "Fentanyl_Patch", 2, 5, 0, 0.6, 0, 0.6, 0, 1.02, 0.05, 0.1, -0.05, 0, 0.12, 0, 0, 2] call EFUNC(vitals,addMedicationAdjustment);
_fentPatch set [_partIndex, 1];
_patient setVariable [VAR_FENT_PATCH, _fentPatch, true];
