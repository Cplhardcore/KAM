#include "..\script_component.hpp"
/*
 * Author: Mazinski.H
 * Locates and Removes Bradycardia Effect.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, syringe_atropine_5ml_2] call kat_pharma_fnc_treatmentAdvanced_AtropineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "AtropineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 10 + floor random ((25 - 10) + 1);
     [_patient, "AtropineOverdose",30, 600,_hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
}; 
