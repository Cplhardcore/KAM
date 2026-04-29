#include "..\script_component.hpp"
/*
 * Author: kymckay
 * Calculates the Surgical Kit treatment time based on the amount of stitchable wounds.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * Treatment Time <NUMBER>
 *
 * Example:
 * [player, cursorObject, "head"] call ace_medical_treatment_fnc_getStitchTime
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

private _unstitchableTypes = ["ETD", "Israeli_Bandage"];

private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _clottedWounds  = GET_COAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _wrappedWounds = GET_WRAPPED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _time = 0;
private _calcTime = {
    params ["_wound"];

    _wound params ["_classID", "_amount"];

    private _category = _classID % 10;

    private _baseTime = switch (_category) do {
        case 0: { GVAR(smallWoundStitchTime) };
        case 1: { GVAR(mediumWoundStitchTime) };
        case 2: { GVAR(largeWoundStitchTime) };
        default { 1 };
    };

    // Optional: scale by class
    private _classIndex = _classID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;

    private _typeMultiplier = switch (_className) do {
        case "VelocityWound": {1.3};
        case "Avulsion": {1.5};
        case "Laceration": {1.2};
        case "Crush": {0.8};
        case "Incision": {0.8};
        case "Abrasion": {0.6};
        default {1};
    };

    (_amount max 1) * _baseTime * _typeMultiplier
};
{
    if ([_medic,_x] call FUNC(canStitchWound)) then {
        _time = _time + ([_x] call _calcTime);
    };
} forEach _bandagedWounds;

{
    if ([_medic, _x] call FUNC(canStitchWound)) then {
        _time = _time + ([_x] call _calcTime);
    };
} forEach _clottedWounds;

{
    if ([_medic,_x] call FUNC(canStitchWound)) then {
        _time = _time + ([_x] call _calcTime);
    };
} forEach _wrappedWounds;
TRACE_1("AmountOf",_amountOf);
_time