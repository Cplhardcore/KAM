#include "ui\ui_macros.hpp"
#include "ui\idc_macros.hpp"
class RscCheckbox;
class RscButton;
class RscEdit;
class RscPictureKeepAspect;
class RscText;
class DD1380_RscButton : RscButton {
	colorDisabled[] = {0,0,0,0};
	colorBackground[] = {0,0,0,0};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorBackgroundActive[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
};
class DD1380_RscCheckbox : RscCheckbox {
	color[] = COLOR_BLACK;
	colorFocused[] = COLOR_BLACK;
	colorHover[] = COLOR_BLACK;
	colorPressed[] = COLOR_BLACK;
	colorDisabled[] = COLOR_BLACK;
	shadow = 0;
};
class DD1380_RscEdit: RscEdit {
	style = ST_LEFT + ST_NO_RECT;
	//w = QUOTE(KAT_TCpxToScreen_W(DD1380_GUI_DH9_OSD_ELEMENT_STD_W));
	//h = QUOTE(KAT_TCpxToScreen_H(DD1380_GUI_DH9_OSD_ELEMENT_STD_H));
	colorText[] = COLOR_BLACK;
	sizeEx = QUOTE(KAT_TCpxToScreen_H(36));
	colorBackground[] = COLOR_TRANSPARENT;
	shadow = 0;
};
class DD1380_RscText: RscText {
	style = ST_LEFT;
	//w = QUOTE(KAT_TCpxToScreen_W(DD1380_GUI_DH9_OSD_ELEMENT_STD_W));
	//h = QUOTE(KAT_TCpxToScreen_H(DD1380_GUI_DH9_OSD_ELEMENT_STD_H));
	colorText[] = COLOR_BLACK;
	sizeEx = QUOTE(KAT_TCpxToScreen_H(36));
	colorBackground[] = COLOR_TRANSPARENT;
	shadow = 0;
};
class GVAR(triageCardDialog)
{
	idd = 1380;
	movingEnable = QUOTE(true);
	onLoad= "((uiNamespace setVariable ['kat_triagecard_triageCard', 1]) && (_this call kat_triagecard_fnc_onLoad))";
	onUnload= "((_this call kat_triagecard_fnc_setData) && (uiNamespace setVariable ['kat_triagecard_triageCard', nil]))";
	class Controls {
		// CARD
		class DD1380_Card : RscPictureKeepAspect {
			idc = IDC_DD1380_Card;
			text = QPATHTOF(ui\TCCC1.paa);
			x = QUOTE(KAT_GUI_GRID_X);
			y = QUOTE(KAT_GUI_GRID_Y);
			w = QUOTE(KAT_GUI_GRID_W);
			h = QUOTE(KAT_GUI_GRID_H);
		};

		// EVAC CHECKBOXES
		class EVAC_URGENT : DD1380_RscCheckbox {
			idc = IDC_DD1380_EVAC_URGENT;
			x = QUOTE(KAT_TCpxToScreen_X(409));
			y = QUOTE(KAT_TCpxToScreen_Y(145));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			h = QUOTE(KAT_TCpxToScreen_H(16));
			tooltip = "Urgent";
		};
		class EVAC_PRIORITY : EVAC_URGENT {
			idc = IDC_DD1380_EVAC_PRIORITY;
			x = QUOTE(KAT_TCpxToScreen_X(502));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			tooltip = "Priority";
		};
		class EVAC_ROUTINE : EVAC_URGENT {
			idc = IDC_DD1380_EVAC_ROUTINE;
			x = QUOTE(KAT_TCpxToScreen_X(603));
			tooltip = "Routine";
		};

