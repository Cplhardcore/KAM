#include "..\script_component.hpp"
/*
 * Author: Blue
 * Unload patient from vehicle and carry (skip animation)
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget] call kat_misc_fnc_unloadAndCarryPatient;
 *
 * Public: No
 */

params ["_medic", "_patient"];

[_medic, _patient] call ACEFUNC(medical_treatment,unloadUnit);
[_medic, _patient, true] call ACEFUNC(common,claim);


// Exempt from weight check if object has override variable set
private _weight = 0;

private _timer = CBA_missionTime;

// Handle objects vs. persons
if (_patient isKindOf "CAManBase") then {
    // Create clone for dead units
    if (!alive _patient) then {
        _patient = [_medic, _patient] call ACEFUNC(dragging,createClone);
    };

    private _primaryWeapon = primaryWeapon _medic;

    // Add a primary weapon if the unit has none
    if (_primaryWeapon == "") then {
        _medic addWeapon "ACE_FakePrimaryWeapon";
        _primaryWeapon = "ACE_FakePrimaryWeapon";
    };

    // Select primary, otherwise the carry animation actions don't work
    _medic selectWeapon _primaryWeapon; // This turns off lasers/lights

    // Move a bit closer and adjust direction when trying to pick up a person
    [QACEGVAR(common,setDir), [_patient, getDir _medic + 180], _patient] call CBA_fnc_patientEvent;
    _patient setPosASL (getPosASL _medic vectorAdd (vectorDir _medic));
};

[_medic, "blockThrow", QUOTE(ADDON), true] call ACEFUNC(common,statusEffect_set);

// Prevents dragging and carrying at the same time
_medic setVariable [QACEGVAR(dragging,isCarrying), true, true];

// Required for aborting (animation & keybind)
_medic setVariable [QACEGVAR(dragging,carriedObject), _patient, true];

[_medic, _patient] call ACEFUNC(dragging,carryObject);
// Disable collisions by setting the PhysX mass to almost zero
private _mass = getMass _patient;

if (_mass > 1) then {
    _patient setVariable [QACEGVAR(dragging,originalMass), _mass, true];
    [QACEGVAR(common,setMass), [_patient, 1e-12]] call CBA_fnc_globalEvent; // Force global sync
};
