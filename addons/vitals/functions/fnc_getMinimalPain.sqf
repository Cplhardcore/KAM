#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Calculate the minimum pain level of a unit
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 *    Minimal Pain level (0-1)
 *
 * Example:
 * [player] call kat_vitals_fnc_getMinimalPain
 *
 * Public: No
 */

params ["_unit"];
private _minPain = 0;
if (((selectMax (_unit getVariable [VAR_FRACTURES, DEFAULT_FRACTURE_VALUES])) != 0)) exitWith {
    _minPain = 0.8;
    _minPain
};
if (_unit getVariable [QEGVAR(hitpoints,evisceration), 0] > 0) exitWith {
    _minPain = 0.8;
    _minPain
};

if (_unit getVariable [QEGVAR(hitpoints,pelvicFracture), 0] > 0) exitWith {
    _minPain = 0.8;
    _minPain
};

private _woundPain = 0;
{
    private _woundMap = _x;
    {
        private _bodyPart = _x;
        private _wounds = _y;
        {
            _x params ["_classID", "_amountOf"];
            private _category = _classID % 10;
            private _basePain = switch (_category) do {
                case 0: {0.2};
                case 1: {0.3};
                case 2: {0.4};
                default {0.3};
            };
            private _classIndex = floor (_classID / 10);
            private _className =
                ACEGVAR(medical_damage,woundClassNames) select _classIndex;
            private _typeMultiplier = switch (_className) do {
                case "VelocityWound": {1.3};
                case "Avulsion": {1.5};
                case "Laceration": {1.2};
                case "Cut": {1.5};
                case "PunctureWound": {1.2};
                case "InternalBleeding": {0};
                default {1};
            };
            _woundPain = _woundPain max (_basePain * _typeMultiplier);
        } forEach _wounds;
    } forEach _woundMap;
} forEach [
    GET_OPEN_WOUNDS(_unit),
    GET_COAGED_WOUNDS(_unit),
    GET_WRAPPED_WOUNDS(_unit),
    GET_BANDAGED_WOUNDS(_unit)
];

_minPain = _woundPain max _minPain;

_minPain