		// PATIENT INFO
		class PATIENT_NAME : DD1380_RscText {
			idc = IDC_DD1380_PATIENT_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(333));
			y = QUOTE(KAT_TCpxToScreen_Y(172));
			w = QUOTE(KAT_TCpxToScreen_W(321));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class PATIENT_LAST4 : PATIENT_NAME {
			idc = IDC_DD1380_PATIENT_LAST4;
			x = QUOTE(KAT_TCpxToScreen_X(735));
			w = QUOTE(KAT_TCpxToScreen_W(94));
		};
		class PATIENT_SEX_M : DD1380_RscCheckbox {
			idc = IDC_DD1380_PATIENT_SEX_M;
			checked = 1;
			x = QUOTE(KAT_TCpxToScreen_X(255));
			y = QUOTE(KAT_TCpxToScreen_Y(206));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class PATIENT_SEX_F : PATIENT_SEX_M {
			idc = IDC_DD1380_PATIENT_SEX_F;
			checked = 0;
			x = QUOTE(KAT_TCpxToScreen_X(300));
		};
		class PATIENT_DATE : DD1380_RscText {
			idc = IDC_DD1380_PATIENT_DATE;
			x = QUOTE(KAT_TCpxToScreen_X(488));
			y = QUOTE(KAT_TCpxToScreen_Y(204));
			w = QUOTE(KAT_TCpxToScreen_W(131));
		};
		class PATIENT_TIME : DD1380_RscEdit {
			idc = IDC_DD1380_PATIENT_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(682));
			y = QUOTE(KAT_TCpxToScreen_Y(204));
			w = QUOTE(KAT_TCpxToScreen_W(110));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class PATIENT_SERVICE : DD1380_RscEdit {
			idc = IDC_DD1380_PATIENT_SERVICE;
			x = QUOTE(KAT_TCpxToScreen_X(294));
			y = QUOTE(KAT_TCpxToScreen_Y(236));
			w = QUOTE(KAT_TCpxToScreen_W(86));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class PATIENT_UNIT : PATIENT_SERVICE {
			idc = IDC_DD1380_PATIENT_UNIT;
			x = QUOTE(KAT_TCpxToScreen_X(435));
			w = QUOTE(KAT_TCpxToScreen_W(160));
		};
		class PATIENT_ALLERGIES : PATIENT_SERVICE {
			idc = IDC_DD1380_PATIENT_ALLERGIES;
			x = QUOTE(KAT_TCpxToScreen_X(713));
			w = QUOTE(KAT_TCpxToScreen_W(116));
		};

		// MECHANISM OF INJURY
		class MECHANISM_ARTY : DD1380_RscCheckbox {
			idc = IDC_DD1380_MECHANISM_ARTY;
			x = QUOTE(KAT_TCpxToScreen_X(224));
			y = QUOTE(KAT_TCpxToScreen_Y(298));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(16));
		};
		class MECHANISM_BLUNT : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_BLUNT;
			x = QUOTE(KAT_TCpxToScreen_X(345));
		};
		class MECHANISM_BURN : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_BURN;
			x = QUOTE(KAT_TCpxToScreen_X(427));
		};
		class MECHANISM_FALL : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_FALL;
			x = QUOTE(KAT_TCpxToScreen_X(505));
		};
		class MECHANISM_GRENADE : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_GRENADE;
			x = QUOTE(KAT_TCpxToScreen_X(576));
		};
		class MECHANISM_GSW : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_GSW;
			x = QUOTE(KAT_TCpxToScreen_X(690));
			w = QUOTE(KAT_TCpxToScreen_W(16));
		};
		class MECHANISM_IED : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_IED;
			x = QUOTE(KAT_TCpxToScreen_X(771));
		};
		class MECHANISM_MINE : MECHANISM_ARTY {
			idc = IDC_DD1380_MECHANISM_MINE;
			x = QUOTE(KAT_TCpxToScreen_X(224));
			y = QUOTE(KAT_TCpxToScreen_Y(322));
		};
		class MECHANISM_MVC : MECHANISM_MINE {
			idc = IDC_DD1380_MECHANISM_MVC;
			x = QUOTE(KAT_TCpxToScreen_X(345));
		};
		class MECHANISM_RPG : MECHANISM_MINE {
			idc = IDC_DD1380_MECHANISM_RPG;
			x = QUOTE(KAT_TCpxToScreen_X(428));
		};
		class MECHANISM_OTHER : MECHANISM_MINE {
			idc = IDC_DD1380_MECHANISM_OTHER;
			x = QUOTE(KAT_TCpxToScreen_X(505));
		};
		class MECHANISM_OTHER_EDIT : DD1380_RscEdit {
			idc = IDC_DD1380_MECHANISM_OTHER_EDIT;
			x = QUOTE(KAT_TCpxToScreen_X(606));
			y = QUOTE(KAT_TCpxToScreen_Y(319));
			w = QUOTE(KAT_TCpxToScreen_W(223));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};

		// INJURY TQ
		class INJURY_TQ_R_ARM_TYPE : DD1380_RscText {
			idc = IDC_DD1380_R_ARM_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(304));
			y = QUOTE(KAT_TCpxToScreen_Y(404));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_R_ARM_TIME : INJURY_TQ_R_ARM_TYPE {
			idc = IDC_DD1380_R_ARM_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(430));
		};
		class INJURY_TQ_UR_ARM_TYPE : DD1380_RscText {
			idc = IDC_DD1380_UR_ARM_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(277));
			y = QUOTE(KAT_TCpxToScreen_Y(404));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_UR_ARM_TIME : INJURY_TQ_UR_ARM_TYPE {
			idc = IDC_DD1380_UR_ARM_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(430));
		};
		class INJURY_TQ_L_ARM_TYPE : DD1380_RscText {
			idc = IDC_DD1380_L_ARM_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(612));
			y = QUOTE(KAT_TCpxToScreen_Y(404));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_L_ARM_TIME : INJURY_TQ_L_ARM_TYPE {
			idc = IDC_DD1380_L_ARM_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(430));
		};
		class INJURY_TQ_UL_ARM_TYPE : DD1380_RscText {
			idc = IDC_DD1380_UL_ARM_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(575));
			y = QUOTE(KAT_TCpxToScreen_Y(404));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_UL_ARM_TIME : INJURY_TQ_UL_ARM_TYPE {
			idc = IDC_DD1380_UL_ARM_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(430));
		};
		class INJURY_TQ_R_LEG_TYPE : DD1380_RscText {
			idc = IDC_DD1380_R_LEG_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(304));
			y = QUOTE(KAT_TCpxToScreen_Y(697));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_R_LEG_TIME : INJURY_TQ_R_LEG_TYPE {
			idc = IDC_DD1380_R_LEG_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(724));
		};
		class INJURY_TQ_UR_LEG_TYPE : DD1380_RscText {
			idc = IDC_DD1380_UR_LEG_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(277));
			y = QUOTE(KAT_TCpxToScreen_Y(697));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_UR_LEG_TIME : INJURY_TQ_UR_LEG_TYPE {
			idc = IDC_DD1380_UR_LEG_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(724));
		};
		class INJURY_TQ_L_LEG_TYPE : DD1380_RscText {
			idc = IDC_DD1380_L_LEG_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(612));
			y = QUOTE(KAT_TCpxToScreen_Y(697));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_L_LEG_TIME : INJURY_TQ_L_LEG_TYPE {
			idc = IDC_DD1380_L_LEG_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(724));
		};
		class INJURY_TQ_UL_LEG_TYPE : DD1380_RscText {
			idc = IDC_DD1380_UL_LEG_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(575));
			y = QUOTE(KAT_TCpxToScreen_Y(697));
			w = QUOTE(KAT_TCpxToScreen_W(37));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class INJURY_TQ_UL_LEG_TIME : INJURY_TQ_UL_LEG_TYPE {
			idc = IDC_DD1380_UL_LEG_TIME;
			y = QUOTE(KAT_TCpxToScreen_Y(724));
		};


		// INJURIES
		class INJURY_R_ARM : DD1380_RscCheckbox {
			idc = IDC_DD1380_INJURY_R_ARM;
			x = QUOTE(KAT_TCpxToScreen_X(376));
			y = QUOTE(KAT_TCpxToScreen_Y(504));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class INJURY_L_ARM : INJURY_R_ARM {
			idc = IDC_DD1380_INJURY_L_ARM;
			x = QUOTE(KAT_TCpxToScreen_X(481));
		};
		class INJURY_R_LEG : DD1380_RscCheckbox {
			idc = IDC_DD1380_INJURY_R_ARM;
			x = QUOTE(KAT_TCpxToScreen_X(408));
			y = QUOTE(KAT_TCpxToScreen_Y(640));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class INJURY_L_LEG : INJURY_R_LEG {
			idc = IDC_DD1380_INJURY_L_LEG;
			x = QUOTE(KAT_TCpxToScreen_X(451));
		};
		class INJURY_TORSO : DD1380_RscCheckbox {
			idc = IDC_DD1380_INJURY_TORSO;
			x = QUOTE(KAT_TCpxToScreen_X(420));
			y = QUOTE(KAT_TCpxToScreen_Y(480));
			w = QUOTE(KAT_TCpxToScreen_W(34));
			h = QUOTE(KAT_TCpxToScreen_H(34));
		};
		class INJURY_HEAD : DD1380_RscCheckbox {
			idc = IDC_DD1380_INJURY_HEAD;
			x = QUOTE(KAT_TCpxToScreen_X(430));
			y = QUOTE(KAT_TCpxToScreen_Y(396));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		// SIGNS/SYMPTOMS COLUMN 1
		class SIGNS_TIME_1 : DD1380_RscEdit {
			idc = IDC_DD1380_SIGNS_TIME_1;
			x = QUOTE(KAT_TCpxToScreen_X(425));
			y = QUOTE(KAT_TCpxToScreen_Y(790));
			w = QUOTE(KAT_TCpxToScreen_W(98));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class SIGNS_PULSE_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_PULSE_1;
			y = QUOTE(KAT_TCpxToScreen_Y(821));
			h = QUOTE(KAT_TCpxToScreen_H(27));
		};
		class SIGNS_BP1_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_BP1_1;
			x = QUOTE(KAT_TCpxToScreen_X(424));
			y = QUOTE(KAT_TCpxToScreen_Y(851));
			w = QUOTE(KAT_TCpxToScreen_W(50));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class SIGNS_BP2_1 : SIGNS_BP1_1 {
			idc = IDC_DD1380_SIGNS_BP2_1;
			x = QUOTE(KAT_TCpxToScreen_X(474));
		};
		class SIGNS_RR_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_RR_1;
			y = QUOTE(KAT_TCpxToScreen_Y(883));
			h = QUOTE(KAT_TCpxToScreen_H(25));
		};
		class SIGNS_SAT_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_SAT_1;
			y = QUOTE(KAT_TCpxToScreen_Y(912));
			h = QUOTE(KAT_TCpxToScreen_H(29));
		};
		class SIGNS_AVPU_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_AVPU_1;
			y = QUOTE(KAT_TCpxToScreen_Y(945));
			h = QUOTE(KAT_TCpxToScreen_H(27));
		};
		class SIGNS_PAIN_1 : SIGNS_TIME_1 {
			idc = IDC_DD1380_SIGNS_PAIN_1;
			y = QUOTE(KAT_TCpxToScreen_Y(976));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		// SIGNS/SYMPTOMS COLUMN 2
		class SIGNS_TIME_2 : DD1380_RscEdit {
			idc = IDC_DD1380_SIGNS_TIME_2;
			x = QUOTE(KAT_TCpxToScreen_X(526));
			y = QUOTE(KAT_TCpxToScreen_Y(790));
			w = QUOTE(KAT_TCpxToScreen_W(98));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class SIGNS_PULSE_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_PULSE_2;
			y = QUOTE(KAT_TCpxToScreen_Y(821));
			h = QUOTE(KAT_TCpxToScreen_H(27));
		};
		class SIGNS_BP1_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_BP1_2;
			x = QUOTE(KAT_TCpxToScreen_X(526));
			y = QUOTE(KAT_TCpxToScreen_Y(851));
			w = QUOTE(KAT_TCpxToScreen_W(50));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class SIGNS_BP2_2 : SIGNS_BP1_2 {
			idc = IDC_DD1380_SIGNS_BP2_2;
			x = QUOTE(KAT_TCpxToScreen_X(576));
		};
		class SIGNS_RR_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_RR_2;
			y = QUOTE(KAT_TCpxToScreen_Y(883));
			h = QUOTE(KAT_TCpxToScreen_H(25));
		};
		class SIGNS_SAT_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_SAT_2;
			y = QUOTE(KAT_TCpxToScreen_Y(912));
			h = QUOTE(KAT_TCpxToScreen_H(29));
		};
		class SIGNS_AVPU_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_AVPU_2;
			y = QUOTE(KAT_TCpxToScreen_Y(945));
			h = QUOTE(KAT_TCpxToScreen_H(27));
		};
		class SIGNS_PAIN_2 : SIGNS_TIME_2 {
			idc = IDC_DD1380_SIGNS_PAIN_2;
			y = QUOTE(KAT_TCpxToScreen_Y(976));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		// FLIP PAGE
		class FLIP_PAGE : DD1380_RscButton {
			idc = IDC_DD1380_FLIP_PAGE;
			x = QUOTE(KAT_TCpxToScreen_X(834));
			y = QUOTE(KAT_TCpxToScreen_Y(0));
			w = QUOTE(KAT_TCpxToScreen_W(40));
			h = QUOTE(KAT_TCpxToScreen_H(84));
			text = ">";
			onButtonClick="_this call kat_triagecard_fnc_flipPage";
			tooltip = "Flip card";
		};
	};
};

