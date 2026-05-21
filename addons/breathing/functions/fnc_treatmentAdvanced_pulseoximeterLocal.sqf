#include "..\script_component.hpp"
/*
 * Author: Katalam
 * Puts a pulseoximeter on the patient
 * Main function
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget, "LeftArm"] call kat_breathing_fnc_treatmentAdvanced_pulseoximeterLocal;
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

if (_patient getVariable ["kat_PulseoxiInUse_PFH", false]) exitWith {};
_patient setVariable ["kat_PulseoxiInUse_PFH", true];

_patient setVariable [QGVAR(pulseoximeter), true, true];
_patient setVariable [QGVAR(PulseOximeter_VolumePatient), _medic getVariable QGVAR(PulseOximeter_Volume), true];

private _attachedPulseOximeter = _patient getVariable [QGVAR(PulseOximeter_Attached), [0,0]];
if ((ALL_BODY_PARTS find toLower _bodyPart) == 4) then {
    _attachedPulseOximeter set [0,1];
};
if ((ALL_BODY_PARTS find toLower _bodyPart) == 6) then {
    _attachedPulseOximeter set [1,1];
};
_patient setVariable [QGVAR(PulseOximeter_Attached), _attachedPulseOximeter, true];

[_patient, "activity", LSTRING(pulseoxi_Log_2), [[_medic] call ACEFUNC(common,getName)]] call ACEFUNC(medical_treatment,addToLog);
