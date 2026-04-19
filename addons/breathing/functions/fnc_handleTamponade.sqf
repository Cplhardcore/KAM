#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Called when an effusion starts
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_breathing_fnc_createTamponade
 *
 * Public: No
 */
params ["_unit", "_deltaT"];
private _time = _unit getVariable [QGVAR(tamponadeTime), 0, true];
_unit setVariable [QGVAR(tamponadeTime), _time + _deltaT, true];
if (5 > _time) exitWith {};
_unit setVariable [QGVAR(tamponadeTime), 0, true];

private _effusion = _unit getVariable [QEGVAR(circulation,effusion), 0];
// If patient is dead, already treated or has already deteriorated into full tamponade, kill the PFH
if ((_effusion == 0) || (_effusion == 4)) exitWith {};
if (floor (random 100) <= EGVAR(circulation,deterioratingTamponade_chance)) then {
    private _effusionTarget = _effusion + 1;
    // Once deteriorated far enough try to inflict tamponade
    if (_effusionTarget == 4) exitWith {
        private _ht = _unit getVariable [QEGVAR(circulation,ht), []];
        if ((_ht findIf {_x isEqualTo "tamponade"}) == -1) then {
            _ht pushBack "tamponade";
            if (_unit getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
                [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
            };
            _unit setVariable [QEGVAR(circulation,ht), _ht, true];
        };
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
    _unit setVariable [QEGVAR(circulation,effusion), _effusionTarget, true];
    [_unit, 0.5 * (_effusionTarget / 4)] call ACEFUNC(medical_status,adjustPainLevel); // Adjust pain based on severity
};