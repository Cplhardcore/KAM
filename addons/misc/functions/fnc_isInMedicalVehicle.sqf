#include "..\script_component.hpp"
/*
 * Author: KoffeinFlummi
 * Checks if the unit is in a medical vehicle.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * In Medical Vehicle <BOOL>
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_isInMedicalVehicle
 *
 * Public: No
 */

params ["_unit"];
private _fnc_checkVehicles = {
    private _vehicle = vehicle _unit;
    (
        _unit != _vehicle &&
        {!(_unit in [driver _vehicle, gunner _vehicle, commander _vehicle])} &&
        {[_vehicle] call ACEFUNC(medical_treatment,isMedicalVehicle)}
    )
    ||
    {
        (
            _unit nearEntities [["Car", "Tank", "Air", "Ship"], GVAR(crateEquipmentRange)]
        ) findIf {
            (alive _x) &&
            {[_x] call ACEFUNC(medical_treatment,isMedicalVehicle)}
        } != -1
    }
};

[[], _fnc_checkVehicles, _unit, QGVAR(inMedicalVehicleCache), 1] call ACEFUNC(common,cachedCall);