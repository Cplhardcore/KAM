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
 
params ["_medic", "_patient", "_bodyPart"];

// Fetch wounds
private _bandaged = GET_BANDAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _wrapped  = GET_WRAPPED_WOUNDS(_patient)  getOrDefault [_bodyPart, []];
private _coag     = GET_COAGED_WOUNDS(_patient)   getOrDefault [_bodyPart, []];
private _stitchableWound = [];
private _sources = [
    [_bandaged, "bandaged"],
    [_wrapped,  "wrapped"],
    [_coag,     "coag"]
];

{
    _x params ["_woundArray", "_source"];

    {
        private _wound = _x;

        if ([_medic, _wound] call FUNC(canStitchWound)) exitWith {
            _stitchableWound = [_wound, _forEachIndex, _source]
        };

    } forEach _woundArray;

} forEach _sources;
TRACE_1("nextWound",_stitchableWound);
// Nothing found
_stitchableWound