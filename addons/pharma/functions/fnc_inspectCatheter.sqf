#include "..\script_component.hpp"
/*
 * Author: 2LT.Mazinski
 * Function for inspecting catheter
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_medic, _patient, "LeftArm"] call kat_pharma_fnc_inspectCatheter;
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;
private _IVarray = _patient getVariable [QGVAR(IVBlockStatus), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVactual = _IVarray select _partIndex;
private _output = LLSTRING(IVblock_clear);
switch (true) do {
    case (_IVactual > 0.9): {
        _output = LLSTRING(IVblock5);
    };
    case (_IVactual > 0.7): {
        _output = LLSTRING(IVblock4);
    };
    case (_IVactual > 0.5): {
        _output = LLSTRING(IVblock3);
    };
    case (_IVactual > 0.3): {
        _output = LLSTRING(IVblock2);
    };
    case (_IVactual > 0.1): {
        _output = LLSTRING(IVblock1);
    };
    default {}
};

[_output, 1.5, _medic] call ACEFUNC(common,displayTextStructured);
