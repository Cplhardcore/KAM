#include "..\script_component.hpp"
/*
 * Author: Mazinski.H, Blue
 * Checks for Carbonate Wakeup values to restore consciousness
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *`
 * Example:
 * [player, cursorTarget] call kat_pharma_fnc_treatmentAdvanced_CarbonateLocal;
 *
 * Public: No
 */
params ["_patient"];
[_patient, CarbonateOverdose, 1, 30, 10, "", "", "", "", ""] call EFUNC(vitals,addMedicationAdjustment);

