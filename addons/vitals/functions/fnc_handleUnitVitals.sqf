#include "..\script_component.hpp"
/*
 * Author: Glowbal, Mazinski
 * Updates the vitals. Called from the statemachine's onState functions.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * Update Ran (at least 1 second between runs) <BOOL>
 *
 * Example:
 * [player] call ace_medical_vitals_fnc_handleUnitVitals
 *
 * Public: No
 */

params ["_unit"];

if ((!(isPlayer _unit)) && (_unit getVariable [QGVAR(simpleMedical),false])) exitWith { [_unit] call FUNC(handleSimpleVitals); };

private _lastTimeUpdated = _unit getVariable [QACEGVAR(medical_vitals,lastTimeUpdated), 0];
private _deltaT = (CBA_missionTime - _lastTimeUpdated) min 10;
if (_deltaT < 1) exitWith { false }; // state machines could be calling this very rapidly depending on number of local units

BEGIN_COUNTER(Vitals);

_unit setVariable [QACEGVAR(medical_vitals,lastTimeUpdated), CBA_missionTime];
private _lastTimeValuesSynced = _unit getVariable [QACEGVAR(medical_vitals,lastMomentValuesSynced), 0];
private _syncValues = (CBA_missionTime - _lastTimeValuesSynced) >= (10 + floor(random 10));

if (_syncValues) then {
    _unit setVariable [QACEGVAR(medical_vitals,lastMomentValuesSynced), CBA_missionTime];
};

//Get Blood Volume from previous cycle
private _bloodVolume = ([_unit, _deltaT, _syncValues] call EFUNC(pharma,getBloodVolumeChange));
_unit setVariable [VAR_BLOOD_VOL, _bloodVolume, _syncValues];

// Enviromental Impact (Altitude, Temperature, Pressure)
private _baroPressure = 760;
private _temperature = DEFAULT_TEMPERATURE;
private _altitude = (getPosASL _unit) select 2;

if (EGVAR(hypothermia,baroPressureEnable)) then {
    if (EGVAR(hypothermia,useACEpressure)) then {
        private _hPa = _altitude call ACEFUNC(weather,calculateBarometricPressure);
        _baroPressure = _hPa * 0.750062;
    } else {
        _baroPressure = 760 * exp((-(_altitude)) / 8400);
    };
};

if (EGVAR(hypothermia,hypothermiaActive)) then {
    private _altitudeTempImpact = switch (true) do {
        case (_altitude >= 10): { abs(_altitude/153) * -1 }; //For every 1000 meters of elevation gain, temperature decreases by ~6.5 degrees celsius
        case (_altitude <= -1): { -35 max((abs(_altitude/50) * -1) - 17) }; //Average water temperature is 20 degrees celsius. Decreases to 2 degrees celsius at 1000 meters
        default { 0 };
    };
    _temperature = [_unit, _altitudeTempImpact, _bloodVolume, _deltaT, _syncValues] call FUNC(handleTemperatureFunction);
};

private _hemorrhage = switch (true) do {
    case (_bloodVolume < BLOOD_VOLUME_CLASS_4_HEMORRHAGE): { 4 };
    case (_bloodVolume < BLOOD_VOLUME_CLASS_3_HEMORRHAGE): { 3 };
    case (_bloodVolume < BLOOD_VOLUME_CLASS_2_HEMORRHAGE): { 2 };
    case (_bloodVolume < BLOOD_VOLUME_CLASS_1_HEMORRHAGE): { 1 };
    default {0};
};

if (_hemorrhage != GET_HEMORRHAGE(_unit)) then {
    _unit setVariable [VAR_HEMORRHAGE, _hemorrhage, true];
};

private _inPain = GET_PAIN_PERCEIVED(_unit) > 0;
if (_inPain isNotEqualTo IS_IN_PAIN(_unit)) then {
    _unit setVariable [VAR_IN_PAIN, _inPain, true];
};

