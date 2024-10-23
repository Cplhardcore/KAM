#include "..\script_component.hpp"
/*
 * Author: Mazinski.H
 * Locates and Removes one opioid after the administration of Naloxone.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_NaloxoneLocal;
 *
 * Public: No
 */
 params ["_patient"];
private _hrValue = [-40, -30, -20, 20, 30, 40];
private _hrAdjust = selectRandom _hrValue;
[_patient, NitroglycerinOverdose, 30, 1200, _hrAdjust, "", "", -0.7, "", ""] call EFUNC(vitals,addMedicationAdjustment);