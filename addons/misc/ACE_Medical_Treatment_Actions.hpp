class ACE_Medical_Treatment_Actions {
    class SurgicalKit;
    class ApplyTourniquet;
    class RemoveTourniquet: ApplyTourniquet {
        treatmentTime = QGVAR(treatmentTimeDetachTourniquet);
    };
};
