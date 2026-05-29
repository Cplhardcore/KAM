#include "..\script_component.hpp"
/*
 * Author: Mazinski
 * Checks blood volume protected by REBOA
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call kat_surgery_fnc_reboaVolume
 *
 * Public: No
 */

params ["_patient"];

private _reboa = _patient getVariable [QGVAR(reboa), [false, false]];
private _reboaStatus = ((_reboa select 0) && (_reboa select 1));
private _tourniquets = GET_SURGICAL_TOURNIQUETS(_patient);
private _volume = 0;

if (_reboaStatus) then { _volume = _volume + 1.2; };
if ((_tourniquets select 3) != 0) then { _volume = _volume + 0.3; };

_volume
