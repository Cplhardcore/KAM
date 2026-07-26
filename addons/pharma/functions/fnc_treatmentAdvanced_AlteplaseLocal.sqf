#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Alteplase
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call kat_pharma_fnc_treatmentAdvanced_AlteplaseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _medicationArray = _patient getVariable [QACEGVAR(medical,medications), []];
{
    _x params ["_medication"];
    private _lowerMed = toLower _medication;
    if (
        (_lowerMed find "txa" != -1) ||
        (_lowerMed find "eaca" != -1)
    ) then {
        _medicationArray deleteAt (_medicationArray find _x);
    };
} forEach _medicationArray;
_patient setVariable [QACEGVAR(medical,medications), _medicationArray, true];
private _surfaceArea = (_patient getVariable [QEGVAR(breathing,lungSurfaceArea), 400]) + 5;
if (_surfaceArea < 400) then {
    _patient setVariable [QEGVAR(breathing,lungSurfaceArea), _surfaceArea, true];
};
private _bloodlevels = GET_BODY_FLUID(_patient);
_bloodlevels set [5, ((_bloodlevels select 5) - 2) max 0];
_patient setVariable [QEGVAR(circulation,bodyFluid), _bloodlevels, true];
