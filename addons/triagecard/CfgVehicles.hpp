class CfgVehicles {
    class Man;
    class CAManBase: Man {
        class ACE_Actions {
            class ACE_Head {
                class openTriageCard {
                    displayName = CSTRING(openTriageCard);
                    condition =  "true";
                    statement = QFUNC(openCard);
                    showDisabled = 0;
                    exceptions[] = {"isNotInside", "isNotSitting"};
                    icon = "";
                };
            };
        };
    };
};
