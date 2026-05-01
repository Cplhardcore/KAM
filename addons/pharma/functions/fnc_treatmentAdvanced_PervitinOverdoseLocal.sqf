#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Pervatin
 *
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_PervitinOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "PervitinOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel > 0.1) exitWith {};
private _randomNumber = floor (random 3) + 1;
switch (_randomNumber) do {
    case 1: {
        private _hrAdjust = 30 + floor random ((50 - 30) + 1);
        [_patient, "TACHYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
        [_patient, "PervitinOverdose", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
    };
    case 2: {
        private _hrAdjust = 30 + floor random ((50 - 30) + 1);
        [_patient, "TACHYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
        [_patient, "PervitinOverdose", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
        private _randomValue = [3, 4];
        private _randomRhythm = selectRandom _randomValue;
        _patient setVariable [QEGVAR(circulation,cardiacArrestType), _randomRhythm, true];
    };
    case 3: {
        private _hrAdjust = 30 + floor random ((50 - 30) + 1);
        [_patient, "TACHYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
        [_patient, "PervitinOverdose", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
        private _randomValue = [3, 4];
        private _randomRhythm = selectRandom _randomValue;
        _patient setVariable [QEGVAR(circulation,cardiacArrestType), _randomRhythm, true];
    };
    case 4: {
        private _hrAdjust = 30 + floor random ((50 - 30) + 1);
        [_patient, "TACHYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
        [_patient, "PervitinOverdose", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
        _patient setVariable [QEGVAR(circulation,cardiacArrestType), 0, true];
    };
};