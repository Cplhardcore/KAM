#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_CaffeineLocal;
 *
 * Public: No
 */
params ["_patient"];
[{
    params ["_patient"];
    private _CaffineOverdoseTarget = 0;
        [{
            params ["_patient", "_idPFH"];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
                _CaffineOverdoseTarget = _CaffineOverdoseTarget + 1;
                if (_CaffineOverdoseTarget > 12) exitWith {
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                };
                private _hr = _patient getVariable [VAR_HEART_RATE, 80];
				private _hrAdd = (_hr + 3);
				_patient setVariable [VAR_HEART_RATE, _hrAdd, true];
        }, 10, [_patient]] call CBA_fnc_addPerFrameHandler;
}, _patient, 10] call CBA_fnc_waitAndExecute;
[{
    params ["_patient"];
    private _CaffineOverdoseTarget = 0;
        [{
            params ["_patient", "_idPFH"];
            if (!(alive _patient)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
                _CaffineOverdoseTarget = _CaffineOverdoseTarget + 1;
                if (_CaffineOverdoseTarget > 12) exitWith {
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                };
                private _hr = _patient getVariable [VAR_HEART_RATE, 80];
				private _hrAdd = (_hr - 3);
				_patient setVariable [VAR_HEART_RATE, _hrAdd, true];
        }, 10, [_patient]] call CBA_fnc_addPerFrameHandler;
}, _patient, 150] call CBA_fnc_waitAndExecute;