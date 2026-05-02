class ACE_Medical_Treatment_Actions {
    class ApplyTourniquet;
    class RemoveTourniquet: ApplyTourniquet {
        treatmentTime = QGVAR(treatmentTimeDetachTourniquet);
    };
};
