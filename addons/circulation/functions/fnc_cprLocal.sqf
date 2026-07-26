#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Modified: Tomcat, Blue
 * Overwrites the cprLocal of ACE to add the success chance for CPR/AED/AED-X
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Used Revive Object <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "AED"] call kat_circulation_fnc_cprLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_reviveObject"];

private _chance = 0;
private _random = (random 100) max 1;
private _spo2ROSC = linearConversion [95, 70, GET_KAT_SPO2(_patient), 0.5, 3];
private _bvROSC = linearConversion [2600, 0, GET_BODY_FLUID_ECB(_patient), 0.5, 4];
private _CPRcount = _patient getVariable [QGVAR(cprCount), 0];
private _lucasCount = _patient getVariable [QGVAR(lucasCount), 0];
private _arrestTime = _patient getVariable [QEGVAR(vitals,arrestTime), -1];
private _cprPerfusion = _patient getVariable [QEGVAR(vitals,cprPerfusion), 0];
private _patientState = _patient getVariable [QGVAR(cardiacArrestType), 0];
private _perfusionMultiplier = linearConversion [0, 100, _cprPerfusion, 0.75, 1.35, true];
private _arrestMultiplier = linearConversion [0, 1200, _arrestTime, 1, 0.2, true];
TRACE_1("cprLocal_1",_reviveObject);
private _fnc_advRhythm = {
    params ["_patient", ["_CPR",false], "_spo2ROSC", "_bvROSC"];
    TRACE_2("cprLocal_6",_patient,_CPR);
    private _patientState = _patient getVariable [QGVAR(cardiacArrestType), 0];
    private _ht = if (GVAR(AdvRhythm_HTHold)) then {
        ((count(_patient getVariable [QGVAR(ht), []])) == 0)
    } else {
        true
    };
    TRACE_1("cprLocal_7",_ht);
    if (_CPR) then {
        if (floor (random 100) < (GVAR(AdvRhythm_CPR_ROSC_Chance) / (_spo2ROSC + _bvROSC))) then {
            _patient setVariable [QGVAR(cardiacArrestType), 0, true];
            TRACE_1("cprLocal_rosc",_patient);
        } else {
            if (_patient getVariable [QGVAR(cardiacArrestType), 0] isEqualTo 1) then {
                _patient setVariable [QGVAR(cardiacArrestType), 3, true];
                TRACE_1("cprLocal_ca3",_patient);
            } else {
                if (_patient getVariable [QGVAR(cardiacArrestType), 0] < 4) then {
                    _patient setVariable [QGVAR(cardiacArrestType), _patientState + 1, true];
                    TRACE_1("cprLocal_ca+1",_patientState+1);
                } else {
                    _patient setVariable [QGVAR(cardiacArrestType), 0, true];
                    TRACE_1("cprLocal_ca+0",_patient);
                };
            };
        };
    } else {
        if (_patientState > 2) then {
            if (floor (random 100) < (GVAR(AdvRhythm_CPR_ROSC_Chance) * (_spo2ROSC + _bvROSC)) || _patientState isEqualTo 4) then {
                _patient setVariable [QGVAR(cardiacArrestType), 0, true];
            } else {
                _patient setVariable [QGVAR(cardiacArrestType), 4, true];
            };
        };
    };

    if !(_ht) then {
        _patient setVariable [QGVAR(cardiacArrestType), 1, true];
    };

    if ((_patient getVariable [QGVAR(cardiacArrestType), 0] isEqualTo 0)) exitWith {
        [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
    };

    if (GVAR(AdvRhythm_deteriorateAfterTreatment)) then {
        [_patient, nil, false] call FUNC(handleCardiacArrest);
    };
};
private _epiDose   = [_patient, "epinephrine"] call EFUNC(misc,getCurrentDosage);
private _amioDose  = [_patient, "amiodarone"] call EFUNC(misc,getCurrentDosage);
private _lidoDose  = [_patient, "lidocaine"] call EFUNC(misc,getCurrentDosage);
private _nitroDose = [_patient, "Nitroglycerin"] call EFUNC(misc,getCurrentDosage);
private _epiCPRBonus = linearConversion [0, 30, _epiDose, 0, 8, true];
private _epiAEDBonus = linearConversion [0, 30, _epiDose, 0, 3, true];
private _amioBonus = [0, linearConversion [0, 40, _amioDose, 0, 18, true]] select ((_patientState in [4, 3]));
private _lidoBonus = [0, linearConversion [0, 40, _lidoDose, 0, 12, true]] select ((_patientState in [4, 3]));
private _nitroPenalty = linearConversion [0, 10, _nitroDose, 0, 6, true];
private _antiArrhythmics = _amioBonus max _lidoBonus;
private _synergyBonus = 0;
if ((_patientState in [4, 3]) && _epiDose > 0 && _antiArrhythmics > 0) then {
    _synergyBonus = 2;
};
TRACE_4("cprLocal_2",_epiCPRBonus,_epiAEDBonus,_lidoBonus,_amioBonus);
switch (_reviveObject) do {
    case "LUCAS": {
        if (GVAR(enable_CPR_Chances)) then {
        _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), 0.05, 0.1, true];
        };
        TRACE_1("cprLocal_3",_chance);
    };
    case "CPR": {
        if (GVAR(enable_CPR_Chances)) then {
            switch (_medic getVariable [QACEGVAR(medical,medicClass),0]) do {
                case 0: {
                    _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), GVAR(CPR_MinChance_Default), GVAR(CPR_MaxChance_Default), true];
                };
                case 1: {
                    _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), GVAR(CPR_MinChance_RegularMedic), GVAR(CPR_MaxChance_RegularMedic), true];
                };
                case 2: {
                    _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), GVAR(CPR_MinChance_Doctor), GVAR(CPR_MaxChance_Doctor), true];
                };
            };
        };
        TRACE_1("cprLocal_3",_chance);
    };
    case "AED": {
        [_patient, "activity", LSTRING(Activity_Shock), [[_medic, false, true] call ACEFUNC(common,getName), "AED"]] call ACEFUNC(medical_treatment,addToLog);
        _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), GVAR(AED_MinChance), GVAR(AED_MaxChance), true];
        TRACE_1("cprLocal_3",_chance);
    };
    case "AEDX": {
        [_patient, "activity", LSTRING(Activity_Shock), [[_medic, false, true] call ACEFUNC(common,getName), "AED-X"]] call ACEFUNC(medical_treatment,addToLog);
        _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), GVAR(AED_X_MinChance), GVAR(AED_X_MaxChance), true];
        TRACE_1("cprLocal_3",_chance);
    };
};

