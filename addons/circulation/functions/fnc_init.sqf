#include "..\script_component.hpp"
/*
 * Author: Katalam
 * Initializes unit variables.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_circulation_fnc_init;
 *
 * Public: No
 */

params ["_unit", ["_isRespawn", true]];

if (!local _unit) exitWith {};

[_unit] call FUNC(fullHealLocal);

_unit setVariable [QGVAR(deviceCode), 0, true];
[{
    params ["_args", "_idPFH"];
    _args params ["_unit"];
    if !(alive _unit) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
    private _isRaining = rain > 0.1;
    private _hits = lineIntersectsSurfaces [
        eyePos _unit,
        eyePos _unit vectorAdd [0,0,50],
        _unit,
        objNull,
        true,
        1,
        "GEOM",
        "NONE"
    ];

    private _isUnderCover = (count _hits) > 0;
    private _bl = _unit getVariable [QGVAR(externalBloodLoss), 0];
    private _bl = (_bl - 0.0025) max 0;
    if (_isRaining && !_isUnderCover) then {
        _bl = (_bl - linearConversion [0, 1, rain, 0, 0.4, true]) max 0;
    };
    _unit setVariable [QGVAR(externalBloodLoss), _bl, true];
}, 10, [_unit]] call CBA_fnc_addPerFrameHandler;
