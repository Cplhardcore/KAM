#include "..\script_component.hpp"
/*
 * Author: Garth 'L-H' de Wet
 * Adds an item, weapon, or magazine to the unit's inventory or places it in a weapon holder if no space.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Classname <STRING>
 * 2: Container (uniform, vest, backpack) <STRING> (default: "")
 * 3: Magazine Ammo Count <NUMBER> (default: -1)
 *
 * Return Value:
 * 0: Added to player <BOOL>
 * 1: Weapon holder item was placed in <OBJECT>
 *
 * Example:
 * [player, "30Rnd_65x39_caseless_mag", "", 5] call ace_common_fnc_addToInventory
 *
 * Public: Yes
 */

params ["_unit", "_classname", ["_container", ""], ["_ammoCount", -1]];

private _type = _classname call ACEFUNC(common,getItemType);

private _canAdd = false;
private _canFitWeaponSlot = false;
private _addedToUnit = false;

switch (_container) do {
    case "vest": {
        _canAdd = (vestContainer _unit) canAdd _classname;
    };
    case "backpack": {
        _canAdd = (backpackContainer _unit) canAdd _classname;
    };
    case "uniform": {
        _canAdd = (uniformContainer _unit) canAdd _classname;
    };
    default {
        _canAdd = _unit canAdd [_classname, 1, true];
        if (_canAdd) then {
            switch (_type select 1) do {
                case "primary": {
                    _canFitWeaponSlot = primaryWeapon _unit == "";
                };
                case "secondary": {
                    _canFitWeaponSlot = secondaryWeapon _unit == "";
                };
                case "handgun": {
                    _canFitWeaponSlot = handgunWeapon _unit == "";
                };
                case "binocular": {
                    _canFitWeaponSlot = binocular _unit == "";
                };
            };
        };
    };
};
_canAdd