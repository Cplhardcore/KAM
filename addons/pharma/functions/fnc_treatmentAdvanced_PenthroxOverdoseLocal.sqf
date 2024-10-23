#include "..\script_component.hpp"
/*
 * Author: Blue
 * Begins Penthrox Inhaler use
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 * 3: Treatment <STRING>
 * 4: Item User (not used) <OBJECT>
 * 5: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "RightArm", classname, objNull, "kat_Penthrox"] call kat_pharma_fnc_treatmentAdvanced_Penthrox;
 *
 * Public: No
 */
params ["_patient"];
if (random 25 < 1) then {
	private _randomValue = [3, 4];
	private _randomRhythm = selectRandom _randomValue;
    _patient setVariable [QEGVAR(circulation,cardiacArrestType), _randomRhythm];
};