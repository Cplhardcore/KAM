#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_CaffeineLocal;
 *
 * Public: No
 */
params ["_patient"];
[_patient, CaffineOverdose, 1, 120, 30, "", "", "", "", ""] call EFUNC(vitals,addMedicationAdjustment);
