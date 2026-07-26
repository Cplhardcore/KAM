#include "..\script_component.hpp"
/*
 * Author: AmsteadRayle
 * Format item counts to be shown in the tooltip.
 *
 * Arguments:
 * 0: Medic count <NUMBER>
 * 1: Patient count <NUMBER>
 * 2: Vehicle count <NUMBER>
 *
 * Return Value:
 * Item count string <STRING>
 *
 * Example:
 * [medicCount, patientCount, vehicleCount] call ace_medical_gui_fnc_formatItemCounts
 *
 * Public: No
 */

params ["_medicCount", "_patientCount", "_vehicleCount", "_crateCount"];
private _countStrings = [format ["%1 %2", _medicCount, ACELLSTRING(medical_gui,TreatmentItemCount_Medic)]];
if ((ACEGVAR(medical_treatment,allowSharedEquipment) != 2) && {!isNil "_patientCount"}) then {
    _countStrings pushBack format ["%1 %2", _patientCount, ACELLSTRING(medical_gui,TreatmentItemCount_Patient)];
};

if (!isNil "_vehicleCount") then {
    _countStrings pushBack format ["%1 %2", _vehicleCount, ACELLSTRING(medical_gui,TreatmentItemCount_Vehicle)];
};

if (!isNil "_crateCount") then {
    _countStrings pushBack format ["%1 %2", _crateCount, LLSTRING(SETTING_TreatmentItemCount_Crate)];
};

_countStrings joinString "\n"