#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_CaffeineLocal;
 *
 * Public: No
 */

params ["_patient"];

if (ACE_Player != _patient) exitWith {};

/// ACE Fatigue
if (ACEGVAR(advanced_fatigue,enabled)) then {
    ACEGVAR(advanced_fatigue,anReserve) = ACEGVAR(advanced_fatigue,anReserve) + 0.7;
} else {
    _patient setStamina(getStamina _patient + 0.3);
};
