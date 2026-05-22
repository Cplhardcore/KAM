#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Lidocaine
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_LidocaineOverdoseLocal;
 *
 * Public: No
 */
params ["_medic", "_patient", "_bodyPart"];

[QGVAR(nerveBlockLocal), [_medic, _patient, _bodyPart], _patient] call CBA_fnc_targetEvent;
