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
if (_doseLevel > 0.1) exitWith {};
[_patient, "nalbuphineOverdose", 20, 2400, 0, 0, 0, 0, 0.3, 0, 0, 0.17, -0.3, 0, 0, "false", "false", "false", 0.7] call EFUNC(vitals,addMedicationAdjustment);
[{
    params ["_patient"];
        [{
            params ["_args", "_idPFH"];
            _args params ["_patient", "_nalbuphineOverdoseTarget"];
            _nalbuphineOverdoseTarget = _nalbuphineOverdoseTarget + 1;
            _args set [1, _nalbuphineOverdoseTarget];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            private _medications = _patient getVariable [QACEGVAR(medical,medications), []];
            if (_medications findIf {_x isEqualTo "nalbuphineOverdose"} == -1) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
                if (_nalbuphineOverdoseTarget > 6) exitWith {
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
                private _medications = _patient getVariable [QACEGVAR(medical,medications), []];
                if (_medications findIf {_x isEqualTo "naloxone"} != -1) exitWith {};
        }, 15, [_patient,0]] call CBA_fnc_addPerFrameHandler;
}, [_patient], 15] call CBA_fnc_waitAndExecute;
