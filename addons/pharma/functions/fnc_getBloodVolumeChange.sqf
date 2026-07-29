#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Calculates the blood volume change and decreases the IVs given to the unit.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Time since last update <NUMBER>
 * 2: Global Sync Values (bloodbags) <BOOL>
 *
 * Return Value:
 * Blood volume change (liters per second) <NUMBER>
 *
 * Example:
 * [player, 1, true] call kat_pharma_fnc_getBloodVolumeChange
 *
 * Public: No
 */

params ["_unit", "_deltaT", "_syncValues"];

private _bloodLoss = GET_BODY_BLEED_RATE(_unit);
private _exBloodLoss = GET_EXTERNAL_BODY_BLEED_RATE(_unit);
private _bloodPressure = GET_BLOOD_PRESSURE(_unit);
private _vasoconstriction = GET_VASOCONSTRICTION(_unit);
private _appliedPressure = GET_APPLIEDPRESSURE(_unit);
private _ECP = GET_BODY_FLUID_ECP(_unit);
private _ECB = GET_BODY_FLUID_ECB(_unit);
private _defaultHR = (_unit getVariable [QEGVAR(circulation,defaultHeartRate), 80]);
private _externalBloodLoss = (_unit getVariable [QEGVAR(circulation,externalBloodLoss), 0]);
_bloodPressure params ["_bloodPressureL", "_bloodPressureH"];
private _map = GET_MAP(_unit);
private _correctedMap = linearConversion [14.3333, 174.3333, _map, 0.05, 2, true];
TRACE_3("correctedMAP",_correctedMap,_map,_bloodPressure);
private _heartRate = GET_HEART_RATE(_unit);

private _trauma = _unit getVariable [QEGVAR(vitals,traumaState),0];
private _capLeak = linearConversion [0.4,0.9,_trauma,0,0.002,true];

