#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles thermalBlanketFalloff
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * none
 *
 * Example:
 * [player] call kat_pharma_fnc_updatePharmaEffects
 *
 * Public: No
 */

 params ["_unit"];
 if (!local _unit) exitWith { ERROR_2("updatePharmaEffects: Unit not local or null [%1:%2]",_unit,typeOf _unit); };
private _hasSpaceblanket = _unit getVariable [QGVAR(spaceBlanket), false];
if ((_hasSpaceblanket) && (abs (speed _unit) > 4 && isNull objectParent _unit)) then {
    private _chance = linearConversion [4, 12, (abs (speed _unit)), 2, 20];
    if ((random 100) < _chance) then {
        _unit setVariable [QGVAR(spaceBlanket), false, true];
        private _impact = (_unit getVariable [QGVAR(warmingImpact), 0]);
        private _reduce = (_impact - 3000) max 0
        _unit setVariable [QGVAR(warmingImpact), _reduce, true];
        [LLSTRING(thermalBlanket_FallOff), 1.5, _unit] call ACEFUNC(common,displayTextStructured);
    };
};
