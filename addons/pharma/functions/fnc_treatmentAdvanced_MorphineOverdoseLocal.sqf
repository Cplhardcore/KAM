#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Morphine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_MorphineOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
[_patient, "morphineOverdose", 20, 2400, 0, 0, 0, 0, 0.3, 0, 0, 0.17, -0.1, 0, 0, "false", "false", "false", 0.7] call EFUNC(vitals,addMedicationAdjustment);
[{
    params ["_patient"];
        [{
            params ["_args", "_idPFH"];
            _args params ["_patient", "_morphineOverdoseTarget"];
            _morphineOverdoseTarget = _morphineOverdoseTarget + 1;
            _args set [1, _morphineOverdoseTarget];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            private _medications = _patient getVariable [QACEGVAR(medical,medications), []];
            if (_medications findIf {_x isEqualTo "morphineOverdose"} == -1) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
                if (_morphineOverdoseTarget > 6) exitWith {
                    [{
                        params ["_args", "_idPFH"];
                        _args params ["_patient"];
                        private _ht = _patient getVariable [QEGVAR(circulation,ht), []];
                        if ((_ht findIf {_x isEqualTo "opioidOD"}) == -1) then {
                            _ht pushBack "opioidOD";
                            if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                                [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
                            };
                            _patient setVariable [QEGVAR(circulation,ht), _ht, true];
                            };
                    }, [_patient], 10] call CBA_fnc_waitAndExecute;
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                };
        }, 15, [_patient,0]] call CBA_fnc_addPerFrameHandler;
}, [_patient], 15] call CBA_fnc_waitAndExecute;
