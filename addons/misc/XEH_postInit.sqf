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
