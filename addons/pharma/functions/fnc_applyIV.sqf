#include "..\script_component.hpp"
/*
 * Author: Mazinski.H
 * Opens an IV/IO on a patient and changes the patient's flow variable
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 * 3: Treatment (not used) <STRING>
 * 4: Item User (not used) <OBJECT>
 * 5: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "LeftLeg", "", objNull, "kat_IV_16"] call kat_circulation_fnc_applyIV;
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart", "_usedItem"];

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0]];
private _IVactual = _IVarray select _partIndex;
private _IVpfh = _patient getVariable [QGVAR(IVpfh), [0,0,0,0,0,0]];
private _IVpfhActual = _IVpfh select _partIndex;

if (_IVpfhActual > 0) then {
    [_IVpfhActual] call CBA_fnc_removePerFrameHandler;
    _IVpfhActual = 0;
    _IVpfh set [_partIndex, _IVpfhActual];
    _patient setVariable [QGVAR(IVpfh), _IVpfh, true];
} else {
    _IVpfhActual = _IVpfhActual - 1;
    _IVpfh set [_partIndex, _IVpfhActual];
    _patient setVariable [QGVAR(IVpfh), _IVpfh, true];
};
switch (_usedItem) do {
    case _usedItem isEqualTo "kat_IV_16": {    _IVarray set [_partIndex, 2];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "16g IV"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "16g IV"] call ACEFUNC(medical_treatment,addToTriageCard); };
    case _usedItem isEqualTo "kat_IV_14": {     _IVarray set [_partIndex, 2];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "14g IV"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "14g IV"] call ACEFUNC(medical_treatment,addToTriageCard);};
    case _usedItem isEqualTo "kat_IV_20": {     _IVarray set [_partIndex, 2];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "20g IV"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "20g IV"] call ACEFUNC(medical_treatment,addToTriageCard);};
    default { _IVarray set [_partIndex, 1];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    private _lidocaineCount = [_patient, "Lidocaine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _morphineCount = [_patient, "Morphine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _nalbuphineCount = [_patient, "Nalbuphine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _fentanylCount = [_patient, "Fentanyl", false] call ACEFUNC(medical_status,getMedicationCount);
    private _ketamineCount = [_patient, "Ketamine", false] call ACEFUNC(medical_status,getMedicationCount);
    if (_lidocaineCount <=  0.6 && _morphineCount <=  0.6 && _nalbuphineCount <=  0.6 && _fentanylCount <=  0.6 && _ketamineCount <=  0.6) then {[_patient, 0.8] call ACEFUNC(medical_status,adjustPainLevel)};

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "FAST IO"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "FAST IO"] call ACEFUNC(medical_treatment,addToTriageCard);
    };
};
if (_usedItem isEqualTo "kat_IV_16") then {
    _IVarray set [_partIndex, 2];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "16g IV"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "16g IV"] call ACEFUNC(medical_treatment,addToTriageCard);
} else {
    _IVarray set [_partIndex, 1];
    _patient setVariable [QGVAR(IV), _IVarray, true];

    private _lidocaineCount = [_patient, "Lidocaine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _morphineCount = [_patient, "Morphine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _nalbuphineCount = [_patient, "Nalbuphine", false] call ACEFUNC(medical_status,getMedicationCount);
    private _fentanylCount = [_patient, "Fentanyl", false] call ACEFUNC(medical_status,getMedicationCount);
    private _ketamineCount = [_patient, "Ketamine", false] call ACEFUNC(medical_status,getMedicationCount);
    if (_lidocaineCount <=  0.6 && _morphineCount <=  0.6 && _nalbuphineCount <=  0.6 && _fentanylCount <=  0.6 && _ketamineCount <=  0.6) then {[_patient, 0.8] call ACEFUNC(medical_status,adjustPainLevel)};

    [_patient, "activity", LSTRING(iv_log), [[_medic] call ACEFUNC(common,getName), "FAST IO"]] call ACEFUNC(medical_treatment,addToLog);
    [_patient, "FAST IO"] call ACEFUNC(medical_treatment,addToTriageCard);
};

if (GVAR(IVdropEnable) && ((_usedItem isEqualTo "kat_IV_16") || (_usedItem isEqualTo "kat_IV_14") || (_usedItem isEqualTo "kat_IV_20"))) then {
    [{
        params ["_patient", "_partIndex", "_IVpfhActual"];

        private _IVpfh = _patient getVariable [QGVAR(IVpfh), [0,0,0,0,0,0]];
        private _IVpfhCurrent = _IVpfh select _partIndex;

        if (_IVpfhCurrent == _IVpfhActual) then {
            [{
                params ["_args", "_idPFH"];
                _args params ["_patient", "_partIndex"];

                private _IVpfh = _patient getVariable [QGVAR(IVpfh), [0,0,0,0,0,0]];
                _IVpfh set [_partIndex, _idPFH];
                _patient setVariable [QGVAR(IVpfh), _IVpfh, true];

                private _bloodBags = _patient getVariable [QACEGVAR(medical,ivBags), []];

                if (_bloodBags isEqualTo []) exitWith {
                    [_idPFH] call CBA_fnc_removePerFrameHandler;
                    private _IVarray = _patient getVariable [QGVAR(IV), [0,0,0,0,0,0]];
                    private _IVactual = _IVarray select _partIndex;

                    if(GVAR(IVreuse)) then {
                        if (_IVactual == 1) then {
                            _patient addItem "kat_IO_FAST";
                        } else {
                            _patient addItem "kat_IV_16";
                        };
                    };

                    _IVarray set [_partIndex, 0];
                    _patient setVariable [QGVAR(IV), _IVarray, true];
                };
            }, GVAR(IVdrop), [_patient, _partIndex]] call CBA_fnc_addPerFrameHandler;
        };
    }, [_patient, _partIndex, _IVpfhActual], GVAR(IVdrop)] call CBA_fnc_waitAndExecute;
};
