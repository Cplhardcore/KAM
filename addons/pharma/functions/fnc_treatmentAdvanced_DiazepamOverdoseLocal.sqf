#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Naloxone.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_NaloxoneOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "DiazepamOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
private _medStack = _patient call ACEFUNC(medical_status,getAllMedicationCount);
private _fentanylEffectiveness = 0;
private _nalbuphineEffectiveness = 0;
private _morphineEffectiveness = 0;
private _lorazepamEffectiveness = 0;
{
    private _medName = toLower (_x select 0);
    private _effectiveness = _x select 2;
    private _dose = _x select 1;
    if ("fentanyl" in _medName) then {
        _fentanylEffectiveness = _fentanylEffectiveness max (_dose * _effectiveness);
    };
    if ("nalbuphine" in _medName) then {
        _nalbuphineEffectiveness = _nalbuphineEffectiveness max (_dose * _effectiveness);
    };
    if ("morphine" in _medName) then {
        _morphineEffectiveness = _morphineEffectiveness max (_dose * _effectiveness);
    };
    if ("morphine" in _medName) then {
        _morphineEffectiveness = _morphineEffectiveness max (_dose * _effectiveness);
    };
    if ("lorazepam" in _medName) then {
        _lorazepamEffectiveness = _lorazepamEffectiveness max (_dose * _effectiveness);
    };
} forEach _medStack;
private _diazapamMult = linearConversion [0, 90, (_fentanylEffectiveness + _nalbuphineEffectiveness + _morphineEffectiveness + _lorazepamEffectiveness), 1, 3, true];
if (_doseLevel < 0.01) then {
    [_patient, "DiazepamOverdose", 30, 600, 0, 0, 0, 0, 0, 0, 0, -(random [0.1, 0.15, 0.3] * _diazapamMult)] call EFUNC(vitals,addMedicationAdjustment);
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "DiazepamOverdose") exitWith {
            _x set [3, (_x # 3) + (1.2  * _diazapamMult)];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
};