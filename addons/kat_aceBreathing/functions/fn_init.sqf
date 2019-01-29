/*
 * Author: Katalam
 * Initializes unit variables.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [bob] call kat_aceBreathing_fnc_init
 *
 * Public: No
 */

params ["_unit"];

_unit setVariable ["kat_aceBreathing_pulseoximeter", false, true];
_unit setVariable ["kat_aceBreathing_pulmo", false, true];
_unit setVariable ["kat_aceBreathing_old_values", [80,100], true];
// ace_medical_airwayStatus - oxygen saturation
