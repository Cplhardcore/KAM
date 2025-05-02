class ACE_Medical_Treatment_Actions {
    class CheckPulse;
    class BasicBandage;
    class Hemostat: BasicBandage {
        displayName = CSTRING(Hemostat);
        displayNameProgress = CSTRING(Hemostat_Progress);
        icon = QPATHTOF(ui\Hemostat.paa);
        consumeItem = 1;
        items[] = {"KAT_Hemostatic_Injector"};
        allowSelfTreatment = 1;
        allowedSelections[] = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperLeftArm", "UpperRightArm", "UpperLeftLeg", "UpperRightLeg"};
        treatmentTime = 6;
    };
    class ApplyTourniquet: BasicBandage {
        allowedSelections[] = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperLeftArm", "UpperRightArm", "UpperLeftLeg", "UpperRightLeg"};
    };
    class Splint: BasicBandage {
        allowedSelections[] = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperLeftArm", "UpperRightArm", "UpperLeftLeg", "UpperRightLeg"};
    };

    // - Syringes -------------------------------------------------------------
    class FieldDressing;
    class Morphine: FieldDressing {
        allowedSelections[] = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperLeftArm", "UpperRightArm", "UpperLeftLeg", "UpperRightLeg"};
    };
    // - Diagnose -------------------------------------------------------------
    class Diagnose: BasicBandage {
        allowedSelections[] = {"Head", "Chest"};
    };    
};