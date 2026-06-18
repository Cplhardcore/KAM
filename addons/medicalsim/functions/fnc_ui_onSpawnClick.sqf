#include "..\script_component.hpp"
/*
	Author: flufflesamy

	Description:
		Handles onClick event of the Spawn button.

	Parameter(s):
		Nothing.

	Returns:
		Nothing.

	Examples:
		[] call afl_medicalsim_fnc_ui_onSpawnClick;
*/

private _stretcher = [] call FUNC(ui_getSelectedStretcher);
TRACE_1("Stretcher: %1",_stretcher);

// unfocus button
ctrlSetFocus displayCtrl IDC_STRETCHERS_LISTBOX;
false call FUNC(ui_updateClearAllButton);
false call FUNC(ui_updateSpawnAllButton);

// spawn patient
private _patient = _stretcher call FUNC(spawnPatient);
TRACE_1("Patient: %1",_patient);
if (isNil "_patient") exitWith {ERROR_1("Patient %1 cannot be nil",_patient)};

// set uncon
private _uncon = cbChecked displayCtrl IDC_MISC_UNCON_CHECKBOX;

if (_uncon) then {
    [_patient, true, 900] call EFUNC(misc,setUnconscious);
};

// set wounds
private _damageArray = [];
_damageArray pushBack [sliderPosition IDC_WOUNDS_HEAD_SLIDER, "Head"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_HEAD_SLIDER, "Neck"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_TORSO_SLIDER, "Chest"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_TORSO_SLIDER, "Body"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_LEFTARM_SLIDER, "UpperLeftArm"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_LEFTARM_SLIDER, "LeftArm"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_RIGHTARM_SLIDER, "UpperRightArm"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_RIGHTARM_SLIDER, "RightArm"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_LEFTLEG_SLIDER, "UpperLeftLeg"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_LEFTLEG_SLIDER, "LeftLeg"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_RIGHTLEG_SLIDER, "UpperRightLeg"];
_damageArray pushBack [sliderPosition IDC_WOUNDS_RIGHTLEG_SLIDER, "RightLeg"];
private _damageIndex = lbCurSel IDC_WOUNDS_DAMAGE_COMBO;
private _typeOfDamage = lbText [IDC_WOUNDS_DAMAGE_COMBO, _damageIndex];

[_patient, _damageArray, _typeOfDamage] call FUNC(setWounds);

// set cardiac arrest
private _cardiacIndex = lbCurSel IDC_CARDIAC_COMBO;
private _cardiacText = lbText [IDC_CARDIAC_COMBO, _cardiacIndex];

if (_cardiacIndex > 0) then {
    [_patient, _cardiacText] call FUNC(setCardiacArrest);
    TRACE_2("Set cardiac arrest",_patient,_cardiacText);
};

// set airway
private _occluded = [0, 0, 0];
private _obstructed = [0, 0, 0];
private _catastrophic = [false, false];
for "_i" from 0 to 2 do {
    _occluded set [_i, sliderPosition IDC_AIRWAY_OCCLUDED_SLIDER];
};
for "_i" from 0 to 2 do {
    private _isobstructed = cbChecked displayCtrl IDC_AIRWAY_OBSTRUCTED_CHECKBOX;
    if (_isobstructed) then {
        _obstructed set [_i, 1];
    };
};


private _iscatastrophic = cbChecked displayCtrl IDC_AIRWAY_CATASTROPHIC_CHECKBOX;
if (_iscatastrophic) then {
    _catastrophic = [true, true];
};

[_patient, _occluded, _obstructed, _catastrophic] call FUNC(setAirway);
TRACE_3("Set airway",_patient,_occluded,_obstructed);

// set ptx
private _ptxStrength = [0, 0];
private _tptxStrength = [false, false];
private _hptxStrength = [0, 0];
private _ptxTamponade = 0;
for "_i" from 0 to 2 do {
    private _isptx = sliderPosition IDC_PTX_STRENGTH_SLIDER;
    if (_isptx > 0) then {
        _ptxStrength set [_i, (sliderPosition IDC_PTX_STRENGTH_SLIDER)];
    };
};
for "_i" from 0 to 2 do {
    private _isptx = sliderPosition IDC_PTX_STRENGTH_SLIDER;
    if (_isptx > 0) then {
        _ptxStrength set [_i, (sliderPosition IDC_PTX_STRENGTH_SLIDER)];
    };
};
private _istptx = cbChecked displayCtrl IDC_TPTX_CHECKBOX;
if (_istptx) then {
    _tptxStrength = [true, false];
};
for "_i" from 0 to 2 do {
    private _ishptx = sliderPosition IDC_HPTX_STRENGTH_SLIDER;
    if (_ishptx > 0) then {
        _hptxStrength set [_i, linearConversion [0, 100, (sliderPosition IDC_HPTX_STRENGTH_SLIDER), 0, 0.8]];
    };
};
private _isTamponade = cbChecked displayCtrl IDC_PTX_TAMPONADE_CHECKBOX;
if (_isTamponade) then {
    _ptxTamponade = selectRandom [0, 1, 2, 3, 4];
};

[_patient, _ptxStrength, _tptxStrength, _hptxStrength, _ptxTamponade] call FUNC(setPneumothorax);

// set fractures
private _fracLArmIndex = lbCurSel IDC_FRACTURES_LEFTARM_COMBO;
private _fracLArmText = lbText [IDC_FRACTURES_LEFTARM_COMBO, _fracLArmIndex];
private _fracRArmIndex = lbCurSel IDC_FRACTURES_RIGHTARM_COMBO;
private _fracRArmText = lbText [IDC_FRACTURES_RIGHTARM_COMBO, _fracRArmIndex];
private _fracLLegIndex = lbCurSel IDC_FRACTURES_LEFTLEG_COMBO;
private _fracLLegText = lbText [IDC_FRACTURES_LEFTLEG_COMBO, _fracLLegIndex];
private _fracRLegIndex = lbCurSel IDC_FRACTURES_RIGHTLEG_COMBO;
private _fracRLegText = lbText [IDC_FRACTURES_RIGHTLEG_COMBO, _fracRLegIndex];

if (_fracLArmIndex > 0) then {
    [_patient, "LeftArm", _fracLArmText] call FUNC(setFracture);
    TRACE_3("LeftArm Fracture",_patient,_fracLArmIndex,_fracLArmText);
};

if (_fracRArmIndex > 0) then {
    [_patient, "RightArm", _fracRArmText] call FUNC(setFracture);
    TRACE_3("RightArm Fracture",_patient,_fracRArmIndex,_fracRArmText);
};


if (_fracLLegIndex > 0) then {
    [_patient, "LeftLeg", _fracLLegText] call FUNC(setFracture);
    TRACE_3("LeftLeg Fracture",_patient,_fracLLegIndex,_fracLLegText);
};

if (_fracRLegIndex > 0) then {
    [_patient, "RightLeg", _fracRLegText] call FUNC(setFracture);
    TRACE_3("RightLeg Fracture",_patient,_fracRLegIndex,_fracRLegText);
};

