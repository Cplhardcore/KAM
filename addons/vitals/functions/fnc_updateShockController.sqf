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
private _lactate = _unit getVariable [QEGVAR(pharma,lactate),1.2];
private _ph = GET_PH(_unit);
private _micro = _unit getVariable [QGVAR(microcirculation),0];
private _bv = GET_BODY_FLUID_ECB(_unit);

private _bvFrac = (_bv / 2700) max 0.3 min 1;

private _shock =
(
    linearConversion [1.2,8,_lactate,0,0.6,true] +
    linearConversion [7.35,7.0,_ph,0,0.5,true] +
    linearConversion [0.9,0.4,_bvFrac,0,0.6,true] +
    (_micro * 0.8)
);

_shock = (_shock / 2.2) min 1;
private _skinPerf = 1 - ((_shock * 0.6) + (_micro * 0.6));
_skinPerf = (_skinPerf max 0) min 1;
private _trauma = _unit getVariable [QGVAR(traumaState),0];

private _drive =
linearConversion [2,10,_lactate,0,0.01,true] +
linearConversion [7.35,7.0,_ph,0,0.01,true] +
(_micro * 0.01);

_trauma = _trauma + (_drive * 5);

if (_lactate < 2 && _ph > 7.34) then {
    _trauma = _trauma - 0.005;
};

_trauma = (_trauma max 0) min 1;

_unit setVariable [QGVAR(traumaState),_trauma,true];
_unit setVariable [QGVAR(skinPerfusion),_skinPerf,true];
_unit setVariable [QGVAR(shockState),_shock,true];