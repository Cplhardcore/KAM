#include "..\script_component.hpp"
/*
 * Author: Katalam, Cplhardcore
 * Checks need of airway management
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget] call kat_airway_fnc_checkAirway;
 *
 * Public: No
 */

params ["_medic", "_patient"];

private _hintPupilStatus = LLSTRING(PupilStatus_Clear);
private _pupilStatus = LSTRING(PupilStatus_Clear_short);
private _ICP = _patient getVariable [QGVAR(ICP),15];
private _rO2 = _patient getVariable [QGVAR(rO2),80];
private _CPR = _patient getVariable [QGVAR(CPR),100];
private _concussion = _patient getVariable [QGVAR(concussion),0];
private _hintWidth = 14;
private _hintSize = 2;
switch (true) do {
        switch (true) do {
        case (_ICP >= 40): {
            _hintPupilStatus = LLSTRING(PupilStatus_fixedDilatedPupil);
            _pupilStatus = LSTRING(PupilStatus_fixedDilatedPupil_short);
        };
        case (_rO2 < 30): {
            _hintPupilStatus = LLSTRING(PupilStatus_fixedDilatedPupil);
            _pupilStatus = LSTRING(PupilStatus_fixedDilatedPupil_short);
        };
        case (_ICP >= 30): {
            _hintPupilStatus = LLSTRING(PupilStatus_DilatedSLuggish);
            _pupilStatus = LSTRING(PupilStatus_DilatedSLuggish_short);
        };
        case (_rO2 < 50 || {_concussion > 0 && {_ICP > 20}}): {
            _hintPupilStatus = LLSTRING(PupilStatus_verySluggish);
            _pupilStatus = LSTRING(PupilStatus_verySluggish_short);
        };
        case (_rO2 < 70 || {_concussion > 0 && {_ICP > 15}}): {
            _hintPupilStatus = LLSTRING(PupilStatus_SLuggish);
            _pupilStatus = LSTRING(PupilStatus_SLuggish_short);
        };
        default {
            _hintPupilStatus = LLSTRING(PupilStatus_Clear);
            _pupilStatus = LSTRING(PupilStatus_Clear_short);
            _hintSize = 1.5;
            _hintWidth = 10;
        };
    };
};

[_hintPupilStatus, _hintSize, _medic, _hintWidth] call ACEFUNC(common,displayTextStructured);

[_patient, "quick_view", LSTRING(checkPupil_log)] call EFUNC(circulation,removeLog);
[_patient, "quick_view", LSTRING(checkPupil_log), [[_medic] call ACEFUNC(common,getName), _pupilStatus]] call ACEFUNC(medical_treatment,addToLog);
