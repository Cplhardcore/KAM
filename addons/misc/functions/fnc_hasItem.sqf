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
    private _nearbyCrates = nearestObjects [
        _patient,
        _objectTypes,
        GVAR(crateEquipmentRange)
    ];

        _nearbyCrates = _nearbyCrates select {

            private _container = _x;

            if (_container == objectParent _patient) exitWith {
                false
            };

            private _hasItem =
                (itemCargo _container) isNotEqualTo []
                || (magazineCargo _container) isNotEqualTo []
                || (weaponCargo _container) isNotEqualTo []
                || (everyBackpack _container) isNotEqualTo [];

            if (!_hasItem) then {

                {
                    private _bp = _x;

                    if (
                        (itemCargo _bp) isNotEqualTo []
                        || (magazineCargo _bp) isNotEqualTo []
                        || (weaponCargo _bp) isNotEqualTo []
                        || (backpackCargo _bp) isNotEqualTo []
                    ) exitWith {
                        _hasItem = true;
                    };

                } forEach everyBackpack _container;
            };

            _hasItem
        };

        {
            private _container = _x;
            private _filteredItems = (itemCargo _container) select {
                !(_x in GVAR(blacklistedItems))
            };
            private _filteredMags = (magazineCargo _container) select {
                !(_x in GVAR(blacklistedItems))
            };

            _unitItems append _filteredItems;
            _unitItems append _filteredMags;
            {
                private _bpFilteredItems = (itemCargo _x) select {
                    !(_x in GVAR(blacklistedItems))
                };

                private _bpFilteredMags = (magazineCargo _x) select {
                    !(_x in GVAR(blacklistedItems))
                };

                _unitItems append _bpFilteredItems;
                _unitItems append _bpFilteredMags;

            } forEach everyBackpack _container;

        } forEach _nearbyCrates;

    };
    _items findAny _unitItems != -1
};

_medic call _fnc_checkItems || {
    ACEGVAR(medical_treatment,allowSharedEquipment) != 2 &&
    {_patient call _fnc_checkItems}
}