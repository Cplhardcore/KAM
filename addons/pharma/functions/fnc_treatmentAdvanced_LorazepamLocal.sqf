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
private _doseLevel = ([_patient, "LorazepamSedation", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _cns = random [0.2, 0.25, 0.3];
    [_patient, "LorazepamSedation", 10, 1200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, _cns] call EFUNC(vitals,addMedicationAdjustment);
    [_patient, true] call ACEFUNC(medical,setUnconscious);
};

