#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Lidocaine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_LidocaineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "LidocaineOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = -20 + floor random ((-20 - -20) + 1);
    [_patient, "LidocaineOverdose", 30, 1200, _hrAdjust, 0, 0, 0, 0.2, 0, 0, 0.3] call EFUNC(vitals,addMedicationAdjustment);
};
if (random(100) < 4) then {
    [{
        params ["_args", "_idPFH"];
        _args params ["_patient"];
        if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
        };
    }, [_patient], 15] call CBA_fnc_waitAndExecute;
};
