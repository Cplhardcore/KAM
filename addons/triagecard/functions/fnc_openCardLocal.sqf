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
 
params["_medic","_patient"];
ACEGVAR(medical_gui,target) = _patient;
ACEGVAR(medical_gui,pendingReopen) = false;
if (dialog) then {
	closeDialog 0;
};
createDialog QGVAR(triageCardDialog);
