#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles advanced IV complications
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: flowDifference (difference in fluid between the cap and the actual)<Number>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 1] call kat_pharma_fnc_handleIVComplications
 *
 * Public: No
 */
params ["_patient", "_overLoad"];

private _taco = _patient getVariable [QEGVAR(breathing,TACO), 0];
private _strain = _patient getVariable [QEGVAR(breathing,TACOStrain), 0];
private _state = _patient getVariable [QEGVAR(breathing,TACOState), 0]; // 0-3
_taco = _taco + (_overLoad * 0.06);
_patient setVariable [QEGVAR(breathing,TACO), _taco, true];

private _strainGain = (_taco * 0.015);
_strain = _strain + _strainGain;
_patient setVariable [QEGVAR(breathing,TACOStrain), _strain, true];
private _newState = _state;

if (_strain > 5)  then {_newState = 1};
if (_strain > 10) then {_newState = 2};
if (_strain > 18) then {_newState = 3};

switch (_newState) do {
    case 1: {
        [_patient, 0.01] call ACEFUNC(medical_status,adjustPainLevel);
    };
    case 2: {
        [_patient, 0.03] call ACEFUNC(medical_status,adjustPainLevel);
    };
    case 3: {
        [_patient, 0.3] call ACEFUNC(medical_status,adjustPainLevel);
        if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
            [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
        };
    };
};

if (_newState != _state) then {
    _patient setVariable [QEGVAR(breathing,TACOState), _newState, true];
};