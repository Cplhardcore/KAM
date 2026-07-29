#include "..\script_component.hpp"
/*
 * Author: Katalam, edited by MiszczuZPolski, Miss Heda & apo_tle
 * Airway Management for collapsing local
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Treatment classname <STRING>
 * 3: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget, "Larynxtubus", "kat_larynx"] call kat_airway_fnc_treatmentAdvanced_airwayLocal;
 *
 * Public: No
 */
params ["_medic", "_patient"];

private _canPlace = (_patient getVariable [QGVAR(capnographConnected), false]);
_canPlace