if (_reviveObject in ["AED", "AEDX"]) exitWith {
    if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && (_patient getVariable [QGVAR(refractoryCA), false])) then {
        _chance = _chance / 4;
    };
    private _aedMedBonus = _epiAEDBonus + _amioBonus + _lidoBonus + _synergyBonus - _nitroPenalty;
    _chance = _chance + _aedMedBonus;
    _chance = _chance max 0;
    private _patientState = _patient getVariable [QGVAR(cardiacArrestType), 0];
    private _AEDeffectivness = (_patient getVariable [QGVAR(AEDEffectiveness), 1]) max 0.2;
    _chance = _chance * _AEDeffectivness;
    _chance = _chance * _perfusionMultiplier;
    _chance = _chance * _arrestMultiplier;
    TRACE_1("cprLocal_4",_chance);
    if (GVAR(AdvRhythm)) then {
        if (_patientState > 2) then {
            if (_random <= _chance) then {
                [_patient, _spo2ROSC, _bvROSC] call _fnc_advRhythm;
            };
            _patient setVariable [QGVAR(cprCount), 2, true];
        } else {
            if (GVAR(AdvRhythm_Hardcore_Enable) && _patientState == 2) then {
                _patient setVariable [QGVAR(cardiacArrestType), 1, true];
            };
        };
    } else {
        if (_random <= _chance) then {
            [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
        };
    };
};