class GVAR(triageCardDialog2)
{
	idd = 13802;
	movingEnable = QUOTE(true);
	onLoad= "((uiNamespace setVariable ['kat_triagecard_triageCard', 2]) && (_this call kat_triagecard_fnc_onLoad))";
	onUnload= "((_this call kat_triagecard_fnc_setData) && (uiNamespace setVariable ['kat_triagecard_triageCard', nil]))";
	class Controls {
		// CARD
		class DD1380_Card : RscPictureKeepAspect {
			idc = IDC_DD1380_Card;
			text = QPATHTOF(ui\TCCC2.paa);
			x = QUOTE(KAT_GUI_GRID_X);
			y = QUOTE(KAT_GUI_GRID_Y);
			w = QUOTE(KAT_GUI_GRID_W);
			h = QUOTE(KAT_GUI_GRID_H);
		};

		// EVAC CHECKBOXES
		class EVAC_URGENT : DD1380_RscCheckbox {
			idc = IDC_DD1380_EVAC_URGENT;
			x = QUOTE(KAT_TCpxToScreen_X(414));
			y = QUOTE(KAT_TCpxToScreen_Y(123));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(16));
			tooltip = "Urgent";
		};
		class EVAC_PRIORITY : EVAC_URGENT {
			idc = IDC_DD1380_EVAC_PRIORITY;
			x = QUOTE(KAT_TCpxToScreen_X(508));
			tooltip = "Priority";
		};
		class EVAC_ROUTINE : EVAC_URGENT {
			idc = IDC_DD1380_EVAC_ROUTINE;
			x = QUOTE(KAT_TCpxToScreen_X(609));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			tooltip = "Routine";
		};

