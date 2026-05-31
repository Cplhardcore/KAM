#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Local call for applying REBOA.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, cursorObject] call kat_surgery_fnc_reboaApplyLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];
[_medic, _patient, "UpperRightLeg"] call EFUNC(pharma,tourniquetRemove);
[_medic, _patient, "UpperLeftLeg"] call EFUNC(pharma,tourniquetRemove);
private _tourniquets = GET_KAT_TOURNIQUETS(_patient);
private _katTourniquets = GET_KAT_TOURNIQUETS(_patient);
private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _surgicalBlock = GET_SURGICAL_TOURNIQUETS(_patient);
private _reboaStatus = _patient getVariable [QGVAR(reboa), [false, false]];
_tourniquets set [9, CBA_missionTime];
_katTourniquets set [9, 1];
_surgicalBlock set [9, 1];
_tourniquets set [11, CBA_missionTime];
_katTourniquets set [11, 1];
_surgicalBlock set [11, 1];
if (_partIndex == 9) then {
    _reboaStatus set [0, true];
} else {
    _reboaStatus set [1, true];
};

_patient setVariable [VAR_KAT_TOURNIQUET, _katTourniquets, true];
_patient setVariable [VAR_TOURNIQUET, _tourniquets, true];
_patient setVariable [QGVAR(surgicalBlock), _surgicalBlock, true];
_patient setVariable [QGVAR(reboa), _reboaStatus, true];
private _imaging = _patient getVariable [QGVAR(imaging), [0,0,0,0,0,0,0,0,0,0,0,0]];
_imaging set [_partIndex, 0];
_patient setVariable [QGVAR(imaging), _imaging, true];


[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);

[_patient] call EFUNC(misc,updateDamageEffects);

private _nearPlayers = (_patient nearEntities ["CAManBase", 6]) select {_x call ACEFUNC(common,isPlayer)};
TRACE_1("clearConditionCaches: tourniquetLocal",_nearPlayers);
[QACEGVAR(interact_menu,clearConditionCaches), [], _nearPlayers] call CBA_fnc_targetEvent;