#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Local call for applying Deep REBOA.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, cursorObject] call kat_surgery_fnc_reboaDeepApplyLocal
 *
 * Public: No
 */

params ["_medic", "_patient"];

private _tourniquets = GET_KAT_TOURNIQUETS(_patient);
private _katTourniquets = GET_KAT_TOURNIQUETS(_patient);
private _surgicalBlock = GET_SURGICAL_TOURNIQUETS(_patient);

_tourniquets set [3, CBA_missionTime];
_patient setVariable [VAR_TOURNIQUET, _tourniquets, true];
_katTourniquets set [3, 1];
_patient setVariable [VAR_KAT_TOURNIQUET, _katTourniquets, true];
_surgicalBlock set [3, 1];
_patient setVariable [QGVAR(surgicalBlock), _surgicalBlock, true];

private _imaging = _patient getVariable [QGVAR(imaging), [0,0,0,0,0,0,0,0,0,0,0,0]];
_imaging set [9, 0];
_imaging set [11, 0];
_patient setVariable [QGVAR(imaging), _imaging, true];

[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);

private _nearPlayers = (_patient nearEntities ["CAManBase", 6]) select {_x call ACEFUNC(common,isPlayer)};
TRACE_1("clearConditionCaches: tourniquetLocal",_nearPlayers);
[QACEGVAR(interact_menu,clearConditionCaches), [], _nearPlayers] call CBA_fnc_targetEvent;