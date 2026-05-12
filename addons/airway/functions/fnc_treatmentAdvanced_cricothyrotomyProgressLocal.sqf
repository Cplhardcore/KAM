#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Progresses the treatment process for a chest Tube
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Current Fracture Status <NUMBER>
 * 3: Side <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, 0.1, 1] call kat_breathing_fnc_treatmentAdvanced_chestTubeProgressLocal;
 *
 * Public: No
 */

params ["_medic", "_patient", "_entry"];

private _cricothyrotomy = _patient getVariable [QGVAR(cricothyrotomy), 0];
private _surgeryString = "";
private _number = _entry;
TRACE_1("crikeProgressLocal",_patient);
private _medStack = _patient call ACEFUNC(medical_status,getAllMedicationCount);
private _fentanylEffectiveness = 0;
private _ketamineEffectiveness = 0;
private _nalbuphineEffectiveness = 0;
private _morphineEffectiveness = 0;
private _localAnesthesia = (_patient getVariable [QEGVAR(pharma,localAnesthesia), [0,0,0,0,0,0,0,0,0,0,0,0]]) select 2;
{
    private _medName = toLower (_x select 0);
    private _effectiveness = _x select 2;
    if ("fentanyl" in _medName) then {
        _fentanylEffectiveness = _fentanylEffectiveness max _effectiveness;
    };
    if ("ketamine" in _medName) then {
        _ketamineEffectiveness = _ketamineEffectiveness max _effectiveness;
    };
    if ("nalbuphine" in _medName) then {
        _nalbuphineEffectiveness = _nalbuphineEffectiveness max _effectiveness;
    };
    if ("morphine" in _medName) then {
        _morphineEffectiveness = _morphineEffectiveness max _effectiveness;
    };
    } forEach _medStack;
    if (
        _fentanylEffectiveness <= 0.8 &&
        _ketamineEffectiveness <= 0.8 &&
        _nalbuphineEffectiveness <= 0.8 &&
        _morphineEffectiveness <= 0.8 &&
        (_localAnesthesia <= 0.8)
    ) then {
        [_patient, [0.7, 0.8, 0.9] select (floor random 3)] call ACEFUNC(medical_status,adjustPainLevel);
    };
if (_number == 0.9) exitWith {
    _surgeryString = LSTRING(ClosedCrike);
    [_patient, "quick_view", LSTRING(ChestTube_log), [[_medic] call ACEFUNC(common,getName), _surgeryString, STRING_BODY_PARTS select 1]] call ACEFUNC(medical_treatment,addToLog);
    _patient setVariable [QGVAR(cricothyrotomy), 0, true];
    [_medic, _patient, "neck"] call EFUNC(surgery,closeIncision);
};
if (_entry == 0.1) then {
    private _openWounds = GET_OPEN_WOUNDS(_patient);
    private _existingWounds = _openWounds getOrDefault ["neck", [], true];
    private _woundTypeToAdd = "Incision";
    TRACE_3("create_Incision1",_openWounds,_existingWounds,_woundTypeToAdd);
    private _woundClassIDToAdd = ACEGVAR(medical_damage,woundClassNames) find _woundTypeToAdd;
    private _injuryBleedingRate = random [0.01, 0.03, 0.04];
    private _bleedMultiplier = random [0.8, 1, 1.2];
    private _woundSize = 1;
    private _bleeding = _woundSize * _bleedMultiplier * _injuryBleedingRate;
    private _classComplex = 10 * _woundClassIDToAdd + _woundSize;
    // Create a new injury. Format [0:classComplex, 1:amountOf, 2:bleedingRate, 3:woundDamage]
    private _injury = [_classComplex, 1, _bleeding, 1];
    TRACE_1("adding new wound",_injury);
    _existingWounds pushBack _injury;
    _patient setVariable [VAR_OPEN_WOUNDS, _openWounds, true];
    [_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);
    if (GVAR(hardcoreCrike)) then {
    [_patient, "blockRadio", "kat_crike", true] call ACEFUNC(common,statusEffect_set);
    [_patient, "blockSpeaking", "kat_crike", true] call ACEFUNC(common,statusEffect_set);
    };
    [{
    params ["_args", "_idPFH"];
    _args params ["_patient"];
    private _cricothyrotomy = _patient getVariable [QGVAR(cricothyrotomy), 0];
    private _alive = alive _patient;
    if ((!_alive) || (_cricothyrotomy == 0) || (_cricothyrotomy == 1)) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };
    if (!(IS_UNCONSCIOUS(_patient))) exitWith {
            [_patient, "Pain_Override", 2, 10, 120, 0.8, 40] call ACEFUNC(medical_status,addMedicationAdjustment);
        [_patient, true] call ACEFUNC(medical,setUnconscious);
        };
    }, 5, [_patient]] call CBA_fnc_addPerFrameHandler;
};

if (_number == _cricothyrotomy) exitWith {
    switch (_entry) do {
        case (0.1):{
            _surgeryString = LSTRING(Incision);
        };
        case (0.3):{
            _surgeryString = LSTRING(PLACED);
        };
    };

    [_patient, "quick_view", LSTRING(ChestTube_log), [[_medic] call ACEFUNC(common,getName), _surgeryString, STRING_BODY_PARTS select 1]] call ACEFUNC(medical_treatment,addToLog);

    _cricothyrotomy = _cricothyrotomy + 0.2;
    _patient setVariable [QGVAR(cricothyrotomy), _cricothyrotomy, true];
};

private _output = LLSTRING(cricothyrotomy_fail);
[_output, 1.5, _medic] call ACEFUNC(common,displayTextStructured);
