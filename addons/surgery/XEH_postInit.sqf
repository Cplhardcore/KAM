#include "script_component.hpp"

[QGVAR(fractureSelect), LINKFUNC(fractureSelectLocal)] call CBA_fnc_addEventHandler;
[QGVAR(closedReduction), LINKFUNC(closedReductionLocal)] call CBA_fnc_addEventHandler;
[QGVAR(openReduction), LINKFUNC(openReductionLocal)] call CBA_fnc_addEventHandler;
[QGVAR(incision), LINKFUNC(incisionLocal)] call CBA_fnc_addEventHandler;
[QGVAR(openReductionProgress), LINKFUNC(openReductionProgressLocal)] call CBA_fnc_addEventHandler;
[QGVAR(ultraAssessment), LINKFUNC(ultraAssessmentLocal)] call CBA_fnc_addEventHandler;
[QGVAR(reboaApply), LINKFUNC(reboaApplyLocal)] call CBA_fnc_addEventHandler;
[QGVAR(reboaDeepApply), LINKFUNC(reboaDeepApplyLocal)] call CBA_fnc_addEventHandler;
[QGVAR(reboaRemove), LINKFUNC(reboaRemoveLocal)] call CBA_fnc_addEventHandler;
[QGVAR(pericardialTap), LINKFUNC(pericardialTapLocal)] call CBA_fnc_addEventHandler;

[QEGVAR(misc,handleRespawn), LINKFUNC(handleRespawn)] call CBA_fnc_addEventHandler;

[QACEGVAR(medical_gui,updateInjuryListPart), LINKFUNC(gui_updateInjuryListPart)] call CBA_fnc_addEventHandler;
[QACEGVAR(medical_treatment,fullHealLocalMod), LINKFUNC(fullHealLocal)] call CBA_fnc_addEventHandler;
[QACEGVAR(medical,fracture), {
    params ["_patient", "_part"];
    private _fractureArray = _patient getVariable [QGVAR(fractures), [0,0,0,0,0,0,0,0,0,0,0,0]];
    private _liveFracture = _fractureArray select _part;
    if (random 100 <= GVAR(simpleChance)) then {
        _liveFracture = 1;
    } else {
        if (random 100 <= GVAR(compoundChance)) then {
            _liveFracture = 2;
        } else {
            _liveFracture = 3;
        };
    };
    _fractureArray set [_part, _liveFracture];
    _patient setVariable [QGVAR(fractures), _fractureArray, true];
}] call CBA_fnc_addEventHandler;


