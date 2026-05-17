#include "..\script_component.hpp"
/*
 * Author: Lynx
 *
 *
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_triagecard_fnc
 *
 * Public: No
 */
 
#include "..\ui\idc_macros.hpp"
params ["_display", ["_config", configNull]];
switch (uiNamespace getVariable [QGVAR(triageCard), 0]) do {
	case (1): {
		(_display displayCtrl IDC_DD1380_PATIENT_NAME) ctrlSetText ([ACEGVAR(medical_gui,target)] call ACEFUNC(common,getName));
		(_display displayCtrl IDC_DD1380_PATIENT_LAST4) ctrlSetText (((name ACEGVAR(medical_gui,target)) call ACEFUNC(dogtags,ssn)) select [7,4]);
		(_display displayCtrl IDC_DD1380_PATIENT_DATE) ctrlSetText ([date] call FUNC(getDate));
		
		if ([ACEGVAR(medical_gui,target), "leftarm"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 4) == 1) then {
				(_display displayCtrl IDC_DD1380_L_ARM_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_L_ARM_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_L_ARM_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 4);
		} else {
			(_display displayCtrl IDC_DD1380_L_ARM_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_L_ARM_TIME) ctrlSetText "";
		};
		if (([ACEGVAR(medical_gui,target), "upperleftarm"] call EFUNC(hitpoints,hasTourniquetAppliedTo))) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 5) == 1) then {
				(_display displayCtrl IDC_DD1380_UL_ARM_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_UL_ARM_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_UL_ARM_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 5);
		} else {
			(_display displayCtrl IDC_DD1380_UL_ARM_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_UL_ARM_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "rightarm"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 6) == 1) then {
				(_display displayCtrl IDC_DD1380_R_ARM_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_R_ARM_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_R_ARM_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 6);
		} else {
			(_display displayCtrl IDC_DD1380_R_ARM_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_R_ARM_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "upperrightarm"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 7) == 1) then {
				(_display displayCtrl IDC_DD1380_UR_ARM_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_UR_ARM_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_UR_ARM_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 7);
		} else {
			(_display displayCtrl IDC_DD1380_UR_ARM_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_UR_ARM_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "leftleg"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 8) == 1) then {
				(_display displayCtrl IDC_DD1380_L_LEG_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_L_LEG_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_L_LEG_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 8);
		} else {
			(_display displayCtrl IDC_DD1380_L_LEG_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_L_LEG_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "upperleftleg"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 9) == 1) then {
				(_display displayCtrl IDC_DD1380_UL_LEG_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_UL_LEG_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_UL_LEG_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 9);
		} else {
			(_display displayCtrl IDC_DD1380_UL_LEG_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_UL_LEG_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "rightleg"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 10) == 1) then {
				(_display displayCtrl IDC_DD1380_R_LEG_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_R_LEG_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_R_LEG_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 10);
		} else {
			(_display displayCtrl IDC_DD1380_R_LEG_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_R_LEG_TIME) ctrlSetText "";
		};
		if ([ACEGVAR(medical_gui,target), "upperrightleg"] call EFUNC(hitpoints,hasTourniquetAppliedTo)) then {
			if ((GET_KAT_TOURNIQUETS(ACEGVAR(medical_gui,target)) select 11) == 1) then {
				(_display displayCtrl IDC_DD1380_UR_LEG_TYPE) ctrlSetText LLSTRING(TQType_CAT);
			} else {
				(_display displayCtrl IDC_DD1380_UR_LEG_TYPE) ctrlSetText LLSTRING(TQType_Hasty);
			};
			(_display displayCtrl IDC_DD1380_UR_LEG_TIME) ctrlSetText (ACEGVAR(medical_gui,target) getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]] select 11);
		} else {
			(_display displayCtrl IDC_DD1380_UR_LEG_TYPE) ctrlSetText "";
			(_display displayCtrl IDC_DD1380_UR_LEG_TIME) ctrlSetText "";
		};

		_priority = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardPriority), createHashMap];
		{
			(_display displayCtrl _x) cbSetChecked _y;
		} forEach _priority;

		_cb = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardCheckboxes), createHashMap];
		{
			(_display displayCtrl _x) cbSetChecked _y;
		} forEach _cb;

		_text = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardText), createHashMap];
		{
			(_display displayCtrl _x) ctrlSetText _y;
		} forEach _text;
	};
	case (2): {
		_priority = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardPriority), createHashMap];
		{
			(_display displayCtrl _x) cbSetChecked _y;
		} forEach _priority;
		
		_cb = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardBackCheckboxes), createHashMap];
		{
			(_display displayCtrl _x) cbSetChecked _y;
		} forEach _cb;

		_text = ACEGVAR(medical_gui,target) getVariable [QGVAR(triageCardBackText), createHashMap];
		{
			(_display displayCtrl _x) ctrlSetText _y;
		} forEach _text;
	};
	default {};
};
