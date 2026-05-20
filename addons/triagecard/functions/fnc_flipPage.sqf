#include "..\script_component.hpp"
/*
 * Author: Lynx
 *
 *
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_triagecard_fnc
 *
 * Public: No
 */

params["_control"];

[ctrlParent _control] call FUNC(setData);
[QGVAR(triageCardFlip), [player, ACEGVAR(medical_gui,target)], player] call CBA_fnc_targetEvent;
