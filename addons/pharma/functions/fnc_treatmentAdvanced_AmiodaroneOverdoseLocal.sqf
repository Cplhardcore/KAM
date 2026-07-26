#include "..\script_component.hpp"
/*
 * Author: Mazinski.H, Edited by MiszczuZPolski and Cplhardcore
 * Handles the overdose effect Amiodarone
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AmiodaroneOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "AmiodaroneOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel > 0.01) exitWith {
   private _hrAdjust = -30 + floor random ((-10 - -30) + 1);
    [_patient, "AmiodaroneOverdose", 30, 1200, _hrAdjust, 0, 0, 0, -0.2] call EFUNC(vitals,addMedicationAdjustment); 
} else {
    private _medications = _patient getVariable [VAR_MEDICATIONS, []];
    {
        if ((_x # 0) isEqualTo "AmiodaroneOverdose") exitWith {
            _x set [3, (_x # 3) + 1.2];
        };
    } forEach _medications;
    _patient setVariable [VAR_MEDICATIONS, _medications, true];
};
if (random(1000) < 5) then {
    if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
        [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
    };
};