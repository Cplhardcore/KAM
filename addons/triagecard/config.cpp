#include "script_component.hpp"

class CfgPatches {
    class ADDON    {
        name = COMPONENT_NAME;
        requiredVersion = REQUIRED_VERSION;
        units[] = {};
        weapons[] = {
        };
        magazines[] = {};
        requiredAddons[] = {
            "ace_medical",
            "ace_dogtags",
            "cba_settings"
        };
        author = "Lynx";
        authors[] = {"Lynx"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "gui.hpp"