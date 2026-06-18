#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Parses AFL_Medicalsim_Presets config for presets.

	Parameter(s):
		Nothing

	Returns:
		Nothing

	Examples:
		[] call afl_medicalsim_fnc_parseConfigPresets;
*/

private _presetsConfigRoot = configFile >> "AFL_Medicalsim_Presets";

GVAR(simPresets) = createHashMap;
GVAR(simPresetNames) = [];

{
    private _entry = _x;
    private _className = configName _entry;

    if (_className == "Base") then { continue };

    private _wounds = GET_ARRAY(_entry >> "wounds",[]);

    private _arrestType = GET_NUMBER(_entry >> "arrestType",0);
    private _pao2 = GET_NUMBER(_entry >> "PAO2",97);
    private _circulation = [_arrestType, _pao2];

    private _obstructed = GET_ARRAY(_entry >> "obstructed",getArray (_entry >> "obstructed"));
    private _occluded = GET_ARRAY(_entry >> "occluded",getArray (_entry >> "occluded"));
    private _catastrophic = GET_ARRAY(_entry >> "catastrophic",getArray (_entry >> "catastrophic"));
    private _airway = [_occluded, _obstructed, _catastrophic];

    private _ptxStrength = GET_ARRAY(_entry >> "ptxStrength",getArray (_entry >> "ptxStrength"));
    private _tptxEnable = GET_ARRAY(_entry >> "tptxEnable",getArray (_entry >> "tptxEnable"));
    private _hptxStrength = GET_ARRAY(_entry >> "hptxStrength",getArray (_entry >> "hptxStrength"));
    private _ptxTamponade = GET_NUMBER(_entry >> "ptxTamponade",0);
    private _ptx = [_ptxStrength, _tptxEnable, _hptxStrength, _ptxTamponade];

    private _fractures = GET_ARRAY(_entry >> "fractures",[]);

    private _uncon = GET_NUMBER(_entry >> "uncon",0);
    private _misc = [_uncon];

    private _details = [_wounds, _circulation, _airway, _ptx, _fractures, _misc];

    GVAR(simPresets) set [_className, _details];
    GVAR(simPresetNames) pushBack _className;
} forEach configProperties [_presetsConfigRoot, "isClass _x"];
