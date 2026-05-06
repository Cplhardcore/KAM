#include "..\script_component.hpp"
/*
 * Author: kymckay
 * Calculates the Surgical Kit treatment time based on the amount of stitchable wounds.
 *
 * Arguments:
 * 0: Medic (not used) <OBJECT>
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

params ["_wound"];
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
        default {1};
    };

    (_amount max 1) * _baseTime * _typeMultiplier
};
private _time = [_wound] call _calcTime;
_time