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
 * [player, "rightleg"] call kat_hitpoints_fnc_wrapSplint
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];

private _partIndex = ALL_BODY_PARTS find _bodyPart;
private _jointArray = GET_JOINTS(_patient);
private _icepackArray = GET_ICEPACKS(_patient);
private _jointGroupIndex = switch (true) do {
case (_partIndex in [4, 5]): { 0 };
case (_partIndex in [6, 7]): { 1 };
case (_partIndex in [8, 9]): { 2 };
case (_partIndex in [10, 11]): { 3 };
default { -1 };
};
if (_jointGroupIndex == -1) exitWith {};
private _limbJointStatus = _jointArray select _jointGroupIndex;
private _limbIcepackStatus = _icepackArray select _jointGroupIndex;
private _selectedJointIndexes = if (["upper", _bodyPart] call BIS_fnc_inString) then {
    [0, 1]
} else {
    [1, 2]
};
{
    private _jointInjury = _limbJointStatus select _x;
    private _icedStatus = _limbIcepackStatus select _x;
    if (_icedStatus == 0) exitWith {
        _limbIcepackStatus set [_x, 600];
        _icepackArray set [_jointGroupIndex, _limbIcepackStatus];
        _patient setVariable [VAR_ICEPACKS, _icepackArray, true];
    };
} forEach _selectedJointIndexes;
    

