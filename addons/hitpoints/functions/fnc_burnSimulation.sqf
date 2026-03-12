#include "..\script_component.hpp"
/*
 * Author: tcvm, johnb43
 * Simulates fire intensity over time on burning units.
 * Arbitrary values to ignite people. Assumed maximum is "10".
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Instigator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, player] call ace_fire_fnc_burnSimulation
 *
 * Public: No
 */

params ["_unit", "_instigator"];

[{
    params ["_args", "_pfhID"];
    _args params ["_unit", "_instigator"];

    if (isNull _unit) exitWith {
        TRACE_1("unit is null",_unit);

        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    // Locality has changed
    if (!local _unit) exitWith {
        TRACE_1("unit is no longer local",_unit);

        _pfhID call CBA_fnc_removePerFrameHandler;

        [QACEGVAR(fire,burnSimulation), [_unit, _instigator], _unit] call CBA_fnc_targetEvent;
    };

    // If the unit is invulnerable, in water or if the fire has died out, stop burning the unit
    if (
        !(_unit call ACEFUNC(fire,isBurning)) ||
        {!(isDamageAllowed _unit && {_unit getVariable [QACEGVAR(medical,allowDamage), true]})} ||
        {private _eyePos = eyePos _unit; surfaceIsWater _eyePos && {(_eyePos select 2) < 0.1}}
    ) exitWith {
        TRACE_3("unit is no longer burning, invulnerable or in water",_unit,_unit call FUNC(isBurning),isDamageAllowed _unit && {_unit getVariable [ARR_2(QACEGVAR(medical,allowDamage),true)]});

        // Remove global effects
        (_unit getVariable [QACEGVAR(fire,jipID), ""]) call CBA_fnc_removeGlobalEventJIP;

        // Update globally that the unit isn't burning anymore
        _unit setVariable [QACEGVAR(fire,intensity), nil, true];

        _pfhID call CBA_fnc_removePerFrameHandler;

        if (!isNil {_unit getVariable QACEGVAR(fire,stopDropRoll)} && {!isPlayer _unit}) then {
            _unit setUnitPos "AUTO";

            _unit setVariable [QACEGVAR(fire,stopDropRoll), nil, true];
        };
    };

    if (isGamePaused) exitWith {};

    private _intensity = _unit getVariable [QACEGVAR(fire,intensity), 0];

    // Propagate fire to other units (alive or dead) if it's intense
    if (_intensity >= BURN_THRESHOLD_INTENSE) then {
        TRACE_2("check for other units",_unit,_intensity);

        {
            private _distancePercent = 1 - ((_unit distance _x) / BURN_PROPAGATE_DISTANCE);
            private _adjustedIntensity = _intensity * _distancePercent;

            // Don't burn if intensity is too low or already burning with higher intensity
            if (BURN_MIN_INTENSITY > _adjustedIntensity || {(_x getVariable [QACEGVAR(fire,intensity), 0]) > _adjustedIntensity}) then {
                continue;
            };

            [QACEGVAR(fire,burn), [_x, _adjustedIntensity, _instigator], _x] call CBA_fnc_targetEvent;

            TRACE_3("propagate fire",_x,_intensity,_adjustedIntensity);
        } forEach nearestObjects [_unit, ["CAManBase"], BURN_PROPAGATE_DISTANCE];
    };

    // Update intensity/fire reactions
    if (CBA_missionTime >= _unit getVariable [QACEGVAR(fire,intensityUpdate), 0]) then {
        TRACE_2("update intensity",_unit,_intensity);

        _unit setVariable [QACEGVAR(fire,intensityUpdate), CBA_missionTime + INTENSITY_UPDATE];

        _intensity = _intensity - INTENSITY_LOSS - (rain / 10);

        if (_unit call ACEFUNC(common,isAwake)) then {
            if (_unit call ACEFUNC(common,isPlayer)) then {
                // Decrease intensity of burn if rolling around
                if ((animationState _unit) in PRONE_ROLLING_ANIMS) then {
                    _intensity = _intensity * INTENSITY_DECREASE_MULT_ROLLING;
                };
            } else {
                private _sdr = _unit getVariable [QACEGVAR(fire,stopDropRoll), false];

                private _vehicle = objectParent _unit;

                if (isNull _vehicle && {_sdr || {0.05 > random 1}}) then {
                    _unit setVariable [QACEGVAR(fire,stopDropRoll), true, true];

                    if (!_sdr) then {
                        TRACE_1("stop, drop, roll!",_unit);

                        _unit setUnitPos "DOWN";
                        doStop _unit;
                    };

                    // Queue up a bunch of animations
                    for "_i" from 0 to 2 do {
                        [_unit, selectRandom ["amovppnemstpsnonwnondnon_amovppnemevasnonwnondl", "amovppnemstpsnonwnondnon_amovppnemevasnonwnondr"], 0] call EFUNC(common,doAnimation);
                    };

                    _intensity = _intensity - (1 / _intensity);
                } else {
                    // Make the unit leave the vehicle
                    if (_vehicle != _unit) then {
                        TRACE_1("Ejecting",_unit);

                        _unit leaveVehicle _vehicle;
                        unassignVehicle _unit;

                        _unit action ["Eject", _vehicle];
                    };

                    _unit disableAI "TARGET";
                    _unit disableAI "AUTOTARGET";

                    // Run away, erraticly
                    if (leader group _unit != _unit) then {
                        [_unit] join grpNull;
                    };

                    _unit doMove ((getPosATL _unit) getPos [20 + random 35, floor (random 360)]);
                    _unit setSpeedMode "FULL";
                    _unit setSuppression 1;
                };
            };

            // Play screams and throw weapon (if enabled)
            _unit call ACEFUNC(fire,burnReaction);
        };

        // Keep pain around unconsciousness limit to allow for more fun interactions
        private _painPercieved = (0 max ((_unit getVariable [QACEGVAR(medical,pain), 0]) - (_unit getVariable [QACEGVAR(medical,painSuppress), 0])) min 1);
        private _painUnconscious = missionNamespace getVariable [QACEGVAR(medical,painUnconsciousThreshold), 0];
        private _damageToAdd = [0.15, _intensity / BURN_MAX_INTENSITY] select (!alive _unit || {_painPercieved < _painUnconscious + random 0.2});

        _damageToAdd = _damageToAdd * (1 - (getNumber (configFile >> "CfgWeapons" >> uniform _unit >> QACEGVAR(fire,protection))));
        if (!isNull _instigator) then {
            _unit setVariable [QACEGVAR(medical,lastDamageSource), _instigator];
            _unit setVariable [QACEGVAR(medical,lastInstigator), _instigator];
        };
        
        {// Use event directly, as ace_medical_fnc_addDamageToUnit requires unit to be alive
            [QACEGVAR(medical,woundReceived), [_unit, [[_damageToAdd, _x, _damageToAdd]], _instigator, "burn"]] call CBA_fnc_localEvent;
        } forEach ALL_BODY_PARTS;

        _unit setVariable [QACEGVAR(fire,intensity), _intensity, true]; // Globally sync intensity across all clients to make sure simulation is deterministic
    };
}, BURN_PROPAGATE_UPDATE, [_unit, _instigator]] call CBA_fnc_addPerFrameHandler;