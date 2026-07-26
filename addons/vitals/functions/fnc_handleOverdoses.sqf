#include "..\script_component.hpp"
/*
 * Author: Glowbal, Cplhardcore
 * Handles the medication given to a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Medication Treatment classname <STRING>
 * 2: Incompatible medication <ARRAY of <STRING, NUMBER>>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "morphine", [["x", 1]]] call kat_pharma_fnc_onMedicationUsage
 *
 * Public: No
 */
 
params ["_target", "_medication", "_ld50", "_od50", "_chanceToOD"];

private _currentDose = [_target, _medication] call EFUNC(misc,getCurrentDosage);
TRACE_4("handleOD",_medication,_ld50,_od50,_chanceToOD);
if (_currentDose > _ld50) then {
    TRACE_1("exceeded lethal dose",_currentDose);
    private _reason = format ["lethaldose_%1", _medication];
    [_target, _reason] call EFUNC(conversion,setDead);
};
if (_od50 > 0) then {
    TRACE_2("onMedUsage2",_currentDose,_medication);
    // Because both {floor random 0} and {floor random 1} return 0
    private _medName = format ["%1Overdose",_medication];
    private _currentOverdose = ([_target, _medName] call EFUNC(misc,getMedicationCount)) select 1;
    if (_currentOverdose != 0) exitWith {
        private _adjustments = _target getVariable [VAR_MEDICATIONS, []];
        {
            _x params ["_oDmedication", "", "", "_timeInSystem"];
            if (_oDmedication isEqualTo _medName) exitWith {
                _x set [3, _timeInSystem + 1.5];
            };
        } forEach _adjustments;
        _target setVariable [VAR_MEDICATIONS, _adjustments, true];
        [format ["kat_pharma_%1OverdoseLocal", toLower _medication], [_target], _target] call CBA_fnc_targetEvent;
    };
    if ((_currentDose > _od50) && ((random 100) < (_chanceToOD * linearConversion [0, _ld50 -_od50, _od50 - _currentDose, 1, 15, true]))) then {
        TRACE_1("exceeded max dose",_currentDose);
        [format ["kat_pharma_%1OverdoseLocal", toLower _medication], [_target], _target] call CBA_fnc_targetEvent;
    };
};
