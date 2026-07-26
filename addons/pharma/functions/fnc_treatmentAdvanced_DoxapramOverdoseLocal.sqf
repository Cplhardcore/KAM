#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effects of Doxapram
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_DoxapramOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "DoxapramOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 10 + floor random ((25 - 10) + 1);
     [_patient, "DoxapramOverdose",30, 600,_hrAdjust,0,0,0,0.15] call EFUNC(vitals,addMedicationAdjustment);
}; 