// Handle pain due tourniquets, that have been applied more than 120 s ago
private _tourniquetPain = 0;
private _tourniquets = GET_TOURNIQUETS(_unit);
{
    if (_x > 0 && (CBA_missionTime - _x > 120)) then {
        _tourniquetPain = _tourniquetPain max (CBA_missionTime - _x - 120) * 0.001;
    };
} forEach _tourniquets;

if (_tourniquetPain > 0) then {
    [_unit, _tourniquetPain] call ACEFUNC(medical_status,adjustPainLevel);
};


private _hrTargetAdjustment = 0;
private _painSupressAdjustment = 0;
private _peripheralResistanceAdjustment = 0;
private _alphaFactorAdjustment = 0;
private _opioidAdjustment = 0;
private _opioidEffectAdjustment = 0;
private _opioidDepressionAdjustment = 0;
private _respiratoryRateAdjustment = 1;
private _contractilityAdjustment = 1;
private _nauseaMultAdjustment = 1;
private _sedationAdjustment = 0;
private _cnsSuppressionAdjustment = 0;
private _paralysisAdjustment = 0;
private _effectRatio = 0;

private _adjustments = _unit getVariable [VAR_MEDICATIONS,[]];

private _ph = GET_PH(_unit);
private _metabolismMult = linearConversion [7.4, 7.0, _ph, 1.0, 0.4, true];
private _onsetMult = linearConversion [7.4, 7.0, _ph, 1.0, 1.6, true];

