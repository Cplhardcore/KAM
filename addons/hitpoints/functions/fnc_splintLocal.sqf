#include "..\script_component.hpp"
/*
 * Author: PabstMirror
 * Local callback for applying a splint to a patient.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, cursorObject, "LeftLeg"] call ace_medical_treatment_fnc_splintLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];
TRACE_3("splintLocal",_medic,_patient,_bodyPart);

private _partIndex = ALL_BODY_PARTS find toLowerANSI _bodyPart;

private _fractures = GET_FRACTURES(_patient);
TRACE_2("handleSplintFalloff1",_partIndex,_fractures);
_fractures set [_partIndex, -1];
_patient setVariable [VAR_FRACTURES, _fractures, true];
if (GVAR(splintFalloff)) then {
    private _delay = random [60, 120, 180];
    [{
        params ["_patient", "_partIndex"];
        private _fractures = GET_FRACTURES(_patient);
        TRACE_3("handleSplintFalloff2",_patient,_partIndex,_fractures);
        if (_fractures select _partIndex == -1) then {
            _fractures set [_partIndex, 1];
            _patient setVariable [VAR_FRACTURES, _fractures, true];
            [LSTRING(SplintFellOff), 1.5, _patient] call ACEFUNC(common,displayTextStructured);
        }
    }, [_patient, _partIndex], _delay] call CBA_fnc_waitAndExecute;

    TRACE_2("splintFalloff",_patient,_bodyPart);
} else {
    _fractures set [_partIndex, -2];
};

_patient setVariable [VAR_FRACTURES, _fractures, true];
// Check if we fixed limping from this treatment
[_patient] call EFUNC(misc,updateDamageEffects);

[_patient, "ACE_splint"] call ACEFUNC(medical_treatment,addToTriageCard);
[_patient, "activity", ACELSTRING(medical_treatment,Activity_appliedSplint), [[_medic, false, true] call ACEFUNC(common,getName)]] call ACEFUNC(medical_treatment,addToLog);