#include "..\script_component.hpp"
/*
 * Author: Ruthberg
 * Check if a unit has stable vitals (required to become conscious)
 *
 * Arguments:
 * 0: The patient <OBJECT>
 *
 * Return Value:
 * Has stable vitals <BOOL>
 *
 * Example:
 * [player] call ace_medical_status_fnc_hasStableVitals
 *
 * Public: No
 */

params ["_unit"];

private _bloodVolume = GET_BLOOD_VOLUME_LITERS(_unit);
if (_bloodVolume < BLOOD_VOLUME_CLASS_4_HEMORRHAGE) exitWith { false };

if IN_CRDC_ARRST(_unit) exitWith { false };
if ((_unit getVariable [QEGVAR(surgery,sedated), 0]) > 0.1) exitWith { false };
if (((_unit getVariable [QEGVAR(surgery,reboa), false]) select 0) || ((_unit getVariable [QEGVAR(surgery,reboa), false]) select 1)) exitWith { false };

private _cardiacOutput = [_unit] call FUNC(getCardiacOutput);
private _bleedRate = GET_BLOOD_LOSS(_unit);
private _bleedRateKO = BLOOD_LOSS_KNOCK_OUT_THRESHOLD * (_cardiacOutput max 0.05);
if (_bleedRate > _bleedRateKO) exitWith { false };

private _map = GET_MAP(_unit);
if (_map < 60 || _map > 120) exitWith { false };

private _heartRate = GET_HEART_RATE(_unit);
private _defaultHeartRate = _unit getVariable [QEGVAR(circulation,defaultHeartRate), 80];
if (_heartRate < ((_defaultHeartRate - 35) max 40)) exitWith { false };

private _unitTemperature = _unit getVariable [QGVAR(unitTemperature), 37];
if (_unitTemperature < 34) exitWith { false };

private _o2 = GET_KAT_SPO2(_unit);
if (_o2 < EGVAR(breathing,Stable_spo2)) exitWith { false };

private _CMR = _unit getVariable [QEGVAR(brain,CMR),100];
if (_CMR < EGVAR(brain,stableCMR)) exitWith { false };

true
