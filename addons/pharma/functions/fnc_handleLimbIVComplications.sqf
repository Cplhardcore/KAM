#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles advanced IV complications
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: The Bodypart <number>
 * 2: flowDifference (difference in fluid between the cap and the actual)<Number>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "LeftLeg", 2] call kat_pharma_fnc_handleLimbIVComplications
 *
 * Public: No
 */

params ["_patient", "_partIndex", "_incomingFlowDifference"];

private _stressArray = _patient getVariable [QGVAR(ivStress), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _conditionArray = _patient getVariable [QGVAR(ivCondition), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _painArray = _patient getVariable [QGVAR(ivPain), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _leakArray = _patient getVariable [QGVAR(IVLeakStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _stress = _stressArray select _partIndex;
private _condition = _conditionArray select _partIndex;
_stress = _stress + (_incomingFlowDifference * 0.1);
_stressArray set [_partIndex, _stress];
_patient setVariable [QGVAR(ivStress), _stressArray];
private _leak = _leakArray select _partIndex;
private _targetLeak = linearConversion [8, 20, _stress, 0, 1, true];
private _newLeak = _leak + ((_targetLeak - _leak) * 0.25);
_leakArray set [_partIndex, _newLeak];
_patient setVariable [QGVAR(IVLeakStatus), _leakArray, true];
private _leakPain = (_newLeak - _leak) * 0.5;
private _prevPain = _painArray select _partIndex;
private _targetPain = (((_stress / 20) ^ 2) min 1) + _leakPain;
private _deltaPain = _targetPain - _prevPain;

if (abs _deltaPain > 0.01) then {
    [_patient, _deltaPain] call ACEFUNC(medical_status,adjustPainLevel);
    _painArray set [_partIndex, _targetPain];
    _patient setVariable [QGVAR(ivPain), _painArray];
};

private _newCondition = _condition;

if (_stress > 5) then {
    _newCondition = 1;
};

if (_stress > 10) then {
    _newCondition = 2;
};

if (_stress > 20) then {
    _newCondition = 3;
};

if (_newCondition != _condition) then {
    _conditionArray set [_partIndex, _newCondition];
    _patient setVariable [QGVAR(ivCondition), _conditionArray];

    private _bodyPart = ALL_BODY_PARTS select _partIndex;

    switch (_newCondition) do {
        case 2: {
            [_patient, 0.3] call ACEFUNC(medical_status,adjustPainLevel);
        };

        case 3: {
            [objNull, _patient, _bodyPart] call EFUNC(pharma,retrieveIV);
        };
    };
};