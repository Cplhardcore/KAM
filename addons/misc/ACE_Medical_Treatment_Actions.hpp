class ACE_Medical_Treatment_Actions {
    class SurgicalKit;
    class ApplyTourniquet;
    class RemoveTourniquet: ApplyTourniquet {
        treatmentTime = QGVAR(treatmentTimeDetachTourniquet);
    };
    class FullBodySurgicalKit: SurgicalKit {
        displayName = CSTRING(Use_SurgicalKitFullBody);
        treatmentTime = QFUNC(getStitchTimeFullBody);
        condition = QFUNC(canStitchFullBody);
        callbackProgress = QFUNC(surgicalKitProgressFullBody);
    };
};
