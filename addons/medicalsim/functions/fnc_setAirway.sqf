#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Sets airway for unit.

	Parameter(s):
		0: Unit <OBJECT>
        1: Occlusion <BOOL>
        2: Obstruction <BOOL>
        3: SPO2 <NUMBER>

	Returns:
		Nothing

	Examples:
		[player, "true", "true", 90] call afl_common_fnc_setAirway;
*/

params["_unit", "_occluded", "_obstructed", "_catastrophic"];
TRACE_3("setAirway",_unit,_occluded,_obstructed);

_unit setVariable [QEGVAR(airway,occluded), _occluded, true];
_unit setVariable [QEGVAR(airway,obstruction), _obstructed, true];
_unit setVariable [QEGVAR(airway,catastrophicAirway), _catastrophic, true];