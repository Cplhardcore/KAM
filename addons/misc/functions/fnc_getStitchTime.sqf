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

params ["", "_patient", "_bodyPart"];

private _unstitchableTypes = ["ETD", "Israeli_Bandage"];

private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _clottedWounds  = GET_COAGED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _wrappedWounds = GET_WRAPPED_WOUNDS(_patient) getOrDefault [_bodyPart, []];
private _time = 0;

_bandagedWounds select {
    _x params ["_woundClassID", "_amountOfWounds", "_bleedingRate", "", "_type"];
    
    private _classIndex = _woundClassID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
    private _category   = _woundClassID % 10;
    switch (_category) do {
        case 0: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(smallWoundStitchTime));
        };
        case 1: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(mediumWoundStitchTime));
        };
        case 2: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(largeWoundStitchTime));
        };
    };
    !(_type in _unstitchableTypes) && !(_className in ["InternalBleeding", "Evisceration", "Thermal_Burn"])  && !(GVAR(allowCatastrophicWoundStitch) && _className in ["Avulsion", "VelocityWound", "Laceration"]);
};

_clottedWounds select {
    _x params ["_woundClassID", "_amountOfWounds", "_bleedingRate", "", "_type"];
    
    private _classIndex = _woundClassID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
    private _category   = _woundClassID % 10;
    switch (_category) do {
        case 0: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(smallWoundStitchTime));
        };
        case 1: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(mediumWoundStitchTime));
        };
        case 2: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(largeWoundStitchTime));
        };
    };
    !(_type in _unstitchableTypes) && !(_className in ["InternalBleeding", "Evisceration", "Thermal_Burn"])  && !(GVAR(allowCatastrophicWoundStitch) && _className in ["Avulsion", "VelocityWound", "Laceration"]);
};
_wrappedWounds select {
    _x params ["_woundClassID", "_amountOfWounds", "_bleedingRate", "", "_type"];
    
    private _classIndex = _woundClassID / 10;
    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
    private _category   = _woundClassID % 10;
    switch (_category) do {
        case 0: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(smallWoundStitchTime));
        };
        case 1: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(mediumWoundStitchTime));
        };
        case 2: {
            _time = _time + ((_amountOfWounds max 1) * GVAR(largeWoundStitchTime));
        };
    };
    !(_type in _unstitchableTypes) && !(_className in ["InternalBleeding", "Evisceration", "Thermal_Burn"])  && !(GVAR(allowCatastrophicWoundStitch) && _className in ["Avulsion", "VelocityWound", "Laceration"]);
};
TRACE_1("AmountOf",_amountOf);
_time