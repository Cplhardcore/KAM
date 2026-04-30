#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles IV fallout
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * none
 *
 * Example:
 * [player] call kat_pharma_fnc_updatePharmaEffects
 *
 * Public: No
 */

 params ["_unit"];
 if (!local _unit) exitWith { ERROR_2("updatePharmaEffects: Unit not local or null [%1:%2]",_unit,typeOf _unit); };
private _IVrate = _patient getVariable [QGVAR(IVrate), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVarray = _unit getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
{
    private _partIndex = ALL_BODY_PARTS find _x;
    if (((_IVarray select _partIndex) in [2,3,4]) && (abs (speed _unit) > 6 && isNull objectParent _unit)) then {
        private _chance = linearConversion [6, 12, (abs (speed _unit)), 2, 15];
        if ((random 100) < _chance) then {
            _IVarray set [_partIndex, 0];
            _IVrate set [_partIndex, 0];
            _unit setVariable [QGVAR(IV), _IVarray, true];
            _patient setVariable [QGVAR(IVrate), _IVrate, true];
        };
    };
} forEach ALL_BODY_PARTS;

if (((_IVarray select 1) == 14) && (abs (speed _unit) > 6 && isNull objectParent _unit)) then {
    private _chance = linearConversion [4, 12, (abs (speed _unit)), 2, 20];
    if ((random 100) < _chance) then {
        _IVarray set [_partIndex, 0];
        _IVrate set [_partIndex, 0];
        _unit setVariable [QGVAR(IV), _IVarray, true];
        _patient setVariable [QGVAR(IVrate), _IVrate, true];
    };
};