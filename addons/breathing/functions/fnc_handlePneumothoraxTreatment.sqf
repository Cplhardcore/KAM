#include "..\script_component.hpp"
/*
 * Author: Blue
 * Handle pneumothorax deterioration
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Deterioration chance increase <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, 15] call kat_breathing_fnc_handlePneumothoraxTreatment;
 *
 * Public: No
 */

params ["_unit", "_side", "_deltaT"];
private _time = _unit getVariable [QGVAR(ptxTTime), 0, true];
_unit setVariable [QGVAR(ptxTTime), _time + _deltaT, true];
private _baroMult = 1;
if (EGVAR(hypothermia,baroPressureEnable)) then {
    private _altitude = (getPosASL _unit) select 2;
    if (EGVAR(hypothermia,useACEpressure)) then {
    private _hPa = _altitude call ACEFUNC(weather,calculateBarometricPressure);
    private _baroPressure = _hPa * 0.750062;
    private _defaulthPa = 0 call ACEFUNC(weather,calculateBarometricPressure);
    private _defaultbaroPressure = _defaulthPa * 0.750062;
    _baroMult = _baroPressure / _defaultBaroPressure;
    } else {
    private _baroPressure = 760 * exp((-(_altitude)) / 8400);
    private _defaultBaroPressure = 760 * exp((-(0)) / 8400);
    _baroMult = _baroPressure / _defaultBaroPressure;
    };
};
private _delay  = (GVAR(chestSealTreatmentLoopTime) * _baroMult) * random [0.8, 1, 1.3];
if (_delay > _time) exitWith {};
_unit setVariable [QGVAR(ptxTTime), 0, true];

            private _pneumothoraxState = _unit getVariable [QGVAR(pneumothorax), [0, 0]];
                if (_pneumothoraxState select _side != 0) then {
                    // If patient is dead, treated, or already deteriorated to advanced pneumothorax, kill the PFH

                    if ((floor (random 100) < 50)) then {
                        private _ptxTarget = (_pneumothoraxState select _side) - 1;
                        if (_ptxTarget < 0) exitWith {
                            if (GVAR(clearChestSealAfterTreatment)) then {
                                private _activeChestSeal = _unit getVariable [QGVAR(activeChestSeal), [false, false]];
                                _activeChestSeal set [_side, false];
                                _unit setVariable [QGVAR(activeChestSeal), _activeChestSeal, true];
                                };
                        };
                        
                        _pneumothoraxState set [_side, _ptxTarget];
                        _unit setVariable [QGVAR(pneumothorax), _pneumothoraxState, true];
                    };
                };