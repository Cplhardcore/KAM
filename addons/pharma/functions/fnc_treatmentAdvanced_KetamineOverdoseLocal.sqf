#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Ketamine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_KetamineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "ketamineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) exitWith {
    [_patient, "ketamineOverdose", 20, 2400, 0, 0, 0, 0, -0.1, 0, 0, 0, -0.15, 0, 0, 0, 0, 0, 0.5] call EFUNC(vitals,addMedicationAdjustment);
};
if (random(100) < 5) then {
    [{
        params ["_args", "_idPFH"];
        _args params ["_patient"];
        if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
        };
    }, [_patient], 15] call CBA_fnc_waitAndExecute;
};