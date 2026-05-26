#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles degrade of a nerve block
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: DeltaT
 *
 * Return Value:
 * None
 *
 * Public: No
 */
params ["_unit", "_deltaT"];

private _anesthesia = _unit getVariable [VAR_LOCAL_ANESTHESIA,[0,0,0,0,0,0,0,0,0,0,0,0]];

{
    _anesthesia set [_forEachIndex, (_x - (0.00333 * _deltaT)) max 0];
} forEach _anesthesia;

_unit setVariable [VAR_LOCAL_ANESTHESIA, _anesthesia, true];