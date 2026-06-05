class CfgFunctions {
    class overwrite_ace_dragging {
        tag = "ace_dragging";
        class ace_dragging {
            class carryObject {
                file = QPATHTOF(functions\fnc_carryObject.sqf);
            };
            class handleUnconscious {
                file = QPATHTOF(functions\fnc_handleUnconscious.sqf);
            };
        };
    };
    class overwrite_ace_medical_engine {
        tag = "ace_medical_engine";
        class ace_medical_engine {
            class updateDamageEffects {
                file = QPATHTOF(functions\fnc_updateDamageEffects.sqf);
            };
            class damageBodyPart {
                file = QPATHTOF(functions\fnc_damageBodyPart.sqf);
            };
        };
    };
    class overwrite_ace_medical_ai {
        tag = "ace_medical_ai";
        class ace_medical_ai {
            class healingLogic {
                file = QPATHTOF(functions\fnc_healingLogic.sqf);
            };
            class isSafe {
                file = QPATHTOF(functions\fnc_isSafe.sqf);
            };
        };
    };
    class overwrite_medical_treatment {
        tag = "ace_medical_treatment";
        class ace_medical_treatment {
            class treatment {
                file = QPATHTOF(functions\fnc_treatment.sqf);
            };
            class treatmentSuccess {
                file = QPATHTOF(functions\fnc_treatmentSuccess.sqf);
            };
            class useItem {
                file = QPATHTOF(functions\fnc_useItem.sqf);
            };
            class bandageLocal {
                file = QPATHTOF(functions\fnc_bandageLocal.sqf);
            };
            class getBandageTime {
                file = QPATHTOF(functions\fnc_getBandageTime.sqf);
            };
            class findMostEffectiveWounds {
                file = QPATHTOF(functions\fnc_findMostEffectiveWounds.sqf);
            };
            class handleBandageOpening {
                file = QPATHTOF(functions\fnc_handleBandageOpening.sqf);
            };
            class canStitch {
                file = QPATHTOF(functions\fnc_canStitch.sqf);
            };
            class stitchWound {
                file = QPATHTOF(functions\fnc_stitchWound.sqf);
            };
            class getStitchTime {
                file = QPATHTOF(functions\fnc_getStitchTime.sqf);
            };
            class surgicalKitProgress {
                file = QPATHTOF(functions\fnc_surgicalKitProgress.sqf);
            };
            class isMedic {
                file = QPATHTOF(functions\fnc_isMedic.sqf);
            };
            class hasItem {
                file = QPATHTOF(functions\fnc_hasItem.sqf);
            };
            class isInMedicalVehicle {
                file = QPATHTOF(functions\fnc_isInMedicalVehicle.sqf);
            };
        };
    };
    class ace_medical {
        tag = "ace_medical";
        class ace_medical {
            class setUnconscious {
                file = QPATHTOF(functions\fnc_setUnconscious.sqf);
            };
            class serializeState {
                file = QPATHTOF(functions\fnc_serializeState.sqf);
            };
            class deserializeState {
                file = QPATHTOF(functions\fnc_deserializeState.sqf);
            };
        };
    };
    class overwrite_dogtags {
        tag = "ace_dogtags";
        class ace_dogtags {
            class getDogtagData {
                file = QPATHTOF(functions\fnc_getDogtagData.sqf);
            };
            class canCheckDogtag {
                file = QPATHTOF(functions\fnc_canCheckDogtag.sqf);
            };
            class showDogtag {
                file = QPATHTOF(functions\fnc_showDogtag.sqf);
            };
        };
    };
    class overwrite_medical_feedback {
        tag = "ace_medical_feedback";
        class ace_medical_feedback {
            class handleEffects {
                file = QPATHTOF(functions\fnc_handleEffects.sqf);
            };
        };
    };
    class overwrite_medical_status {
        tag = "ace_medical_status";
        class ace_medical_status {
            class getMedicationCount {
                file = QPATHTOF(functions\fnc_getMedicationCount.sqf);
            };
        };
    };
    class overwrite_ace_advanced_throwing {
        tag = "ace_advanced_throwing";
        class ace_advanced_throwing {
            class throw {
                file = QPATHTOF(functions\fnc_throw.sqf);
            };
            class prepare {
                file = QPATHTOF(functions\fnc_prepare.sqf);
            };
        };
    };
};
