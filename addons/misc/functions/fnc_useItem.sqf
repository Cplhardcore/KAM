#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001
 * Modified: Blue
 * Uses one of the treatment items. Respects the priority defined by the allowSharedEquipment setting.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * User and Item <ARRAY>
 *
 * Example:
 * [player, cursorObject, ["bandage"]] call ace_medical_treatment_fnc_useItem;
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

if (_medic isEqualTo player && {!isNull findDisplay 312}) exitWith {
    [_medic, _items select 0, false]
};

scopeName "Main";

private _sharedUseOrder = [[_patient, _medic],
    [_medic, _patient],
    [_medic],
    ([[_patient, _medic],[_medic, _patient]] select ([_medic] call ACEFUNC(medical_treatment,isMedic)))
] select ACEGVAR(medical_treatment,allowSharedEquipment);

private _useOrder = [];
private _nearbyCrates = [];
private _containsBlacklisted = _items findIf {
    _x in GVAR(blacklistedItems)
} > -1;
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
private _vehicle = objectParent _medic;
private _vehicleCondition = !(isNull _vehicle) && _vehicle isEqualTo (objectParent _patient);
private _vehicleIndex = -1;

if (GVAR(allowSharedVehicleEquipment) > 0 && _vehicleCondition) then {
    switch (GVAR(allowSharedVehicleEquipment)) do {
        case 1: { // Medic's equipment first
            _useOrder = [_medic,_vehicle] + _sharedUseOrder;
            _vehicleIndex = 1;
        };
        case 2: { // Vehicle's equipment first (no self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 3: { // Vehicle's equipment first (except self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder + [_vehicle];
                _vehicleIndex = (count _useOrder) - 1;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 4: { // Vehicle's equipment first (always)
            _useOrder = ([_vehicle] + _sharedUseOrder);
            _vehicleIndex = 0;
        };
        default {
            _useOrder = _sharedUseOrder;
        };
    };
} else {
    _useOrder = +_sharedUseOrder;
    if (
        !_containsBlacklisted &&
        GVAR(allowCrateEquipment) &&
        {_nearbyContainers isNotEqualTo []} &&
        ([_medic, GVAR(medicCrateEquipment)] call ACEFUNC(common,isMedic))
    ) then {
        _useOrder = _nearbyContainers + _useOrder;
    };
};
TRACE_2("useOrder",_useOrder,_nearbyContainers);
{
    private _origin = _x;
    private _isVehicleSource = (_forEachIndex == _vehicleIndex);

    private _allowAccess = false;

    switch (GVAR(crateAccess)) do {
        case 0: {
            _allowAccess = (_origin isKindOf "WeaponHolderSimulated");
        };
        case 1: {
            _allowAccess =
                (_origin isKindOf "ThingX") ||
                (_origin isKindOf "WeaponHolderSimulated");
        };
        case 2: {
            _allowAccess =
                (_origin isKindOf "LandVehicle") ||
                (_origin isKindOf "Air") ||
                (_origin isKindOf "Ship") ||
                (_origin isKindOf "ThingX") ||
                (_origin isKindOf "WeaponHolderSimulated");
        };
    };
    if (!_isVehicleSource && !_allowAccess) then {// Remove unit item
        private _originItems = [_origin, 0] call ACEFUNC(common,uniqueItems); // Item
        {
            if (_x in _originItems) then {
                _origin removeItem _x;
                [_origin, _x, true] breakOut "Main";
            };
        } forEach _items;

        _originItems = [_origin, 2] call ACEFUNC(common,uniqueItems); // Magazine
        {
            if (_x in _originItems) then {
                private _magsStart = count magazines _origin;
                [_origin, _x] call ACEFUNC(common,adjustMagazineAmmo);
                private _magsEnd = count magazines _origin;
                [_origin, _x, (_magsEnd < _magsStart)] breakOut "Main";
            };
        } forEach _items;
    } else { // Remove vehicle item
        private _originItems = [_origin, 0] call ACEFUNC(common,uniqueItems); // Item
        {
            if (_x in _originItems) then {
                _origin addItemCargoGlobal [_x, -1];
                [_origin, _x, false] breakOut "Main";
            };
        } forEach _items;
        {
        private _bp = _x;
            {
                if (_x in itemCargo _bp) exitWith {
                    _bp addItemCargoGlobal [_x, -1];
                    [_origin, _x, false] breakOut "Main";
                };
            } forEach _items;

        } forEach everyBackpack _origin;

        _originItems = [_origin, 2] call ACEFUNC(common,uniqueItems); // Magazine
        {
            if (_x in _originItems) then {
                [_origin, _x] call ACEFUNC(common,adjustMagazineAmmo);
                [_origin, _x, false] breakOut "Main";
            };
        } forEach _items;
        {
        private _bp = _x;
            {
                if (_x in magazineCargo _bp) exitWith {
                    _bp addItemCargoGlobal [_x, -1];
                    [_origin, _x, false] breakOut "Main";
                };
            } forEach _items;

        } forEach everyBackpack _origin;
    };
} forEach _useOrder;

[objNull, ""]