private _effectiveDose = 1;
if (_ph < 7.1) then {
    _effectiveDose = linearConversion [7.1, 6.8, _ph, 1.0, 1.4, true];;
};
private _ph = GET_PH(_unit);
private _ca = GET_CA(_unit);
private _phDilationMult = linearConversion [
    7.4,    // normal
    7.0,    // severe acidosis
    _ph,
    1.0,    // baseline dilation
    1.5,    // exaggerated dilation
    true
];
private _phVasoMult = linearConversion [
    7.4,    // normal
    7.0,    // severe acidosis
    _ph,
    1.0,    // full response
    0.4,    // profound resistance
    true
];
private _calciumVasoMult = linearConversion [
    2.0,    // hypocalcemia
    3.0,    // hypercalcemia
    _ca,
    0.6,    // poor response
    1.3,    // exaggerated response
    true
];
private _vasoEffectMult = _phVasoMult * _calciumVasoMult;
private _vasodilatorMult = _phDilationMult * (1 / _calciumVasoMult);
TRACE_1("HUV",_adjustments);
_vasoEffectMult = (_vasoEffectMult max 0.25) min 1.5;
_vasodilatorMult = (_vasodilatorMult max 0.6) min 1.8;
if (_adjustments isNotEqualTo []) then {
    private _deleted = false;

    {
        _x params [
            "_medication", "_timeAdded", "_timeTillMaxEffect", "_maxTimeInSystem",
            "_hrAdjust", "_painAdjust", "_flowAdjust", "_dose", "_alphaFactor",
            "_opioidRelief", "_opioidEffect", "_opioidDepression",
            "_respiratoryRate", "_contractility", "_nauseaMult",
            "_sedation", "_paralysis", "_linear", "_cnsSuppression", "_overdoseAdmin"
        ];
        _overdoseAdmin params ["_ld50", "_od50", "_chanceToOD", "_bloodBased", "_weightMult", "_theraputic"];
        private _scaledMaxTime = _maxTimeInSystem / _metabolismMult;
        private _scaledTimeToMax = _timeTillMaxEffect * _onsetMult;
        private _timeInSystem = CBA_missionTime - _timeAdded;
        private _medLower = toLower _medication;
        private _blockedWords = ["overdose", "override", "bradycardia", "tachycardia"];
        private _found = _blockedWords findIf { _medLower find _x != -1 };
        if ((_overdoseAdmin select 1 > 0) && (_found == -1) && (_overdoseAdmin select 0 > 0)) then {
            [_unit, _medication, _ld50, _od50, _chanceToOD] call FUNC(handleOverdoses);
        };
        TRACE_3("TIS",_medication,_timeInSystem,_scaledMaxTime);
        if (_timeInSystem >= _scaledMaxTime) then {
            _deleted = true;
            _adjustments deleteAt _forEachIndex;
        } else {
            if (_linear == "true") then {
                _effectRatio = 1;
            } else {
                _effectRatio =
                    (((_timeInSystem / _scaledTimeToMax) ^ 2) min 1)
                    * ((_scaledMaxTime - _timeInSystem) / _scaledMaxTime);
            };
            private _dampening = {
                params ["_total", "_effect", "_cap", "_base"];
                if (abs (_total * _effect) > _base) then {
                    _total = _total + (_effect * (1 - (abs _total / _cap)));
                } else {
                    _total = _total + _effect;
                };
                _total
            };
            private _diazapamMult = 1;
            if (toLower _medication == "diazapam") then {
                private _medStack = _unit call ACEFUNC(medical_status,getAllMedicationCount);
                private _fentanylEffectiveness = 0;
                private _nalbuphineEffectiveness = 0;
                private _morphineEffectiveness = 0;
                private _lorazepamEffectiveness = 0;
                {
                    private _medName = toLower (_x select 0);
                    private _effectiveness = _x select 2;
                    private _dose = _x select 1;
                    if ("fentanyl" in _medName) then {
                        _fentanylEffectiveness = _fentanylEffectiveness max (_dose * _effectiveness);
                    };
                    if ("nalbuphine" in _medName) then {
                        _nalbuphineEffectiveness = _nalbuphineEffectiveness max (_dose * _effectiveness);
                    };
                    if ("morphine" in _medName) then {
                        _morphineEffectiveness = _morphineEffectiveness max (_dose * _effectiveness);
                    };
                    if ("lorazepam" in _medName) then {
                        _lorazepamEffectiveness = _lorazepamEffectiveness max (_dose * _effectiveness);
                    };
                } forEach _medStack;
                _diazapamMult = linearConversion [0, 90, (_fentanylEffectiveness + _nalbuphineEffectiveness + _morphineEffectiveness * _lorazepamEffectiveness), 1, 4, true];
            };
            private _hemocrit = 1;
            if (_bloodBased == "true") then {
                _hemocrit = (GET_BODY_FLUID_ECB(_unit)/GET_BODY_FLUID_ECP(_unit)) / (DEFAULT_ECB/DEFAULT_ECP)
            } else {
                _hemocrit = (GET_BODY_FLUID_ECP(_unit)/GET_BODY_FLUID_ECB(_unit)) / (DEFAULT_ECP/DEFAULT_ECB)
            };
            private _drugMult = ((((GET_BLOOD_VOLUME_LITERS(_unit) / DEFAULT_BLOOD_VOLUME) * _hemocrit) max 0.2) min 2) * _diazapamMult;
            if (_found == -1) then {
                if (_hrAdjust != 0) then { _hrTargetAdjustment = [_hrTargetAdjustment, _hrAdjust * _drugMult * _effectRatio * _effectiveDose, 125, 0] call _dampening };
                if (_painAdjust != 0) then { _painSupressAdjustment = [_painSupressAdjustment, _painAdjust * _drugMult * _effectRatio * _effectiveDose, 1.25, 0] call _dampening };
                if (_flowAdjust >= 0) then { _peripheralResistanceAdjustment = [_peripheralResistanceAdjustment * _drugMult + _flowAdjust * _effectRatio * _effectiveDose * _vasoEffectMult, 1.25, 0] call _dampening };
                if (_alphaFactor >= 0) then { _alphaFactorAdjustment = [_alphaFactorAdjustment,  _alphaFactor * _drugMult * _effectRatio * _effectiveDose * _vasoEffectMult, 1.25, 0] call _dampening};
                if (_flowAdjust < 0) then { _peripheralResistanceAdjustment = [_peripheralResistanceAdjustment * _drugMult + _flowAdjust * _effectRatio * _effectiveDose * _vasodilatorMult, 1.25, 0] call _dampening};
                if (_alphaFactor < 0) then { _alphaFactorAdjustment = [_alphaFactorAdjustment, _alphaFactor * _drugMult * _effectRatio * _effectiveDose * _vasodilatorMult, 1.25, 0] call _dampening };
                if (_opioidRelief != 0) then { _opioidAdjustment = [_opioidAdjustment, _opioidRelief * _drugMult * _effectRatio * _effectiveDose, 1.25, 0] call _dampening };
                if (_opioidEffect != 0) then { _opioidEffectAdjustment = [_opioidEffectAdjustment, _opioidEffect * _drugMult * _effectRatio * _effectiveDose, 1.25, 0] call _dampening };
                if (_opioidDepression != 0) then { _opioidDepressionAdjustment = [_opioidDepressionAdjustment, _opioidDepression * _drugMult * _effectRatio * _effectiveDose, 12.5, 0] call _dampening };
                if (_respiratoryRate != 0) then { _respiratoryRateAdjustment = [_respiratoryRateAdjustment, _respiratoryRate * _drugMult * _effectRatio * _effectiveDose, 1.25, 1] call _dampening };
                if (_contractility != 0) then { _contractilityAdjustment = [_contractilityAdjustment, _contractility * _drugMult * _effectRatio * _effectiveDose, 1.25, 1] call _dampening };
                if (_nauseaMult != 0) then { _nauseaMultAdjustment = ([_nauseaMultAdjustment, (_nauseaMult * _effectRatio * _drugMult), 1.25, 1] call _dampening ) max 0.1};
                if (_sedation == "true") then { _sedationAdjustment = (_sedationAdjustment + (1 * _effectRatio)) min 1; };
                if (_paralysis == "true") then { _paralysisAdjustment = (_paralysisAdjustment + (1 * _effectRatio)) min 1; };
                if (_cnsSuppression != 0) then { _cnsSuppressionAdjustment = [_cnsSuppressionAdjustment, _cnsSuppression * _drugMult * _effectRatio * _effectiveDose, 1.25, 0] call _dampening};
            } else {
                if (_hrAdjust != 0) then { _hrTargetAdjustment = _hrTargetAdjustment + _hrAdjust * _drugMult * _effectRatio * _effectiveDose; };
                if (_painAdjust != 0) then { _painSupressAdjustment = _painSupressAdjustment + _painAdjust * _drugMult * _effectRatio * _effectiveDose; };
                if (_flowAdjust >= 0) then { _peripheralResistanceAdjustment = _peripheralResistanceAdjustment * _drugMult + _flowAdjust * _effectRatio * _effectiveDose * _vasoEffectMult; };
                if (_alphaFactor >= 0) then { _alphaFactorAdjustment = _alphaFactorAdjustment + _alphaFactor * _drugMult * _effectRatio * _effectiveDose * _vasoEffectMult; };
                if (_flowAdjust < 0) then { _peripheralResistanceAdjustment = _peripheralResistanceAdjustment * _drugMult + _flowAdjust * _effectRatio * _effectiveDose * _vasodilatorMult; };
                if (_alphaFactor < 0) then { _alphaFactorAdjustment = _alphaFactorAdjustment + _alphaFactor * _drugMult * _effectRatio * _effectiveDose * _vasodilatorMult; };
                if (_opioidRelief != 0) then { _opioidAdjustment = _opioidAdjustment + _opioidRelief * _drugMult * _effectRatio * _effectiveDose; };
                if (_opioidEffect != 0) then { _opioidEffectAdjustment = _opioidEffectAdjustment + _opioidEffect * _drugMult * _effectRatio * _effectiveDose; };
                if (_opioidDepression != 0) then { _opioidDepressionAdjustment = _opioidDepressionAdjustment + _opioidDepression * _drugMult * _effectRatio * _effectiveDose; };
                if (_respiratoryRate != 0) then { _respiratoryRateAdjustment = _respiratoryRateAdjustment + _respiratoryRate * _drugMult * _effectRatio * _effectiveDose; };
                if (_contractility != 0) then { _contractilityAdjustment = _contractilityAdjustment + _contractility * _drugMult * _effectRatio * _effectiveDose; };
                if (_nauseaMult != 0) then { _nauseaMultAdjustment = (_nauseaMultAdjustment + (_nauseaMult * _effectRatio * _drugMult)) max 0.1; };
                if (_sedation == "true") then { _sedationAdjustment = (_sedationAdjustment + (1 * _effectRatio)) min 1; };
                if (_paralysis == "true") then { _paralysisAdjustment = (_paralysisAdjustment + (1 * _effectRatio)) min 1; };
                if (_cnsSuppression != 0) then { _cnsSuppressionAdjustment = _cnsSuppressionAdjustment + _cnsSuppression * _drugMult * _effectRatio * _effectiveDose; };
            };
            private _currentDose = [_unit, _medication] call EFUNC(misc,getCurrentDosage);
            if (_currentDose > _theraputic) then {
                private _overage = (_dose - _theraputic);
                if (_medication in ["EACA", "TXA"]) then {
                    [format ["kat_pharma_%1Local", toLower _medication], [_unit, _deltaT], _unit] call CBA_fnc_targetEvent;
                };
                if (_medication in ["Lorazepam","Etomidate","Sugammadex","Flumazenil"]) then {
                    [format ["kat_pharma_%1Local", toLower _medication], [_unit, _overage], _unit] call CBA_fnc_targetEvent;
                };
                if (_medication in ["Atropine","Alteplase"]) then {
                    [format ["kat_pharma_%1Local", toLower _medication], [_unit], _unit] call CBA_fnc_targetEvent;
                };
                
            }
        };

    } forEach _adjustments;
    if (_deleted) then {   
        _syncValues = true;
        _unit setVariable [VAR_MEDICATIONS, _adjustments - [objNull], true];
    };
};


