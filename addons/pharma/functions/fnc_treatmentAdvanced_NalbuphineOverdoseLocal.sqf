#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Nalbuphine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_NalbuphineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "nalbuphineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    [_patient, "nalbuphineOverdose", 20, 2400, 0, 0, 0, 0, 0.3, 0, 0, 0.17, -0.3, 0, 0, 0, 0, 0, 0.7] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "nalbuphineOverdose") exitWith {
            _x set [3, (_x # 3) + 1.2];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
};
if (random 100 < 5) then {
    private _ht = _patient getVariable [QEGVAR(circulation,ht), []];    
    if ((_ht findIf {_x isEqualTo "opioidOD"}) == -1) then {
    _ht pushBack "opioidOD";
    if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
        [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
    };
    _patient setVariable [QEGVAR(circulation,ht), _ht, true];
    };
};
