#include "..\script_component.hpp"
/*
 * Author: Dslyecxi, Jonpas
 * Throw selected throwable.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * unit call ace_advanced_throwing_fnc_throw
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("params",_unit);

// Prime the throwable if it hasn't been cooking already
// Next to proper simulation this also has to happen before delay for orientation of the throwable to be set
if !(_unit getVariable [QACEGVAR(advanced_throwing,primed), false]) then {
    [_unit] call ACEFUNC(advanced_throwing,prime);
};

[_unit, "ThrowGrenade"] call ACEFUNC(common,doGesture);

// Pass position to reset later because animation may change it in certain stances
private _dropMode = _unit getVariable [QACEGVAR(advanced_throwing,dropMode), false];
[{
    params ["_unit", "_activeThrowable", "_posThrown", "_throwMod", "_throwSpeed", "_dropMode"];
    TRACE_6("delayParams",_unit,_activeThrowable,_posThrown,_throwMod,_throwSpeed,_dropMode);

    // Reset position in case animation changed it
    _activeThrowable setPosASL _posThrown;

    // Launch actual throwable
    private _direction = vectorLinearConversion [THROW_MODIFER_MIN, THROW_MODIFER_MAX, _throwMod, THROWSTYLE_HIGH_DIR, THROWSTYLE_NORMAL_DIR, true];
    private _velocity = linearConversion [THROW_MODIFER_MIN, THROW_MODIFER_MAX, _throwMod, _throwSpeed / THROWSTYLE_HIGH_VEL_COEF / 1.2, _throwSpeed, true];
    _velocity = [_velocity, THROWSTYLE_DROP_VEL] select _dropMode;

    private _p2 = (eyePos _unit) vectorAdd (AGLToASL (positionCameraToWorld _direction)) vectorDiff (AGLToASL (positionCameraToWorld [0, 0, 0]));
    private _p1 = _activeThrowable modelToWorldVisualWorld [0, 0, 0];

    private _newVelocity = (_p1 vectorFromTo _p2) vectorMultiply _velocity;

    // Adjust for throwing from inside vehicles, where we have a vehicle-based velocity that can't be compensated for by a human
    if (!isNull objectParent _unit) then {
        _newVelocity = _newVelocity vectorAdd (velocity (vehicle _unit));
    };
    private _joint = GET_JOINTS(_unit);
    private _armArrays = (_joint select 0) + (_joint select 1);
    if ((selectMax _armArrays) > 0) then {
        private _injury = linearConversion [0.3, 2.9, (selectMax _armArrays), 1, 3, true];
        private _strengthVariance = _injury * 0.1;
        private _strengthFactor = linearConversion [1, 3, _injury, 0.85, 0.4, true];
        _newVelocity = _newVelocity vectorMultiply _strengthFactor;
        _newVelocity = _newVelocity vectorMultiply (1 + random (_strengthVariance * 2) - _strengthVariance);
        private _spread = 0.05 * _injury;
        private _dir = _p1 vectorFromTo _p2;

        _dir = vectorNormalized (
            _dir vectorAdd [
                random (_spread * 2) - _spread,
                random (_spread * 2) - _spread,
                random (_spread * 2) - _spread
            ]
        );

        private _speed = vectorMagnitude _newVelocity;
        _newVelocity = _dir vectorMultiply _speed;
    };

    // Calculate torque of thrown grenade
    private _config = configOf _activeThrowable;
    private _torqueDir = getArray (_config >> QACEGVAR(advanced_throwing,torqueDirection));
    _torqueDir = if (_torqueDir isEqualTypeArray [0,0,0]) then { vectorNormalized _torqueDir } else { [0,0,0] };
    private _torqueMag = getNumber (_config >> QACEGVAR(advanced_throwing,torqueMagnitude));

    if (_dropMode) then {
        _torqueMag = _torqueMag * THROWSTYLE_DROP_TORQUE_COEF;
    } else {
        _torqueMag = _torqueMag * linearConversion [THROW_MODIFER_MIN, THROW_MODIFER_MAX, _throwMod, THROWSTYLE_HIGH_TORQUE_COEF, 1];
    };

    private _torque = _torqueDir vectorMultiply _torqueMag;
    
    private _chance = linearConversion [0.3, 2.9, (selectMax _armArrays), 0, 15, true];
    // Drop if unit dies during throw process
    if ((alive _unit) || ((random 100) > _chance)) then {
        _activeThrowable setVelocity _newVelocity;
        _activeThrowable addTorque (_unit vectorModelToWorld _torque);
    } else {
        [LELSTRING(hitpoints,droppedGrenade), 3, _unit, 10] call ACEFUNC(common,displayTextStructured);
    };
    // Invoke listenable event
    ["ace_throwableThrown", [_unit, _activeThrowable]] call CBA_fnc_localEvent;
}, [
    _unit,
    _unit getVariable [QACEGVAR(advanced_throwing,activeThrowable), objNull],
    getPosASLVisual (_unit getVariable [QACEGVAR(advanced_throwing,activeThrowable), objNull]),
    [ACE_player getVariable [QACEGVAR(advanced_throwing,throwMod), THROW_MODIFER_DEFAULT], THROW_MODIFER_MIN] select _dropMode,
    _unit getVariable [QACEGVAR(advanced_throwing,throwSpeed), THROW_SPEED_DEFAULT],
    _dropMode
], 0.3] call CBA_fnc_waitAndExecute;


#ifdef DRAW_THROW_PATH
ACEGVAR(advanced_throwing,predictedPath) = call ACEFUNC(advanced_throwing,drawArc); // Save the current throw arc
ACEGVAR(advanced_throwing,flightPath) = [];
ACEGVAR(advanced_throwing,flightRotation) = [];
(_unit getVariable QACEGVAR(advanced_throwing,activeThrowable)) spawn {
    while {!isNull _this && {(getPosATL _this) select 2 > 0.05}} do {
        ACEGVAR(advanced_throwing,flightPath) pushBack [ASLToAGL (getPosASL _this), vectorUp _this];
        sleep 0.05;
    };
};
#endif


// Stop rendering arc and doing rendering magic while throw is happening
[_unit, "Completed a throw fully"] call ACEFUNC(advanced_throwing,exitThrowMode);