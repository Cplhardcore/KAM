#include "..\script_component.hpp"
/*
 * Author: Blue
 * Handle effects for when tourniquet is applied for prolonged time
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_misc_fnc_handleTourniquetEffects;
 *
 * Public: No
 */

params ["_unit"];

if (!(GVAR(tourniquetEffects_Enable))) exitWith {};


private _tourniquet_ArmNecrosis = _unit getVariable [QGVAR(Tourniquet_ArmNecrosis), 0];
private _tourniquet_LegNecrosis = _unit getVariable [QGVAR(Tourniquet_LegNecrosis), 0];
private _activeTourniquets = GET_KAT_TOURNIQUETS(_unit);
private _armTourniquets = (_activeTourniquets select 4) + (_activeTourniquets select 5) + (_activeTourniquets select 6) + (_activeTourniquets select 7);
private _legTourniquets = (_activeTourniquets select 8) + (_activeTourniquets select 9) + (_activeTourniquets select 10) + (_activeTourniquets select 11);
if (_armTourniquets > 0) then {
    _tourniquet_ArmNecrosis = _tourniquet_ArmNecrosis + (0.16 * GVAR(tourniquetEffects_PositiveMultiplier));
    if (_tourniquet_ArmNecrosis >= 100) then {
        _tourniquet_ArmNecrosis = 100;
    };
} else {
    _tourniquet_ArmNecrosis = _tourniquet_ArmNecrosis - (0.32 * GVAR(tourniquetEffects_NegativeMultiplier));
    if (_tourniquet_ArmNecrosis <= 0) then {
        _tourniquet_ArmNecrosis = 0;
    };
};
if (_legTourniquets > 0) then {
    _tourniquet_LegNecrosis = _tourniquet_LegNecrosis + (0.16 * GVAR(tourniquetEffects_PositiveMultiplier));
    if (_tourniquet_LegNecrosis >= 100) then {
        _tourniquet_LegNecrosis = 100;
    };
} else {
    _tourniquet_LegNecrosis = _tourniquet_LegNecrosis - (0.32 * GVAR(tourniquetEffects_NegativeMultiplier));
    if (_tourniquet_LegNecrosis <= 0) then {
        _tourniquet_LegNecrosis = 0;
    };
};
if ((_tourniquet_ArmNecrosis + _tourniquet_LegNecrosis <= 0 && _armTourniquets + _legTourniquets == 0) || !(alive _unit)) exitWith {
    _unit setVariable [QGVAR(Tourniquet_ArmNecrosis), 0];
    _unit setVariable [QGVAR(Tourniquet_LegNecrosis), 0];
    _unit setVariable [QGVAR(Tourniquet_LegNecrosis_Threshold), 0, true];
};
_unit setVariable [QGVAR(Tourniquet_ArmNecrosis), _tourniquet_ArmNecrosis];
_unit setVariable [QGVAR(Tourniquet_LegNecrosis), _tourniquet_LegNecrosis];