[_unit, _painSupressAdjustment, _deltaT, _syncValues] call ACEFUNC(medical_vitals,updatePainSuppress); //Leave alone
[_unit, _peripheralResistanceAdjustment, _deltaT, _syncValues] call ACEFUNC(medical_vitals,updatePeripheralResistance);
[_unit, _opioidAdjustment, _deltaT, _syncValues] call FUNC(updateOpioidRelief);
[_unit, _opioidEffectAdjustment, _deltaT, _syncValues] call FUNC(updateOpioidEffect);
[_unit, _opioidDepressionAdjustment, _deltaT, _syncValues] call FUNC(updateOpioidDepression);//resp depth
[_unit, _respiratoryRateAdjustment, _deltaT, _syncValues] call FUNC(updateRespiratoryRate);
[_unit, _contractilityAdjustment, _deltaT, _syncValues] call FUNC(updateContractility);
[_unit, _nauseaMultAdjustment, _deltaT, _syncValues] call FUNC(updateNauseaMult);
[_unit, _sedationAdjustment, _deltaT, _syncValues] call FUNC(updateSedation);
[_unit, _paralysisAdjustment, _deltaT, _syncValues] call FUNC(updateParalysis);
[_unit, _cnsSuppressionAdjustment, _deltaT, _syncValues] call FUNC(updateCnsSuppression);
private _aceAnFatigue = 0;
private _aceAnReserve = 0;
if (_unit getVariable [QGVAR(fatigueEnabled), false]) then {
    _aceAnFatigue = [_unit] call FUNC(returnFatigue);
};

