#include "..\script_component.hpp"
/*
 * Author: YetheSamartaka
 * Ensures proper initial values reset on respawn
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Corpse <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [alive, body] call kat_misc_fnc_handleRespawn;
 *
 * Public: No
 */

params ["_unit"];
    
if !(_unit getVariable [QGVAR(pulseoximeter), false]) exitWith {
    [_unit, "quick_view", LSTRING(pulseoxi_Log)] call EFUNC(circulation,removeLog);
};
private _HR = GET_HEART_RATE(_unit);
private _SpO2 = GET_KAT_SPO2(_unit);
private _attachedPulseOximeter = _unit getVariable [QGVAR(PulseOximeter_Attached), [0,0]];

private _bodyPartN = [6, 4] select ((_attachedPulseOximeter select 0) > 0);
private _isOccluded = [_unit,_bodyPartN] call EFUNC(pharma,occlusionCheck);
private _isDamaged = [_unit,_bodyPartN] call EFUNC(hitpoints,damageCheck);
if (_isOccluded || _isDamaged) then {
    _HR = 0;
    _SpO2 = 0;
};
if(_unit getVariable [QGVAR(PulseOximeter_VolumePatient), false] && _SpO2 < GVAR(PulseOximeter_SpO2Warning)) then {
    playSound3D [QPATHTOF_SOUND(audio\pulseoximeter_warning.wav), _unit, false, getPosASL _unit, 4, 1, 15];
};
[_unit, "quick_view", LSTRING(pulseoxi_Log)] call EFUNC(circulation,removeLog);
[_unit, "quick_view", LSTRING(pulseoxi_Log), [round _HR, round _SpO2]] call ACEFUNC(medical_treatment,addToLog);