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
private _oxygenDelivery = _patient getVariable [QEGVAR(vitals,oxygenDelivery), 1];
private _capRefillOutput = LSTRING(Check_capRefill_Output_Normal);
private _logCapRefillOutput = LSTRING(Check_capRefill_Output_Normal_log);
private _venousReturnOutput = LSTRING(Check_venousReturn_Output_Normal);
private _logVenousReturnOutput = LSTRING(Check_venousReturn_Output_Normal_log);
private _cardiacOutput = ((_patient call EFUNC(vitals,getCardiacOutput)) * _oxygenDelivery);
private _damage = GET_BODYPART_DAMAGE(_patient);
private _shock = _patient getVariable [QEGVAR(vitals,shockState),0];
private _micro = _patient getVariable [QEGVAR(vitals,microcirculation),0];
private _vaso = [_patient, _bodyPartN] call EFUNC(pharma,vasoconstrictionLevel);
private _vasoPerf = linearConversion [1,1.9,_vaso,1,0.3,true];
private _microPerf = linearConversion [0,1,_micro,1,0.4,true];
private _coNorm =
linearConversion [0.04, 0.10, _cardiacOutput, 0, 1, true];
private _perfusionScore =
(_coNorm * 0.5)
+ (_vasoPerf * 0.3)
+ (_microPerf * 0.2);
_perfusionScore = _perfusionScore * (1 - (_shock * 0.4));
_perfusionScore = _perfusionScore * (1 - _occlusion);
private _venousPerf = _perfusionScore;
_venousPerf = _venousPerf - (0.3 * (_damage select _bodyPartN));
_venousPerf = _venousPerf * (_shock min 1);   
if ((_occlusion > 0.9) || _isDamaged) then {
    _capRefillOutput = LSTRING(Check_capRefill_Output_NoRefill);
    _logCapRefillOutput = LSTRING(Check_capRefill_Output_NoRefill_log);
} else {
    switch (true) do {
        case (_perfusionScore >= 0.85): {
            _capRefillOutput = LSTRING(Check_capRefill_Output_Normal);
            _logCapRefillOutput = LSTRING(Check_capRefill_Output_Normal_log);
            if (_micro > 0.6) then {
                _capRefillOutput = LSTRING(Check_capRefill_Output_Normal_Mottled);
                _logCapRefillOutput = LSTRING(Check_capRefill_Output_Normal_Mottled_log);
            };
        };
        case (_perfusionScore >= 0.65): {
            _capRefillOutput = LSTRING(Check_capRefill_Output_Delayed);
            _logCapRefillOutput = LSTRING(Check_capRefill_Output_Delayed_log);
            if (_micro > 0.6) then {
                _capRefillOutput = LSTRING(Check_capRefill_Output_Delayed_Mottled);
                _logCapRefillOutput = LSTRING(Check_capRefill_Output_Delayed_Mottled_log);
            };
        };
        default {
            _capRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed);
            _logCapRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed_log);
            if (_micro > 0.6) then {
                _capRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed_Mottled);
                _logCapRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed_Mottled_log);
            };
        };
    };
};
if (_vaso > 1.7) then {
    _capRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed);
    _logCapRefillOutput = LSTRING(Check_capRefill_Output_SeverelyDelayed_log);
};

if ((_occlusion > 0.9) || _isDamaged) then {
    _venousReturnOutput = LSTRING(Check_venousReturn_Output_NoRefill);
    _logVenousReturnOutput = LSTRING(Check_venousReturn_Output_NoRefill_log);
} else {
    switch (true) do {
        case (_perfusionScore >= 0.6): {
            _venousReturnOutput = LSTRING(Check_venousReturn_Output_Normal);
            _logVenousReturnOutput = LSTRING(Check_venousReturn_Output_Normal_log);
        };
        case (_perfusionScore >= 0.25): {
            _venousReturnOutput = LSTRING(Check_venousReturn_Output_Delayed);
            _logVenousReturnOutput = LSTRING(Check_venousReturn_Output_Delayed_log);
        };
        default {
            _venousReturnOutput = LSTRING(Check_venousReturn_Output_SeverelyDelayed);
            _logVenousReturnOutput = LSTRING(Check_venousReturn_Output_SeverelyDelayed_log);
        };
    };
};

[_patient, "quick_view", LSTRING(Check_Neck_Output), [_medic call ACEFUNC(common,getName), _logCapRefillOutput]] call ACEFUNC(medical_treatment,addToLog);
[QACEGVAR(common,displayTextStructured), [[_capRefillOutput, _patient call ACEFUNC(common,getName)], 1.5, _medic], _medic] call CBA_fnc_targetEvent;
[_patient, "quick_view", LSTRING(Check_Neck_Output), [_medic call ACEFUNC(common,getName), _logVenousReturnOutput]] call ACEFUNC(medical_treatment,addToLog);