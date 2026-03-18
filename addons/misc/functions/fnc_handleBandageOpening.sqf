#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Handles the bandage of a patient.
 *
 * Arguments:
 * 0: The target <OBJECT>
 * 1: The impact <NUMBER>
 * 2: Body part <STRING>
 * 3: Injury index <NUMBER>
 * 4: Injury <ARRAY>
 * 5: Used Bandage type <STRING>
 * 6: New Bandage <Bool> Optional, default is true
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_target"];

private _fnc_processWounds = {
    params ["_target", "_part", "_wounds", "_eachIndex", "_variable"];
    _wounds params ["_classID", "_amountOf", "_bleeding", "", "_bandage", "_woundIndex", "_delay"];
        private _bodyPartIndex = ALL_BODY_PARTS find _part;
        private _occlusionLevel = [_target, _bodyPartIndex] call EFUNC(pharma,occlusionLevel);
        private _isBeingCarried = _target call ACEFUNC(common,isBeingCarried);
        private _speed = if (((abs (speed _target) > 1) && (isNull objectParent _target) && !_isBeingCarried)) then {
            private _config = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "Bandaging";
            private _bandageConfig = _config >> _bandage;
            if !(isClass _bandageConfig) exitWith {1};
            private _bandageMovementPenalty = GET_NUMBER(_bandageConfig >> "bandageMovementPenalty",1);
            (linearConversion [1, 12, (abs (speed _target)), 1, 3, true] * _bandageMovementPenalty) 
        } else {1};
        private _newDelay = _delay - (1 + (_bleeding * _occlusionLevel) + _speed);
        _wounds set [6, _newDelay];
        private _bandagedWounds = _target getVariable [_variable, createHashMap];
        private _partWounds = _bandagedWounds getOrDefault [_part, []];
        _partWounds set [_eachIndex, _wounds];
        _bandagedWounds set [_part, _partWounds];
        _target setVariable [_variable, _bandagedWounds, true];
        if (_newDelay <= 0) then {
            private _openWounds = GET_OPEN_WOUNDS(_target);
            private _woundsOnPart = _openWounds getOrDefault [_part, []];
            if (count _woundsOnPart - 1 < _woundIndex) exitWith { TRACE_2("index bounds",_woundIndex,count _woundsOnPart); };
            private _fixedClassID = floor _classID;
            private _selectedInjury = _woundsOnPart select _woundIndex;
            _selectedInjury params ["_selClassID", "_selAmount", "", "_selDamage"];
            if (_selClassID == _fixedClassID) then { // matching the IDs
                _wounds set [1, 0];
                TRACE_2("Before openWound update",_openWounds,_bandagedWounds);
                    TRACE_2("Reopening Wound",_bandagedWounds,_openWounds);
                    _selectedInjury set [1, _selAmount + _amountOf];
                    TRACE_3("Reopening Wound2",_selectedInjury,_amountOf,_selAmount);
                    _target setVariable [_variable, _bandagedWounds, true];
                    _target setVariable [VAR_OPEN_WOUNDS, _openWounds, true];
                    [_target] call ACEFUNC(medical_status,updateWoundBloodLoss);
                    private _partIndex = ALL_BODY_PARTS find _part;
                    // Re-add trauma and damage visuals
                    if (ACEGVAR(medical_treatment,clearTrauma) == 2) then {
                        [_target, _part, _selDamage * _amountOf] call ACEFUNC(medical_treatment,addTrauma);
                    };
                    private _classIndex = _selClassID / 10;
                    private _className = ACEGVAR(medical_damage,woundClassNames) select _classIndex;
                    if (_className isEqualTo "Contusion") then {
                        [_target, _part, _selDamage * _amountOf] call ACEFUNC(medical_treatment,addTrauma);
                    };
                    // Check if we gained limping from this wound re-opening
                    if ((ACEGVAR(medical,limping) == 1) && {_partIndex > 7}) then {
                        [_target] call FUNC(updateDamageEffects);
                    };
            };
        }; 
};
private _woundVariables = [
    VAR_BANDAGED_WOUNDS,
    VAR_COAGED_WOUNDS,
    VAR_WRAPPED_WOUNDS
];
{
    private _variable = _x;

    private _bandagedWounds = _target getVariable [_variable, createHashMap];

    {
        private _part = _x;
        private _wounds = _bandagedWounds getOrDefault [_part, []];

        {
            [_target, _part, _x, _forEachIndex, _variable] call _fnc_processWounds;
        } forEach _wounds;

    } forEach (keys _bandagedWounds);

    _target setVariable [_variable, _bandagedWounds, true];

} forEach _woundVariables;
