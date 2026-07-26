#include "..\script_component.hpp"
/*
 * Author: Dslyecxi, Jonpas
 * Prepares throwable or selects the next.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call ace_advanced_throwing_fnc_prepare
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("params",_unit);

// Select next throwable if one already in hand
if (_unit getVariable [QACEGVAR(advanced_throwing,inHand), false]) exitWith {
    TRACE_1("inHand",_unit);
    if !(_unit getVariable [QACEGVAR(advanced_throwing,primed), false]) then {
        TRACE_1("not primed",_unit);
        // Restore muzzle ammo (setAmmo has no impact if no applicable throwable in inventory)
        // selectNextGrenade relies on muzzles array (setAmmo 0 removes the muzzle from the array and current can't be found, cycles between 0 and 1 muzzles)
        ACE_player setAmmo (ACE_player getVariable [QACEGVAR(advanced_throwing,activeMuzzle), ["", -1]]);
        [_unit] call ACEFUNC(weaponselect,selectNextGrenade);
    };
};

// Try selecting next throwable if none currently selected
if (isNull (_unit getVariable [QACEGVAR(advanced_throwing,activeThrowable), objNull]) && {(currentThrowable _unit) isEqualTo []} && {!([_unit] call ACEFUNC(weaponselect,selectNextGrenade))}) exitWith {
    TRACE_1("no throwables",_unit);
};

// Temporarily enable wind info, to aid in throwing smoke grenades effectively
if (ACEGVAR(advanced_throwing,enableTempWindInfo) && {!(missionNamespace getVariable [QACEGVAR(weather,WindInfo), false])}) then {
    [] call ACEFUNC(weather,displayWindInfo);
    ACEGVAR(advanced_throwing,tempWindInfo) = true;
};

_unit setVariable [QACEGVAR(advanced_throwing,inHand), true];
private _joint = GET_JOINTS(_unit);
private _armArrays = (_joint select 0) + (_joint select 1);
private _fractures = _unit getVariable [QACEGVAR(medical_engine,aimFracture), 0];
if (((selectMax _armArrays) > 0) || (_fractures > 0)) then {
    [LELSTRING(hitpoints,armThrowHurt), 3, _unit, 10] call ACEFUNC(common,displayTextStructured);
};

// Add controls hint
call ACEFUNC(advanced_throwing,updateControlsHint);

// Add throw action to suppress weapon firing (not possible to suppress mouseButtonDown event)
_unit setVariable [QACEGVAR(advanced_throwing,throwAction), [_unit, "DefaultAction", {true}, {true}] call ACEFUNC(common,addActionEventHandler)];

// Draw throwable and throw arc if enabled
ACEGVAR(advanced_throwing,draw3DHandle) = addMissionEventHandler ["Draw3D", {
    call ACEFUNC(advanced_throwing,drawThrowable);
    if (ACEGVAR(advanced_throwing,showThrowArc)) then {
        call ACEFUNC(advanced_throwing,drawArc);
    };
}];