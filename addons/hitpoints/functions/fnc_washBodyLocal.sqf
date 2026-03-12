#include "..\script_component.hpp"
/*
 * Author: Cplhardcore, 
 * Function to wrap all wrappable wounds on a specified body part
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Body part ("Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg") <STRING>
 *
 * Return Value:
 * True if at least one wound was wrapped, otherwise false <BOOL>
 *
 * Example:
 * [player, "RightLeg"] call kat_hitpoints_fnc_wrapWound
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

_patient setVariable [QEGVAR(circulation,externalBloodLoss), 0, true];
[_patient, false, false, false, false] call ACEFUNC(medical_engine,updateBodyPartVisuals);