#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Fentanyl
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_FentanylOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "FentanylOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    [_patient, "FentanylOverdose", 10, 2400, 0, 0, 0, 0, 0.4, 0, 0, 0.17, -0.1, 0, 0, 0, 0, 0, 0.8] call EFUNC(vitals,addMedicationAdjustment);
};
private _ht = _patient getVariable [QEGVAR(circulation,ht), []];
if (((_ht findIf {_x isEqualTo "opioidOD"}) == -1) && ((random 100) < 10)) then {
    _ht pushBack "opioidOD";
    if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
        [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
    };
    _patient setVariable [QEGVAR(circulation,ht), _ht, true];
    };
