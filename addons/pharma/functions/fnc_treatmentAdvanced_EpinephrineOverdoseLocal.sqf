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
 * [_patient] call kat_pharma_fnc_treatmentAdvanced_EpinephrineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "EpinephrineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = 30 + floor random ((60 - 30) + 1);
    [_patient, "EpinephrineOverdose", 30, 1200,_hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
};
if (random 100 < 1) then {
    private _randomValue = [3, 4];
    private _randomRhythm = selectRandom _randomValue;
    _patient setVariable [QEGVAR(circulation,cardiacArrestType), _randomRhythm, true];
};