#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Local callback for checking the pulse or heart rate of a patient.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "Head"] call kat_circulation_fnc_checkPulseLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];
private _bodyPartN = ALL_BODY_PARTS find _bodyPart;
private _occlusion = [_patient,_bodyPartN] call EFUNC(pharma,occlusionLevel);
private _isDamaged = [_patient,_bodyPartN] call EFUNC(hitpoints,damageCheck);
private _skinPerfusion = (_patient getVariable [QEGVAR(vitals,skinPerfusion), 1]) * (1 - (_occlusion * 0.4)) ;
private _capRefillOutput = LSTRING(Checkskin_Output_Normal);
private _logCapRefillOutput = LSTRING(Checkskin_Output_Normal_log);
if ((_occlusion > 0.9) || _isDamaged) then {
    _capRefillOutput = LSTRING(Check_skin_Output_NoRefill);
    _logCapRefillOutput = LSTRING(Check_skin_Output_NoRefill_log);
} else {
    switch (true) do {
        case (_skinPerfusion >= 0.8): {
            // Normal refill ≤ 2s
            _capRefillOutput = LSTRING(Checkskin_Output_Normal);
            _logCapRefillOutput = LSTRING(Checkskin_Output_Normal_log);
        };
        case (_skinPerfusion >= 0.6): {
            // Normal refill ≤ 2s
            _capRefillOutput = LSTRING(Checkskin_Output_SlightlyDelayed);
            _logCapRefillOutput = LSTRING(Checkskin_Output_SlightlyDelayed_log);
        };
        case (_skinPerfusion >= 0.3): {
            // Delayed refill ~3-4s
            _capRefillOutput = LSTRING(Checkskin_Output_Delayed);
            _logCapRefillOutput = LSTRING(Checkskin_Output_Delayed_log);
        };
        case (_skinPerfusion >= 0): {
            // Severely delayed refill ≥ 5s
            _capRefillOutput = LSTRING(Checkskin_Output_SeverelyDelayed);
            _logCapRefillOutput = LSTRING(Checkskin_Output_SeverelyDelayed_log);
        };
        default {
            // Severely delayed refill ≥ 5s
            _capRefillOutput = LSTRING(Checkskin_Output_Normal);
            _logCapRefillOutput = LSTRING(Checkskin_Output_Normal);
        };
    };
};

[_patient, "quick_view", LSTRING(Check_Neck_Output), [_medic call ACEFUNC(common,getName), _logCapRefillOutput]] call ACEFUNC(medical_treatment,addToLog);
[QACEGVAR(common,displayTextStructured), [[_capRefillOutput, _patient call ACEFUNC(common,getName)], 1.5, _medic], _medic] call CBA_fnc_targetEvent;