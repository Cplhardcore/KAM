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
switch (uiNamespace getVariable [QGVAR(triageCard), 0]) do {
	case (1): {
		if (dialog) then {closeDialog 0};
		createDialog QGVAR(triageCardDialog2);
	};
	case (2): {
		if (dialog) then {closeDialog 0};
		createDialog QGVAR(triageCardDialog);
	};
};
