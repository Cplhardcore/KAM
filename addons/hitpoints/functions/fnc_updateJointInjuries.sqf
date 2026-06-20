#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Called when an effusion starts
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_breathing_fnc_createTamponade
 *
 * Public: No
 */
params ["_unit", "_deltaT"];

private _wrappedJointArray = GET_WRAPPED_JOINTS(_unit);
private _icepackArray = GET_ICEPACKS(_unit);
private _jointArray = GET_JOINTS(_unit);
{
    _wrappedJointArray set [_forEachIndex, _x apply {(_x - _deltaT) max 0}];
} forEach _wrappedJointArray;
{
    _icepackArray set [_forEachIndex, _x apply {(_x - _deltaT) max 0}];
} forEach _icepackArray;
_unit setVariable [VAR_WRAPPED_JOINTS, _wrappedJointArray, true];
_unit setVariable [VAR_ICEPACKS, _icepackArray, true];
TRACE_2("joints2",_icepackArray,_wrappedJointArray);
private _speedMult = 1.5;
if ((abs (speed _unit) > 2 && isNull objectParent _unit) && !(_unit call ACEFUNC(medical_status,isBeingDragged) || _unit call ACEFUNC(medical_status,isBeingCarried))) then {
    _speedMult = linearConversion [2, 14, abs (speed _unit), 1, 0.1]
};
{
    TRACE_1("joints3",_rowIndex);
    private _rowIndex = _forEachIndex;
    private _jointSubArray = _jointArray select _rowIndex;
    {
        private _colIndex = _forEachIndex;
        TRACE_1("joints4",_colIndex);
        if (_x < 3) then
        {
            private _icePackMultiplier = [1, 2] select (((_icepackArray # _rowIndex) # _colIndex) > 0);
            private _wrapMultiplier    = [1, 1.8] select (((_wrappedJointArray # _rowIndex) # _colIndex) > 0);
            private _moderator = linearConversion [0, 3, _x, 1, 3]
            TRACE_2("joints1",_icePackMultiplier,_wrapMultiplier);

            private _jointValue =
                (_x - (0.00031 * _deltaT * _icePackMultiplier * _wrapMultiplier * _speedMult * _moderator)) max 0;

            _jointSubArray set [_colIndex, _jointValue];
        }
        else
        {
            _jointSubArray set [_colIndex, _x];
        };

    } forEach _jointSubArray;
    _jointArray set [_rowIndex, _jointSubArray];

} forEach _jointArray;
TRACE_1("joints",_jointArray);
_unit setVariable [VAR_JOINTS, _jointArray, true];