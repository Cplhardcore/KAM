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

params ["_wound"];

_wound params ["_classID", "", "", "", "_type"];

private _classIndex = _classID / 10;
private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;

private _unstitchableTypes = ["ETD", "Israeli_Bandage"];

private _allow = GVAR(allowAdvancedStitching);

if (!_allow && {_className in ["Avulsion","VelocityWound","Laceration"]}) exitWith {false};

if (_type in _unstitchableTypes) exitWith {false};

if (_className in ["InternalBleeding","Evisceration","Thermal_Burn"]) exitWith {false};

true