if (_unit getVariable [QGVAR(fatigueEnabled), false]) then {
    _aceAnReserve = [_unit] call FUNC(returnReserve);
};
[_unit] call FUNC(updateShockController);
[_unit] call FUNC(updateSympatheticTone);
private _heartRate = [_unit, _hrTargetAdjustment, 0, _bloodVolume, _aceAnFatigue, _aceAnReserve, _deltaT, _syncValues] call FUNC(handleCardiacFunction);

private _spo2 = 97;
if (EGVAR(breathing,enable)) then {
    // Additional variables for Respiration functions
    private _bloodGas = GET_BLOOD_GAS(_unit);
    private _opioidDepression = GET_OPIOID_DEPRESSION(_unit);
    private _anerobicPressure = (DEFAULT_ANEROBIC_EXCHANGE * (6 / (_bloodVolume max 6))) min 1.2;

    _spo2 = [_unit, _heartRate, _anerobicPressure, _bloodGas, _temperature, _baroPressure, _opioidDepression, _aceAnFatigue, _aceAnReserve, _deltaT, _syncValues] call FUNC(handleOxygenFunction);
};

private _woundBloodLoss = GET_BODY_BLEED_RATE(_unit);
private _totalBloodLoss = 0;
{ _totalBloodLoss = _totalBloodLoss + _x } forEach _woundBloodLoss;
private _damage = GET_BODYPART_DAMAGE(_unit);
private _symp = _unit getVariable [QGVAR(sympatheticTone),0.5];
private _trauma = _unit getVariable [QGVAR(traumaState),0];
private _bloodVol = GET_BLOOD_VOLUME_LITERS(_unit);
private _sympVaso = linearConversion [0.5,1,_symp,0,0.3,true];
// Vasoconstriction from Wound Blood Loss and Alpha Adjustment
private _vasoArray = _unit getVariable [VAR_VASOCONSTRICTION, [1,1,1,1,1,1,1,1,1,1,1,1]];
{
    private _limbIndex = _forEachIndex;
    private _bodyPartDamage = linearConversion [0, 20, (_damage select _limbIndex), 0, 0.3, true];
    private _bloodLoss = linearConversion [0.05, 0.3, (_woundBloodLoss select _limbIndex), 0, -1, true];
    private _bloodVolRemaining = linearConversion [6, 4, _bloodVol, 1, 0.3, true];
    private _vasoconstriction = 1 + (0.7 * (_bloodLoss * _bloodVolRemaining)) + _alphaFactorAdjustment + _bodyPartDamage + _sympVaso;
    if (_trauma > 0.7) then {
    _vasoconstriction = _vasoconstriction * (1 - ((_trauma - 0.7) * 1.2));
    };
    TRACE_4("vaso", _bodyPartDamage, _bloodLoss, _alphaFactorAdjustment, _sympVaso);
    _vasoArray set [_limbIndex, (1.9 min (0.2 max _vasoconstriction))];
} forEach _vasoArray;

