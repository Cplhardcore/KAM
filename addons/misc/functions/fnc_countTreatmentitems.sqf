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

        
private _magazineItems = [];
private _itemItems = [];
_items = _items select {
    !(_x in GVAR(blacklistedItems))
};

{
    if (isClass (configFile >> "CfgMagazines" >> _x)) then {
        _magazineItems pushBack _x;
    } else {
        _itemItems pushBack _x;
    };

} forEach _items;

//
// Vehicle
//

_fnc_getCountsFromCargo = {

    params ["_object", "_magazineItems", "_itemItems"];

    private _count = 0;
    TRACE_3("crateCount2",_count,_magazineItems,_itemItems);
    if (_magazineItems isNotEqualTo []) then {

        (getMagazineCargo _object) params ["_itemTypes", "_itemCounts"];
        TRACE_1("crateCount2",(getMagazineCargo _object));
        private _map = _itemTypes createHashMapFromArray _itemCounts;
        TRACE_1("crateCount2",_map);
        {
            _count = _count + (_map getOrDefault [_x, 0]);
        } forEach _magazineItems;
        TRACE_1("crateCount2",_count);
    };
    TRACE_1("crateCount3",_count);
    if (_itemItems isNotEqualTo []) then {

        (getItemCargo _object) params ["_itemTypes", "_itemCounts"];
        TRACE_1("crateCount3",(getItemCargo _object));
        private _map = _itemTypes createHashMapFromArray _itemCounts;
        TRACE_1("crateCount3",_map);
        {
            _count = _count + (_map getOrDefault [_x, 0]);
        } forEach _itemItems;
        TRACE_1("crateCount3",_count);
    };

    _count
};

private _medicVehicle = objectParent ACE_player;
private _patientVehicle = objectParent ACEGVAR(medical_gui,target);

private _vehicle = [_patientVehicle, _medicVehicle] select (!isNull _medicVehicle);

if (!isNull _vehicle) then {

    _vehicleCount = [_vehicle, _magazineItems, _itemItems] call _fnc_getCountsFromCargo;

};

//
// Nearby Crates
//
if (GVAR(allowCrateEquipment) && ([ACE_player, GVAR(medicCrateEquipment)] call ACEFUNC(common,isMedic)) && ((isNull (objectParent ACE_player)))) then {

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

    private _ignoredObjects = [ACE_player, ACEGVAR(medical_gui,target), _medicVehicle, _patientVehicle];

    {

        if (_x in _ignoredObjects) exitWith {};
        _crateCount = _crateCount + ([_x, _magazineItems, _itemItems] call _fnc_getCountsFromCargo);
        TRACE_3("crateCount",_crateCount,_magazineItems,_itemItems);
        if ((everyBackpack _x) isNotEqualTo []) then {

            {
                _crateCount = _crateCount + ([_x, _magazineItems, _itemItems] call _fnc_getCountsFromCargo);
            } forEach everyBackpack _x;
        };
    } forEach _nearbyContainers;

};

[
    _medicCount,
    _patientCount,
    _vehicleCount,
    _crateCount
]