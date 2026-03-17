#include "..\script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Local call for clearing all wounds on a patient
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "LeftLeg"] call kat_surgery_fnc_npwtTreatmentLocal;
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];
[QACEGVAR(medical_treatment,bandageLocal), [_patient, _bodyPart, "IncisionClosure"], _patient] call CBA_fnc_targetEvent; //TODO replace this

private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient);
private _bandagedWoundsOnPart = _bandagedWounds get _bodyPart;

if (_bandagedWoundsOnPart isEqualTo []) exitWith {false};

private _treatedWound = [];
private _woundCount = count _bandagedWoundsOnPart;

for "_i" from (_woundCount - 1) to 0 step -1 do {
    private _wound = _bandagedWoundsOnPart select _i;
    private _treatedID = _wound select 0;
    private _classIndex = _treatedID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
    if (_className in ["Incision"]) then {
        _treatedWound = _bandagedWoundsOnPart deleteAt _i;
    };
};

_treatedWound params ["_treatedID", "_treatedAmountOf", "", "_treatedDamageOf"];

// Check if we need to add a new stitched wound or increase the amount of an existing one
private _stitchedWounds = GET_STITCHED_WOUNDS(_patient);
private _stitchedWoundsOnPart = _stitchedWounds getOrDefault [_bodyPart, [], true];

private _woundIndex = _stitchedWoundsOnPart findIf {
    _x params ["_classID"];
    _classID == _treatedID
};

if (_woundIndex == -1) then {
    _stitchedWoundsOnPart pushBack _treatedWound;
} else {
    private _wound = _stitchedWoundsOnPart select _woundIndex;
    _wound set [1, (_wound select 1) + _treatedAmountOf];
};

_patient setVariable [VAR_BANDAGED_WOUNDS, _bandagedWounds, true];
_patient setVariable [VAR_STITCHED_WOUNDS, _stitchedWounds, true];

[_patient] call ACEFUNC(medical_engine,updateDamageEffects);
[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);