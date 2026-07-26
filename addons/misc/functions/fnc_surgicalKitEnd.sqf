#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Records in game time when tourniquet was applied
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Body Part <STRING>
 *
 * ReturnValue:
 * None
 *
 * Example:
 * [cursorObject, "LeftLeg"] call kat_misc_fnc_setTourniquetTime;
 *
 * Public: No
 */

params [];

[ACEFUNC(medical_gui,openMenu), ACEGVAR(medical_gui,target)] call CBA_fnc_execNextFrame;