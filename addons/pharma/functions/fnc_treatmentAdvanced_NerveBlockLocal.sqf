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
private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
[{
    params ["_patient", "_partIndex"];
    private _anesthesiaArray = _patient getVariable [QEGVAR(pharma,localAnesthesia), [0,0,0,0,0,0,0,0,0,0,0,0]];
    _anesthesiaArray set [_partIndex, 1];
    _patient setVariable [VAR_LOCAL_ANESTHESIA, _anesthesiaArray, true];
}, [_patient,_partIndex], 5] call CBA_fnc_waitAndExecute;
