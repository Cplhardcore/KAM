#define DEBUG_MODE_FULL
#include "..\script_component.hpp"
/*
 * Author: AmsteadRayle
 * Counts how many of the given items are present between the medic and patient.
 * If medic or patient are in a vehicle then vehicle's inventory will also be checked.
 *
 * Arguments:
 * 0: Items <ARRAY>
 *
 * Return Value:
 * Counts (can be nil) <ARRAY>
 *
 * Example:
 * [items] call ace_medical_gui_fnc_countTreatmentItems
 *
 * Public: No
 */

params ["_items"];

private _medicCount = 0;
private _patientCount = nil;
private _vehicleCount = nil;
private _crateCount = nil;

//
// Medic
//
{
    _medicCount = _medicCount + ([ACE_player, _x] call ACEFUNC(common,getCountOfItem));
} forEach _items;

//
// Patient
//
TRACE_2("patient",ACE_player,ACEGVAR(medical_gui,target));
if (ACE_player != ACEGVAR(medical_gui,target)) then {
    _patientCount = 0;

    {
        _patientCount = _patientCount + ([ACEGVAR(medical_gui,target), _x] call ACEFUNC(common,getCountOfItem));
    } forEach _items;
};

//
// Vehicle
//
private _medicVehicle = objectParent ACE_player;
private _patientVehicle = objectParent ACEGVAR(medical_gui,target);

private _vehicle = [_patientVehicle, _medicVehicle] select (!isNull _medicVehicle);

if (!isNull _vehicle) then {

    _vehicleCount = 0;

    private _magazineItems = [];
    private _itemItems = [];

    {
        if (isClass (configFile >> "CfgMagazines" >> _x)) then {
            _magazineItems pushBack _x;
        } else {
            _itemItems pushBack _x;
        };
    } forEach _items;

    if (_magazineItems isNotEqualTo []) then {

        (getMagazineCargo _vehicle) params ["_itemTypes", "_itemCounts"];

        {
            _vehicleCount = _vehicleCount + (_itemCounts param [_itemTypes find _x, 0]);
        } forEach _magazineItems;
    };

    if (_itemItems isNotEqualTo []) then {

        (getItemCargo _vehicle) params ["_itemTypes", "_itemCounts"];

        {
            _vehicleCount = _vehicleCount + (_itemCounts param [_itemTypes find _x, 0]);
        } forEach _itemItems;
    };
};

//
// Nearby Crates
//
if (GVAR(allowCrateEquipment) && ([ACE_player, GVAR(medicCrateEquipment)] call ACEFUNC(common,isMedic)) && ((isNull (objectParent ACE_player)))) then {

    _crateCount = 0;

    private _nearbyContainers = nearestObjects [
        ACEGVAR(medical_gui,target),
        [
            "ThingX",
            "GroundWeaponHolder",
            "WeaponHolderSimulated",
            "LandVehicle",
            "Air",
            "Ship"
        ],
        GVAR(crateEquipmentRange)
    ];

    _nearbyContainers = _nearbyContainers select {

        private _container = _x;

        if (_container == objectParent ACEGVAR(medical_gui,target)) exitWith {
            false
        };

         private _hasLoot =
                (itemCargo _container) isNotEqualTo []
                || (magazineCargo _container) isNotEqualTo []
                || (weaponCargo _container) isNotEqualTo []
                || (everyBackpack _container) isNotEqualTo [];

            if (!_hasLoot) then {

                {
                    private _bp = _x;

                    if (
                        (itemCargo _bp) isNotEqualTo []
                        || (magazineCargo _bp) isNotEqualTo []
                        || (weaponCargo _bp) isNotEqualTo []
                        || (backpackCargo _bp) isNotEqualTo []
                    ) exitWith {
                        _hasLoot = true;
                    };

                } forEach everyBackpack _container;
            };
        _hasLoot
    };
    private _magazineItems = [];
    private _itemItems = [];
    {
        if (isClass (configFile >> "CfgMagazines" >> _x)) then {
            _magazineItems pushBack _x;
        } else {
            _itemItems pushBack _x;
        };
    } forEach _items;

    {
        private _crate = _x;
        if (_magazineItems isNotEqualTo []) then {

            (getMagazineCargo _crate) params ["_itemTypes", "_itemCounts"];

            {
                _crateCount = _crateCount + (_itemCounts param [_itemTypes find _x, 0]);
            } forEach _magazineItems;
        };
        if (_itemItems isNotEqualTo []) then {

            (getItemCargo _crate) params ["_itemTypes", "_itemCounts"];

            {
                _crateCount = _crateCount + (_itemCounts param [_itemTypes find _x, 0]);
            } forEach _itemItems;
        };

    } forEach _nearbyContainers;
    {
        private _container = _x;
        {
            private _crate = _x;
            if (_magazineItems isNotEqualTo []) then {

                (getMagazineCargo _crate) params ["_itemTypes", "_itemCounts"];

                {
                    _crateCount = _crateCount + (_itemCounts param [_itemTypes find _x, 0]);
                } forEach _magazineItems;
            };
            if (_itemItems isNotEqualTo []) then {

                (getItemCargo _crate) params ["_itemTypes", "_itemCounts"];

                {
                    _crateCount = _crateCount + (_itemCounts param [_itemTypes find _x, 0]);
                } forEach _itemItems;
            };

        } forEach everyBackpack _container;
    } forEach _nearbyContainers;
};
[
    _medicCount,
    _patientCount,
    _vehicleCount,
    _crateCount
]