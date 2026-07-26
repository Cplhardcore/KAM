#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Called when a unit is damaged.
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Damage done to each body part <ARRAY>
 *    0: Engine damage <NUMBER>
 *    1: Body part <STRING>
 *    2: Real damage <NUMBER>
 * 2: Damage type (unused) <STRING>
 * 3: Ammo (unused) <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, [1, "Body", 2], "bullet", "B_556x45_Ball"] call kat_breathing_fnc_woundsHandlerJoints
 *
 * Public: No
 */

params ["_unit", "_allDamages", "_damageType"];

{
    _x params ["_damage", "_bodyPart"];

    private _fixedBodyPart = toLower _bodyPart;

    if !(GVAR(CatastrophicEnable) && !(_fixedBodyPart in ["head", "neck", "chest", "body"])) then {
        TRACE_1("NotEnable",_fixedBodyPart);
    } else {
        private _chanceIncrease = 0;
        if (GVAR(JointDamageThreshold_TakenDamage)) then {
            _chanceIncrease = linearConversion [GVAR(JointDamageThreshold), 3, _damage, 0, 30, true];
            TRACE_1("chanceIncrease",_chanceIncrease);
        };
        TRACE_3("WHJoints1",_unit,_chance,_chanceIncrease);

        if (floor (random 100) < (GVAR(JointChance) + _chanceIncrease)) then {
            private _partIndex = ALL_BODY_PARTS find _fixedBodyPart;
            private _jointArray = GET_JOINTS(_unit);
            private _jointGroupIndex = switch (true) do {
                case (_partIndex in [4, 5]): { 0 };
                case (_partIndex in [6, 7]): { 1 };
                case (_partIndex in [8, 9]): { 2 };
                case (_partIndex in [10, 11]): { 3 };
                default { -1 };
            };
            TRACE_2("WHJoints3",_partIndex,_jointGroupIndex);
            private _wrappedArray = GET_WRAPPED_JOINTS(_unit);
            private _icepackArray = GET_ICEPACKS(_unit);
            if (_jointGroupIndex >= 0) then {
                private _limbJointStatus = _jointArray select _jointGroupIndex;
                private _jointNumber = selectRandom [0,1,2];
                private _jointInjury = _limbJointStatus select _jointNumber;
                if (_jointInjury == 0) then {
                    if (_damage <= 4) then {
                        _jointInjury = linearConversion [0, 4, _damage, 0.5, 2.9, true];
                        _jointInjury = (_jointInjury + random [ -0.5, 0, 1]) min 0.4; 
                        _limbJointStatus set [_jointNumber, _jointInjury];
                    } else {
                        _jointInjury = 4;
                        _limbJointStatus set [_jointNumber, _jointInjury];
                    };
                    _limbJointStatus set [_jointNumber, _jointInjury];
                    _jointArray set [_jointGroupIndex, _limbJointStatus];
                    private _icepackStatus = _icepackArray select _jointGroupIndex;
                    private _wrappedStatus = _wrappedArray select _jointGroupIndex;
                    _icepackStatus set [_jointNumber, 0];
                    _wrappedStatus set [_jointNumber, 0];
                    _icepackArray set [_jointGroupIndex, _icepackStatus];
                    _wrappedArray set [_jointGroupIndex, _wrappedStatus];
                    _unit setVariable [VAR_JOINTS, _jointArray, true];
                    _unit setVariable [VAR_ICEPACKS, _icepackArray, true];
                    _unit setVariable [VAR_WRAPPED_JOINTS, _wrappedArray, true];
                    private _pain = linearConversion [0, 4, _jointInjury, 0, 0.8, true];
                    [_unit, _pain] call ACEFUNC(medical_status,adjustPainLevel);
                    TRACE_3("WHJoints4",_limbJointStatus,_jointInjury,_jointNumber);
                    if ((random 100) > 20) exitWith {_this};
                };
            };
        };
    };
} forEach _allDamages;

_this // Final return