#include "..\script_component.hpp"
#pragma hemtt suppress pw3_padded_arg file
/*
 * Author: Glowbal
 * Modified: Blue
 * Calculate the blood pressure of a unit.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * 0: BloodPressure Low <NUMBER>
 * 1: BloodPressure High <NUMBER>
 *
 * Example:
 * [player] call ace_medical_status_fnc_getBloodPressure
 *
 * Public: No
 */
params ["_unit"];
#define BASELINE_MAP 94.7
#define BASELINE_CO  0.1054056 // L/s
#define BASELINE_SVR (94.7 / 0.1054056 )  // ≈ 860
private _cardiacOutput = [_unit] call EFUNC(vitals,getCardiacOutput);
private _strokeVolume  = [_unit] call EFUNC(vitals,getStrokeVolume);
private _heartRate     = GET_HEART_RATE(_unit);
private _exertionSVR = 1;
if (_unit getVariable [QEGVAR(vitals,fatigueEnabled), false]) then {
    private _aceAnFatigue = [_unit] call EFUNC(vitals,returnFatigue);
    private _aceAnReserve = [_unit] call EFUNC(vitals,returnReserve);
    private _totalFatigue =
    (_aceAnFatigue * 1200)
    + ((2200 - _aceAnReserve) * 0.4);
    _exertionSVR = linearConversion [0, 2600, _totalFatigue, 1, 0.75, true];
} else {
    _exertionSVR = linearConversion [60, 130, _heartRate, 1.05, 0.75, true];
};
private _resistance        = _unit getVariable [VAR_PERIPH_RES, DEFAULT_PERIPH_RES];
private _vasoconstrictionArray  = GET_VASOCONSTRICTION(_unit);
private _tourniquets       = GET_TOURNIQUETS(_unit);
private _icp               = GET_ICP(_unit);

private _occlusionMap = [
    [3, [3, 8, 9, 10, 11]],
    [4, [4]],
    [5, [4, 5]],
    [6, [6]],
    [7, [6, 7]],
    [8, [8]],
    [9, [8, 9]],
    [10, [10]],
    [11, [10, 11]]
];

private _partOcclusion = [];
_partOcclusion resize 12;
_partOcclusion = _partOcclusion apply {0};
{
    private _tq = _tourniquets select (_x#0);
    if (_tq > 0) then {
        {
            _partOcclusion set [_x, (_partOcclusion select _x) max _tq];
        } forEach (_x#1);
    };
} forEach _occlusionMap;

private _occlusionAmount = 0;
{
    _occlusionAmount = _occlusionAmount + _x;
} forEach _partOcclusion;

private _prevMAP = GET_MAP(_unit);
private _vasoconstriction = 0;
private _weight = 0;
{
    private _factor = 1 - (_partOcclusion select _forEachIndex);
    _vasoconstriction = _vasoconstriction + (_x * _factor);
    _weight = _weight + _factor;
} forEach _vasoconstrictionArray;
if (_weight > 0) then {
    _vasoconstriction = _vasoconstriction / _weight;
};
private _vasoFactor = linearConversion [0.2, 1.8, _vasoconstriction, 1.25, 0.75, true];
if (_icp > 25) then {
    private _cpp = _prevMAP - _icp;
    if (_cpp < 60) then {
        _resistance = _resistance * linearConversion [60, 30, _cpp, 1.0, 1.25, true];
    };
};
private _map =
    (_cardiacOutput
    * BASELINE_SVR
    * (_resistance / 100)
    * _exertionSVR
    * _vasoFactor)
    * (1.045 ^ _occlusionAmount);
TRACE_4("BP2", _map, _vasoFactor, BASELINE_SVR, _cardiacOutput);
_map = _map * 0.95;
private _cushing = [_unit] call EFUNC(vitals,getCushings);
if (_cushing > 0) then {
    _map = _map * linearConversion [0, 1, _cushing, 1.0, 1.35, true];
};
_map = ((_map max 0) min 240);
_unit setVariable [QGVAR(map), _map];
TRACE_1("BP3", _map);
private _basePulsePressure = linearConversion [60, 110, _map, 30, 50, true];
TRACE_1("BP4", _basePulsePressure);
private _baselineSV = 0.068; 
private _svFactor =
    linearConversion [0.03, _baselineSV, _strokeVolume, 0.4, 1.0, true];
private _shockClass = _unit getVariable [QEGVAR(vitals,shockClass), 0];
private _shockPPMult = [_shockClass, 1, 1.05, 0.4, 0.4] call EFUNC(misc,getSineValue);
private _bradyFactor =
    linearConversion [80, 40, _heartRate, 0.1, 1, true];

private _cushingPPMult =
    1 + (_cushing * _bradyFactor * 0.6);
private _complianceFactor =
    linearConversion [0.75, 1.25, _vasoFactor, 0.9, 1.1, true];

private _pulsePressure =
    _basePulsePressure
    * _svFactor
    * _shockPPMult
    * _cushingPPMult
    * _complianceFactor;
_pulsePressure = _pulsePressure max (_map * 0.15) min (_map * 0.9);
TRACE_1("BP4", _pulsePressure);
private _systolic  = _map + (_pulsePressure * 0.6666667);
private _diastolic = _map - (_pulsePressure * 0.3333333);

private _BPChange = _unit getVariable [VAR_BLOODPRESSURE_CHANGE, []];
private _changeSystolic = 0;
private _changeDiastolic = 0;

{
    _changeSystolic  = _changeSystolic  + (_x select 0);
    _changeDiastolic = _changeDiastolic + (_x select 1);
} forEach _BPChange;

[
    (round (_diastolic + _changeDiastolic) max 0),
    (round (_systolic  + _changeSystolic) max 0)
]