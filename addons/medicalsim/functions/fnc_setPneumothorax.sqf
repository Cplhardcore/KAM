#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Adds pneumothorax for a unit.

	Parameter(s):
		0: Unit <OBJECT>
        1: Pneumothorax type <STRING>
        2. Pneumothorax strength (Optional Default 1) <NUMBER>

	Returns:
		Nothing

	Examples:
		[player, "tension", 4, true, false] call afl_medicalsim_fnc_setPneumothorax;
*/

params ["_unit", ["_strength", [0, 0]], ["_tptx", [false, false]], ["_hptx", [0, 0]], ["_tam", 0]];
TRACE_3("setPulmo",_unit,_strength,_tam);

if (isNil "_unit") exitWith {
    ERROR_1("%1 cannot be nil.",_unit);
};


if ((selectMax _strength) > 0) then {
    _unit setVariable [QEGVAR(breathing,deepPenetratingInjury), [true, true], true];
    _unit setVariable [QEGVAR(breathing,activeChestSeal), [false, false], true];
};

// Initial
_unit setVariable [QEGVAR(breathing,pneumothorax), _strength, true];
_unit setVariable [QEGVAR(breathing,tensionpneumothorax), _tptx, true];
_unit setVariable [QEGVAR(breathing,hemopneumothorax), _hptx, true];
_unit setVariable [QEGVAR(circulation,effusion), _tam, true];

