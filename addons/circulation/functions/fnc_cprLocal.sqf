#define DEBUG_MODE_FULL
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
private _randomAmi = random 4;
private _epiBoost = 0;
private _amiBoost = 0;
private _lidoBoost = 0;
private _nitroEffect = 1;
private _CPRcount = _patient getVariable [QGVAR(cprCount), 0];
TRACE_1("cprLocal_1",_reviveObject);
private _fnc_advRhythm = {
    params ["_patient", ["_CPR",false]];
    TRACE_2("cprLocal_6",_patient,_CPR);
    private _patientState = _patient getVariable [QGVAR(cardiacArrestType), 0];
    private _ht = if (GVAR(AdvRhythm_HTHold)) then {
        ((count(_patient getVariable [QGVAR(ht), []])) == 0)
    } else {
        true
    };
    TRACE_1("cprLocal_7",_ht);
    if (_CPR) then {
        if (floor (random 100) < GVAR(AdvRhythm_CPR_ROSC_Chance)) then {
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
            if (floor (random 100) < GVAR(AdvRhythm_AED_ROSC_Chance) || _patientState isEqualTo 4) then {
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

{
    _x params ["_medication", "", "", "", "", "", "", "_dose"];

    switch(_medication) do
    {
        case "Epinephrine":
        {
            _epiBoost = _epiBoost + (1.25 * (_dose / 10));
        };
        case "Lidocaine":
        {
            _lidoBoost = _lidoBoost + (4 * (_dose / 10));
        };
        case "Amiodarone":
        {
            _amiBoost = _amiBoost + ((random [4,8,14]) * (_dose / 10));
        };
        case "Nitroglycerin":
        {
            _nitroEffect = (_nitroEffect + (2 * _dose));
        };
    };
} forEach (_patient getVariable [QACEGVAR(medical,medications), []]);
/*private _ph = GET_PH(_patient);
private _ca = GET_CA(_patient);
private _phChance = if (_ph > 7.5) then {
    linearConversion [7.55, 7.9, _ph, 1, 0.4, true];
} else {
    linearConversion [7.3, 6.8, _ph, 1, 0.1, true];
};
private _caChance = if (_ca > 2.6) then {
    linearConversion [2.6, 3.4, _ca, 1, 0.4, true];
} else {
    linearConversion [2.2, 1.8, _ca, 1, 0.2, true];
};*/
TRACE_3("cprLocal_2",_epiBoost,_lidoBoost,_amiBoost);
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
    _chance = _chance + (_amiBoost + (1 max _lidoBoost) * _epiBoost) / _nitroEffect;
    private _patientState = _patient getVariable [QGVAR(cardiacArrestType), 0];
    private _AEDeffectivness = (_patient getVariable [QGVAR(AEDEffectiveness), 1]) max 0.2;
    _chance = _chance * _AEDeffectivness;
    TRACE_1("cprLocal_4",_chance);
    if (GVAR(AdvRhythm)) then {
        if (_patientState > 2) then {
            if (_random <= _chance) then {
                [_patient] call _fnc_advRhythm;
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
            [_patient, true] call _fnc_advRhythm;
        } else {
            [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
        };
    };
} else {
    if (_reviveObject in ["LUCAS"]) then {
        if (_epiBoost > 1.5) then {
            _chance = _chance + (2 ^ _CPRcount);
            _CPRcount = _CPRcount + 0.01;
            _patient setVariable [QGVAR(cprCount), _CPRcount, true];
        };

        if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && _randomAmi > 2) then {
            _chance = _chance + (_amiBoost / 10);
            TRACE_1("_amiBoost",(_amiBoost / 10));
        };

        if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && (_patient getVariable [QGVAR(refractoryCA), false])) then {
            _chance = _chance / 4;
            TRACE_1("refractory",_chance);
        };
        _chance = _chance / _nitroEffect;
        TRACE_3("cprLocal_5",_random,_chance,_nitroEffect);
        if (_random <= _chance) then {
            if (GVAR(AdvRhythm)) then {
                if (_patient getVariable [QGVAR(cardiacArrestType), 0] != 0) then {
                    [_patient, true] call _fnc_advRhythm;
                };
            } else {
                [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
            };
            _patient setVariable [QGVAR(cprCount), 2, true];
        } else {
            _CPRcount = _CPRcount + 0.01;
            _patient setVariable [QGVAR(cprCount), _CPRcount, true];
        };

    } else {
        
        if (_epiBoost > 1.5) then {
        _chance = _chance + (2 ^ _CPRcount);

        _CPRcount = _CPRcount + 1;
        _patient setVariable [QGVAR(cprCount), _CPRcount, true];
        TRACE_2("_CPRcount",_chance,_CPRcount);
    };

    if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && _randomAmi > 2) then {
        _chance = _chance + (_amiBoost / 10);
        TRACE_1("_amiBoost",(_amiBoost / 10));
    };

    if (_patient getVariable [QGVAR(cardiacArrestType), 0] in [4,3] && (_patient getVariable [QGVAR(refractoryCA), false])) then {
        _chance = _chance / 4;
        TRACE_1("refractoryCA",_chance);
    };
    _chance = _chance / _nitroEffect;
    TRACE_3("cprLocal_5",_random,_chance,_nitroEffect);
    if (_random <= _chance) then {
        if (GVAR(AdvRhythm)) then {
            if (_patient getVariable [QGVAR(cardiacArrestType), 0] != 0) then {
                [_patient, true] call _fnc_advRhythm;
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
