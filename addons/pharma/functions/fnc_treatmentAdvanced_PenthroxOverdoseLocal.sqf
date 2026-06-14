#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Penthrox
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 * 3: Treatment <STRING>
 * 4: Item User (not used) <OBJECT>
 * 5: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_PenthroxOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "PenthroxOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    [_patient, "PenthroxOverdose",15,600,0,0,0,0,-0.2,0,0,0,0,0,0,0,0,0,0.2] call EFUNC(vitals,addMedicationAdjustment);
}; 