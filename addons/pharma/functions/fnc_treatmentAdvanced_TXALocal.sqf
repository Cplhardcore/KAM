#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Begins TXA bandaging process
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_TXALocal;
 *
 * Public: No
 */

params ["_patient","_deltaT"];
TRACE_1("Patient",_patient);
private _cycleTime = missionNamespace getVariable [QGVAR(bandageCycleTime_TXA), 5];
private _time = _patient getVariable [QGVAR(TXATime), 0];
_patient setVariable [QGVAR(TXATime), _time + _deltaT, true];
if (_cycleTime > _time) exitWith {};
TRACE_1("CycleTime",_patient);
_patient setVariable [QGVAR(TXATime), 0, true];
private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVStatusArray = _patient getVariable [QGVAR(IVBlockStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
{
private _partIndex = _x;
private _IVactual = _IVarray select _partIndex;
private _IVStatusActual = _IVStatusArray select _partIndex;
if (_IVactual in [2,3,4]) then {
    private _randomNumber = random 100;
    if (_randomNumber < GVAR(blockChance)) then {
        _IVStatusArray set [_partIndex, ((_IVStatusActual + (random [0.01, 0.03, 0.05])) min 1)];
        _patient setVariable [QGVAR(IVBlockStatus), _IVStatusArray, true];
    };
};
} forEach [4,5,6,7,8,9,10,11];

private _fnc_txaClot = {
    params ["_patient", "_bodyPart", "_id", "_amount", "_bleeding", "_damage", "_delay", "_oldBandage", "_newBandage", "_factorCountToRemove"];
    TRACE_2("_fnc_txaClot",_patient,_delay);
    [{
    params ["_patient", "_bodyPart", "_id", "_amount", "_bleeding", "_damage", "_oldBandage", "_newBandage", "_factorCountToRemove"];
    if !(alive _patient) exitWith {};
    private _eacaAmount = [_patient, "EACA", false] call ACEFUNC(medical_status,getMedicationCount) select 1;
    if (_eacaAmount > 0.1) exitWith {};
    TRACE_1("EACA",_patient);
    private _coagulationFactor = GET_BODY_FLUID_PLATELETS(_patient);
    if (_coagulationFactor <= 0) exitWith {};
    TRACE_1("Coags",_coagulationFactor);
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
    private _bodyFluid = GET_BODY_FLUID(_patient);
    _bodyFluid set [5, (_coagulationFactor - _factorCountToRemove)];
    _patient setVariable [VAR_BODY_FLUID, _bodyFluid, true];
    }, [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _oldBandage, _newBandage,_factorCountToRemove], _delay] call CBA_fnc_waitAndExecute;
};


if (GVAR(coagulation)) then {
private _eacaAmount = [_patient, "EACA", false] call ACEFUNC(medical_status,getMedicationCount) select 1;
if (_eacaAmount > 0.1) exitWith {};
private _random = random [6.4, 6.8, 7.2];
private _ph     = GET_PH(_patient);
if (_random <= _ph) then {
    TRACE_1("Started Clotting",_ph);
    private _coagWounds       = GET_COAGED_WOUNDS(_patient);
    private _pulse            = _patient getVariable [VAR_HEART_RATE, 80];
    private _coagulationFactor = GET_BODY_FLUID_PLATELETS(_patient);
    private _exit = false;
    if (_coagWounds isEqualTo createHashMap) exitWith {};
    if (GET_BLOOD_VOLUME_LITERS(_patient) < GVAR(coagulation_requireBV)) exitWith {};
    if ((_pulse < 20) && {GVAR(coagulation_requireHR)}) exitWith {};
    if (_coagulationFactor <= 0) exitWith {};
    TRACE_1("PassedExitWith Clotting",_ph);
    {
        private _bodyPart = _x;
        private _wounds = _coagWounds getOrDefault [_bodyPart, []];
        {
            _x params ["_id", "_amount", "_bleeding", "_damage", "_bandage", "_time"];
            switch (true) do {
                case (_bandage isEqualTo "BloodClotMinor"): {
                    private _delay = random [10, 15, 20];
                    private _newBandage = "BloodClotMinorTXA";
                    private _factorCountToRemove = random [6, 11, 15];
                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage, _factorCountToRemove] call _fnc_txaClot;
                    TRACE_6("Small Clotting",_patient,_bodyPart,_delay,_bandage,_newBandage,_factorCountToRemove);
                    _exit = true;
                };
                case (_bandage isEqualTo "BloodClotMedium"): {
                    private _delay = random [15, 23, 45];
                    private _newBandage = "BloodClotMediumTXA";
                    private _factorCountToRemove = random [12, 18, 25];
                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage, _factorCountToRemove] call _fnc_txaClot;
                    TRACE_6("Medium Clotting",_patient,_bodyPart,_delay,_bandage,_newBandage,_factorCountToRemove);
                    _exit = true;
                };
                case (_bandage isEqualTo "BloodClotLarge"): {
                    private _delay = random [20, 40, 60];
                    private _newBandage = "BloodClotLargeTXA";
                    private _factorCountToRemove = random [16, 23, 30];
                    [_patient, _bodyPart, _id, _amount, _bleeding, _damage, _delay, _bandage, _newBandage, _factorCountToRemove] call _fnc_txaClot;
                    TRACE_6("Large Clotting",_patient,_bodyPart,_delay,_bandage,_newBandage,_factorCountToRemove);
                    _exit = true;
                };
                default {};
            };
        if (_exit) exitWith {}; 
        } forEach _wounds;
        if (_exit) exitWith {}; 
    } forEach (keys _coagWounds);

};
};
if (!(GVAR(coagulation)) || GVAR(coagulation_allow_TXA_script)) then {
    {
    _x params ["_targetBodyPart"];

    private _openWounds = GET_OPEN_WOUNDS(_patient);
    private _openWoundsOnPart = _openWounds getOrDefault [_targetBodyPart, []];
    private _bodyPartN = ALL_BODY_PARTS find _targetBodyPart;
    if (_openWoundsOnPart isEqualTo [] ||{[_patient, _bodyPartN] call EFUNC(pharma,occlusionCheck)}) then {
        continue;
    };
    private _woundIndex = _openWoundsOnPart findIf {(_x select 1) > 0 && (_x select 2) > 0};
    if (_woundIndex != -1) exitWith {
        [QACEGVAR(medical_treatment,bandageLocal),[_patient, _targetBodyPart, "PackingBandage"],_patient] call CBA_fnc_targetEvent;
    };
    } forEach ALL_BODY_PARTS_PRIORITY;
};