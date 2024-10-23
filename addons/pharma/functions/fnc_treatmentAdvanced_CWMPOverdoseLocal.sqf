#include "..\script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Begins CWMP Treatment
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
 * [player, cursorObject, "RightArm", "CWMP", objNull, "kat_Painkiller"] call kat_pharma_fnc_treatmentAdvanced_CWMP;
 *
 * Public: No
 */
params ["_patient"];