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

 params ["_unit", "_deltaT"];
 if (!local _unit) exitWith { ERROR_2("updatePharmaEffects: Unit not local or null [%1:%2]",_unit,typeOf _unit); };
[_unit] call FUNC(clotWound);
[_unit] call FUNC(coagRegen);
[_unit, _deltaT] call FUNC(handleNerveBlock);
private _IVrate = _unit getVariable [QGVAR(IVrate), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVarray = _unit getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
{
    private _partIndex = ALL_BODY_PARTS find _x;
    if (((_IVarray select _partIndex) in [2,3,4]) && (abs (speed _unit) > 11 && isNull objectParent _unit) && !(_unit call ACEFUNC(medical_status,isBeingDragged) || _unit call ACEFUNC(medical_status,isBeingCarried))) then {
        private _chance = linearConversion [11, 18, (abs (speed _unit)), 0.01, 15];
        if ((random 100) < _chance) then {
            _IVarray set [_partIndex, 0];
            _IVrate set [_partIndex, 0];
            _unit setVariable [QGVAR(IV), _IVarray, true];
            _unit setVariable [QGVAR(IVrate), _IVrate, true];
        };
    };
} forEach ALL_BODY_PARTS;

if (((_IVarray select 1) == 14) && (abs (speed _unit) > 6 && isNull objectParent _unit) && !(_unit call ACEFUNC(medical_status,isBeingDragged) || _unit call ACEFUNC(medical_status,isBeingCarried))) then {
    private _chance = linearConversion [6, 12, (abs (speed _unit)), 2, 20];
    if ((random 100) < _chance) then {
        _IVarray set [1, 0];
        _IVrate set [1, 0];
        _unit setVariable [QGVAR(IV), _IVarray, true];
        _unit setVariable [QGVAR(IVrate), _IVrate, true];
    };
};

