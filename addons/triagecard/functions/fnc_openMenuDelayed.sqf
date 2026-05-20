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
 params ["_display"];
 [ACEFUNC(medical_gui,openMenu), ACEGVAR(medical_gui,target)] call CBA_fnc_execNextFrame;
 true