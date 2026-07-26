#include "..\script_component.hpp"
/*
 * Author: commy2, PabstMirror
 * Modified: Blue
 * Updates damage effects for limping and fractures.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_engine_fnc_updateDamageEffects
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];
if (!local _unit) exitWith { ERROR_2("updateDamageEffects: Unit not local or null [%1:%2]",_unit,typeOf _unit); };
private _lastTimeUpdated = _unit getVariable [QGVAR(lastTimeUDEUpdated), 0];
private _deltaT = (CBA_missionTime - _lastTimeUpdated) min 10;
if (_deltaT < 2) exitWith { false }; 
_unit setVariable [QGVAR(lastTimeUDEUpdated), CBA_missionTime];
private _isLimping = false;
private _hasLegSplint = false;
private _noSprint = false;
private _noJog = false;
private _noThrow = false;
private _noHurtThrow = false;
private _keepProne = false;
private _aimFracture = 0;
private _armJointArray = GET_JOINTS(_unit) select [0, 2];
private _legJointArray = GET_JOINTS(_unit) select [2, 2];
if (ACEGVAR(medical,fractures) > 0) then {
    private _fractures = GET_FRACTURES(_unit);
    TRACE_1("",_fractures);
    if ((_fractures select 8) > 0 || (_fractures select 9) > 0 || (_fractures select 10) > 0 || (_fractures select 11) > 0) then {
        TRACE_1("limping because of fracture",_fractures);
        _isLimping = true;
    };
    if ((_fractures select 4) > 0) then { _aimFracture = _aimFracture + 4;};
    if ((_fractures select 5) > 0) then { _aimFracture = _aimFracture + 4;};
    if ((_fractures select 6) > 0) then { _aimFracture = _aimFracture + 4;};
    if ((_fractures select 7) > 0) then { _aimFracture = _aimFracture + 4;};

    if (ACEGVAR(medical,fractures) in [2, 3]) then { // the limp with a splint will still cause effects
        // Block sprint / force walking based on fracture setting and leg splint status
        _hasLegSplint = (_fractures select 8) in [-1, -2, -3] || (_fractures select 9) in [-1, -2, -3] || (_fractures select 10) in [-1, -2, -3] || (_fractures select 11) in [-1, -2, -3];
        if (ACEGVAR(medical,fractures) == 2) then {
            _noSprint = _hasLegSplint;
        } else {
            _noJog = _hasLegSplint;
        };

        if ((_fractures select 4) in [-1, -2, -3]) then { _aimFracture = _aimFracture + 2;};
        if ((_fractures select 5) in [-1, -2, -3]) then { _aimFracture = _aimFracture + 2;};
        if ((_fractures select 6) in [-1, -2, -3]) then { _aimFracture = _aimFracture + 2;};
        if ((_fractures select 7) in [-1, -2, -3]) then { _aimFracture = _aimFracture + 2;};
    };
};
if (EGVAR(hitpoints,JointChance) > 0) then {
    {
        {if (_x > 0) then {_aimFracture = _aimFracture + 1};} forEach _x;
    } forEach _armJointArray;

    {
        {if (_x >=2) then {_aimFracture = _aimFracture + 3};} forEach _x;
    } forEach _armJointArray;

    {
        {if (_x >= 3) then {_aimFracture = _aimFracture + 6};} forEach _x;
    } forEach _armJointArray;

};

_unit setVariable [QACEGVAR(medical_engine,aimFracture), _aimFracture, false]; // local only var, used in ace_medical's postInit to set ACE_setCustomAimCoef
private _painSuppression = GET_PAIN_SUPPRESS(_unit);
if (!_isLimping && {ACEGVAR(medical,limping) > 0}) then {
    private _openWounds = GET_OPEN_WOUNDS(_unit);

    private _legWounds = (_openWounds getOrDefault ["leftleg", []])
        + (_openWounds getOrDefault ["upperleftleg", []])
        + (_openWounds getOrDefault ["rightleg", []])
        + (_openWounds getOrDefault ["upperrightleg", []]);

    if (ACEGVAR(medical,limping) == 2) then {
        private _bandagedWounds = GET_BANDAGED_WOUNDS(_unit);
        _legWounds = _legWounds
            + (_bandagedWounds getOrDefault ["leftleg", []])
            + (_bandagedWounds getOrDefault ["upperleftleg", []])
            + (_bandagedWounds getOrDefault ["rightleg", []])
            + (_bandagedWounds getOrDefault ["upperrightleg", []]);

        private _wrappedWounds = GET_WRAPPED_WOUNDS(_unit);
        _legWounds = _legWounds
            + (_wrappedWounds getOrDefault ["leftleg", []])
            + (_wrappedWounds getOrDefault ["upperleftleg", []])
            + (_wrappedWounds getOrDefault ["rightleg", []])
            + (_wrappedWounds getOrDefault ["upperrightleg", []]);

        private _coagWounds = GET_COAGED_WOUNDS(_unit);
        _legWounds = _legWounds
            + (_coagWounds getOrDefault ["leftleg", []])
            + (_coagWounds getOrDefault ["upperleftleg", []])
            + (_coagWounds getOrDefault ["rightleg", []])
            + (_coagWounds getOrDefault ["upperrightleg", []]);
    };

    {
        _x params ["_xClassID", "_xAmountOf", "", "_xDamage"];
        if (
            (_xAmountOf > 0)
            && {_xDamage > LIMPING_DAMAGE_THRESHOLD_DEFAULT}
            // select _causeLimping from woundDetails
            && {(ACEGVAR(medical_damage,woundDetails) get (floor (_xClassID / 10))) select 3}
        ) exitWith {
            TRACE_1("limping because of wound",_x);
            _isLimping = true;
        };
    } forEach _legWounds;
};

if (_unit getVariable [QGVAR(Tourniquet_LegNecrosis_Threshold), 0] >= 20) then {
    _noSprint = true;
};

if (_unit getVariable [QGVAR(Tourniquet_LegNecrosis_Threshold), 0] >= 60) then {
    _noJog = true;
};

if (_unit getVariable [QGVAR(Tourniquet_LegNecrosis_Threshold), 0] >= 90) then {
    _isLimping = true;
};
if (_unit getVariable [QEGVAR(hitpoints,evisceration), 0] > 0) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
};

if ((_unit getVariable [QEGVAR(hitpoints,pelvicFracture), 0]) > 0) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
    _keepProne = true;
};

if ((_unit getVariable [QEGVAR(hitpoints,pelvicFracture), 0]) < 0) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
};



private _hasLegDislocationInjury = _legJointArray findIf {_x findIf {_x == 4} != -1} != -1;
private _hasLegJointInjury = _legJointArray findIf {_x findIf {((_x >= 1) && (_x < 2))} != -1} != -1;
private _hasLegSprainInjury = _legJointArray findIf {_x findIf {((_x > 0) && (_x < 1))} != -1} != -1;
private _hasLegStrainInjury = _legJointArray findIf {_x findIf {((_x >= 2) && (_x < 3))} != -1} != -1;
private _hasArmDislocationInjury = _armJointArray findIf {_x findIf {_x == 4} != -1} != -1;
private _hasArmJointInjury = _armJointArray findIf {_x findIf {_x != 0} != -1} != -1;
TRACE_7("HasInjury",_hasLegSprainInjury,_hasLegStrainInjury,_hasLegDislocationInjury,_hasArmDislocationInjury,_hasArmJointInjury,_legJointArray,_armJointArray);

if (_hasLegStrainInjury && (_painSuppression >= 0.4)) then {};
if (_hasLegStrainInjury && (_painSuppression < 0.4)) then {
    _noSprint = true;
};
if (_hasLegJointInjury && (_painSuppression >= 0.4)) then {
    _noSprint = true;
};
if (_hasLegJointInjury && (_painSuppression < 0.4)) then {
    _noSprint = true;
    _noJog = true;
};

if (_hasLegSprainInjury && (_painSuppression >= 0.4)) then {
    _noSprint = true;
    _noJog = true;
};
if (_hasLegSprainInjury && (_painSuppression < 0.4)) then {
    _noSprint = true;
    _noJog = true;
    _isLimping = true;
};

if (_hasLegDislocationInjury) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
    _keepProne = true;
};


if (_hasArmDislocationInjury) then {
    _noThrow = true;
};

if (_hasArmJointInjury) then {
    _noHurtThrow = true;
};

if ((_unit getVariable [QEGVAR(surgery,reboa), [false, false]]) select 0) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
};
if ((_unit getVariable [QEGVAR(surgery,reboa), [false, false]]) select 1) then {
    _isLimping = true;
    _noJog = true;
    _noSprint = true;
};

[_unit, "blockSprint", QACEGVAR(medical,fracture), _noSprint] call ACEFUNC(common,statusEffect_set);
[_unit, "forceWalk", QACEGVAR(medical,fracture), _noJog] call ACEFUNC(common,statusEffect_set);
[_unit, "blockThrow", QEGVAR(hitpoints,joints), _noThrow] call ACEFUNC(common,statusEffect_set);
_unit setVariable [QACEGVAR(medical,isLimping), _isLimping, true];
_unit setVariable [QEGVAR(hitpoints,cantThrowJoints), _noHurtThrow, true];
if (_keepProne && !(IS_UNCONSCIOUS(_unit)) && (lifeState _unit != "INCAPACITATED") && (isPlayer _unit)) then {
    if (stance _unit != "PRONE") then {
        _unit setUnconscious true;
        [{
            params ["_unit"];
            _unit setUnconscious false;
            [{
            params ["_unit"];
            TRACE_3("after delay",_unit,animationState _unit,lifeState _unit);
            if (!alive _unit) exitWith {};
            // Fix unit being in locked animation with switchMove (If unit was unloaded from a vehicle, they may be in deadstate instead of unconscious)
            private _animation = animationState _unit;
            if ((_animation == "unconscious" || {_animation == "deadstate" || {_animation find QGVAR(uncon_anim) != -1}}) && {lifeState _unit != "INCAPACITATED"}) then {
                [_unit, "AmovPpneMstpSnonWnonDnon", 2] call ACEFUNC(common,doAnimation);
                TRACE_1("forcing SwitchMove",animationState _unit);
            };
        }, _unit, 0.5] call CBA_fnc_waitAndExecute;
        }, [_unit], 3] call CBA_fnc_waitAndExecute;
    };
};

// refresh
private _isDamaged = _unit getHitPointDamage "HitLegs" >= 0.45 && {_unit getHitPointDamage "HitLegs" != 0.5};
[_unit, "Legs", _isDamaged] call ACEFUNC(medical_engine,damageBodyPart);