_unit setVariable [VAR_VASOCONSTRICTION, _vasoArray, _syncValues];

private _bloodPressure = [_unit] call EFUNC(circulation,getBloodPressure);
_unit setVariable [VAR_BLOOD_PRESS, _bloodPressure, _syncValues];

_bloodPressure params ["_bloodPressureL", "_bloodPressureH"];
private _map = GET_MAP(_unit);
private _oxygenDelivery = _unit getVariable [QGVAR(oxygenDelivery),0];
// Statements are ordered by most lethal first.
switch (true) do {
    case ((_spo2 < EGVAR(breathing,SpO2_dieValue)) && EGVAR(breathing,SpO2_dieActive)): {
        TRACE_3("O2 Fatal",_unit,EGVAR(breathing,SpO2_dieValue),_spo2);
        [_unit, "Fatal_Blood_Oxygen"] call ACEFUNC(medical_status,setDead);
    };
    case ((_bloodVolume) < BLOOD_VOLUME_FATAL): {
        TRACE_3("BloodVolume Fatal",_unit,BLOOD_VOLUME_FATAL,_bloodVolume);
        [QACEGVAR(medical,Bleedout), _unit] call CBA_fnc_localEvent;
    };
    case (IN_CRDC_ARRST(_unit)): {}; // if in cardiac arrest just break now to avoid throwing unneeded events
    case ((_spo2 < EGVAR(breathing,SpO2_cardiacValue)) && EGVAR(breathing,SpO2_cardiacActive)): {
        TRACE_2("SpO2 below Cardiac Value",_unit,_spo2);
        if ((_unit getVariable [QEGVAR(conversion,convert), false]) && (isPlayer _unit) && EGVAR(conversion,enableAutomaticConversion)) then {
            [QEGVAR(conversion,convertCasualty), _unit] call CBA_fnc_localEvent;
        };
        [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
    };
    case ((_bloodVolume) < BLOOD_VOLUME_CLASS_4_HEMORRHAGE): {
        TRACE_3("Class IV Hemorrhage",_unit,_hemorrhage,_bloodVolume);
        if ((_unit getVariable [QEGVAR(conversion,convert), false]) && (isPlayer _unit) && EGVAR(conversion,enableAutomaticConversion)) then {
            [QEGVAR(conversion,convertCasualty), _unit] call CBA_fnc_localEvent;
        };
        [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_heartRate < 20 || {(_heartRate - (_aceAnFatigue / 40)) > 220}): {
        TRACE_2("heartRate Fatal",_unit,_heartRate);
        if ((_unit getVariable [QEGVAR(conversion,convert), false]) && (isPlayer _unit) && EGVAR(conversion,enableAutomaticConversion)) then {
            [QEGVAR(conversion,convertCasualty), _unit] call CBA_fnc_localEvent;
        };
        [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_map < 25 || {_map > 240}): {
        [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
        if ((_unit getVariable [QEGVAR(conversion,convert), false]) && (isPlayer _unit) && EGVAR(conversion,enableAutomaticConversion)) then {
            [QEGVAR(conversion,convertCasualty), _unit] call CBA_fnc_localEvent;
        };
    };
    case (_oxygenDelivery < 0.25): {
        [QACEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
        if ((_unit getVariable [QEGVAR(conversion,convert), false]) && (isPlayer _unit) && EGVAR(conversion,enableAutomaticConversion)) then {
            [QEGVAR(conversion,convertCasualty), _unit] call CBA_fnc_localEvent;
        };
    };
    case (_map < 45 || {_map > 190}): {
        [QACEGVAR(medical,CriticalVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_spo2 < EGVAR(breathing,SpO2_unconscious)): {
        [QACEGVAR(medical,CriticalVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_totalBloodLoss > BLOOD_LOSS_KNOCK_OUT_THRESHOLD): {
        [QACEGVAR(medical,CriticalVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_totalBloodLoss > 0): {
        [QACEGVAR(medical,LoweredVitals), _unit] call CBA_fnc_localEvent;
    };
    case (_inPain): {
        [QACEGVAR(medical,LoweredVitals), _unit] call CBA_fnc_localEvent;
    };
};
[_unit] call EFUNC(misc,handleBandageOpening);
[_unit] call EFUNC(misc,updateDamageEffects);
[_unit] call EFUNC(misc,handleTourniquetEffects);


private _isUnconscious  = _unit getVariable ["ACE_isUnconscious", false];
if (_isUnconscious) then {
    [_unit, _deltaT] call EFUNC(airway,airwayDeterioration);
};
[_unit, _deltaT] call EFUNC(airway,handlePuking);
[_unit] call EFUNC(airway,handleAirwayEffects);

if (_unit getVariable [QEGVAR(brain,concussion), 0] > 0) then {
    [_unit, _deltaT] call EFUNC(brain,concussionPFH);
};
[_unit, _deltaT] call EFUNC(brain,handleAutoregulation);
[_unit, _deltaT] call EFUNC(brain,handleBrainActivity);
{
private _side = _x;
[_unit, _side, _deltaT] call EFUNC(breathing,handleHemothoraxTreatment);
[_unit, _side, 0, _deltaT] call EFUNC(breathing,handleHemothoraxDeterioration);
[_unit, _side, _deltaT] call EFUNC(breathing,handlePneumothoraxDeterioration);
[_unit, _side, _deltaT] call EFUNC(breathing,handlePneumothoraxTreatment);
} forEach [0, 1];
[_unit, _deltaT] call EFUNC(breathing,handleTamponade);

[_unit, _deltaT] call EFUNC(pharma,updatePharmaEffects);
[_unit] call EFUNC(hypothermia,updateHypothermiaEffects);
[_unit] call EFUNC(breathing,updateTACOEffects);
[_unit] call EFUNC(breathing,handlePulseoximeter);
[_unit] call EFUNC(airway,airwayDeterioration);

END_COUNTER(Vitals);

//placed outside the counter as 3rd-party code may be called from this event
[QACEGVAR(medical,handleUnitVitals), [_unit, _deltaT]] call CBA_fnc_localEvent;

true