if !(GVAR(enable_CPR_Chances)) then {
    private _min = ACEGVAR(medical_treatment,cprSuccessChanceMin);
    private _max = ACEGVAR(medical_treatment,cprSuccessChanceMax);
    _chance = linearConversion [BLOOD_VOLUME_CLASS_4_HEMORRHAGE, BLOOD_VOLUME_CLASS_2_HEMORRHAGE, GET_BLOOD_VOLUME_LITERS(_patient), _min, _max, true];
    // ACE Medical settings are percentages (decimals, 0 <= x <= 1) instead of integers
    if ((random 1) <= _chance) then {
        if (GVAR(AdvRhythm)) then {
            [_patient, true, _spo2ROSC, _bvROSC] call _fnc_advRhythm;
        } else {
            [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
        };
    };
    _patient setVariable [QEGVAR(vitals,cprPerfusion), ((_cprPerfusion + 2) min 100), true];
} else {
    if (_reviveObject in ["LUCAS"]) then {
        if (_epiCPRBonus > 4) then {
            _chance = _chance + (2 ^ (_lucasCount/50));
            _lucasCount = _lucasCount + 0.05;
            _patient setVariable [QGVAR(lucasCount), _lucasCount, true];
        };
        
        if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && (_patient getVariable [QGVAR(refractoryCA), false])) then {
            _chance = _chance / 4;
            TRACE_1("refractory",_chance);
        };
        private _lucasMedBonus = ((_epiCPRBonus/ 10) * 1.15) - _nitroPenalty;
        _chance = _chance + _lucasMedBonus;
        private _cprShockBonus = [0, ((_amioBonus/ 10) * 0.2) + ((_lidoBonus/ 10) * 0.2)] select ((_patientState in [4, 3]));
        _chance = _chance + _cprShockBonus;
        _patient setVariable [QEGVAR(vitals,cprPerfusion), ((_cprPerfusion + 2) min 100), true];
        _chance = _chance * _perfusionMultiplier;
        _chance = _chance * _arrestMultiplier;
        _chance = _chance max 0;
        TRACE_2("cprLocal_5",_random,_chance);
        if (_random <= _chance) then {
            if (GVAR(AdvRhythm)) then {
                if (_patient getVariable [QGVAR(cardiacArrestType), 0] != 0) then {
                    [_patient, true, _spo2ROSC, _bvROSC] call _fnc_advRhythm;
                };
            } else {
                [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
            };
            _patient setVariable [QGVAR(lucasCount), 2, true];
        } else {
            _lucasCount = _lucasCount + 0.1;
            _patient setVariable [QGVAR(lucasCount), _lucasCount, true];
        };

    } else {
        _patient setVariable [QEGVAR(vitals,cprPerfusion), ((_cprPerfusion + 2) min 100), true];
        if (_epiCPRBonus > 4) then {
            _chance = _chance + (2 ^ (_CPRcount/25));
            _CPRcount = _CPRcount + 1;
            _patient setVariable [QGVAR(cprCount), _CPRcount, true];
            TRACE_2("_CPRcount",_chance,_CPRcount);
        };

        if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && (_patient getVariable [QGVAR(refractoryCA), false])) then {
            _chance = _chance / 4;
            TRACE_1("refractoryCA",_chance);
        };
        private _cprMedBonus = _epiCPRBonus - _nitroPenalty;
        private _cprShockBonus = [0, (_amioBonus * 0.25) + (_lidoBonus * 0.25)] select ((_patientState in [4, 3]));
        _chance = _chance + _cprMedBonus;
        _chance = _chance + _cprShockBonus;
        _chance = _chance * _perfusionMultiplier;
        _chance = _chance * _arrestMultiplier;
        TRACE_2("cprLocal_5",_random,_chance);
        if (_random <= _chance) then {
            if (GVAR(AdvRhythm)) then {
                if (_patient getVariable [QGVAR(cardiacArrestType), 0] != 0) then {
                    [_patient, true, _spo2ROSC, _bvROSC] call _fnc_advRhythm;
                };
            } else {
                [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
            };
            _patient setVariable [QGVAR(cprCount), 2, true];
        } else {
            _CPRcount = _CPRcount + 1;
            _patient setVariable [QGVAR(cprCount), _CPRcount, true];
        };
    };
};
