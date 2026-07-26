#include "..\script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Handles any visual effects of medical.
 *
 * Arguments:
 * 0: Manual, instant update (optional, default false) <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call kat_feedback_fnc_handleEffects
 *
 * Public: No
 */
params [["_manualUpdate", false]];

if (ACEGVAR(common,OldIsCamera) || {!alive ACE_player}) exitWith {
    [false]    call FUNC(effectOpioid);
    [false]    call FUNC(effectLowSpO2);
    [false]    call FUNC(effectLowDO2);
    [false]    call FUNC(effectHurtEye);
    [false]    call FUNC(effectEyeInjury);
    [false]    call FUNC(effectLossCMR);
    [false]    call FUNC(effectConcussion);
};

BEGIN_COUNTER(handleEffects);

// - Current state info -------------------------------------------------------
private _opioid          = GET_PP(ACE_player);
private _spO2             = GET_KAT_SPO2(ACE_player);
private _unconscious      = IS_UNCONSCIOUS(ACE_player);
private _lungSurface     = GET_KAT_SURFACE_AREA(ACE_player);
private _wheeze = (_lungSurface < 350);
private _eyeInjurySeverity        = GET_DUST_INJURY(ACE_player);
private _eyeInjuries        = GET_EYE_INJURIES(ACE_player);
private _cmr             = GET_CMR(ACE_player);
private _do2 = ACE_player getVariable [QEGVAR(vitals,oxygenDelivery), 13];
[!_unconscious] call FUNC(effectConcussion);
// - Visual effects -----------------------------------------------------------
[!_unconscious, _opioid] call FUNC(effectOpioid);
private _spo2Die = EGVAR(breathing,SpO2_dieValue);
[
    !_unconscious,
    linearConversion [93, _spo2Die, _spO2, 0, 1, true]
] call FUNC(effectLowSpO2);
[
    !_unconscious,
    linearConversion [10, 5, _do2, 0, 0.4, true]
] call FUNC(effectLowDO2);
private _time = ACE_player getVariable [QGVAR(airwayTimer), -1];
private _timeElapsed = ACE_player getVariable [QGVAR(airwayElapsed), 0];
[!_unconscious, (_time != -1)] call FUNC(effectAirways);
[!_unconscious, (_time != -1), linearConversion [0, _time, _timeElapsed, 0.4, 1, true]] call FUNC(effectAirwaysColor);
[!_unconscious, _wheeze, ACE_player] call FUNC(effectBreathingWheeze);
[!_unconscious, _eyeInjurySeverity] call FUNC(effectEyeInjury);
[!_unconscious, _eyeInjuries, _manualUpdate] call FUNC(effectHurtEye);

[!_unconscious, _cmr] call FUNC(effectLossCMR);

END_COUNTER(handleEffects);
