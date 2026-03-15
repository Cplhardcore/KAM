#include "..\script_component.hpp"
#pragma hemtt suppress pw3_padded_arg file
/*
 * Author: Glowbal, Mazinski
 * Update heart rate
 
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Heart Rate Adjustments <NUMBER>
 * 2: Heart Rate Target <NUMBER>
 * 3: Blood Volume <NUMBER>
 * 4: ACE Fatigue <NUMBER>
 * 5: Time since last update <NUMBER>
 * 6: Sync value? <BOOL>
 *
 * ReturnValue:
 * Current Heart Rate <NUMBER>
 *
 * Example:
 * [player, 0, 80, 6, 0.1, 1, false] call kat_vitals_handleCardiacFunction;
 *
 * Public: No
 */

params ["_unit", "_hrTargetAdjustment", "_hrTarget", "_bloodVolume", "_aceAnFatigue", "_aceAnReserve",  "_deltaT", "_syncValue"];

private _icp = GET_ICP(_unit);
private _map = GET_MAP(_unit);
private _actualHeartRate = _hrTarget;
private _painLevel = 0;
private _shockClass = "NONE";
private _metabolicDemand = 0;
private _sedation = _unit getVariable [QEGVAR(surgery,sedated), 0];
private _opioid = _unit getVariable [QEGVAR(pharma,opioidDepression), 0];
[_unit] call FUNC(updateSympatheticTone);
private _cnsSuppression =
    (_sedation max _opioid) * 0.6;
