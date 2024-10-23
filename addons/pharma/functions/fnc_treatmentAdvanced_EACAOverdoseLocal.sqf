#include "..\script_component.hpp"
/*
 * Author: 2LT.Mazinski
 * Local function for EACA treatment
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
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
 [_patient, EACAOverdose, 1, 900, "", "", -90, -0.3, "", ""] call EFUNC(vitals,addMedicationAdjustment);
[{
    params ["_patient"];
    private _EACAOverdoseTarget = 0;
        [{
            params ["_patient", "_idPFH"];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            if (floor (random 100) < GVAR(deterioratingPneumothorax_chance)) then {
                _EACAOverdoseTarget = _EACAOverdoseTarget + 1;
                if (_EACAOverdoseTarget > 12) exitWith {
                    if (random(100) < 25) then {
                    [{
                        params ["_args", "_idPFH"];
                        _args params ["_patient"];
                        private _ht = _patient getVariable [QEGVAR(circulation,ht), []];
                        if ((_ht findIf {_x isEqualTo "eacaOD"}) == -1) then {
                            _ht pushBack "eacaOD";

                            if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                                [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
                            };

                            _patient setVariable [QEGVAR(circulation,ht), _ht, true];
                            };
                    }, [_patient], 15] call CBA_fnc_waitAndExecute;
                    };
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                };
                private _surfaceArea = (_patient getVariable [QGVAR(lungSurfaceArea), 400]) - 10;
                _patient setVariable [QGVAR(lungSurfaceArea), _surfaceArea];
            };
        }, 15, [_patient]] call CBA_fnc_addPerFrameHandler;
}, _patient, 15] call CBA_fnc_waitAndExecute;