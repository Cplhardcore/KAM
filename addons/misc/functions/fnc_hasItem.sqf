#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001
 * Checks if one of the given items are present between the medic and patient.
 * Does not respect the priority defined by the allowSharedEquipment setting.
 * Will check medic first and then patient if shared equipment is allowed.
 * If medic or patient are in a vehicle then vehicle's inventory will also be checked.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * Has Item <BOOL>
 *
 * Example:
 * [player, cursorObject, ["ACE_fieldDressing"]] call ace_medical_treatment_fnc_hasItem
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

private _fnc_checkItems = {

    params ["_unit"];

    private _unitItems = [_unit, 1] call ACEFUNC(common,uniqueItems);
    private _unitVehicle = objectParent _unit;

    if (!isNull _unitVehicle) then {

        _unitItems append (itemCargo _unitVehicle);
        _unitItems append (magazineCargo _unitVehicle);
    };
    if (GVAR(allowCrateEquipment) && ([_unit, GVAR(medicCrateEquipment)] call ACEFUNC(common,isMedic)) && (isNull _unitVehicle)) then {
    private _fnc_crateCheck = {
    private _objectTypes = [];
    private _crateItems = [];

    _crateCount = 0;

    private _objectTypes = [];

    switch (GVAR(crateAccess)) do {
        case 0: {
            _objectTypes = ["GroundWeaponHolder", "WeaponHolderSimulated"];
        };
        case 1: {
            _objectTypes = ["GroundWeaponHolder", "WeaponHolderSimulated", "ThingX"];
        };
        case 2: {
            _objectTypes = ["GroundWeaponHolder", "WeaponHolderSimulated", "ThingX", "LandVehicle", "Air", "Ship"];
        };
    };

        private _nearbyContainers = nearestObjects [
            ACEGVAR(medical_gui,target),
            _objectTypes,
            GVAR(crateEquipmentRange)
        ];
        private _medicVehicle = objectParent ACE_player;
        private _patientVehicle = objectParent ACEGVAR(medical_gui,target);
        private _ignoredObjects = [ACE_player, ACEGVAR(medical_gui,target), _medicVehicle, _patientVehicle];
        {
            private _container = _x;
            if (_x in _ignoredObjects) exitWith {};
            private _filteredItems = (itemCargo _container) select {
                !(_x in GVAR(blacklistedItems))
            };
            private _filteredMags = (magazineCargo _container) select {
                !(_x in GVAR(blacklistedItems))
            };

            _crateItems append _filteredItems;
            _crateItems append _filteredMags;
            {
                private _bpFilteredItems = (itemCargo _x) select {
                    !(_x in GVAR(blacklistedItems))
                };

                private _bpFilteredMags = (magazineCargo _x) select {
                    !(_x in GVAR(blacklistedItems))
                };

                _crateItems append _bpFilteredItems;
                _crateItems append _bpFilteredMags;

            } forEach everyBackpack _container;

        } forEach _nearbyContainers;
        _crateItems
        };
        _unitItems = _unitItems + ([[], _fnc_crateCheck, ACE_player, QGVAR(clearCrateCache), 1] call ACEFUNC(common,cachedCall));
    };
    _items findAny _unitItems != -1
};

_medic call _fnc_checkItems || {
    ACEGVAR(medical_treatment,allowSharedEquipment) != 2 &&
    {_patient call _fnc_checkItems}
}