#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Local callback for bandaging a patient's open wounds.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
 * 2: Treatment <STRING>
 * 3: Bandage effectiveness coefficient <NUMBER> (default: 1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "Head", "FieldDressing"] call ace_medical_treatment_fnc_bandageLocal
 *
 * Public: No
 */

params ["_patient", "_bodyPart", "_bandage", ["_bandageEffectiveness", 1, [0]]];
TRACE_4("bandageLocal",_patient,_bodyPart,_bandage,_bandageEffectiveness);
_bodyPart = toLowerANSI _bodyPart;

private _openWounds = GET_OPEN_WOUNDS(_patient);
private _woundsOnPart = _openWounds getOrDefault [_bodyPart, []];
if (_woundsOnPart isEqualTo []) exitWith {};

// Figure out which injuries for this bodypart are the best choice to bandage
private _targetWounds = [_patient, _bandage, _bodyPart, _bandageEffectiveness * ACEGVAR(medical_treatment,bandageEffectiveness)] call FUNC(findMostEffectiveWounds);
// Everything is patched up on this body part already
if (count _targetWounds == 0) exitWith {};

private _treatedDamage = 0;
private _clearConditionCache = false;

{
    private _wound = _x;
    _wound params ["_classID", "_amountOf", "_bleeding", "_damage"];
    _y params ["_effectiveness", "_woundIndex", "_impact"];

    // clear condition cache if we stopped all bleeding for this injury
    if (!_clearConditionCache) then {
        _clearConditionCache = (_effectiveness >= _amountOf);
    };

    // Reduce the amount this injury is present
    (_woundsOnPart select _woundIndex) set [1, _amountOf - _impact];

    // Store treated damage for clearing trauma
    _treatedDamage = _treatedDamage + (_impact * _damage);

    // Handle reopening bandaged wounds
    if (_impact > 0 && {ACEGVAR(medical_treatment,advancedBandages) == 2}) then {
        private _className = ACEGVAR(medical_damage,woundClassNamesComplex) select _classID;
        private _reopeningChance = DEFAULT_BANDAGE_REOPENING_CHANCE;
        private _reopeningMinDelay = DEFAULT_BANDAGE_REOPENING_MIN_DELAY;
        private _reopeningMaxDelay = DEFAULT_BANDAGE_REOPENING_MAX_DELAY;

        // Get the default values for the used bandage
        private _config = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "Bandaging";

        if (isClass (_config >> _bandage)) then {
            _config = _config >> _bandage;
            _reopeningChance = getNumber (_config >> "reopeningChance");
            _reopeningMinDelay = getNumber (_config >> "reopeningMinDelay");
            _reopeningMaxDelay = getNumber (_config >> "reopeningMaxDelay") max _reopeningMinDelay;
        } else {
            WARNING_2("No config for bandage [%1] config base [%2]",_bandage,_config);
        };

        if (isClass (_config >> _className)) then {
            private _woundTreatmentConfig = _config >> _className;

            if (isNumber (_woundTreatmentConfig >> "reopeningChance")) then {
                _reopeningChance = getNumber (_woundTreatmentConfig >> "reopeningChance");
            };

            if (isNumber (_woundTreatmentConfig >> "reopeningMinDelay")) then {
                _reopeningMinDelay = getNumber (_woundTreatmentConfig >> "reopeningMinDelay");
            };

            if (isNumber (_woundTreatmentConfig >> "reopeningMaxDelay")) then {
                _reopeningMaxDelay = getNumber (_woundTreatmentConfig >> "reopeningMaxDelay") max _reopeningMinDelay;
            };
        } else {
            WARNING_2("No config for wound type [%1] config base [%2]",_className,_config);
        };
        private _delay = ((_reopeningMinDelay + random (_reopeningMaxDelay - _reopeningMinDelay)));
        TRACE_1("",_reopeningChance);
        // Check if we are ever going to reopen this
        if (random 1 >= _reopeningChance * ACEGVAR(medical_treatment,woundReopenChance)) then {
            _delay = _delay * random [1.5, 2, 2.5];
        };
        if (GVAR(longTermBandages) && (_bandage in ["Israeli_Bandage", "ETD", "Burn_Dressing", "Hemostat", "Adhesive_Bandage"])) then {
            _delay = _delay * random [3, 6, 10];
        };
        private _classIndex = _classID / 10;
        private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
        if (_className isNotEqualTo "Contusion") then {
            private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient);
            private _exist = false;
            {
                _x params ["_id", "_amountOf", "", "", "_oldBandage", "", "_oldDelay"];
                if ((_id == _classID) && (_oldBandage == _bandage) && (_oldDelay == _delay)) exitWith {
                    _x set [1, _amountOf + _impact];
                    TRACE_2("adding to existing bandagedWound",_id,_bodyPart);
                    _exist = true;
                };
            } forEach (_bandagedWounds getOrDefault [_bodyPart, []]);

            if (!_exist) then {
                TRACE_2("adding new bandagedWound",_classID,_bodyPart);
                private _bandagedInjury = +_wound;
                _bandagedInjury set [1, _impact];
                _bandagedInjury set [4, _bandage];
                _bandagedInjury set [5, _woundIndex];
                _bandagedInjury set [6, _delay];
                (_bandagedWounds getOrDefault [_bodyPart, [], true]) pushBack _bandagedInjury;
            };


            _patient setVariable [VAR_BANDAGED_WOUNDS, _bandagedWounds, true];
        } else {
            private _wrappedWounds = GET_WRAPPED_WOUNDS(_patient);
            private _exist = false;
            {
                _x params ["_id", "_amountOf", "", "", "_oldBandage", "", "_oldDelay"];
                if ((_id == _classID) && (_oldBandage == _bandage) && (_oldDelay == _delay)) exitWith {
                    _x set [1, _amountOf + _impact];
                    TRACE_2("adding to existing bandagedWound",_id,_bodyPart);
                    _exist = true;
                };
            } forEach (_wrappedWounds getOrDefault [_bodyPart, []]);

            if (!_exist) then {
                TRACE_2("adding new bandagedWound",_classID,_bodyPart);
                private _bandagedInjury = +_wound;
                _bandagedInjury set [1, _impact];
                _bandagedInjury set [4, _bandage];
                _bandagedInjury set [5, _woundIndex];
                _bandagedInjury set [6, _delay];
                (_wrappedWounds getOrDefault [_bodyPart, [], true]) pushBack _bandagedInjury;
            };
            [_patient, _bodyPart, -(_damage * _impact)] call ACEFUNC(medical_treatment,addTrauma);
            _patient setVariable [VAR_WRAPPED_WOUNDS, _wrappedWounds, true];
        }
        
        
    };
} forEach _targetWounds;

_patient setVariable [VAR_OPEN_WOUNDS, _openWounds, true];

[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);

// Check if we fixed limping from this treatment
if (
    ACEGVAR(medical,limping) == 1
    && {_clearConditionCache}
    && {_bodyPart in ["leftleg", "rightleg", "upperleftleg", "upperrightleg"]}
    && {_patient getVariable [QACEGVAR(medical,isLimping), false]}
) then {
    [_patient] call ACEFUNC(medical_engine,updateDamageEffects);
};

if (ACEGVAR(medical_treatment,clearTrauma) == 2) then {
    TRACE_2("trauma - clearing trauma after bandage",_bodyPart,_woundsOnPart);
    [_patient, _bodyPart, -_treatedDamage] call ACEFUNC(medical_treatment,addTrauma);
};

// Reset treatment condition cache for nearby players if we stopped all bleeding
if (_clearConditionCache) then {
    private _nearPlayers = (_patient nearEntities ["CAManBase", 6]) select {_x call ACEFUNC(common,isPlayer)};
    TRACE_1("clearConditionCaches: bandage",_nearPlayers);
    [QEGVAR(interact_menu,clearConditionCaches), [], _nearPlayers] call CBA_fnc_targetEvent;
};