class RscStandardDisplay;
class RscDisplayMain: RscStandardDisplay {
    class controls {
        class GroupSingleplayer: RscControlsGroupNoScrollbars {
            class Controls;
        };
        class GroupTutorials: GroupSingleplayer {
            h = "(7 *   1.5) *  (pixelH * pixelGrid * 2)";

            class Controls: Controls {
                class Bootcamp;
                class Arsenal;
                class ace_arsenal_mission;
                class GVAR(mission): Bootcamp {
                    idc = -1;
                    text = CSTRING(Mission);
                    tooltip = CSTRING(Mission_tooltip);
                    y = "(4 *   1.5) *  (pixelH * pixelGrid * 2) +  (pixelH)";
                    onbuttonclick = QUOTE(playMission [ARR_2('','PATHTOF(missions\KAT_MEDICAL_TESTING_FACILITY.Stratis)')]);
                };
                class FieldManual: Bootcamp {
                    y = "(5 *   1.5) *  (pixelH * pixelGrid * 2) +  (pixelH)";
                };
                class CommunityGuides: Bootcamp {
                    y = "(6 *   1.5) *  (pixelH * pixelGrid * 2) +  (pixelH)";
                };
            };
        };
    };
};