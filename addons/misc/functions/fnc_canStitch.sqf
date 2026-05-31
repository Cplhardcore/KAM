#include "..\script_component.hpp"
/*
 * Author: Katalam, mharis001, Brett Mayson
 * Checks if the patient's body part can be stitched.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * ReturnValue:
 * Can Stitch <BOOL>
 *
 * Example:
 * [player, cursorTarget, "head"] call ace_medical_treatment_fnc_canStitch
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

if ((ACEGVAR(medical_treatment,consumeSurgicalKit) == 2) && {!([_medic, _patient, ["ACE_suture"]] call ACEFUNC(medical_treatment,hasItem))}) exitWith {false};
private _unstitchableTypes = ["ETD", "Israeli_Bandage"];
private _bandaged = GET_BANDAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _hasStitchableBandage = (_bandaged findIf {
    _x params ["", "", "", "", "_type"];
    !(_type in _unstitchableTypes)
}) != -1;
private _isBleeding = false;
private _allow = switch (GVAR(allowAdvancedStitching)) do {
    case 0: {true};
    case 1: {
        IN_MED_VEHICLE(_medic)
    };
    case 2: {
        IN_MED_FACILITY(_medic)
    };
    case 3: {
        IN_MED_VEHICLE(_medic) || {IN_MED_FACILITY(_medic)}
    };
    default {false};
};
{
    _x params ["_woundClassID", "_amountOf", "_bleedingRate"];
    private _classIndex = _woundClassID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
    if (_amountOf > 0 && {_bleedingRate > 0} && {!(_className in ["InternalBleeding", "Evisceration"])} && {(_allow && {_className in ["Avulsion","VelocityWound","Laceration"]})}) then {
        _isBleeding = true;
        TRACE_4("canStitch - Bleeding from non-allowed wound",_woundClassID,_classIndex,_className,_isBleeding);
        break; 
    };
    TRACE_4("canStitch",_woundClassID,_classIndex,_className,_isBleeding);
    if (_isBleeding && !(_className in ["InternalBleeding", "Evisceration", "Thermal_Burn"])) then {break};
} forEach (GET_OPEN_WOUNDS(_patient) get _bodyPart);

(!(_isBleeding) && (
    (_hasStitchableBandage)||
    (GET_COAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []]) isNotEqualTo [] ||
    (GET_WRAPPED_WOUNDS(_patient) getOrDefault [_bodyPart, []]) isNotEqualTo []
)) // return