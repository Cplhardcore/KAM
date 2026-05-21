#include "..\script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Begins Flumazenil unsedating process
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_FlumazenilLocal;
 *
 * Public: No
 */

params ["_patient"];
    private _medications = _patient getVariable [QACEGVAR(medical,medications), []];
    if (_medications findIf {_x isEqualTo "Lorazepam"} != -1) exitWith {};
    [{
        params ["_args", "_idPFH"];
        _args params ["_patient"];
        private _medicationArray = _patient getVariable [QACEGVAR(medical,medications), []];
        {
        _x params ["_medication"];
        if (_medication isEqualTo "Lorazapam") then {
            _medicationArray deleteAt (_medicationArray find _x);
        };
        } forEach _medicationArray;
        _patient setVariable [QACEGVAR(medical,medications), _medicationArray, true];
    }, [_patient], 15] call CBA_fnc_waitAndExecute;