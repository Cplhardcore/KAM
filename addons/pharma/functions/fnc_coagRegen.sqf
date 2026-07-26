#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Regenerates clots
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_coagRegen;
 *
 * Public: No
 */

params ["_unit"];

if !(GVAR(coagulation)) exitWith {};
private _lastTimeUpdated = _unit getVariable [QGVAR(lastTimeCoagUpdated), 0];
private _deltaT = (CBA_missionTime - _lastTimeUpdated) min 10;
if (_deltaT < 5) exitWith { false }; 
_unit setVariable [QGVAR(lastTimeCoagUpdated), CBA_missionTime];

private _alive = alive _unit;
if !(_alive) exitWith {};
if (!GVAR(coagulation_allowOnAI) && ACE_Player != _unit) exitWith {};
private _bv = GET_BLOOD_VOLUME_LITERS(_unit);
if (_bv < GVAR(coagulation_requireBV)) exitWith {};
if ((GET_HEART_RATE(_unit) < 20) && GVAR(coagulation_requireHR)) exitWith {};
private _ph = GET_PH(_unit);
private _ca = GET_CA(_unit);
if (_ph < 6.9) exitWith {};
if (_ca < 1.0) exitWith {};
private _bodyFluid = GET_BODY_FLUID(_unit);
private _currentCoagFactors = GET_BODY_FLUID_PLATELETS(_unit);
private _medStack = [_unit, false] call ACEFUNC(medical_status,getAllMedicationCount);
private _eacaEffectiveness = 0;
private _txaEffectiveness = 0;
{
    private _medName = toLower (_x select 0);
    private _effectiveness = _x select 2;
    if ("txa" in _medName) then {
        _txaEffectiveness = _txaEffectiveness max _effectiveness;
    };
    if ("eaca" in _medName) then {
        _eacaEffectiveness = _eacaEffectiveness max _effectiveness;
    };
} forEach _medStack;
private _calciumRegenMult = linearConversion [1.2, 2.4,_ca,0.3, 1.0,true];
private _phRegenMult = linearConversion [7.0, 7.4,_ph,0.2, 1.0,true];
private _ph = GET_PH(_unit);
private _ca = GET_CA(_unit);
private _phMax = if (_ph > 7.5) then {
    linearConversion [7.55, 7.9, _ph, 1, 0.5, true];
} else {
    linearConversion [7.3, 6.8, _ph, 1, 0.5, true];
};
private _caMax = if (_ca > 2.6) then {
    linearConversion [2.6, 3.4, _ca, 1, 0.5, true];
} else {
    linearConversion [2.2, 1.8, _ca, 1, 0.5, true];
};
if (_currentCoagFactors < (600 * (_caMax * _phMax))) exitWith {
    private _bodyFluid = GET_BODY_FLUID(_unit);
    private _baseRegen = 0.3;
    private _pain = GET_PAIN(_unit);
    private _painBoost = linearConversion [0, 1, _pain, 0.01, 0.5, true];
    private _factorDeficit = 600 - _currentCoagFactors;
    private _reboundMultiplier = 1 + (1 - exp(-3 * (_factorDeficit / 600)));
    private _regenAmount = (
        (_baseRegen + _painBoost) *
        _reboundMultiplier *
        _calciumRegenMult *
        _phRegenMult
    ) min _factorDeficit;
    private _totalAmount = _currentCoagFactors + _regenAmount;
    _bodyFluid set [5, _totalAmount];
    _unit setVariable [VAR_BODY_FLUID, _bodyFluid, true];
};  
if ((_currentCoagFactors > (600 * (_caMax * _phMax)))) exitWith {
    if (_txaEffectiveness > 0 || _eacaEffectiveness > 0) exitWith {}; // If TXA or EACA is in system don't remove factor
    private _factorOverflow = (_currentCoagFactors - 600) max 0;
    private _reboundMultiplier = exp(2 * (_factorOverflow / 600)) - 1;
    private _alkalosisDecayMult = 1;
    if (_ph > 7.5) then {
        _alkalosisDecayMult = linearConversion [7.5, 7.6, _ph, 1.0, 1.5, true];
    };
    _bodyFluid set [5, (_currentCoagFactors - ((1 * _reboundMultiplier) * _alkalosisDecayMult))];
    _unit setVariable [VAR_BODY_FLUID, _bodyFluid, true];
};

