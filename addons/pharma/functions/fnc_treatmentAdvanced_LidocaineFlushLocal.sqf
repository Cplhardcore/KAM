#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Lidocaine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_LidocaineOverdoseLocal;
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];
private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
[{
    params ["_patient", "_partIndex"];
    private _anesthesiaArray = _patient getVariable [QEGVAR(pharma,localAnesthesia), [0,0,0,0,0,0,0,0,0,0,0,0]];
    _anesthesiaArray set [_partIndex, 1];
    _patient setVariable [VAR_LOCAL_ANESTHESIA, _anesthesiaArray, true];
}, [_patient,_partIndex], 5] call CBA_fnc_waitAndExecute;

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IVBlockStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
_IVarray set [_partIndex, 0];
_patient setVariable [QGVAR(IVBlockStatus), _IVarray, true];
[_patient, _bodyPart, "syringe_lidocaine_5ml_5"] call FUNC(medicationLocal);
private _occludedMedications = _patient getVariable [QACEGVAR(medical,occludedMedications), []];

private _occludedFlushed = false;

[_patient, "activity", LLSTRING(flush_log), [[_medic] call ACEFUNC(common,getName)]] call ACEFUNC(medical_treatment,addToLog);

if ([_patient, _partIndex] call FUNC(occlusionCheck)) exitWith {};

{
    _x params ["_bodyPartN", "_medication", "_patient"];

        private _isStillOccluded = [_patient, _bodyPartN] call FUNC(occlusionCheck);
        TRACE_1("delayed medication call after tourniquet removal",_isStillOccluded);
    if (!_isStillOccluded) then {
        [QGVAR(medicationLocal), [_patient, _bodyPart, _medication, true], _patient] call CBA_fnc_targetEvent;

        _occludedMedications set [_forEachIndex, []];
        _occludedFlushed = true;
    };
} forEach _occludedMedications;

if (_occludedFlushed) then {
    _occludedMedications = _occludedMedications - [[]];
    _patient setVariable [QACEGVAR(medical,occludedMedications), _occludedMedications, true];
};