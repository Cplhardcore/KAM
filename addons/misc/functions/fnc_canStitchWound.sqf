#include "..\script_component.hpp"
/*
 * Author: cplhardcore
 * Checks if the patient can be stitched.
 *
 * Arguments:
 * 0: wound 
 *
 * ReturnValue:
 * Can Stitch <BOOL>
 *
 * Example:
 * [player, cursorTarget] call kat_misc_fnc_canStitchFullBody
 *
 * Public: No
 */

params ["_unit", "_wound"];

_wound params ["_classID", "", "", "", "_type"];

private _classIndex = _classID / 10;
private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;

private _unstitchableTypes = ["ETD", "Israeli_Bandage"];
if (_className in ["InternalBleeding","Evisceration","Thermal_Burn"]) exitWith {false};
private _allow = switch (GVAR(allowAdvancedStitching)) do {
    case 0: {true};
    case 1: {
        IN_MED_VEHICLE(_unit)
    };
    case 2: {
        IN_MED_FACILITY(_unit)
    };
    case 3: {
        IN_MED_VEHICLE(_unit) || {IN_MED_FACILITY(_unit)}
    };
    default {false};
};
if (!_allow && {_className in ["Avulsion","VelocityWound","Laceration"]}) exitWith {false};

if (_type in _unstitchableTypes) exitWith {false};

true