#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut, mharis001
 * Handles the surgical kit treatment by periodically closing bandaged wounds.
 *
 * Arguments:
 * 0: Arguments <ARRAY>
 *   0: Medic <OBJECT>
 *   1: Patient <OBJECT>
 *   2: Body Part <STRING>
 * 1: Elapsed Time <NUMBER>
 * 2: Total Time <NUMBER>
 *
 * Return Value:
 * Continue Treatment <BOOL>
 *
 * Example:
 * [[objNull, player], 5, 10] call ace_medical_treatment_fnc_surgicalKitProgress
 *
 * Public: No
 */
params ["_args", "_elapsedTime", "_totalTime"];
_args params ["_medic", "_patient", "_bodyPart"];

private _currentWound = [_medic, _patient, _bodyPart] call FUNC(getNextStitchableWound);

if (_currentWound isEqualTo []) exitWith {false};
TRACE_1("_currentWound", _currentWound);
_currentWound params ["_wound"];
private _requiredTime = [_wound] call FUNC(getStitchTimeWound);
TRACE_1("ReqTime", _requiredTime);
private _totalStitchTime = ([_patient, _patient, _bodyPart] call FUNC(getStitchTime));
TRACE_1("stitchTime", _totalStitchTime);
if (_totalTime - _elapsedTime > (_totalStitchTime - _requiredTime)) exitWith {true};
// Get all wounds
private _bandagedWounds  = GET_BANDAGED_WOUNDS(_patient);
private _wrappedWounds   = GET_WRAPPED_WOUNDS(_patient);
private _coagWounds      = GET_COAGED_WOUNDS(_patient);

// Select wounds on given body part
private _unstitchableTypes = ["ETD", "Israeli_Bandage"];
private _bandagedWoundsOnPart = _bandagedWounds getOrDefault [_bodyPart, []];
private _wrappedWoundsOnPart  = _wrappedWounds  getOrDefault [_bodyPart, []];
private _coagWoundsOnPart     = _coagWounds     getOrDefault [_bodyPart, []];

private _allWounds = [];
{
    _x params ["_woundArray", "_woundSource"];

    {
        if (
            ([_medic, _x] call FUNC(canStitchWound))
        ) then {
            _allWounds pushBack [_x, _forEachIndex, _woundSource];
        };
    } forEach _woundArray;

} forEach [
    [_bandagedWoundsOnPart, "bandaged"],
    [_wrappedWoundsOnPart,  "wrapped"],
    [_coagWoundsOnPart,     "coag"]
];
// Stop treatment if there are no wounds that can be stitched remaining
if (_allWounds isEqualTo []) exitWith {false};

// Stitch the first possible wound on the body part
private _stitched = [_medic, _patient, _bodyPart] call FUNC(stitchWound);

if (typeName _stitched != "array") exitWith {
    ERROR_1("failed to stitch wound on unit - %1",_patient);
    false
};

// Consume a suture for the next wound if one exists, stop stitching if none are left
if (GVAR(consumeSurgicalKit) == 2 && {_bandagedWoundsOnPart isNotEqualTo []} &&  {_wrappedWoundsOnPart isNotEqualTo []} &&  {_coagWoundsOnPart isNotEqualTo []}) then {
    _stitched params ["_wound", "_amount", "_source"];
    _wound params ["_classID", "", "", "", "_type"];
    private _category = _classID % 10;
    private _cost = switch (_category) do {
        case 0: {1};
        case 1: {2};
        case 2: {3};
        default {1};
    };

    for "_i" from 1 to _cost do {
        ([_medic, _patient, ["ACE_suture"]] call FUNC(useItem)) params ["_user"];
        if (isNull _user) exitWith {false};
    };
    true
} else {
    true
}