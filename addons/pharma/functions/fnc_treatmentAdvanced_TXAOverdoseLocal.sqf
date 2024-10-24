#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * causes TXA overdose effect
 *
 * Arguments:
 * 0: Medic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_TXAOverdoseLocal;
 *
 * Public: No
 */

params ["_patient"];

[_patient, TXAOverdose, 1, 900, "", "", -90, -0.3, "", ""] call EFUNC(vitals,addMedicationAdjustment);
[{
    params ["_patient"];
    private _TXAOverdoseTarget = 0;
        [{
            params ["_patient", "_idPFH"];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
                _TXAOverdoseTarget = _TXAOverdoseTarget + 1;
                if (_TXAOverdoseTarget > 12) exitWith {
                    if (random(100) < 25) then {
                    [{
                        params ["_args", "_idPFH"];
                        _args params ["_patient"];
                        private _ht = _patient getVariable [QEGVAR(circulation,ht), []];
                        if ((_ht findIf {_x isEqualTo "txaOD"}) == -1) then {
                            _ht pushBack "txaOD";

                            if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                                [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
                            };

                            _patient setVariable [QEGVAR(circulation,ht), _ht, true];
                            };
                    }, [_patient], 15] call CBA_fnc_waitAndExecute;
                    };
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                };
                private _surfaceArea = (_patient getVariable [QEGVAR(breathing,lungSurfaceArea), 400]) - 10;
                _patient setVariable [QEGVAR(breathing,lungSurfaceArea), _surfaceArea];
                private _coagulationFactor = (_patient getVariable [QGVAR(coagulationFactor), 30]);
                private _factorstoremove = 1
                _patient setVariable [QGVAR(coagulationFactor), (_coagulationFactor - _factorstoremove), true];
        }, 15, [_patient]] call CBA_fnc_addPerFrameHandler;
}, _patient, 15] call CBA_fnc_waitAndExecute;
