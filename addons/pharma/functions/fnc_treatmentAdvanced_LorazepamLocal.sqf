#include "..\script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Begins Lorazepam sedating process
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_LorazepamLocal;
 *
 * Public: No
 */

params ["_patient", "_dose"];

private _random = random 3;
private _doseBradyLevel = ([_patient, "LorazepamBrady", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if ((_doseBradyLevel < 0.01) && (_random <= 1)) then {
    private _hrValue = [-40, -30, -50];
    private _hrAdjust = selectRandom _hrValue;
    [_patient, "BRADYCARDIA", 120, 1200, _hrAdjust] call EFUNC(vitals,addMedicationAdjustment);
    [_patient, "LorazepamBrady", 120, 1200] call EFUNC(vitals,addMedicationAdjustment);
};
private _doseLevel = ([_patient, "LorazepamSedation", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    [_patient, "LorazepamSedation", 10, 600, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "true"] call EFUNC(vitals,addMedicationAdjustment);
    [_patient, true] call ACEFUNC(medical,setUnconscious);
};

