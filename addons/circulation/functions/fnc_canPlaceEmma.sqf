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

private _airways = ["Larynxtubus", "IGEL", "ETT", "Surgical_Airway"];
private _adjunct = _patient getVariable [QEGVAR(airway,airway_item), ""];
private _hasAppropriateAdjunct = _adjunct in _airways;
private _canPlace =
    _hasAppropriateAdjunct &&
    !(_patient getVariable [QGVAR(capnographConnected), false]);
TRACE_4("EMMA",_hasAppropriateAdjunct,_canPlace,_patient,_adjunct);
_canPlace