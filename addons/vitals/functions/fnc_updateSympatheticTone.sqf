#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Update symp tone
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_vitals_fnc_updateSympatheticTone
 *
 * Public: No
 */

params ["_unit"];

private _pain = GET_PAIN(_unit);
private _map = GET_MAP(_unit);
private _spo2 = GET_KAT_SPO2(_unit);
private _paco2 = GET_PACO2(_unit);
private _sedation = _unit getVariable [QEGVAR(surgery,sedated),0];
private _debt = _unit getVariable [QGVAR(oxygenDebt),0];
private _shock = _unit getVariable [QGVAR(shockState),0];
private _tone = 0.5;
private _trauma = _unit getVariable [QGVAR(traumaState),0];


_tone = _tone + linearConversion [90,50,_map,0,0.45,true];
TRACE_1("tone1", _tone);
_tone = _tone + linearConversion [95,70,_spo2,0,0.25,true];
TRACE_1("tone2", _tone);
_tone = _tone + linearConversion [45,80,_paco2,0,0.25,true];
TRACE_1("tone3", _tone);
_tone = _tone + (_pain * 0.2);
TRACE_1("tone4", _tone);
_tone = _tone + linearConversion [0,6,_debt,0,0.4,true];
TRACE_1("tone5", _tone);
_tone = _tone + linearConversion [0,0.6,_shock,0,1,true];
TRACE_1("tone6", _tone);
if (_trauma > 0.7) then {
    _tone = _tone * (1 - ((_trauma - 0.7) * 1.2));
};
TRACE_1("tone7", _tone);
_tone = _tone * linearConversion [0,1,_sedation,1,0.45,true];
TRACE_1("tone8", _tone);
_tone = (_tone max 0) min 1;

_unit setVariable [QGVAR(sympatheticTone),_tone];