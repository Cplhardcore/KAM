#include "..\script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Mazinski
 * Open PulseOx View Monitor
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget, 1] call kat_circulation_fnc_PulseOx_ViewMonitor.sqf;
 *
 * Public: No
 */

params ["_medic", "_target"];

private _dlg = uiNamespace getVariable ["kat_capno", displayNull];

[{
    params ["_args", "_idPFH"];
    _args params ["_dlg", "_target"];

    if !(GVAR(CapnographDisplay)) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };

    (_dlg displayCtrl 22806) ctrlSetText (format["%1", round(GET_ETCO2(_target))]);
    (_dlg displayCtrl 22809) ctrlSetText (format["%1", round(GET_BREATHING_RATE(_target))]);
}, 1, [_dlg, _target]] call CBA_fnc_addPerFrameHandler;