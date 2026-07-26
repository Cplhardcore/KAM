#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of EACA
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 
 *
 * Return Value:
 * None
 *
 * Example:
 * [_patient] call kat_pharma_fnc_treatmentAdvanced_EACAOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "EACAOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    [_patient, "EACAOverdose", 1, 900, 0, 0, -0.5] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "EACAOverdose") exitWith {
            _x set [3, (_x # 3) + 1.2];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
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
private _surface = (_patient getVariable [QEGVAR(breathing,lungSurfaceArea), 400]);
if (_surface > 150) then {
    private _surfaceArea = _surface - 2;
    _patient setVariable [QEGVAR(breathing,lungSurfaceArea), _surfaceArea, true];;
};
private _bloodlevels = GET_BODY_FLUID(_patient);
_bloodlevels set [5, ((_bloodlevels select 5) - 5) max 0];
_patient setVariable [QEGVAR(circulation,bodyFluid), _bloodlevels, true];
if ((random 10000) < 1) then {[_patient, "EACAOD"] call ACEFUNC(medical_status,setDead);};