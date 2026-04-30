#include "..\script_component.hpp"
/*
 * Author: 2LT.Mazinski
 * Local function for EACA treatment
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_patient, "LeftArm"] call kat_pharma_fnc_treatmentAdvanced_EACALocal;
 *
 * Public: No
 */

params ["_patient", "_bodyPart", "_timeTillMaxEffect", "_timeInSystem"];

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVactual = _IVarray select _partIndex;
private _IVStatusArray = _patient getVariable [QGVAR(IVStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVStatusActual = _IVStatusArray select _partIndex;
private _eacaEffectiveness = [_patient, "EACA", false] call ACEFUNC(medical_status,getMedicationCount) select 1;
private _allowStack = missionNamespace getVariable [QGVAR(allowStackScript_EACA), true];
private _keepRunning = missionNamespace getVariable [QGVAR(keepScriptRunning_EACA), false];
private _cycleTime = missionNamespace getVariable [QGVAR(bandageCycleTime_EACA), 5];

if (([2,3,4] find _IVactual > 0)) then {
    private _randomNumber = random 100;
    if (_randomNumber < GVAR(blockChance)) then {
        [{
            params ["_args", "_idPFH"];
            _args params ["_patient", "_IVStatusArray", "_partIndex", "_IVStatusActual"];
            if !(alive _patient) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            private _IVStatusArray = _patient getVariable [QGVAR(IVStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
            private _IVStatusActual = _IVStatusArray select _partIndex;
            if (_IVStatusActual >= 1) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            if ((random 6) >= 3) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };
            _IVStatusArray set [_partIndex, ((_IVStatusActual + (random [0.01, 0.1, 0.2])) min 1)];
            _patient setVariable [QGVAR(IVStatus), _IVStatusArray, true];
        }, 15, [_patient, _IVStatusArray, _partIndex, _IVStatusActual]] call CBA_fnc_addPerFrameHandler;
    };
};


private _fnc_eacaClot = {
    params ["_patient", "_bodyPart", "_id", "_amount", "_bleeding", "_damage", "_delay", "_oldBandage", "_newBandage"];
    [{
    params ["_patient", "_bodyPart", "_id", "_amount", "_bleeding", "_damage", "_oldBandage", "_newBandage"];
    if !(alive _patient) exitWith {};
    private _coagWoundsLive = GET_COAGED_WOUNDS(_patient);
    private _currentWounds  = _coagWoundsLive getOrDefault [_bodyPart, []];
    private _minorIndex = -1;
    private _minorWound = -1;
    {
        _x params ["_idW", "_amount", "_bleeding", "_damage", "_bandage", "_time"];
        if ((_bandage isEqualTo _oldBandage) && (_idW isEqualTo _id)) exitWith {
            _minorIndex = _forEachIndex;
            _minorWound = _x;
        };
    } forEach _currentWounds;

    if (_minorIndex == -1) exitWith {};
    _minorWound params ["_id", "_amount", "_bleeding", "_damage", "_bandage", "_time"];
    _currentWounds deleteAt _minorIndex;
    private _newWound = [_id, _amount, _bleeding, _damage, _newBandage, CBA_missionTime];
    _currentWounds pushBack _newWound;
    _coagWoundsLive set [_bodyPart, _currentWounds];
    _patient setVariable [VAR_COAGED_WOUNDS, _coagWoundsLive, true];
    }, [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _oldBandage, _newBandage], _delay] call CBA_fnc_waitAndExecute;
};


if (GVAR(coagulation)) then {
    if ((_eacaEffectiveness < 0.3) && (!_allowStack)) exitWith {};
        [{
            params ["_args", "_idPFH"];
            _args params ["_patient", "_timeInSystem", "_fnc_eacaClot"];

            if !(alive _patient) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };

            private _random = random [6.4, 6.8, 7.2];
            private _ph     = GET_PH(_patient);

            if (_random <= _ph) then {
                private _coagWounds       = GET_COAGED_WOUNDS(_patient);
                private _pulse            = _patient getVariable [VAR_HEART_RATE, 80];

                if (_coagWounds isEqualTo createHashMap) exitWith {};
                if (GET_BLOOD_VOLUME_LITERS(_patient) < GVAR(coagulation_requireBV)) exitWith {};
                if ((_pulse < 20) && {GVAR(coagulation_requireHR)}) exitWith {};

                {
                    private _bodyPart = _x;

                    // Skip if tourniquet applied and blocking is enabled
                    private _bodyPartN = ALL_BODY_PARTS find _x;
                    if ([_patient,_bodyPartN] call EFUNC(pharma,occlusionCheck)
                        && { missionNamespace getVariable [QGVAR(coagulation_tourniquetBlock), true] }) then {
                        continue;
                    };

                    private _wounds = _coagWounds getOrDefault [_bodyPart, []];

                    {
                        _x params ["_id", "_amount", "_bleeding", "_damage", "_bandage", "_time"];
                        switch (true) do {
                            case (_bandage isEqualTo "BloodClotMinor"): {
                                private _delay = random [30, 45, 60];
                                private _newBandage = "BloodClotMinorEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            case (_bandage isEqualTo "BloodClotMedium"): {
                                private _delay = random [60, 90, 120];
                                private _newBandage = "BloodClotMediumEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            case (_bandage isEqualTo "BloodClotLarge"): {
                                private _delay = random [90, 120, 160];
                                private _newBandage = "BloodClotLargeEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            case (_bandage isEqualTo "BloodClotMinorTXA"): {
                                private _delay = random [20, 35, 60];
                                private _newBandage = "BloodClotMinorEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            case (_bandage isEqualTo "BloodClotMediumTXA"): {
                                private _delay = random [45, 60, 90];
                                private _newBandage = "BloodClotMediumEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            case (_bandage isEqualTo "BloodClotLargeTXA"): {
                                private _delay = random [60, 90, 120];
                                private _newBandage = "BloodClotLargeEACA";
                                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage] call _fnc_eacaClot;
                            };
                            default {};
                        };
                    } forEach _wounds;

                } forEach (keys _coagWounds);
            };
            [{
                params ["_patient", "_idPFH"];
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            }, [_patient, _idPFH], _timeInSystem] call CBA_fnc_waitAndExecute;

        }, 10, [_patient, _timeInSystem, _fnc_eacaClot]] call CBA_fnc_addPerFrameHandler;
};


if (!(GVAR(coagulation)) || GVAR(coagulation_allow_EACA_script)) then {
        if ((_eacaEffectiveness < 0.3) && (!_allowStack)) exitWith {};

        [{
            params ["_args", "_idPFH"];
            _args params ["_patient", "_keepRunning", "_timeInSystem"];

            private _alive = alive _patient;
            private _exit = true;

            private _random = random [6.4, 6.8, 7.2];
            private _ph = GET_PH(_patient);

            if !(_alive) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };

            if (_random <= _ph) then {
                {
                    _x params ["_targetBodyPart"];

                    private _coagWounds = GET_BANDAGED_WOUNDS(_patient);
                    private _bandagedWoundsOnPart = _coagWounds getOrDefault [_targetBodyPart, []];
                    private _bodyPartN = ALL_BODY_PARTS find _x;
                    if (_bandagedWoundsOnPart isEqualTo [] || [_patient,_bodyPartN] call EFUNC(pharma,occlusionCheck)) then {
                        continue;
                    };

                    private _index = _bandagedWoundsOnPart findIf {!((_x select 0) in [20,21,22])};

                    if (_index != -1) exitWith {
                        (_bandagedWoundsOnPart select _index) params ["_classID", "_amountOf", "", "_damageOf"];

                        private _treatedWound = [_classID, _amountOf, 0, _damageOf];

                        private _stitchedWounds = GET_STITCHED_WOUNDS(_patient);
                        private _stitchedWoundsOnPart = _stitchedWounds getOrDefault [_targetBodyPart, []];

                        private _woundIndex = _stitchedWoundsOnPart findIf {(_x select 0) isEqualTo _classID};

                        if (_woundIndex == -1) then {
                            _stitchedWoundsOnPart pushBack _treatedWound;
                        } else {
                            private _wound = _stitchedWoundsOnPart select _woundIndex;
                            _stitchedWoundsOnPart set [_woundIndex, [(_wound select 1) + _amountOf, _wound select 2, _wound select 3]];
                        };
                        _stitchedWounds set [_targetBodyPart, _stitchedWoundsOnPart];
                        _patient setVariable [VAR_STITCHED_WOUNDS, _stitchedWounds, true];

                        _bandagedWoundsOnPart deleteAt _index;
                        _coagWounds set [_targetBodyPart, _bandagedWoundsOnPart];

                        _patient setVariable [VAR_BANDAGED_WOUNDS, _coagWounds, true];

                        private _partIndex = ALL_BODY_PARTS find _targetBodyPart;
                        private _bodyPartDamage = _patient getVariable [QACEGVAR(medical,bodyPartDamage), []];
                        private _damage = (_bodyPartDamage select _partIndex) - (_damageOf * _amountOf);
                        
                        if (_damage < 0.05) then {
                            _bodyPartDamage set [_partIndex, 0];
                        } else {
                            _bodyPartDamage set [_partIndex, _damage];
                        };
                        _patient setVariable [QACEGVAR(medical,bodyPartDamage), _bodyPartDamage, true];

                        _exit = false;
                    };
                } forEach ALL_BODY_PARTS_PRIORITY;
            };

            [{
                params ["_patient", "_idPFH"];
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            },
            [_patient, _idPFH], _timeInSystem] call CBA_fnc_waitAndExecute;

            if (_exit && !(_keepRunning)) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };

        }, _cycleTime, [_patient, _keepRunning, _timeInSystem]] call CBA_fnc_addPerFrameHandler;
};
