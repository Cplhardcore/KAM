#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Callback to wrap a splint on a bodypart
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>

 * Return Value:
 * None
 *
 * Example:
 * [player, "rightleg"] call kat_hitpoints_fnc_wrapJoint
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];

private _partIndex = ALL_BODY_PARTS find _bodyPart;
private _jointArray = GET_JOINTS(_patient);
private _wrappedJointArray = GET_WRAPPED_JOINTS(_patient);
private _jointGroupIndex = switch (true) do {
case (_partIndex in [4, 5]): { 0 };
case (_partIndex in [6, 7]): { 1 };
case (_partIndex in [8, 9]): { 2 };
case (_partIndex in [10, 11]): { 3 };
default { -1 };
};

private _limbJointStatus = _jointArray select _jointGroupIndex;
private _limbWrappedStatus = _wrappedJointArray select _jointGroupIndex;
private _selectedJointIndexes = if (["upper", _bodyPart] call BIS_fnc_inString) then {
    [0, 1]
} else {
    [1, 2]
};
{
    private _jointInjury = _limbJointStatus select _x;
    private _wrappedStatus = _limbWrappedStatus select _x;
    if (_wrappedStatus == 0) exitWith {
        _limbWrappedStatus set [_x, 1200];
        _wrappedJointArray set [_jointGroupIndex, _limbWrappedStatus];
        _patient setVariable [VAR_WRAPPED_JOINTS, _wrappedJointArray, true];
    };
} forEach _selectedJointIndexes;
    
