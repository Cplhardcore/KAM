#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ace_medical",
            "ace_medical_damage",
            "kat_vitals",
            "kat_circulation",
            "kat_breathing",
            "kat_surgery"
        };
        author = "flufflesamy";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "AFL_Medicalsim_Presets.hpp"
#include "ui\RscSimMenu.hpp"
#include "RscDisplayMain.hpp"
