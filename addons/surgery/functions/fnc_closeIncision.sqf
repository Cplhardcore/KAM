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

diag_log format ["[TRACE][IncisionClosure] START | Medic: %1 | Patient: %2 | BodyPart: %3", _medic, _patient, _bodyPart];

[QACEGVAR(medical_treatment,bandageLocal), [_patient, _bodyPart, "IncisionClosure"], _patient] call CBA_fnc_targetEvent; //TODO replace this

diag_log format ["[TRACE][IncisionClosure] Fired bandageLocal target event for %1 on %2", _patient, _bodyPart];

private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient);
diag_log format ["[TRACE][IncisionClosure] Bandaged wounds map: %1", _bandagedWounds];

private _bandagedWoundsOnPart = _bandagedWounds get _bodyPart;
diag_log format ["[TRACE][IncisionClosure] Bandaged wounds on %1: %2", _bodyPart, _bandagedWoundsOnPart];

if (_bandagedWoundsOnPart isEqualTo []) exitWith {
    diag_log format ["[TRACE][IncisionClosure] EXIT - No bandaged wounds found on %1", _bodyPart];
    false
};

private _treatedWound = [];
private _woundCount = count _bandagedWoundsOnPart;

diag_log format ["[TRACE][IncisionClosure] Wound count on %1: %2", _bodyPart, _woundCount];

for "_i" from (_woundCount - 1) to 0 step -1 do {

    diag_log format ["[TRACE][IncisionClosure] Inspecting wound index: %1", _i];

    private _wound = _bandagedWoundsOnPart select _i;

    diag_log format ["[TRACE][IncisionClosure] Raw wound data: %1", _wound];

    private _treatedID = _wound select 0;
    private _classIndex = _treatedID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;

    diag_log format [
        "[TRACE][IncisionClosure] Wound ID: %1 | ClassIndex: %2 | ClassName: %3",
        _treatedID,
        _classIndex,
        _className
    ];

    if (_className == "Incision") then {

        diag_log format [
            "[TRACE][IncisionClosure] MATCH FOUND - Removing incision wound at index %1",
            _i
        ];

        _treatedWound = _bandagedWoundsOnPart deleteAt _i;
        _bandagedWounds set [_bodyPart, _bandagedWoundsOnPart];
        diag_log format [
            "[TRACE][IncisionClosure] Treated wound extracted: %1",
            _treatedWound
        ];
    };
};

diag_log format ["[TRACE][IncisionClosure] Final treated wound: %1", _treatedWound];

_treatedWound params ["_treatedID", "_treatedAmountOf", "", "_treatedDamageOf"];

diag_log format [
    "[TRACE][IncisionClosure] Treated wound unpacked | ID: %1 | Amount: %2 | Damage: %3",
    _treatedID,
    _treatedAmountOf,
    _treatedDamageOf
];

// Check if we need to add a new stitched wound or increase the amount of an existing one
private _stitchedWounds = GET_STITCHED_WOUNDS(_patient);

diag_log format ["[TRACE][IncisionClosure] Existing stitched wounds map: %1", _stitchedWounds];

private _stitchedWoundsOnPart = _stitchedWounds getOrDefault [_bodyPart, [], true];

diag_log format [
    "[TRACE][IncisionClosure] Stitched wounds on %1 before update: %2",
    _bodyPart,
    _stitchedWoundsOnPart
];

private _woundIndex = _stitchedWoundsOnPart findIf {
    _x params ["_classID"];

    diag_log format [
        "[TRACE][IncisionClosure] Comparing stitched wound classID %1 against treatedID %2",
        _classID,
        _treatedID
    ];

    _classID == _treatedID
};

diag_log format [
    "[TRACE][IncisionClosure] Existing stitched wound index result: %1",
    _woundIndex
];

if (_woundIndex == -1) then {

    diag_log format [
        "[TRACE][IncisionClosure] No existing stitched wound found. Adding new stitched wound."
    ];

    _stitchedWoundsOnPart pushBack _treatedWound;

} else {

    diag_log format [
        "[TRACE][IncisionClosure] Existing stitched wound found at index %1",
        _woundIndex
    ];

    private _wound = _stitchedWoundsOnPart select _woundIndex;

    diag_log format [
        "[TRACE][IncisionClosure] Existing stitched wound before modification: %1",
        _wound
    ];

    _wound set [1, (_wound select 1) + _treatedAmountOf];

    diag_log format [
        "[TRACE][IncisionClosure] Existing stitched wound after modification: %1",
        _wound
    ];
};

diag_log format [
    "[TRACE][IncisionClosure] Final stitched wounds on %1: %2",
    _bodyPart,
    _stitchedWoundsOnPart
];

_patient setVariable [VAR_BANDAGED_WOUNDS, _bandagedWounds, true];

diag_log format [
    "[TRACE][IncisionClosure] Updated VAR_BANDAGED_WOUNDS: %1",
    _bandagedWounds
];

_patient setVariable [VAR_STITCHED_WOUNDS, _stitchedWounds, true];

diag_log format [
    "[TRACE][IncisionClosure] Updated VAR_STITCHED_WOUNDS: %1",
    _stitchedWounds
];

diag_log format [
    "[TRACE][IncisionClosure] Calling updateDamageEffects for patient %1",
    _patient
];

[_patient] call ACEFUNC(medical_engine,updateDamageEffects);

diag_log format [
    "[TRACE][IncisionClosure] Calling updateWoundBloodLoss for patient %1",
    _patient
];

[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);

diag_log format [
    "[TRACE][IncisionClosure] END | Patient: %1 | BodyPart: %2",
    _patient,
    _bodyPart
];