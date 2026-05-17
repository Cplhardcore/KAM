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
params["_medic", "_patient"];
[QGVAR(triageCardOpen), [_medic, _patient], _medic] call CBA_fnc_targetEvent;
