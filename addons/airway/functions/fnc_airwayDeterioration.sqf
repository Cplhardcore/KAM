#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * handels airway degredation
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Damage done to each body part <ARRAY>
 *    0: Engine damage <NUMBER>
 *    1: Body part <STRING>
 *    2: Real damage <NUMBER>
 * 2: Damage type (unused) <STRING>
 * 3: Ammo (unused) <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, [1, "Body", 2], "bullet", "B_556x45_Ball"] call kat_hitpoints_fnc_woundsHandlerPelvicHit
 *
 * Public: No
 */

params ["_unit"];
private _isUnconscious  = _unit getVariable ["ACE_isUnconscious", false];
if !(_isUnconscious) exitWith {};
private _alive = alive _unit;
if !(_alive) exitWith {};


if (
    !(GVAR(enable))
    || {_unit getVariable ["KAT_Occlusion_Exclusion", false]}
) exitWith {};
if (_unit getVariable [QEGVAR(vitals,simpleMedical), false]) exitWith {};

private _lastTimeUpdated = _unit getVariable [QGVAR(lastTimeHDUpdated), 0];
private _deltaT = (CBA_missionTime - _lastTimeUpdated) min 10;
if (_deltaT < 5) exitWith { false }; 
_unit setVariable [QGVAR(lastTimeHDUpdated), CBA_missionTime];


private _occlusionState = _unit getVariable [QGVAR(occlusion), [0, 0, 0]];
private _mitigation     = _unit getVariable [QGVAR(occlusionMitigation), [0, 0, 0]];
{
    private _level = _forEachIndex;
    private _current = _x;
    private _bleeding = ((GET_BODY_PART_RATE(_unit,0)) + (GET_BODY_PART_RATE(_unit,1)));
    _occlusionState set [_level, (_current + (_bleeding max 0.1)) min 10];
} forEach _occlusionState;

{
    private _a = _x;
    private _b = _x + 1;

    private _occA = _occlusionState select _a;
    private _occB = _occlusionState select _b;

    private _mitA = _mitigation select _a;
    private _mitB = _mitigation select _b;

    private _gravityBias = 1;
    if (_occB > _occA) then {
        _gravityBias = 0.5;
    };
    private _rate = 0.1
        * (1 - ((_mitA + _mitB) / 2))
        * _gravityBias;
    private _difference = _occA - _occB;
    if (_difference > 0) then {
        if (_occB < 10 && _mitB < 1) then {
            private _delta = _difference * _rate;
            private _actual =
                (_delta min _occA)
                min (10 - _occB);
            _occlusionState set [_a, _occA - _actual];
            _occlusionState set [_b, _occB + _actual];
        };
    } else {
        if (_difference < 0) then {
            if (_occA < 10 && _mitA < 1) then {
            
                private _delta = abs(_difference) * _rate;
                private _actual =
                    (_delta min _occB)
                    min (10 - _occA);
                _occlusionState set [_a, _occA + _actual];
                _occlusionState set [_b, _occB - _actual];
            };
        };
    };

} forEach [0,1];

_unit setVariable [QGVAR(occlusion), _occlusionState, true];