if (IN_CRDC_ARRST(_unit)) then {
    if (alive (_unit getVariable [QACEGVAR(medical,CPR_provider), objNull])) then {
        if (_actualHeartRate == 0) then { _syncValue = true };
        _actualHeartRate = random [95, 100, 110];
    } else {
        if (_actualHeartRate != 0) then { _syncValue = true };
        _actualHeartRate = 0;
    };
} else {
    private _defaultHR = _unit getVariable [QEGVAR(circulation,defaultHeartRate), 80];
    private _mapSetpoint = linearConversion [60, 100, _defaultHR, 83, 103, true];
    #define MAP_DEADBAND 3
    #define BARO_KP 0.6
    #define BARO_KI 0.12
    #define INTEGRAL_CLAMP 30
    #define MIN_HR 20
    #define MAX_HR 220
    _metabolicDemand = linearConversion [2200, 400, _aceAnReserve, 0, 1, true];
    private _symp = _unit getVariable [QGVAR(sympatheticTone),0.5];
    private _catecholamine =
    _unit getVariable [QGVAR(catecholamine),0];
    private _target = linearConversion [0.5,1,_symp,0,1,true];
    _catecholamine =
    _catecholamine + ((_target - _catecholamine) * (_deltaT / 8));
    _unit setVariable [QGVAR(catecholamine),_catecholamine];

    _painLevel = GET_PAIN_PERCEIVED(_unit);

    private _lastHR =
        GET_HEART_RATE(_unit)
        - _hrTargetAdjustment
        + (10 * _painLevel * (1 - (_cnsSuppression * 0.75)))
        - (_aceAnFatigue * 40);

    private _baselineSV = 0.0810542;
    private _strokeVolume = [_unit] call FUNC(getStrokeVolume);

    private _svMemory =
        _unit getVariable [QGVAR(svMemory), _baselineSV];

    private _svTau = 6;
    _svMemory = _svMemory + ((_strokeVolume - _svMemory) * (_deltaT / _svTau));
    _unit setVariable [QGVAR(svMemory), _svMemory];

    private _effectiveSV = _svMemory max 0.03;

    TRACE_5(
        "SV_MODEL",
        _strokeVolume,
        _svMemory,
        _effectiveSV,
        _svTau,
        _baselineSV
    );
    private _mapError = (_mapSetpoint) - _map;
    if (abs _mapError < MAP_DEADBAND) then { _mapError = 0 };

    private _mapIntegral =
        _unit getVariable [QGVAR(mapIntegral), 0];

    _mapIntegral = _mapIntegral + (_mapError * _deltaT);
    
    if (abs _mapError < MAP_DEADBAND) then {
        _mapIntegral = _mapIntegral * 0.85;
    };
    
    _mapIntegral = (_mapIntegral max -INTEGRAL_CLAMP) min INTEGRAL_CLAMP;
    _unit setVariable [QGVAR(mapIntegral), _mapIntegral];

    private _baroScale =
        linearConversion [0, 1, _cnsSuppression, 1, 0.55, true];
    private _baroDelta =
        ((BARO_KP * _mapError)
      + (BARO_KI * _mapIntegral)) * _baroScale;

    private _modelHR = _defaultHR + _baroDelta;
    _modelHR = _modelHR - linearConversion [0,1,_cnsSuppression,0,8,true];

    TRACE_6(
        "BARO_CORE",
        _map,
        _mapError,
        _mapIntegral,
        _modelHR,
        BARO_KP,
        BARO_KI
    );
    private _centralBias = 0;
    
    if (
        _painLevel < 0.05
        && _aceAnFatigue < 0.05
        && abs (_effectiveSV - _baselineSV) < 0.003
    ) then {
        _centralBias = linearConversion [90, 100, _map, 0, 6, true];
    };
    private _sympatheticSurge = 0;
    if (_effectiveSV < (_baselineSV * 0.9) && _map > 75) then {
        _sympatheticSurge =
            linearConversion [
                _baselineSV * 0.9,
                _baselineSV * 0.7,
                _effectiveSV,
                0,
                22,
                true
            ];
    };
    _sympatheticSurge =
    _sympatheticSurge * linearConversion [0,1,_painLevel,0.7,1.2,true];
    _modelHR = _modelHR + _centralBias;
    _modelHR = _modelHR + (_sympatheticSurge * (1 - (_cnsSuppression * 0.7)));
    TRACE_2("CENTRAL_CMD", _centralBias, _modelHR);

    private _staminaHRBias =
        linearConversion [0, 1, _metabolicDemand, 0, 25, true];
    _staminaHRBias = _staminaHRBias * (1 - (_cnsSuppression * 0.6));
    _modelHR = _modelHR + _staminaHRBias;

    if (_icp > EGVAR(brain,ICPbradycardiaThreshold)) then {
        private _ICPbias = linearConversion [EGVAR(brain,ICPbradycardiaThreshold), 60, _icp, -20, -45, true];
        _modelHR = _modelHR + _ICPbias;
    };
    
    TRACE_2("STAMINA_CMD", _metabolicDemand, _staminaHRBias);

    private _vagalTone = 0;

    if (_painLevel > 0.7) then {
        _vagalTone = linearConversion [0.7, 1.0, _painLevel, 0, 0.35, true];
    };

    private _spo2 = GET_KAT_SPO2(_unit);
    if (_spo2 < 85) then {
        _vagalTone = _vagalTone max
            linearConversion [85, 60, _spo2, 0, 0.5, true];
    };

    _vagalTone =
        _vagalTone
        * linearConversion [0, 1, _metabolicDemand, 1, 0.4, true];

    TRACE_3("VAGAL", _painLevel, _spo2, _vagalTone);

    _modelHR = _modelHR * (1 - _vagalTone);
    _shockClass = "NONE";
    private _metShock = _unit getVariable [QGVAR(shockState),0];
    if (_effectiveSV < 0.06 && _map < 70) then { _shockClass = "COMPENSATED" };
    if (_effectiveSV < 0.04 && _map < 60) then { _shockClass = "DECOMPENSATED" };
    if (_effectiveSV < 0.025 || _metShock > 0.85) then {
        _shockClass = "TERMINAL"
    };

    _unit setVariable [QGVAR(shockClass), _shockClass];

    TRACE_3(
        "SHOCK",
        _shockClass,
        _effectiveSV,
        _map
    );
    switch (_shockClass) do {
        case "DECOMPENSATED": { _modelHR = _modelHR * 1.1 };
        case "TERMINAL":     { _modelHR = _modelHR * 0.6 };
    };
    private _paCO2 = GET_PACO2(_unit);
    private _co2Tachy =
    linearConversion [45, 80, _paCO2, 0, 18, true];
    _co2Tachy =
    _co2Tachy * (1 - (_cnsSuppression * 0.7));
    _modelHR = _modelHR + _co2Tachy;

    private _pao2 = GET_PAO2(_unit);
    private _hypoxiaTachy = linearConversion [80, 40, _pao2, 0, 20, true];
    _modelHR = _modelHR + _hypoxiaTachy;

    private _respDepth =
    _unit getVariable [VAR_RESPIRATORY_DEPTH, 10];

    private _vagalResp =
    linearConversion [14, 22, _respDepth, 0, 10, true];

    _modelHR = _modelHR - _vagalResp;


    private _respFatigue =
    _unit getVariable [QGVAR(respFatigue),0];

    if (_respFatigue > 0.9) then {

        private _respCollapse =
        linearConversion [0.9,1.2,_respFatigue,0,25,true];

        _modelHR = _modelHR - _respCollapse;
    };
    private _pH = GET_PH(_unit);
    if (_pH < 7.2) then {
        _modelHR = _modelHR - linearConversion [7.2,6.9,_pH,0,25,true];
    };
    _modelHR = (_modelHR max MIN_HR) min MAX_HR;
    private _hrDelta = _modelHR - _lastHR;
    private _rate =
        (1.2 * _deltaT)
        * linearConversion [0, 1, _metabolicDemand, 1, 1.6, true];
    _rate = _rate * linearConversion [0, 1, _cnsSuppression, 1, 0.65, true];
    TRACE_4("SA_NODE", _lastHR, _modelHR, _hrDelta, _rate);

    TRACE_4(
        "SA_NODE",
        _lastHR,
        _modelHR,
        _hrDelta,
        _rate
    );

    if (abs _hrDelta < 0.25) then {
        _actualHeartRate = _lastHR;
    } else {
        _actualHeartRate =
            _lastHR + ((_hrDelta max -_rate) min _rate);
    };
    private _respRate = _unit getVariable [QEGVAR(breathing,breathRate), 12];
    private _respDepth = _unit getVariable [VAR_RESPIRATORY_DEPTH, 10];

    if (_respRate > 4) then {
        private _rsaAmp =
            linearConversion [6, 20, _respRate, 6, 2, true];
        _rsaAmp =
            _rsaAmp
            * linearConversion [4, 14, _respDepth, 0.4, 1.0, true];
        _rsaAmp =
            _rsaAmp
            * (1 - (_cnsSuppression * 0.6))
            * linearConversion [0,1,_metabolicDemand,1,0.5,true];
        private _rsa =
            sin (CBA_missionTime * (_respRate / 60) * 360) * _rsaAmp;
        _actualHeartRate = _actualHeartRate + _rsa;
    };
    _actualHeartRate =
        _actualHeartRate
        + _hrTargetAdjustment
        + (10 * _painLevel * (1 - (_cnsSuppression * 0.75)))
        + (_aceAnFatigue * 40);

    _actualHeartRate = (_actualHeartRate max MIN_HR) min MAX_HR;
    private _hrMem =
    _unit getVariable [QGVAR(hrMemory), _actualHeartRate];
    private _hrTau = 3.5;

    _hrTau =
        _hrTau
        * linearConversion [0, 1, _metabolicDemand, 1, 1.4, true];
    if (_shockClass != "NONE" || _painLevel > 0.4) then {
        _hrTau = 1.8;
    };
    _hrMem =
        _hrMem
        + ((_actualHeartRate - _hrMem) * (_deltaT / _hrTau));
    _unit setVariable [QGVAR(hrMemory), _hrMem];
    if (_unit getVariable [QEGVAR(circulation,heartRestart), false]) then {
        _hrMem = 70;
        _unit setVariable [QGVAR(hrMemory), _hrMem, true];
        
    };
    _actualHeartRate = _hrMem;
    TRACE_3(
        "HR_FINAL",
        _actualHeartRate,
        _map,
        GET_BLOOD_VOLUME_LITERS(_unit)
    );
    private _delivery =
    (_spo2 / 100) * linearConversion [50,90,_map,0.4,1,true];

    private _deficit = _metabolicDemand - _delivery;
    private _mito = _unit getVariable [QEGVAR(pharma,mitoFailure),0];
    _delivery = _delivery * (1 - (_mito * 0.35));
    private _debt =
    _unit getVariable [QGVAR(oxygenDebt),0];

    _debt = _debt + (_deficit * _deltaT);

    _debt = (_debt max 0) min 10;

    _unit setVariable [QGVAR(oxygenDebt),_debt];
    private _irreversible = _unit getVariable [QGVAR(irreversibleShock),0];

    if (_map < 40 && _debt > 5) then {
        _irreversible = _irreversible + (_deltaT / 45);
    };

    _irreversible = (_irreversible max 0) min 1;

    _unit setVariable [QGVAR(irreversibleShock), _irreversible];

    if (_irreversible > 0) then {
        _actualHeartRate = _actualHeartRate * (1 - (_irreversible * 0.4));
    };
};

_unit setVariable [VAR_HEART_RATE, _actualHeartRate, _syncValue];
_actualHeartRate

