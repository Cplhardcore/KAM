#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the effect of Etomidate
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_EtomidateLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "EtomidateSedation", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
TRACE_1("EtomidateOD",_doseLevel);
if (_doseLevel < 0.1) then {
    [_patient, "EtomidateSedation", 5, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "true"] call EFUNC(vitals,addMedicationAdjustment);
    [_patient, true] call ACEFUNC(medical,setUnconscious);
};