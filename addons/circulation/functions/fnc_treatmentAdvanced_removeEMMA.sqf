#include "..\script_component.hpp"
/*
 * Author: Kygan
 * Treatment for hemopneumothorax
 * Main function
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
 * [player, cursorObject, "Body", "TensionpneumothoraxTreatment", objNull, "kat_aatKit"] call kat_breathing_fnc_treatmentAdvanced_tensionpneumothorax;
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart", "_classname", "", "_usedItem", "_side"];


[_medic, "kat_EMMA"] call ACEFUNC(common,addToInventory);
_patient setVariable [QGVAR(capnographConnected), false, true];