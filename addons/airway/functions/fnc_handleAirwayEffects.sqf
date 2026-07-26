#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Called when a unit is damaged.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, [1, "Body", 2], "bullet", "B_556x45_Ball"] call kat_hitpoints_fnc_handleAirwayHit
 *
 * Public: No
 */
params ["_unit", "_deltaT"];

if (_unit getVariable [QGVAR(recovery), false]) then {
    if (GVAR(RecoveryPosition_TimeToDrain) > 0) then {
    private _occlusionState = _unit getVariable [QGVAR(occlusion), [0, 0, 0]];
    _occlusionState set [0, ((_occlusionState select 0) - random [0.1, 0.2, 0.3]) max 0];
    _occlusionState set [1, ((_occlusionState select 1) - random [0.1, 0.2, 0.3]) max 0];
    _occlusionState set [2, ((_occlusionState select 2) - random [0.1, 0.2, 0.3]) max 0];
    _unit setVariable [QGVAR(occlusion), _occlusionState, true];
    };
};

if (_unit call ACEFUNC(medical_status,isBeingDragged) || _unit call ACEFUNC(medical_status,isBeingCarried) || !(_unit getVariable [QGVAR(recovery), false]) || !(isNull objectParent _unit)) then {
    _unit setVariable [QGVAR(recovery), false, true];
    _unit setVariable [QGVAR(overstretch), false, true];
};