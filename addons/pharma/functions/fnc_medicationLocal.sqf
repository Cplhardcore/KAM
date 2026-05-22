
#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001
 * Modified: MiszczuZPolski, Blue, Mazinski
 * Local callback for administering medication to a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
 * 2: Treatment <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "RightArm", "Morphine"] call kat_pharma_fnc_medicationLocal
 *
 * Public: No
 */

params ["_patient", "_bodyPart", "_classname", ["_isFlushed", false], "_usedItem"];
TRACE_3("medicationLocal",_patient,_bodyPart,_classname);

// Medication has no effects on dead units
if (!alive _patient) exitWith {};

TRACE_1("Running treatmentMedicationLocal with Advanced configuration for",_patient);
if (_classname in ["CWMP", "Painkillers", "Penthrox", "Caffeine", "Pervitin", "Carbonate"]) then {
    private _airway = HAS_AIRWAY(_patient);
    if !(_airway) exitWith {
        TRACE_1("Medication  is occluded by airway",_airway);
    };
    
};
if (_classname in ["Penthrox", "Carbonate"]) then {
    private _breathing = GET_BREATHING_RATE(_patient);
    if (_breathing < 2) exitWith {
        TRACE_1("Medication cannot be inhaled",_breathing);
    };
};

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVStatusArray = _patient getVariable [QGVAR(IVBlockStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
// Handle IV blockage
if ((_IVStatusArray select _partIndex) > 0.3) exitWith {
    private _occludedMedications = _patient getVariable [QGVAR(occludedMedications), []];
    _occludedMedications pushBack [_partIndex, _classname, _patient];
    _patient setVariable [QGVAR(occludedMedications), _occludedMedications, true];
};
private _tourniquets = GET_TOURNIQUETS(_patient);
private _occlusionMap = [
    [4, [4, 5]],
    [5, [5]],
    [6, [6, 7]],
    [7, [7]],
    [8, [8, 9, 3]],
    [9, [9, 3]],
    [10, [10, 11, 3]],
    [11, [11, 3]]
];

private _idx = _occlusionMap findIf { _x#0 == _partIndex };
private _result = if (_idx != -1) then { _occlusionMap select _idx select 1 } else { [] };
private _medParts = _classname splitString "_";
private _hasValidSuffix = count _medParts > 2 && { _medParts select 2 isEqualTo "5ml" };
private _isOccluded = 
    ({ _tourniquets select _x != 0 } count _result > 0) 
    && !( ((_IVarray select _partIndex isEqualTo 13) && _hasValidSuffix));
private _isDamaged = [_patient,_partIndex] call EFUNC(hitpoints,damageCheck);
if (_isDamaged) exitWith {
    TRACE_3("Medication injection site is too damaged",_partIndex,_classname,_patient);
};

if (_isOccluded) exitWith {
    TRACE_3("Medication injection site is occluded by tourniquet",_partIndex,_classname,_patient);
    private _occludedMedications = _patient getVariable [QACEGVAR(medical,occludedMedications), []];
    _occludedMedications pushBack [_partIndex, _classname, _patient];
    _patient setVariable [QACEGVAR(medical,occludedMedications), _occludedMedications, true];
};
private _isInCA = (_patient getVariable [QACEGVAR(medical,inCardiacArrest), false] && !(alive (_patient getVariable [QACEGVAR(medical,CPR_provider), objNull])));
if (_isInCA && ((_IVarray select _partIndex) in [2,3,4]) && !_isFlushed) exitWith {
    TRACE_3("Medication injection site is occluded by CA",_partIndex,_classname,_patient);
    private _occludedMedications = _patient getVariable [QACEGVAR(medical,occludedMedications), []];
    _occludedMedications pushBack [_partIndex, _classname, _patient];
    _patient setVariable [QACEGVAR(medical,occludedMedications), _occludedMedications, true];
};

// Get adjustment attributes for used medication

// Get and calculate medication modifiers
    private _defaultConfig = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "Medication";

// Medications that should NOT be converted to syringe_x
private _excludedMeds = [
    "CWMP",
    "Painkillers",
    "Penthrox",
    "Carbonate",
    "BubbleWrap",
    "Caffeine",
    "Pervitin",
    "Naloxone"
];

private _medicationConfigName = _classname;
if !(_classname in _excludedMeds) then {
    private _parts = _classname splitString "_";
    private _medName = "";
    if ((_parts select 0) isEqualTo "syringe") then {
        _medName = _parts select 1;
    } else {
        _medName = _parts select 0;
    };
    if ((toUpper _medName) find "AUTO" >= 0) then {
        _medName = _medName select [0, (count _medName) - 4];
    };
    if ((toUpper _medName) find "IV" == ((count _medName) - 2)) then {
        _medName = _medName select [0, (count _medName) - 2];
    };
    _medicationConfigName = format ["syringe_%1", _medName];
};

private _medicationConfig = _defaultConfig >> _medicationConfigName;
TRACE_3("Medication config ",_classname,_medicationConfigName,_medicationConfig);
if (!isClass _medicationConfig) then {
    _medicationConfig = _defaultConfig;
};
TRACE_3("Medication config resolved",_classname,_medicationConfigName,_medicationConfig);
private _startDose = 1;
private _parts = (_classname splitString "_");
if (count _parts > 3) then {
    _startDose = parseNumber (_parts select -1);
};
if (_classname in ["Epinephrine", "Morphine", "Adenosine", "TXAAuto", "PhenylephrineAuto", "Atropine"]) then {
    _startDose = switch (_classname) do {
        case "Epinephrine": {10};
        case "Morphine": {10};
        case "Adenosine": {10};
        case "Atropine": {10};
        case "TXAAuto": {5};
        case "PhenylephrineAuto": {10};
    };
};
private _bloodBased = GET_STRING(_medicationConfig >> "bloodBased",getText (_defaultConfig >> "bloodBased"));
private _weightBase = GET_STRING(_medicationConfig >> "weightBased",getText (_defaultConfig >> "weightBased"));
private _weightDose = GET_NUMBER(_medicationConfig >> "weightDose",getNumber (_defaultConfig >> "weightDose"));
private _weightMult = 1;
private _weightFixed = 1;
private _weightDoseFixed = 1;
private _defaultWeight = _patient getVariable [QEGVAR(vitals,currentWeight), 80];
if (_weightBase == "true") then {
    _weightFixed = linearConversion [60, 100, _defaultWeight, 1, 3, true];
    _weightDoseFixed = _startDose;
    if (_weightDose != 20) then {
        private _weightDoseMin = GET_NUMBER(_medicationConfig >> "weightDoseMin",getNumber (_defaultConfig >> "weightDoseMin"));
        private _weightDoseMax = GET_NUMBER(_medicationConfig >> "weightDoseMax",getNumber (_defaultConfig >> "weightDoseMax"));
        _weightDoseFixed = linearConversion [_weightDoseMin, _weightDoseMax, _startDose, 1, 3, true];
    };
    _weightMult = (_weightDoseFixed/_weightFixed);
} else {
    if ((_classname find "ml") != -1) then {
        private _lc = linearConversion [10, 30, _startDose, 0.6, 1.4, true];
        _weightMult = _weightMult * _lc;
        TRACE_2("weightMult",_weightMult,_lc);
    };
};
private _medicationParts = _medicationConfigName splitString "_";
private _medicationName = _medicationParts select 1;
private _maximumEffectiveDose = 40;
private _maxOverEffective = 40;
private _currentDose = [_patient, _medicationName] call ACEFUNC(medical_status,getMedicationCount) select 0;
if !(_classname in ["CWMP", "Painkillers", "Penthrox", "Carbonate", "BubbleWrap", "Caffeine", "Pervitin", "Naloxone"]) then {
    private _doseConfig = _defaultConfig >> _medicationConfigName;
    _maximumEffectiveDose = GET_NUMBER(_doseConfig >> "maximumEffectiveDose",getNumber (_defaultConfig >> "maximumEffectiveDose"));
    _maxOverEffective = GET_NUMBER(_doseConfig >> "maxOverEffective",getNumber (_defaultConfig >> "_maxOverEffective"));
} else {
    _maximumEffectiveDose = GET_NUMBER(_medicationConfig >> "maximumEffectiveDose",getNumber (_defaultConfig >> "maximumEffectiveDose"));
    _maxOverEffective = GET_NUMBER(_medicationConfig >> "_maxOverEffective",getNumber (_defaultConfig >> "maxOverEffective"));
};
TRACE_4("medicationEffectivness",_currentDose,_medicationName,_maximumEffectiveDose,_startDose);
private _doseMult = 1;
    if ((_currentDose + _startDose) > (_maximumEffectiveDose * (_weightDoseFixed/_weightFixed))) then {
        private _excess = (_currentDose + _startDose) - _maximumEffectiveDose;
        private _reductionFactor = linearConversion [0, _maxOverEffective, _excess, 1.0, 0.01, true];
        _doseMult = _doseMult * _reductionFactor;
    };
private _routeMult = 1;
if ((_IVarray select _partIndex) in [1, 13]) then {
    _routeMult = random [0.7, 0.85, 1];
};
if ((_IVarray select _partIndex) == 14) then {
    _routeMult = random [1.1, 1.25, 1.35];
};
private _theraputicMult = linearConversion [60, 100, _defaultWeight, 0.5, 1.5, true];
private _drugMult = _weightMult * _doseMult;
private _durationMult = sqrt _drugMult;
TRACE_5("_drugMult",_patient,(GET_BLOOD_VOLUME_LITERS(_patient) / DEFAULT_BLOOD_VOLUME),_drugMult,_weightMult,_doseMult);
private _painReduce             = GET_NUMBER(_medicationConfig >> "painReduce",getNumber (_defaultConfig >> "painReduce")) * _drugMult;
private _timeInSystem           = GET_NUMBER(_medicationConfig >> "timeInSystem",getNumber (_defaultConfig >> "timeInSystem")) * _durationMult * (2 - _routeMult);
private _timeTillMaxEffect      = GET_NUMBER(_medicationConfig >> "timeTillMaxEffect",getNumber (_defaultConfig >> "timeTillMaxEffect")) * (2 - _routeMult);
private _viscosityChange        = GET_NUMBER(_medicationConfig >> "viscosityChange",getNumber (_defaultConfig >> "viscosityChange")) * _drugMult;
private _alphaFactor            = GET_NUMBER(_medicationConfig >> "alphaFactor",getNumber (_defaultConfig >> "alphaFactor")) * _drugMult;
private _opioidRelief           = GET_NUMBER(_medicationConfig >> "opioidRelief",getNumber (_defaultConfig >> "opioidRelief")) * _drugMult;
private _opioidEffect           = GET_NUMBER(_medicationConfig >> "opioidEffect",getNumber (_defaultConfig >> "opioidEffect")) * _drugMult;
private _respiratoryRate        = GET_NUMBER(_medicationConfig >> "respiratoryRate",getNumber (_defaultConfig >> "respiratoryRate")) * _drugMult;
private _opioidDepression       = GET_NUMBER(_medicationConfig >> "opioidDepression",getNumber (_defaultConfig >> "opioidDepression")) * _drugMult;
private _hrIncreaseLow          = GET_ARRAY(_medicationConfig >> "hrIncreaseLow",getArray (_defaultConfig >> "hrIncreaseLow"));
private _hrIncreaseNormal       = GET_ARRAY(_medicationConfig >> "hrIncreaseNormal",getArray (_defaultConfig >> "hrIncreaseNormal"));
private _hrIncreaseHigh         = GET_ARRAY(_medicationConfig >> "hrIncreaseHigh",getArray (_defaultConfig >> "hrIncreaseHigh"));
private _incompatibleMedication = GET_ARRAY(_medicationConfig >> "incompatibleMedication",getArray (_defaultConfig >> "incompatibleMedication"));
private _maxRelief              = GET_NUMBER(_medicationConfig >> "maxRelief",getNumber (_defaultConfig >> "maxRelief"));
private _dose                   = GET_NUMBER(_medicationConfig >> "dose",getNumber (_defaultConfig >> "dose")) * _startDose;
private _contractility          = GET_NUMBER(_medicationConfig >> "contractility",getNumber (_defaultConfig >> "contractility")) * _drugMult;
private _nauseaMult             = GET_NUMBER(_medicationConfig >> "nauseaMult",getNumber (_defaultConfig >> "nauseaMult")) * _drugMult;
private _sedation               = GET_STRING(_medicationConfig >> "sedation",getText (_defaultConfig >> "sedation"));
private _paralysis              = GET_STRING(_medicationConfig >> "paralysis",getText (_defaultConfig >> "paralysis"));
private _cnsSuppression         = GET_NUMBER(_medicationConfig >> "cnsSuppression",getNumber (_defaultConfig >> "cnsSuppression")) * _drugMult;
private _maxDose                = GET_NUMBER(_medicationConfig >> "OD50",getNumber (_defaultConfig >> "OD50"));
private _ld50                   = GET_NUMBER(_medicationConfig >> "LD50",getNumber (_defaultConfig >> "LD50"));
private _chanceToOD             = GET_NUMBER(_medicationConfig >> "chanceToOD",getNumber (_defaultConfig >> "chanceToOD"));
private _therapeutic            = GET_NUMBER(_medicationConfig >> "therapeutic",getNumber (_defaultConfig >> "therapeutic")) * _theraputicMult;
private _heartRate = GET_HEART_RATE(_patient);
private _hrIncrease = [_hrIncreaseLow, _hrIncreaseNormal, _hrIncreaseHigh] select (floor ((0 max _heartRate min 110) / 55));
_hrIncrease params ["_minIncrease", "_maxIncrease"];
private _low = _minIncrease min _maxIncrease;
private _high = _minIncrease max _maxIncrease;

private _heartRateChange =
    random [_low, (_low + _high)/2, _high] * _drugMult;
private _presentPain = GET_PAIN(_patient);
if (_maxRelief > 0) then {
    if (_presentPain > _maxRelief) then {
        _painReduce = _painReduce / 4;
    };
};
private _maxDoseMult = 1;
private _currentWeight = _patient getVariable [QEGVAR(vitals,currentWeight), 80];
_maxDoseMult = linearConversion [60, 100, _currentWeight, 0.75, 1.25, true];
private _maxDoseFixed = _maxDose * _maxDoseMult;
private _upperMed = toUpper _medicationName;
if ((_upperMed select [count _upperMed - 4]) isEqualTo "AUTO") then {
    _medicationName = _medicationName select [0, count _medicationName - 4];
};
_upperMed = toUpper _medicationName;
if ((_upperMed select [count _upperMed - 2]) isEqualTo "IV") then {
    _medicationName = _medicationName select [0, count _medicationName - 2];
};

TRACE_6("adjustments1",_patient,_medicationName,_timeTillMaxEffect,_timeInSystem,_heartRateChange,_painReduce);
TRACE_7("adjustments2",_viscosityChange,_dose,_alphaFactor,_opioidRelief,_opioidEffect,_opioidDepression,_respiratoryRate);
[_patient, _medicationName, _timeTillMaxEffect, _timeInSystem, _heartRateChange, _painReduce, _viscosityChange, _dose, _alphaFactor, _opioidRelief, _opioidEffect, _opioidDepression, _respiratoryRate, _contractility, _nauseaMult, _sedation, _paralysis, "false", _cnsSuppression, [_ld50, _maxDoseFixed, _chanceToOD, _bloodBased, 1, _therapeutic]] call EFUNC(vitals,addMedicationAdjustment);
if (_medicationName in ["Amiodarone"]) then {
[format ["kat_pharma_%1Local", toLower _medicationName], [_patient, _bodyPart], _patient] call CBA_fnc_targetEvent;
};
if (_medicationName in ["Rocuronium","Succinylcholine"]) then {
[format ["kat_pharma_%1Local", toLower _medicationName], [_patient, _dose, _timeTillMaxEffect, _timeInSystem], _patient] call CBA_fnc_targetEvent;
};
if (_medicationName in ["Ketamine","Adenosine","Lidocaine"]) then {
[format ["kat_pharma_%1Local", toLower _medicationName], [_patient, _bodyPart, _classname], _patient] call CBA_fnc_targetEvent;
};

private _TXAmedications = ["syringe_TXA_5ml_10", "syringe_TXA_10ml_10", "TXAAuto"];
    if (_classname in _TXAmedications) then {
        TRACE_1("TXADose",_patient);
        if (_classname in ["TXAAuto"]) then {
            _medicationName = _classname select [0, count _classname - 4];
        };
        private _medicationParts = (_classname splitString "_");
        if (count _medicationParts > 3) then {
                _medicationName = _medicationParts select 1;
        };
        private _medication = _medicationName;
        private _administered = _patient getVariable [QGVAR(TXAActive), []];
        private _effectTriggered = _patient getVariable [QGVAR(TXATriggered), false];
        if (!(_medication in _administered)) then {
            _administered pushBack _medication;
            _patient setVariable [QGVAR(TXAActive), _administered, true];
        };
        if (count _administered == 1) then {
            _patient setVariable [QGVAR(TXATriggered), false, true];
        [{
            params ["_patient"];
            _patient setVariable [QGVAR(TXAWindow), true, true];  
        },
        [_patient], 120] call CBA_fnc_waitAndExecute; 
        [{
            params ["_patient"];
            _patient setVariable [QGVAR(TXAWindow), false, true]; 
        },
        [_patient], 300] call CBA_fnc_waitAndExecute; 
        };
        if ((count _administered == count _TXAmedications) && (_patient getVariable [QGVAR(TXAWindow), false]) && {!_effectTriggered}) then {
            _effectTriggered = true;
            [_patient, "EACA_Override", 15, 360] call EFUNC(vitals,addMedicationAdjustment);
            [_patient, "Body"] call FUNC(treatmentAdvanced_EACALocal);
            _patient setVariable [QGVAR(TXATriggered), false, true];
            _patient setVariable [QGVAR(TXAActive), [], true];
            _patient setVariable [QGVAR(TXAWindow), false, true];
        };
    };