		// TQ
		class TREAT_TQ_EXTREMITY : DD1380_RscCheckbox {
			idc = IDC_DD1380_TREAT_TQ_EXTREMITY;
			x = QUOTE(KAT_TCpxToScreen_X(284));
			y = QUOTE(KAT_TCpxToScreen_Y(180));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			h = QUOTE(KAT_TCpxToScreen_H(16));
		};
		class TREAT_TQ_JUNCTIONAL : TREAT_TQ_EXTREMITY {
			idc = IDC_DD1380_TREAT_TQ_JUNCTIONAL;
			x = QUOTE(KAT_TCpxToScreen_X(397));
		};
		class TREAT_TQ_TRUNCAL : TREAT_TQ_EXTREMITY {
			idc = IDC_DD1380_TREAT_TQ_TRUNCAL;
			x = QUOTE(KAT_TCpxToScreen_X(520));
			w = QUOTE(KAT_TCpxToScreen_W(17));
		};
		class TREAT_TQ_TYPE : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_TQ_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(664));
			y = QUOTE(KAT_TCpxToScreen_Y(177));
			w = QUOTE(KAT_TCpxToScreen_W(164));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		// DRESSING
		class TREAT_DRESSING_HEMOSTATIC : DD1380_RscCheckbox {
			idc = IDC_DD1380_TREAT_DRESSING_HEMOSTATIC;
			x = QUOTE(KAT_TCpxToScreen_X(332));
			y = QUOTE(KAT_TCpxToScreen_Y(211));
			w = QUOTE(KAT_TCpxToScreen_W(17));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class TREAT_DRESSING_PRESSURE : TREAT_DRESSING_HEMOSTATIC {
			idc = IDC_DD1380_TREAT_DRESSING_PRESSURE;
			x = QUOTE(KAT_TCpxToScreen_X(461));
			w = QUOTE(KAT_TCpxToScreen_W(16));
		};
		class TREAT_DRESSING_OTHER : TREAT_DRESSING_HEMOSTATIC {
			idc = IDC_DD1380_TREAT_DRESSING_OTHER;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(16));
		};
		class TREAT_DRESSING_TYPE : TREAT_TQ_TYPE {
			idc = IDC_DD1380_TREAT_DRESSING_TYPE;
			y = QUOTE(KAT_TCpxToScreen_Y(211));
		};
		// A
		class TREAT_A_INTACT : DD1380_RscCheckbox {
			idc = IDC_DD1380_TREAT_A_INTACT;
			x = QUOTE(KAT_TCpxToScreen_X(246));
			y = QUOTE(KAT_TCpxToScreen_Y(245));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class TREAT_A_NPA : TREAT_A_INTACT {
			idc = IDC_DD1380_TREAT_A_NPA;
			x = QUOTE(KAT_TCpxToScreen_X(321));
		};
		class TREAT_A_CRIC : TREAT_A_INTACT {
			idc = IDC_DD1380_TREAT_A_CRIC;
			x = QUOTE(KAT_TCpxToScreen_X(389));
		};
		class TREAT_A_ETTUBE : TREAT_A_INTACT {
			idc = IDC_DD1380_TREAT_A_ETTUBE;
			x = QUOTE(KAT_TCpxToScreen_X(461));
		};
		class TREAT_A_SGA : TREAT_A_INTACT {
			idc = IDC_DD1380_TREAT_A_SGA;
			x = QUOTE(KAT_TCpxToScreen_X(569));
		};
		class TREAT_A_TYPE : TREAT_TQ_TYPE {
			idc = IDC_DD1380_TREAT_A_TYPE;
			y = QUOTE(KAT_TCpxToScreen_Y(243));
		};
		// B
		class TREAT_B_O2 : DD1380_RscCheckbox {
			idc = IDC_DD1380_TREAT_B_O2;
			x = QUOTE(KAT_TCpxToScreen_X(246));
			y = QUOTE(KAT_TCpxToScreen_Y(279));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			h = QUOTE(KAT_TCpxToScreen_H(17));
		};
		class TREAT_B_NEEDLED : TREAT_B_O2 {
			idc = IDC_DD1380_TREAT_B_NEEDLED;
			x = QUOTE(KAT_TCpxToScreen_X(298));
		};
		class TREAT_B_CHESTTUBE : TREAT_B_O2 {
			idc = IDC_DD1380_TREAT_B_CHESTTUBE;
			x = QUOTE(KAT_TCpxToScreen_X(407));
		};
		class TREAT_B_CHESTSEAL : TREAT_B_O2 {
			idc = IDC_DD1380_TREAT_B_CHESTSEAL;
			x = QUOTE(KAT_TCpxToScreen_X(538));
		};
		class TREAT_B_TYPE : TREAT_TQ_TYPE {
			idc = IDC_DD1380_TREAT_B_TYPE;
			y = QUOTE(KAT_TCpxToScreen_Y(277));
		};
		// FLUID 1
		class TREAT_C_FLUID1_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_C_FLUID1_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(335));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class TREAT_C_FLUID1_VOLUME : TREAT_C_FLUID1_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID1_VOLUME;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(87));
		};
		class TREAT_C_FLUID1_ROUTE : TREAT_C_FLUID1_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID1_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_FLUID1_TIME : TREAT_C_FLUID1_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID1_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// FLUID 2
		class TREAT_C_FLUID2_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_C_FLUID2_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(365));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(28));
		};
		class TREAT_C_FLUID2_VOLUME : TREAT_C_FLUID2_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID2_VOLUME;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(87));
		};
		class TREAT_C_FLUID2_ROUTE : TREAT_C_FLUID2_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID2_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_FLUID2_TIME : TREAT_C_FLUID2_NAME {
			idc = IDC_DD1380_TREAT_C_FLUID2_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// BLOOD 1
		class TREAT_C_BLOOD1_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_C_BLOOD1_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(395));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(30));
		};
		class TREAT_C_BLOOD1_VOLUME : TREAT_C_BLOOD1_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD1_VOLUME;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_BLOOD1_ROUTE : TREAT_C_BLOOD1_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD1_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_BLOOD1_TIME : TREAT_C_BLOOD1_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD1_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// BLOOD 2
		class TREAT_C_BLOOD2_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_C_BLOOD2_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(427));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(30));
		};
		class TREAT_C_BLOOD2_VOLUME : TREAT_C_BLOOD2_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD2_VOLUME;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_BLOOD2_ROUTE : TREAT_C_BLOOD2_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD2_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_C_BLOOD2_TIME : TREAT_C_BLOOD2_NAME {
			idc = IDC_DD1380_TREAT_C_BLOOD2_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// ANALGESIC 1
		class TREAT_MEDS_ANALGESIC1_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC1_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(489));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(26));
		};
		class TREAT_MEDS_ANALGESIC1_DOSE : TREAT_MEDS_ANALGESIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC1_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC1_ROUTE : TREAT_MEDS_ANALGESIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC1_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC1_TIME : TREAT_MEDS_ANALGESIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC1_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// ANALGESIC 2
		class TREAT_MEDS_ANALGESIC2_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC2_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(517));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(30));
		};
		class TREAT_MEDS_ANALGESIC2_DOSE : TREAT_MEDS_ANALGESIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC2_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC2_ROUTE : TREAT_MEDS_ANALGESIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC2_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC2_TIME : TREAT_MEDS_ANALGESIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC2_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// ANALGESIC 3
		class TREAT_MEDS_ANALGESIC3_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC3_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(548));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(30));
		};
		class TREAT_MEDS_ANALGESIC3_DOSE : TREAT_MEDS_ANALGESIC3_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC3_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC3_ROUTE : TREAT_MEDS_ANALGESIC3_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC3_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANALGESIC3_TIME : TREAT_MEDS_ANALGESIC3_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANALGESIC3_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// ANTIBIOTIC 1
		class TREAT_MEDS_ANTIBIOTIC1_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC1_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(580));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(29));
		};
		class TREAT_MEDS_ANTIBIOTIC1_DOSE : TREAT_MEDS_ANTIBIOTIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC1_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANTIBIOTIC1_ROUTE : TREAT_MEDS_ANTIBIOTIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC1_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANTIBIOTIC1_TIME : TREAT_MEDS_ANTIBIOTIC1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC1_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// ANTIBIOTIC 2
		class TREAT_MEDS_ANTIBIOTIC2_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC2_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(611));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(29));
		};
		class TREAT_MEDS_ANTIBIOTIC2_DOSE : TREAT_MEDS_ANTIBIOTIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC2_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANTIBIOTIC2_ROUTE : TREAT_MEDS_ANTIBIOTIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC2_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_ANTIBIOTIC2_TIME : TREAT_MEDS_ANTIBIOTIC2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_ANTIBIOTIC2_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// OTHER 1
		class TREAT_MEDS_OTHER1_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_OTHER1_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(643));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(29));
		};
		class TREAT_MEDS_OTHER1_DOSE : TREAT_MEDS_OTHER1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER1_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_OTHER1_ROUTE : TREAT_MEDS_OTHER1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER1_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_OTHER1_TIME : TREAT_MEDS_OTHER1_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER1_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// OTHER 2
		class TREAT_MEDS_OTHER2_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_MEDS_OTHER2_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(380));
			y = QUOTE(KAT_TCpxToScreen_Y(673));
			w = QUOTE(KAT_TCpxToScreen_W(188));
			h = QUOTE(KAT_TCpxToScreen_H(30));
		};
		class TREAT_MEDS_OTHER2_DOSE : TREAT_MEDS_OTHER2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER2_DOSE;
			x = QUOTE(KAT_TCpxToScreen_X(569));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_OTHER2_ROUTE : TREAT_MEDS_OTHER2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER2_ROUTE;
			x = QUOTE(KAT_TCpxToScreen_X(657));
			w = QUOTE(KAT_TCpxToScreen_W(88));
		};
		class TREAT_MEDS_OTHER2_TIME : TREAT_MEDS_OTHER2_NAME {
			idc = IDC_DD1380_TREAT_MEDS_OTHER2_TIME;
			x = QUOTE(KAT_TCpxToScreen_X(746));
			w = QUOTE(KAT_TCpxToScreen_W(86));
		};
		// TREAT OTHER
		class TREAT_OTHER_CPP : DD1380_RscCheckbox {
			idc = IDC_DD1380_TREAT_OTHER_CPP;
			x = QUOTE(KAT_TCpxToScreen_X(297));
			y = QUOTE(KAT_TCpxToScreen_Y(714));
			w = QUOTE(KAT_TCpxToScreen_W(16));
			h = QUOTE(KAT_TCpxToScreen_H(16));
		};
		class TREAT_OTHER_EYESHIELD : TREAT_OTHER_CPP {
			idc = IDC_DD1380_TREAT_OTHER_EYESHIELD;
			x = QUOTE(KAT_TCpxToScreen_X(486));
		};
		class TREAT_OTHER_EYESHIELDR : TREAT_OTHER_CPP {
			idc = IDC_DD1380_TREAT_OTHER_EYESHIELDR;
			x = QUOTE(KAT_TCpxToScreen_X(616));
		};
		class TREAT_OTHER_EYESHIELDL : TREAT_OTHER_CPP {
			idc = IDC_DD1380_TREAT_OTHER_EYESHIELDL;
			x = QUOTE(KAT_TCpxToScreen_X(660));
		};
		class TREAT_OTHER_SPLINT : TREAT_OTHER_CPP {
			idc = IDC_DD1380_TREAT_OTHER_SPLINT;
			x = QUOTE(KAT_TCpxToScreen_X(714));
		};
		class TREAT_OTHER_HYPOTHERMIA : TREAT_OTHER_CPP {
			idc = IDC_DD1380_TREAT_OTHER_HYPOTHERMIA;
			x = QUOTE(KAT_TCpxToScreen_X(251));
			y = QUOTE(KAT_TCpxToScreen_Y(739));
		};
		class TREAT_OTHER_HYPOTHERMIA_TYPE : DD1380_RscEdit {
			idc = IDC_DD1380_TREAT_OTHER_HYPOTHERMIA_TYPE;
			x = QUOTE(KAT_TCpxToScreen_X(545));
			y = QUOTE(KAT_TCpxToScreen_Y(737));
			w = QUOTE(KAT_TCpxToScreen_W(283));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		// NOTES
		class NOTES : DD1380_RscEdit {
			idc = IDC_DD1380_NOTES;
			style = ST_LEFT + ST_NO_RECT + ST_MULTI;
			x = QUOTE(KAT_TCpxToScreen_X(284));
			y = QUOTE(KAT_TCpxToScreen_Y(764));
			w = QUOTE(KAT_TCpxToScreen_W(544));
			h = QUOTE(KAT_TCpxToScreen_H(188));
		};
		// FIRST RESPONDER
		class FIRST_RESPONDER_NAME : DD1380_RscEdit {
			idc = IDC_DD1380_FIRST_RESPONDER_NAME;
			x = QUOTE(KAT_TCpxToScreen_X(355));
			w = QUOTE(KAT_TCpxToScreen_W(288));
			y = QUOTE(KAT_TCpxToScreen_Y(978));
			h = QUOTE(KAT_TCpxToScreen_H(20));
		};
		class FIRST_RESPONDER_LAST4 : FIRST_RESPONDER_NAME {
			idc = IDC_DD1380_FIRST_RESPONDER_LAST4;
			x = QUOTE(KAT_TCpxToScreen_X(736));
			w = QUOTE(KAT_TCpxToScreen_W(92));
			onMouseButtonDblClick = "_this select 0 ctrlSetText (((name player) call ace_dogtags_fnc_ssn) select [7,4])";
			tooltip = "Double Click Me!";
		};
		// FLIP PAGE
		class FLIP_PAGE : DD1380_RscButton {
			idc = IDC_DD1380_FLIP_PAGE;
			x = QUOTE(KAT_TCpxToScreen_X(834));
			y = QUOTE(KAT_TCpxToScreen_Y(0));
			w = QUOTE(KAT_TCpxToScreen_W(40));
			h = QUOTE(KAT_TCpxToScreen_H(84));
			text = ">";
			onButtonClick="_this call kat_triagecard_fnc_flipPage";
			tooltip = "Flip card";
		};
	};
};
