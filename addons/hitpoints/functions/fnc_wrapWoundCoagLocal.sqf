#include "..\script_component.hpp"
/*
 * Author: Cplhardcore, 
 * Function to wrap all wrappable wounds on a specified body part
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Body part ("Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg") <STRING>
 *
 * Return Value:
 * True if at least one wound was wrapped, otherwise false <BOOL>
 *
 * Example:
 * [player, "RightLeg"] call kat_hitpoints_fnc_wrapWound
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

private _bandagedWounds = GET_COAGED_WOUNDS(_patient);
private _wrappedWounds = _patient getVariable [VAR_WRAPPED_WOUNDS, createHashMap];
private _wounds = _bandagedWounds getOrDefault [_bodyPart, []];
TRACE_1("WrapAllWounds1",_wounds);
private _wrappedAny = false;

private _newBandagedWounds = [];
private _newWrappedWounds = _wrappedWounds getOrDefault [_bodyPart, []];

{
    _x params ["_id", "_amount", "_bleeding", "_damage", "_bandage", "_index", "_oldDelay"];
    TRACE_4("aaa",_id,_amount,_bleeding,_bandage);
    private _classIndex = _id / 10;
     private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;

    if (("BloodClot" in _bandage) && (_className != "InternalBleeding")) then {
        // Create wrapped wound
        private _newClassID = _id + 0.01;
        private _newBandage = _bandage + "_wrapped";
        private _reopeningChance = DEFAULT_BANDAGE_REOPENING_CHANCE;
        private _reopeningMinDelay = DEFAULT_BANDAGE_REOPENING_MIN_DELAY;
        private _reopeningMaxDelay = DEFAULT_BANDAGE_REOPENING_MAX_DELAY;
        private _config = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "Bandaging";
        if (isClass (_config >> _bandage)) then {
            _config = _config >> _bandage;
            _reopeningChance = getNumber (_config >> "reopeningChance");
            _reopeningMinDelay = getNumber (_config >> "reopeningMinDelay");
            _reopeningMaxDelay = getNumber (_config >> "reopeningMaxDelay") max _reopeningMinDelay;
        } else {
            WARNING_2("No config for bandage [%1] config base [%2]",_bandage,_config);
        };
        private _delay = ((_reopeningMinDelay + random (_reopeningMaxDelay - _reopeningMinDelay)));
        if (GVAR(longTermBandages)) then {
            _delay = _delay * random [3, 6, 10];
        };
        private _newWound = [_newClassID, _amount, _bleeding, _damage, _newBandage, _index, _delay];

        TRACE_2("Wound Before/After Wrap",_x,_newWound);

        // Add to wrapped wounds
        _newWrappedWounds pushBack _newWound;
        _wrappedAny = true;
    } else {
        _newBandagedWounds pushBack _x; // keep unwrapped wounds
    };
} forEach _wounds;

// Update bandaged wounds
if (_newBandagedWounds isEqualTo []) then {
    _bandagedWounds deleteAt _bodyPart;
} else {
    _bandagedWounds set [_bodyPart, _newBandagedWounds];
};

// Update wrapped wounds
if (_newWrappedWounds isNotEqualTo []) then {
    _wrappedWounds set [_bodyPart, _newWrappedWounds];
};

// Store updated variables
_patient setVariable [VAR_COAGED_WOUNDS, _bandagedWounds, true];
_patient setVariable [VAR_WRAPPED_WOUNDS, _wrappedWounds, true];

_wrappedAny