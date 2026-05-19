#include "script_component.hpp"

[QGVAR(triageCardOpen), LINKFUNC(openCardLocal)] call CBA_fnc_addEventHandler;
[QGVAR(triageCardFlip), LINKFUNC(flipPageLocal)] call CBA_fnc_addEventHandler;
[QACEGVAR(medical_treatment,fullHealLocalMod), LINKFUNC(fullHealLocal)] call CBA_fnc_addEventHandler;