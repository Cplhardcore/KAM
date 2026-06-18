#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Spawns patient based on preset;

	Parameter(s):
		0: Stretcher <OBJECT>
        1: Preset Name <STRING>

	Returns:
		0: Patient <OBJECT>

	Examples:
		[[]] call afl_medicalsim_fnc_presetSpawn;
*/
params ["_stretcher", "_presetName"];
TRACE_2("presetSpawn",_stretcher,_presetName);

private _preset = GVAR(simPresets) get _presetName;
_preset params ["_wounds", "_circulation", "_airway", "_ptx", "_fractures", "_misc"];
TRACE_1("preset params",_preset);

// Get wounds from preset
private _woundsArray = [];
{
    private _woundsN = [_x] call FUNC(chanceArrayToValue);

    if (_woundsN > 0) then {
        private _partName = ALL_BODY_PARTS select _forEachIndex;
        _woundsArray pushBack [_woundsN, _partName];
    };
} forEach _wounds;

// Get circulation values
_circulation params ["_circulation_arrestType", "_circulation_pao2"];

private _arrestType = 0;
switch (true) do {
    case (_circulation_arrestType == 0): {};
    case (_circulation_arrestType >= 1): {
        _arrestType = _circulation_arrestType;
    };
    case (_circulation_arrestType < 1): {
        if (_circulation_arrestType >= random 1) then {
            _arrestType = floor (random 4) + 1;
        };
    };
};

// Get airway values
_airway params ["_airway_occluded", "_airway_obstructed", "_airway_catastrophic"];
private _occluded = [0, 0, 0];
private _obstructed = [0, 0, 0];
private _catastrophic = [0, 0];
{
    private _isoccluded = CHANCE_TO_BOOL((_airway_occluded) select _x);
    if (_isoccluded) then {
        _occluded set [_x, linearConversion [0, 1, ((_airway_occluded) select _x), 0, 10]];
    };
} forEach _airway_occluded;

{
    private _isobstructed = CHANCE_TO_BOOL((_airway_obstructed) select _x);
    if (_isobstructed) then {
        _obstructed set [_x, 1];
    };
} forEach _airway_obstructed;

{
    private _iscatastrophic = CHANCE_TO_BOOL((_airway_catastrophic) select _x);
    if (_iscatastrophic) then {
        _catastrophic set [_x, true];
    };
} forEach _airway_catastrophic;


// ptx
_ptx params ["_ptx_ptxStrength", "_ptx_tptxStrength", "_ptx_hptxStrength", "_ptx_ptxTamponade"];


private _ptxStrength = [0, 0];
private _tptxStrength = [false, false];
private _hptxStrength = [0, 0];
private _ptxTamponade = 0;
{
    private _isptx = CHANCE_TO_BOOL((_ptx_ptxStrength) select _x);
    if (_isptx) then {
        _ptxStrength set [_x, linearConversion [0, 1, ((_ptx_ptxStrength) select _x), 0, 8]];
    };
} forEach _ptx_ptxStrength;

{
    private _isobstructed = CHANCE_TO_BOOL((_ptx_tptxStrength) select _x);
    if (_isobstructed) then {
        _tptxStrength set [_x, true];
    };
} forEach _ptx_tptxStrength;

{
    private _ishptx = CHANCE_TO_BOOL((_ptx_hptxStrength) select _x);
    if (_ishptx) then {
        _hptxStrength set [_x, linearConversion [0, 1, ((_ptx_hptxStrength) select _x), 0, 0.5]];
    };
} forEach _ptx_hptxStrength;

private _isTamponade = CHANCE_TO_BOOL(_ptx_ptxTamponade);
if (_isTamponade) then {
    _ptxTamponade = selectRandom [0, 1, 2, 3, 4];
};

// Get fractures
private _fractureArray = [];
{
    private _fractureN = [_x] call FUNC(chanceArrayToValue);
    TRACE_1("fractureN",_fractureN);

    if (_fractureN > 0) then {
        private _fracName = FRACTURE_TYPE select _fractureN;
        private _partName = ALL_BODY_PARTS select _forEachIndex;
        _fractureArray pushBack [_partName, _fracName];
    };
} forEach _fractures;

TRACE_1("fractureArray",_fractureArray);

// Get misc
_misc params ["_misc_uncon"];

private _uncon = CHANCE_TO_BOOL(_misc_uncon);
TRACE_3("uncon",_misc,_misc_uncon,_uncon);

// Spawn patient
private _patient = _stretcher call FUNC(spawnPatient);
if (isNil "_patient") exitWith {ERROR_1("Patient %1 cannot be nil",_patient)};

// Set wounds
if (_woundsArray isNotEqualTo []) then {
    [_patient, _woundsArray] call FUNC(setWounds);
};

// Set Circulation / Airway
if (_arrestType > 0) then {
    private _arrestTypeText = ARREST_TYPE select _arrestType;
    [_patient, _arrestTypeText] call FUNC(setCardiacArrest);
};

[_patient, _occluded, _obstructed, _catastrophic] call FUNC(setAirway);

// Set PTX
[_patient, _ptxStrength, _tptxStrength, _hptxStrength, _ptxTamponade] call FUNC(setPneumothorax);
// Set fractures
{
    _x params ["_bodyPart", "_fracType"];

    [_patient, _bodyPart, _fracType] call FUNC(setFracture);
} forEach _fractureArray;

// Set uncon
if (_uncon) then {
    [_patient, true, 300] call KEFUNC(misc,setUnconscious);
};