private _lossVolumeChange = 0;
{
    private _occlusionLevel = [_unit,_forEachIndex] call FUNC(occlusionLevel);
    private _pressureApplied = _appliedPressure select _forEachIndex;
    _lossVolumeChange = _lossVolumeChange + (-(_deltaT/18) * (((_bloodLoss select _forEachIndex) * (_heartRate / _defaultHR) * _correctedMap * (((_ECP/_ECB) / (DEFAULT_ECP/DEFAULT_ECB))) min 2) * (_vasoconstriction select _forEachIndex) * (1 - _pressureApplied) * (1 - _occlusionLevel)));
    TRACE_9("_lossVolumeChange",_lossVolumeChange,-(_deltaT/18),(_bloodLoss select _forEachIndex),(_heartRate / _defaultHR),_correctedMap,(((_ECP/_ECB) / (DEFAULT_ECP/DEFAULT_ECB))),(_vasoconstriction select _forEachIndex),(1 - _pressureApplied),(1 - _occlusionLevel));
} forEach _bloodLoss;
_lossVolumeChange = _lossVolumeChange + _capLeak;
private _externalLossVolumeChange = 0;
{
    private _occlusionLevel = [_unit,_forEachIndex] call FUNC(occlusionLevel);
    private _pressureApplied = _appliedPressure select _forEachIndex;
    _externalLossVolumeChange = _externalLossVolumeChange + ((_deltaT/18) * (((_exBloodLoss select _forEachIndex) * (_heartRate / _defaultHR) * _correctedMap * (((_ECP/_ECB) / (DEFAULT_ECP/DEFAULT_ECB))) min 2) * (_vasoconstriction select _forEachIndex) * (1 - _pressureApplied) * (1 - _occlusionLevel)));
} forEach _exBloodLoss;
private _enableFluidShift = EGVAR(vitals,enableFluidShift);
private _fluidVolume = GET_BODY_FLUID(_unit);
TRACE_4("gbvc",_bloodLoss,_heartRate,_lossVolumeChange,_externalLossVolumeChange);
_fluidVolume params ["_ECB","_ECP","_SRBC","_ISP","_fullVolume","_platelets"];
private _HTSsalineFlow = 0;
private _salineFlow = 0;
_ECP = (_ECP + (_lossVolumeChange * LITERS_TO_ML) / 2) max 100;
_ECB = (_ECB + (_lossVolumeChange * LITERS_TO_ML) / 2) max 100;
_platelets = (_platelets + ((_lossVolumeChange * LITERS_TO_ML) / 10)) max 0;
_unit setVariable [QEGVAR(circulation,externalBloodLoss), _externalBloodLoss + _externalLossVolumeChange, _syncValues];
if (count (_unit getVariable [QACEGVAR(medical,ivBags), []]) > 0) then {
    private _bloodBags = _unit getVariable [QACEGVAR(medical,ivBags), []];
    private _IVarray = _unit getVariable [QGVAR(IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
    private _IVStatusArray = _unit getVariable [QGVAR(IVBlockStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
    private _flowCalculation = (ACEGVAR(medical,ivFlowRate) * _deltaT * 3.16);
    private _hypothermia = EGVAR(hypothermia,hypothermiaActive);
    private _vasoconstriction = GET_VASOCONSTRICTION(_unit);
    private _incomingFlowAmount = [0,0,0,0,0,0,0,0,0,0,0,0];
    private _incomingVolumeChange = [0,0,0,0,0,0,0,0,0,0,0,0];
    private _fluidWarmer = _unit getVariable [QEGVAR(hypothermia,fluidWarmer), [0,0,0,0,0,0,0,0,0,0,0,0]];
    private _fluidHeat = 0;

    _bloodBags = _bloodBags apply {
        _x params ["_bagVolumeRemaining", "_type", "_bodyPart", "_treatment", "_rateCoef", "_item", "_plateletAmount", "_phChange", "_caChange", "_uuid"];

        private _tourniquets = GET_TOURNIQUETS(_unit);
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

        private _idx = _occlusionMap findIf { _x#0 == _bodyPart };
        private _result = if (_idx != -1) then { _occlusionMap select _idx select 1 } else { [] };
        private _isOccluded = ({ _tourniquets select _x != 0 } count _result > 0) && (_IVarray select _bodyPart isNotEqualTo 13);
        if ((!_isOccluded) && ((_IVStatusArray select _bodyPart) != 1)) then {
            if (_type in ["Blood", "Saline", "Plasma", "Ringers Lactate", "PackedRBC", "Hypertonic Saline", "Hextend", "FBTK_500", "FBTK_250", "Platelets"]) then {
            private _IVflow = _unit getVariable [QGVAR(IVflow), [0,0,0,0,0,0,0,0,0,0,0,0]];
            private _IVrate = _unit getVariable [QGVAR(IVrate), [0,0,0,0,0,0,0,0,0,0,0,0]];
            private _pressureBag = _unit getVariable [QGVAR(pressureBag), [0,0,0,0,0,0,0,0,0,0,0,0]];
            if ((GET_HEART_RATE(_unit) < 20) && ((_IVarray select _bodyPart) != 14) && ((_pressureBag select _bodyPart) == 0)) then {
                _flowCalculation = _flowCalculation * 0.2;
            };
            if ((_unit getVariable [QACEGVAR(medical,CPR_provider), objNull]) != objNull) then {
                _flowCalculation = _flowCalculation * 0.6;
            };
            private _bagChange = 0;
            if (_type in ["Blood", "Saline", "Plasma", "Ringers Lactate", "PackedRBC", "Hypertonic Saline", "Hextend", "Platelets"]) then {
            _bagChange = (_flowCalculation * (_IVflow select _bodyPart) * (1 - (((_IVStatusArray select _bodyPart) min 1) max 0)) * (_IVrate select _bodyPart) * (1 + (_pressureBag select _bodyPart)) * _rateCoef) min _bagVolumeRemaining; // absolute value of the change in miliLiters
            if ((_IVarray select _bodyPart) in [2,3,4]) then {
                _bagChange = _bagChange * ((1 * (_vasoconstriction select _bodyPart)) max 0.2);
            };
            if (_plateletAmount > 0) then {
                if ((random 100) < 2) then {
                    private _amount = linearConversion [0, 2, _plateletAmount, 0.001, 0.03];
                    _IVStatusArray set [_bodyPart, (_IVStatusArray select _bodyPart) + _amount];
                    _unit setVariable [QGVAR(IVBlockStatus),_IVStatusArray, true];
                };
            };
            _bagVolumeRemaining = _bagVolumeRemaining - _bagChange;
            _incomingFlowAmount set [_bodyPart, ((_incomingFlowAmount select _bodyPart) + _bagChange)];
            _unit setVariable [QGVAR(IVincomingFlowAmount), _incomingFlowAmount, true];
            private _totalFlow = 0;
            {
                _totalFlow = _totalFlow + _x;
            } forEach _incomingFlowAmount;
            TRACE_8("IV",_bagChange,_IVrate,_IVflow,_IVarray,_isOccluded,_rateCoef,_flowCalculation,_bodyPart);
            TRACE_2("IV2",_bagVolumeRemaining,_incomingFlowAmount);
            private _flowRatio = ((_incomingFlowAmount select _bodyPart) max 0.01) / ((_IVrate select _bodyPart) max 0.01);
            private _vasoFactor = 1 / ((_vasoconstriction select _bodyPart) max 0.2);
            private _capacity = 4 * _vasoFactor * ((_IVrate select _bodyPart) max 0.01);
            private _pressure = 1 + (_pressureBag select _bodyPart);
            private _overload = (_flowRatio * _pressure) / _capacity;
            private _chance = linearConversion [1, 3, _overload, 0, 100, true];
            if ((GVAR(LimbIVComplications)) && (_overload > 1) && ((random 100) < _chance)) then {
                private _incomingFlowDifference = (_incomingFlowAmount select _bodyPart) - (5 * ((1 * (_vasoconstriction select _bodyPart)) max 0.2));
                [_unit, _bodyPart, _incomingFlowDifference] call FUNC(handleLimbIVComplications)};
            if (GVAR(IVComplications)) then {
                private _hr = GET_HEART_RATE(_unit);
                private _bp = GET_BLOOD_PRESSURE(_unit) select 0;
                private _lungCondition = (_unit getVariable [QEGVAR(breathing,lungSurfaceArea), 400]);
                private _riskCoef = 1;
                if (_hr < 50) then {_riskCoef = _riskCoef * (linearConversion [50, 30, _hr, 1, 1.5, true])};
                if (_bp < 90) then {_riskCoef = _riskCoef * (linearConversion [90, 50, _bp, 1, 1.5, true])};
                if (_lungCondition < 350) then {_riskCoef = _riskCoef * (linearConversion [350, 150, _lungCondition, 1, 1.5, true])};
                private _fixedVaso = 0;
                {
                    _fixedVaso = _fixedVaso + _x;
                } forEach _vasoconstriction;
                private _fixedVaso = (_fixedVaso /12);
                private _maxSafeFlow = (20 * ((1 * _fixedVaso) max 0.2)) / _riskCoef;
                if (_totalFlow > _maxSafeFlow) then {
                    [_unit, (_totalFlow - _maxSafeFlow)] call FUNC(handleIVComplications)
                    };
                };
            if (_hypothermia) then {
                // If fluid warmers are on the line, fluids are "warmed" and added to the warmer. If there is no fluid warmer on the line, the fluids stayed cooled
                if (_fluidWarmer select _bodyPart == 1) then {
                    _incomingVolumeChange set [_bodyPart, ((_incomingVolumeChange select _bodyPart) + _bagChange)];
                } else {
                    _incomingVolumeChange set [_bodyPart, ((_incomingVolumeChange select _bodyPart) - _bagChange)];
                };
            };
            if ((_type == "Blood") && (_bagChange > 1)) then {
                if !([_unit, _treatment] call EFUNC(circulation,compatible)) then {
                    private _medCount = [_unit, "BloodPoisoning_Override"] call ACEFUNC(medical_status,getMedicationCount) select 1;
                    if (_medCount < 0.05) then {
                        [_unit, "BloodPoisoning_Override", 0, 30, 0, 0, 0, 0, 0, 0, 0, 0.2, 0.3, 0, 0, 0, 0, 1] call EFUNC(vitals,addMedicationAdjustment);
                    };
                    private _bloodlevels = GET_BODY_FLUID(_unit);
                    _bloodlevels set [0, ((_bloodlevels select 0) - 8) max 0];
                    _bloodlevels set [1, ((_bloodlevels select 1) + 8) max 0];
                    _bloodlevels set [5, ((_bloodlevels select 5) - 3) max 0];
                    _unit setVariable [QEGVAR(circulation,bodyFluid), _bloodlevels, true];
                };
            };
            // Plasma adds to ECP. Saline splits between the ECP and ISP. Blood adds to ECB/ECP
            if GVAR(kidneyAction) then {
                private _ph = _unit getVariable [QGVAR(externalPh), 0];
                private _ph = (_ph + (_phChange * _bagChange));
                _unit setVariable [QGVAR(externalPh), _ph, true];
                private _ca = _unit getVariable [QGVAR(externalCa), 0];
                private _ca = (_ca + (_caChange * _bagChange));
                _unit setVariable [QGVAR(externalCa), _ca, true];
            };
            } else {
                _bagChange = (_flowCalculation * (_IVrate select _bodyPart) *  _rateCoef); // absolute value of the change in miliLiters
                if ((_IVarray select _bodyPart) in [2,3,4]) then {
                    _bagChange = _bagChange * ((2 - (_vasoconstriction select _bodyPart)) max 0.2);
                };
            };
            switch (true) do {
                case(_type == "Plasma"): {
                    _ECP = _ECP + _bagChange; _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS); 
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;};
                    
                case(_type == "Saline"): { 
                    if (_enableFluidShift) then {
                        _ECP = _ECP + (_bagChange / 2); 
                        _ISP = _ISP + (_bagChange / 2); 
                        _lossVolumeChange = _lossVolumeChange + (_bagChange / 2000);
                    } else {
                        _ECP = _ECP + _bagChange; _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
                    };
                    _salineFlow = _salineFlow + _bagChange;
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                };
                case(_type == "Ringers Lactate"): {
                    if (_enableFluidShift) then {
                        _ECP = _ECP + (_bagChange * 0.75); 
                        _ISP = _ISP + (_bagChange * 0.25); 
                        _lossVolumeChange = _lossVolumeChange + (_bagChange / 2000);
                    } else {
                        _ECP = _ECP + _bagChange; _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
                    };
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                };
                case(_type == "Blood"): { 
                    _ECB = _ECB + (_bagChange / 2); 
                    _ECP = _ECP + (_bagChange / 2); 
                    _lossVolumeChange = _lossVolumeChange + (_bagChange / 2000);
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0; 
                };
                case(_type == "PackedRBC"): {
                    private _plasma = (_fluidVolume select 1);
                    private _ph = GET_PH(_unit);
                    if ((_plasma >= 2000) && (_ph > 6.8) && (_ph < 8)) then {
                        _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                    };
                    if (_plasma >= 2000) then {
                        _ECB = _ECB + (_bagChange * 1.5); 
                        _lossVolumeChange = _lossVolumeChange + ((_bagChange * 1.5) / ML_TO_LITERS); 
                    } else {
                        _ECP = _ECP + _bagChange; 
                        _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
                    };
                };
                case(_type == "Hypertonic Saline"): { 
                    if (_enableFluidShift) then {
                        private _shiftVolume = (_bagChange / 1.5);
                        _shiftVolume = _shiftVolume min _ISP;
                        _ISP = _ISP - _shiftVolume;
                        _ECP = _ECP + _shiftVolume;
                        _ECP = _ECP + (_bagChange - _shiftVolume);
                    
                        _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
                    } else {
                        _ECP = _ECP + _bagChange; _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
                    };
                    _HTSsalineFlow = _HTSsalineFlow + _bagChange;
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                };
                case(_type == "Hextend"): {
                    _ECP = _ECP + (_bagChange * 1.5); 
                    _lossVolumeChange = _lossVolumeChange + ((_bagChange * 1.5) / ML_TO_LITERS); 
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                };
                case(_type == "Platelets"): {
                    _ECP = _ECP + (_bagChange * 0.5); 
                    _lossVolumeChange = _lossVolumeChange + ((_bagChange * 0.5) / ML_TO_LITERS); 
                    _platelets = (_platelets + (_plateletAmount * _bagChange)) max 0;
                };
                case(_type == "FBTK_250"): {
                    if (_bagVolumeRemaining < 250) then {
                        _bagVolumeRemaining = (_bagVolumeRemaining + _bagChange) min 250;
                        _ECB = _ECB - (_bagChange / 2); 
                        _ECP = _ECP - (_bagChange / 2);
                        _platelets = _platelets - (0.1 * _bagChange);
                        _lossVolumeChange = _lossVolumeChange - (_bagChange / ML_TO_LITERS); 
                    };
                };
                case(_type == "FBTK_500"): {
                    if (_bagVolumeRemaining < 500) then {
                        _bagVolumeRemaining = (_bagVolumeRemaining + _bagChange) min 500;
                        _ECB = _ECB - (_bagChange / 2); 
                        _ECP = _ECP - (_bagChange / 2);
                        _platelets = _platelets - (0.1 * _bagChange);
                        _lossVolumeChange = _lossVolumeChange - (_bagChange / ML_TO_LITERS); 
                    };
                };
            };
            
            private _damageAmount = [_unit,_idx] call EFUNC(hitpoints,damageAmount);
            if ((_damageAmount > GVAR(ivLeakageThreshold)) && GVAR(ivCheckLimbDamage)) then {
                private _lostFluids = linearConversion [GVAR(ivLeakageThreshold), 50, _damageAmount, 1, 0, true];
                private _leakAmount = _bagChange * (1 - _lostFluids);
                _ECB = _ECB - _leakAmount;
                _ECP = _ECP - _leakAmount;
                _platelets = _platelets - _leakAmount;
                _ISP = _ISP - _leakAmount;
            };
            private _leakAmount = ((_unit getVariable [QGVAR(IVLeakStatus), [0,0,0,0,0,0,0,0,0,0,0,0]]) select _bodyPart);
            if (_leakAmount > 0) then {
                private _leak = _bagChange * (1 - _leakAmount);
                _ECB = _ECB - _leak;
                _ECP = _ECP - _leak;
                _platelets = _platelets - _leak;
                _ISP = _ISP - _leak;
            };
        } else {
            private _IVflow = _unit getVariable [QGVAR(IVflow), [0,0,0,0,0,0,0,0,0,0,0,0]];
            private _IVrate = _unit getVariable [QGVAR(IVrate), [0,0,0,0,0,0,0,0,0,0,0,0]];
            private _bagChange = (_flowCalculation * (_IVflow select _bodyPart) * (_IVrate select _bodyPart) * _rateCoef) min _bagVolumeRemaining;
            private _medicationMult = ((_flowCalculation * (_IVflow select _bodyPart) * (_IVrate select _bodyPart) * _rateCoef)) ;
            _bagVolumeRemaining = _bagVolumeRemaining - _bagChange;
            _incomingFlowAmount set [_bodyPart, ((_incomingFlowAmount select _bodyPart) + _bagChange)];
            _unit setVariable [QGVAR(IVincomingFlowAmount), _incomingFlowAmount, true];
            private _defaultConfig = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "IV";
            private _ivConfig = _defaultConfig >> _treatment;
            private _painReduce             = (GET_NUMBER(_ivConfig >> "painReduce",getNumber (_defaultConfig >> "painReduce")) * _medicationMult);
            private _viscosityChange        = (GET_NUMBER(_ivConfig >> "viscosityChange",getNumber (_defaultConfig >> "viscosityChange")) * _medicationMult);
            private _timeInSystem           = (GET_NUMBER(_ivConfig >> "timeInSystem",getNumber (_defaultConfig >> "timeInSystem")));
            private _timeTillMaxEffect      = (GET_NUMBER(_ivConfig >> "timeTillMaxEffect",getNumber (_defaultConfig >> "timeTillMaxEffect")) * _medicationMult);
            private _hrIncreaseLow          = GET_ARRAY(_ivConfig >> "hrIncreaseLow",getArray (_defaultConfig >> "hrIncreaseLow"));
            private _hrIncreaseNormal       = GET_ARRAY(_ivConfig >> "hrIncreaseNormal",getArray (_defaultConfig >> "hrIncreaseNormal"));
            private _hrIncreaseHigh         = GET_ARRAY(_ivConfig >> "hrIncreaseHigh",getArray (_defaultConfig >> "hrIncreaseHigh"));
            private _alphaFactor            = (GET_NUMBER(_ivConfig >> "alphaFactor",getNumber (_defaultConfig >> "alphaFactor")) * _medicationMult);
            private _maxRelief              = (GET_NUMBER(_ivConfig >> "maxRelief",getNumber (_defaultConfig >> "maxRelief")) * _medicationMult);
            private _opioidRelief           = (GET_NUMBER(_ivConfig >> "opioidRelief",getNumber (_defaultConfig >> "opioidRelief")) * _medicationMult);
            private _opioidEffect           = (GET_NUMBER(_ivConfig >> "opioidEffect",getNumber (_defaultConfig >> "opioidEffect")) * _medicationMult);
            private _dose                   = (GET_NUMBER(_ivConfig >> "dose",getNumber (_defaultConfig >> "dose")) * _medicationMult);
            private _respiratoryRate        = (GET_NUMBER(_ivConfig >> "respiratoryRate",getNumber (_defaultConfig >> "respiratoryRate")) * _medicationMult);
            private _opioidDepression       = (GET_NUMBER(_ivConfig >> "opioidDepression",getNumber (_defaultConfig >> "opioidDepression")) * _medicationMult);
            private _contractility          = (GET_NUMBER(_ivConfig >> "contractility",getNumber (_defaultConfig >> "contractility"))* _medicationMult);
            private _nauseaMult             = (GET_NUMBER(_ivConfig >> "nauseaMult",getNumber (_defaultConfig >> "nauseaMult")) * _medicationMult);
            private _cnsSuppression         = (GET_NUMBER(_ivConfig >> "cnsSuppression",getNumber (_defaultConfig >> "cnsSuppression")) * _medicationMult);
            private _theraputicDose        = (GET_NUMBER(_ivConfig >> "theraputicDose",getNumber (_defaultConfig >> "theraputicDose")));
            private _heartRate = GET_HEART_RATE(_unit);
            private _hrIncrease = [_hrIncreaseLow, _hrIncreaseNormal, _hrIncreaseHigh] select (floor ((0 max _heartRate min 110) / 55));
            _hrIncrease params ["_minIncrease", "_maxIncrease"];
            private _heartRateChange = ((_minIncrease + random (_maxIncrease - _minIncrease)) * _medicationMult);

            private _presentPain = GET_PAIN(_unit);
            if (_maxRelief > 0) then {
                if (_presentPain > _maxRelief) then {
                    _painReduce = _painReduce / 4;
                };
            };
            TRACE_6("adjustments1",_unit,_type,_timeTillMaxEffect,_timeInSystem,_heartRateChange,_painReduce);
            TRACE_7("adjustments2",_viscosityChange,_dose,_alphaFactor,_opioidRelief,_opioidEffect,_opioidDepression,_respiratoryRate);
            private _medicationName = (_type splitString "_") select 0;
            TRACE_6("adjustments1",_unit,_medicationName,_timeTillMaxEffect,_timeInSystem,_heartRateChange,_painReduce);
            private _drugMult = linearConversion [0, 4, _medicationMult, 0.01, 4];
            private _adjustments = _unit getVariable [VAR_MEDICATIONS, []];
            private _index = _adjustments findIf {
                (_x select 0) isEqualTo _medicationName
                && {((_x select 19) select 6) == 3}
            };
            if (_index > -1) then {
                private _entry = _adjustments select _index;
                _entry params [
                    "_med", "_timeAdded", "_timeTillMaxEffect", "_maxTimeInSystem",
                    "_hrAdjust", "_painAdjust", "_flowAdjust", "_olddose", "_oldalphaFactor",
                    "_oldopioidRelief", "_oldopioidEffect", "_oldopioidDepression",
                    "_oldrespiratoryRate", "_oldcontractility", "_oldnauseaMult",
                    "_sedation", "_paralysis", "_medGraph", "_oldcnsSuppression", "_admin"
                ];
                _adjustments set [_index, [
                    _med,
                    _timeAdded,
                    _timeTillMaxEffect,
                    _maxTimeInSystem + 1.5,
                    _hrAdjust + ((_heartRateChange - _hrAdjust) * 0.25),
                    _painAdjust + ((_painReduce - _painAdjust) * 0.25),
                    _flowAdjust + ((_viscosityChange - _flowAdjust) * 0.25),
                    _olddose + ((_dose - _olddose) * 0.25),
                    _oldalphaFactor + ((_alphaFactor - _oldalphaFactor) * 0.25),
                    _oldopioidRelief + ((_opioidRelief - _oldopioidRelief) * 0.25),
                    _oldopioidEffect + ((_opioidEffect - _oldopioidEffect) * 0.25),
                    _oldopioidDepression + ((_opioidDepression - _oldopioidDepression) * 0.25),
                    _oldrespiratoryRate + ((_respiratoryRate - _oldrespiratoryRate) * 0.25),
                    _oldcontractility + ((_contractility - _oldcontractility) * 0.25),
                    _oldnauseaMult + ((_nauseaMult - _oldnauseaMult) * 0.25),
                    _sedation,
                    _paralysis,
                    _medGraph,
                    _oldcnsSuppression + ((_cnsSuppression - _oldcnsSuppression) * 0.25),
                    _admin
                ]];
                _unit setVariable [VAR_MEDICATIONS, _adjustments, true];
            } else {
                [_unit, _medicationName, _timeTillMaxEffect, _timeInSystem, _heartRateChange, _painReduce, _viscosityChange, _dose, _alphaFactor, _opioidRelief, _opioidEffect, _opioidDepression, _respiratoryRate, _contractility, _nauseaMult, 0, 0, 1, _cnsSuppression, [-1, -1, -1, 0, _drugMult, _theraputicDose, 3]] call EFUNC(vitals,addMedicationAdjustment);
            }; 
            

            if (_hypothermia) then {
                // If fluid warmers are on the line, fluids are "warmed" and added to the warmer. If there is no fluid warmer on the line, the fluids stayed cooled
                if (_fluidWarmer select _bodyPart == 1) then {
                    _incomingVolumeChange set [_bodyPart, ((_incomingVolumeChange select _bodyPart) + _bagChange)];
                } else {
                    _incomingVolumeChange set [_bodyPart, ((_incomingVolumeChange select _bodyPart) - _bagChange)];
                };
            };
            if GVAR(kidneyAction) then {
                private _ph = _unit getVariable [QGVAR(externalPh), 0];
                private _ph = (_ph + (_phChange * _bagChange));
                _unit setVariable [QGVAR(externalPh), _ph, true];
            };
            if (_enableFluidShift) then {
                _ECP = _ECP + _bagChange / 2; 
                _ISP = _ISP + _bagChange / 2; 
                _lossVolumeChange = _lossVolumeChange + (_bagChange / 2000);
            } else {
                _ECP = _ECP + _bagChange; _lossVolumeChange = _lossVolumeChange + (_bagChange / ML_TO_LITERS);
            };
            private _damageAmount = [_unit,_idx] call EFUNC(hitpoints,damageAmount);
            if ((_damageAmount > GVAR(ivLeakageThreshold)) && GVAR(ivCheckLimbDamage)) then {
                private _lostFluids = linearConversion [GVAR(ivLeakageThreshold), 50, _damageAmount, 1, 0, true];
                private _leakAmount = _bagChange * (1 - _lostFluids);
                _ECP = _ECP - _leakAmount;
                _ISP = _ISP - _leakAmount;
            };
            private _leakAmount = ((_unit getVariable [QGVAR(IVLeakStatus), [0,0,0,0,0,0,0,0,0,0,0,0]]) select _bodyPart);
            if (_leakAmount > 0) then {
                private _leak = _bagChange * (1 - _leakAmount);
                _ECP = _ECP - _leak;
                _ISP = _ISP - _leak;
            };
        };
    };
    if ((_bagVolumeRemaining < 0.01) && (_type isNotEqualTo "FBTK")) then {
            []
        } else {
            [_bagVolumeRemaining, _type, _bodyPart, _treatment, _rateCoef, _item, _plateletAmount, _phChange, _caChange, _uuid]
    };
    };
    _unit setVariable [QEGVAR(brain,salineFlow), _salineFlow, true];
    _unit setVariable [QEGVAR(brain,HTSsalineFlow), _HTSsalineFlow, true];
    _bloodBags = _bloodBags - [[]]; // remove empty bags
    if (_bloodBags isEqualTo []) then {
        _unit setVariable [QACEGVAR(medical,ivBags), nil, true]; // no bags left - clear variable (always globaly sync this)
    } else {
        _unit setVariable [QACEGVAR(medical,ivBags), _bloodBags, _syncValues];
    };

    // Incoming fluids impacting internal temperature
    if (_hypothermia) then {
        { _fluidHeat = _fluidHeat + _x; } forEach _incomingVolumeChange;

        if (_fluidHeat > 0) then {
            private _totalHeat = _unit getVariable [QEGVAR(hypothermia,warmingImpact), 0];
            _unit setVariable [QEGVAR(hypothermia,warmingImpact), _totalHeat + _fluidHeat, _syncValues];
        } else {
            private _totalCooling = _unit getVariable [QEGVAR(hypothermia,warmingImpact), 0];
            _unit setVariable [QEGVAR(hypothermia,warmingImpact), _totalCooling + _fluidHeat, _syncValues];
        };
    };
} else {
    _unit setVariable [QGVAR(IVincomingFlowAmount), [0,0,0,0,0,0,0,0,0,0,0,0], true];
    _unit setVariable [QEGVAR(brain,salineFlow), 0, true];
    _unit setVariable [QEGVAR(brain,HTSsalineFlow), 0, true];
};

if (_enableFluidShift && ((_ECP + _ECB) > 4600)) then {
    private _srbcRate = 0;
    if ((_SRBC > 0) && (_ECB < DEFAULT_ECB)) then {
        _srbcRate = linearConversion [
            DEFAULT_ECB * 0.7,
            DEFAULT_ECB,
            _ECB,
            0.05,
            0.3,
            true
        ];
    };
    private _srbcShift = _srbcRate min _SRBC;
    _SRBC = _SRBC - _srbcShift;
    _ECB  = _ECB  + _srbcShift;
    private _intravascularVol = _ECB + _ECP;
    private _targetRatio = 0.6;

    private _currentRatio =
        _intravascularVol / ((_ISP max 1));
    private _drive =
        (_targetRatio - _currentRatio);

    private _mapCoef =
        linearConversion [40, 100, _map, 0.3, 1.2, true];

    private _maxRecruit = 1.5;   // ISP → ECP
    private _maxLeak    = 0.4;   // ECP → ISP (slower)

    private _shiftRate =
        _drive
        * _mapCoef
        * ([_maxLeak, _maxRecruit] select (_drive > 0));

    private _shiftVolume =
        (_shiftRate * _deltaT)
        min (_ISP max 0);
    private _icp = GET_ICP(_unit);
    if (_icp > 20) then {
    _shiftVolume = _shiftVolume * 0.7;
    };
    _ISP = _ISP - _shiftVolume;
    _ECP = _ECP + _shiftVolume;
    private _HTS = (_unit getVariable [QGVAR(HTSsalineFlow),0]) min 5;
    private _availableFluid = (_ISP - 6000) max 0;
    private _icpFactor = linearConversion [15, 40, _icp, 0.5, 1.5, true];
    private _mannitol = ([_unit,"Mannitol",false] call ACEFUNC(medical_status,getMedicationCount)) select 1;

    if (_HTS > 0) then {
        private _htsShift = (0.25 * _HTS * _icpFactor * _deltaT) min _ISP;
        _ISP = _ISP - _htsShift;
        _ECP = _ECP + _htsShift;
    };
    if (_mannitol > 0) then {
        private _mannitolShift = (0.35 * _mannitol * _icpFactor * _deltaT) min _ISP;
        _ISP = _ISP - _mannitolShift;
        _ECP = _ECP + (_mannitolShift * 0.7);
        _ECP = _ECP - (_mannitolShift * 0.3);
    };
};

_unit setVariable [QEGVAR(circulation,bodyFluid), [_ECB, _ECP, _SRBC, _ISP, (_ECP + _ECB), _platelets], _syncValues];
TRACE_3("bloodLoss",_ECB,_ECP,(_ECP + _ECB));
((_lossVolumeChange + GET_BLOOD_VOLUME_LITERS(_unit)) max 0.01)
