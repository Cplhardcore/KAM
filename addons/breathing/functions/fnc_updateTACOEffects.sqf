#include "..\script_component.hpp"
/*
 * Author: Blue
 * Inflict advanced pneumothorax
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Deterioration chance increase <NUMBER>
 * 2: Has deteriorated? <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 15, 1, false] call kat_breathing_fnc_inflictAdvancedPneumothorax;
 *
 * Public: No
 */

params ["_patient"];
private _taco = _patient getVariable [QGVAR(TACO), 0];
private _strain = _patient getVariable [QGVAR(TACOStrain), 0];
_taco = _taco - 0.001;
_patient setVariable [QGVAR(TACO), _taco, true];
private _strainLoss = (_taco * 0.005);
_strain = _strain - _strainLoss;
_patient setVariable [QGVAR(TACOStrain), _strain, true];