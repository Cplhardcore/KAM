#include "script_component.hpp"

if (GVAR(incompatibilityWarning)) then {
    call FUNC(incompatibilityWarning);
};

[QEGVAR(hitpoints,tourniquetLocal), LINKFUNC(setTourniquetTime)] call CBA_fnc_addEventHandler;
[QACEGVAR(medical_treatment,tourniquetRemove), LINKFUNC(removeTourniquetTime)] call CBA_fnc_addEventHandler;

["kat_Armband_Red_Cross_Item", "kat_Armband_Red_Cross_Goggles"] call ACEFUNC(common,registerItemReplacement);
["kat_Armband_Medic_Item", "kat_Armband_Medic_Goggles"] call ACEFUNC(common,registerItemReplacement);
["kat_Armband_Doctor_Item", "kat_Armband_Doctor_Goggles"] call ACEFUNC(common,registerItemReplacement);
["kat_Armband_Kat_Item", "kat_Armband_Kat_Goggles"] call ACEFUNC(common,registerItemReplacement);

[QGVAR(stopCarryingPrompt), LINKFUNC(stopCarryingPrompt)] call CBA_fnc_addEventHandler;
[QGVAR(dropObject_carryLocal), {
    params ["_carrier", "_target"];

    [_carrier, _target] call ACEFUNC(dragging,dropObject_carry);
}] call CBA_fnc_addEventHandler;

call FUNC(FAK_updateContents);

[QACEGVAR(medical_treatment,tourniquetLocal), LINKFUNC(handleTourniquetEffects)] call CBA_fnc_addEventHandler;

["baseline", {
    private _activeTourniquets = GET_TOURNIQUETS(ACE_player);
    if (GVAR(tourniquetEffects_Enable)) then {
        ((_activeTourniquets select 4) + (_activeTourniquets select 5) + (_activeTourniquets select 6) + (_activeTourniquets select 7) min 1)
    } else {0};
}, QUOTE(ADDON)] call ACEFUNC(common,addSwayFactor);

["multiplier", {
    if (ACE_player getVariable [QGVAR(Tourniquet_ArmNecrosis), 0] > 0) then {
        1 max (ACE_player getVariable [QGVAR(Tourniquet_ArmNecrosis), 0]) / 10
    } else {1};
}, QUOTE(ADDON)] call ACEFUNC(common,addSwayFactor);
#define CBA_SETTINGS_CAT LSTRING(cba_name)
GVAR(blacklistedItems) = [
    "kat_accuvac",
    "kat_X_AED",
    "kat_AED",
    "kat_laryngoscope",
    "kat_suction",
    "kat_pocketBVM",
    "kat_BVM",
    "kat_stethoscope",
    "kat_BPCuff",
    "kat_fluidWarmer",
    "kat_thermometer",
    "kat_pressureBag",
    "kat_coag_sense",
    "kat_vacuum",
    "kat_ultrasound"
];
#include "\a3\ui_f\hpp\defineDIKCodes.inc"
[CBA_SETTINGS_CAT, QGVAR(dropBackpack), CSTRING(dropBackpact), {
    if (!([ACE_player, objNull, ["isNotEscorting"]] call ACEFUNC(common,canInteractWith))) exitWith { false };

    ACE_player call FUNC(dropBag);
    true
}, { false }, [DIK_LCONTROL + DIK_I, [false, false, true]], false] call CBA_fnc_addKeybind;