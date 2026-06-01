class CfgFunctions {
    class overwrite_medical_gui {
        tag = "ace_medical_gui";
        class ace_medical_gui {
            class addTreatmentActions {
                file = QPATHTOF(functions\fnc_addTreatmentActions.sqf);
            };
            class collectActions {
                file = QPATHTOF(functions\fnc_collectActions.sqf);
            };
            class menuPFH {
                file = QPATHTOF(functions\fnc_menuPFH.sqf);
            };
            class onMenuClose {
                file = QPATHTOF(functions\fnc_onMenuClose.sqf);
            };
            class onMenuOpen {
                file = QPATHTOF(functions\fnc_onMenuOpen.sqf);
            };
            class updateCategories {
                file = QPATHTOF(functions\fnc_updateCategories.sqf);
            };
            class updateInjuryList {
                file = QPATHTOF(functions\fnc_updateInjuryList.sqf);
            };
            class updateBodyImage {
                file = QPATHTOF(functions\fnc_updateBodyImage.sqf);
            };
            class displayPatientInformation {
                file = QPATHTOF(functions\fnc_displayPatientInformation.sqf);
            };
            class updateTriageStatus {
                file = QPATHTOF(functions\fnc_updateTriageStatus.sqf);
            };
            class modifyActionTriageLevel {
                file = QPATHTOF(functions\fnc_modifyActionTriageLevel.sqf);
            };
        };
    };
    class overwrite_medical_treatment {
        tag = "ace_medical_treatment";
        class ace_medical_treatment {
            class getTriageStatus {
                file = QPATHTOF(functions\fnc_getTriageStatus.sqf);
            };
        };
    };
};
