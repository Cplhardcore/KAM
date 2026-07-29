class ACE_Medical_Treatment_Actions {
    class ApplyTourniquet;
    class FieldDressing;
    class BasicBandage;
    class RemoveTourniquet: ApplyTourniquet {
        treatmentTime = QGVAR(treatmentTimeDetachTourniquet);
    };
    class SurgicalKit: FieldDressing {
        callbackSuccess = QFUNC(surgicalKitEnd);
        callbackFailure = QFUNC(surgicalKitEnd);
    };
};
