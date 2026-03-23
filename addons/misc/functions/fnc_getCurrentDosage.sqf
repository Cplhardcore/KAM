#include "..\script_component.hpp"
/*
 * Author: PabstMirror, Cplhardcore
 * Gets effective count of medications in a unit's system
 * (each medication dose is scaled from 0..1 based on time till max effect and max time in system)
 *
 * Arguments:
 * 0: The patient <OBJECT>
 * 1: Medication (not case sensitive) <STRING>
 * 2: Get raw count (true) or effect ratio (false) <BOOL> (default: true)
 *
 * Returns Value:
 *  0: Dose Count <NUMBER>
 *  1: Medication effectiveness (0-1) <NUMBER>
 *
 *
 * Example:
 * [player, "Epinephrine"] call kat_misc_fnc_getCurrentDosage
 *
 * Public: No
 */

params ["_target", "_medication"];
private _medDose = 0;
{
    _x params ["_xMed", "_timeAdded", "_timeTillMaxEffect", "_maxTimeInSystem", "", "", "", "_dose", "", "", "", "", "", "", "", "", "", "", "", "_overdoseAdmin"];
    _overdoseAdmin params ["_ld50", "_od50", "_chanceToOD", "_bloodBased"];
    if ((toLower _xMed) == (toLower _medication)) then {
        private _timeInSystem = CBA_missionTime - _timeAdded;
        // as used in handleUnitVitals, a medication effectiveness will start low, ramp up to timeTillMaxEffect, and then drop off
        private _effectiveness = (((_timeInSystem / _timeTillMaxEffect) ^ 2) min 1) * (_maxTimeInSystem - _timeInSystem) / _maxTimeInSystem;
        private _diazapamMult = 1;
            if (toLower _medication == "diazapam") then {
                private _medStack = _target call ACEFUNC(medical_status,getAllMedicationCount);
                private _fentanylEffectiveness = 0;
                private _nalbuphineEffectiveness = 0;
                private _morphineEffectiveness = 0;
                private _lorazepamEffectiveness = 0;
                {
                    private _medName = toLower (_x select 0);
                    private _effectiveness = _x select 2;
                    private _dose = _x select 1;
                    if ("fentanyl" in _medName) then {
                        _fentanylEffectiveness = _fentanylEffectiveness max (_dose * _effectiveness);
                    };
                    if ("nalbuphine" in _medName) then {
                        _nalbuphineEffectiveness = _nalbuphineEffectiveness max (_dose * _effectiveness);
                    };
                    if ("morphine" in _medName) then {
                        _morphineEffectiveness = _morphineEffectiveness max (_dose * _effectiveness);
                    };
                    if ("lorazepam" in _medName) then {
                        _lorazepamEffectiveness = _lorazepamEffectiveness max (_dose * _effectiveness);
                    };
                } forEach _medStack;
                _diazapamMult = linearConversion [0, 90, (_fentanylEffectiveness + _nalbuphineEffectiveness + _morphineEffectiveness * _lorazepamEffectiveness), 1, 4, true];
            };
        private _hemocrit = 1;
        if (_bloodBased == "true") then {
            _hemocrit = (GET_BODY_FLUID_ECB(_target)/GET_BODY_FLUID_ECP(_target)) / (DEFAULT_ECB/DEFAULT_ECP)
        } else {
            _hemocrit = (GET_BODY_FLUID_ECP(_target)/GET_BODY_FLUID_ECB(_target)) / (DEFAULT_ECP/DEFAULT_ECB)
        };
        private _drugMult = ((((GET_BLOOD_VOLUME_LITERS(_target) / DEFAULT_BLOOD_VOLUME) * _hemocrit) max 0.2) min 2) * _diazapamMult;
        TRACE_1("getMedicationCount1",_medDose);
        _medDose = _medDose + (_dose * _effectiveness * _drugMult);
        TRACE_7("getMedicationCount",_target,_medication,_dose,_effectiveness,_medDose,_diazapamMult,_drugMult);
    };
} forEach (_target getVariable [VAR_MEDICATIONS, []]);

_medDose