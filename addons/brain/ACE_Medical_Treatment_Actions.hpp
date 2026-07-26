class ACE_Medical_Treatment_Actions {
    class BasicBandage;
    class CheckPulse;
    class HeadUltrasound: BasicBandage {
        displayName = CSTRING(UltraICP_Use);
        displayNameProgress = CSTRING(UltraICP_Action);
        category = "examine";
        treatmentLocations = QEGVAR(surgery,ultrasoundLocation);
        allowedSelections[] = {"Head"};
        allowSelfTreatment = 0;
        medicRequired = QEGVAR(surgery,ultrasoundAction_MedLevel);
        treatmentTime = QEGVAR(surgery,ultrasoundTime);
        items[] = {"kat_ultrasound"};
        consumeItem = 0;
        condition = QGVAR(enable);
        callbackSuccess = QFUNC(icpAssessment);
    };
    class CheckPupils: CheckPulse {
        displayName = CSTRING(checkPupils);
        displayNameProgress = CSTRING(action_checking);
        category = "examine";
        medicRequired = QGVAR(pupilAction_MedLevel);
        treatmentTime = 6;
        allowedSelections[] = {"Head"};
        allowSelfTreatment = 0;
        callbackSuccess = QFUNC(checkPupils);
        condition = QGVAR(enable);
        animationPatientUnconscious = "AinjPpneMstpSnonWrflDnon_rolltoback";
        animationPatientUnconsciousExcludeOn[] = {"ainjppnemstpsnonwrfldnon", "kat_recoveryposition"};
    };
};
