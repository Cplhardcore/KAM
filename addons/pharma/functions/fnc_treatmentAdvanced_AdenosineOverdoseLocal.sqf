#include "..\script_component.hpp"
/*
 * Author:Cplhardcore
 * Handles the overdose effect of Adenosine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AdenosineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "AdenosineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = -10 + floor random ((-25 - -10) + 1);
    [_patient, "AdenosineOverdose",10,120,_hrAdjust,0,0,0,0,0,0,0,-0.05,0,0,0,0,0] call EFUNC(vitals,addMedicationAdjustment);
};
if (random(1000) < 5) then {
    if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
        [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
    };
};