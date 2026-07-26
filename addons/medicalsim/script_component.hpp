#define COMPONENT medicalsim
#define COMPONENT_BEAUTIFIED Medical Simulator

#include "\x\kat\addons\main\script_mod.hpp"

#define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MISC
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MISC
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MISC
#endif

#include "\x\kat\addons\main\script_macros.hpp"


// idd/idc definitions for UI
#define IDD_MEDSIM_MENU                 324467

#define IDC_SPAWN_BUTTON                11601
#define IDC_CLEAR_BUTTON                11602
#define IDC_CLEARALL_BUTTON             11603
#define IDC_PRESET_SPAWN_BUTTON         11604
#define IDC_PRESET_SPAWNALL_BUTTON      11605

#define IDC_STRETCHERS_CG               11501
#define IDC_WOUNDS_CG                   11502
#define IDC_CARDIAC_CG                  11503
#define IDC_FRACTURES_CG                11504
#define IDC_PTX_CG                      11505
#define IDC_AIRWAY_CG                   11506
#define IDC_MISC_CG                     11507
#define IDC_PRESETS_CG                  11508

#define IDC_STRETCHERS_LISTBOX          1501
#define IDC_PRESETS_LISTBOX             1502

#define IDC_WOUNDS_HEAD_SLIDER          14301
#define IDC_WOUNDS_TORSO_SLIDER         14302
#define IDC_WOUNDS_LEFTARM_SLIDER       14303
#define IDC_WOUNDS_RIGHTARM_SLIDER      14304
#define IDC_WOUNDS_LEFTLEG_SLIDER       14305
#define IDC_WOUNDS_RIGHTLEG_SLIDER      14306
#define IDC_AIRWAY_PAO2_SLIDER          14307
#define IDC_PTX_STRENGTH_SLIDER         14308
#define IDC_HPTX_STRENGTH_SLIDER         14309

#define IDC_CARDIAC_COMBO               1401
#define IDC_PTX_TYPE_COMBO              1402
#define IDC_FRACTURES_LEFTARM_COMBO     1403
#define IDC_FRACTURES_RIGHTARM_COMBO    1404
#define IDC_FRACTURES_LEFTLEG_COMBO     1405
#define IDC_FRACTURES_RIGHTLEG_COMBO    1406

#define IDC_WOUNDS_HEAD_VAL             1201
#define IDC_WOUNDS_TORSO_VAL            1202
#define IDC_WOUNDS_LEFTARM_VAL          1203
#define IDC_WOUNDS_RIGHTARM_VAL         1204
#define IDC_WOUNDS_LEFTLEG_VAL          1205
#define IDC_WOUNDS_RIGHTLEG_VAL         1206
#define IDC_AIRWAY_PAO2_VAL             1207
#define IDC_PTX_STRENGTH_VAL            1208
#define IDC_HPTX_STRENGTH_VAL            1209
#define IDC_AIRWAY_OCCLUDED_VAL         1210

#define IDC_AIRWAY_OCCLUDED_SLIDER    17701
#define IDC_AIRWAY_OBSTRUCTED_CHECKBOX  17702
#define IDC_TPTX_CHECKBOX    17703
#define IDC_PTX_TAMPONADE_CHECKBOX      17704
#define IDC_MISC_UNCON_CHECKBOX         17705
#define IDC_AIRWAY_CATASTROPHIC_CHECKBOX  17706
#define IDC_WOUNDS_DAMAGE_CHECKBOX 17711
#define IDC_WOUNDS_DAMAGE_TEXT 17712
#define IDC_WOUNDS_DAMAGE_COMBO 17710
#define MEDSIM_SLIDER_ARRAY [\
[IDC_WOUNDS_HEAD_SLIDER, IDC_WOUNDS_HEAD_VAL], \
[IDC_WOUNDS_TORSO_SLIDER, IDC_WOUNDS_TORSO_VAL], \
[IDC_WOUNDS_LEFTARM_SLIDER, IDC_WOUNDS_LEFTARM_VAL], \
[IDC_WOUNDS_RIGHTARM_SLIDER, IDC_WOUNDS_RIGHTARM_VAL], \
[IDC_WOUNDS_LEFTLEG_SLIDER, IDC_WOUNDS_LEFTLEG_VAL], \
[IDC_WOUNDS_RIGHTLEG_SLIDER, IDC_WOUNDS_RIGHTLEG_VAL], \
[IDC_AIRWAY_OCCLUDED_SLIDER, IDC_AIRWAY_OCCLUDED_VAL], \
[IDC_PTX_STRENGTH_SLIDER, IDC_PTX_STRENGTH_VAL], \
[IDC_HPTX_STRENGTH_SLIDER, IDC_HPTX_STRENGTH_VAL]\
]

// UI dimensions
#define MEDSIM_BACKGROUND_UW            40
#define MEDSIM_BACKGROUND_UH            22
#define MEDSIM_BACKGROUND_H             POS_H(MEDSIM_BACKGROUND_UH)
#define MEDSIM_BACKGROUND_W             POS_W(MEDSIM_BACKGROUND_UW)
#define MEDSIM_CONTROLS_UH              (MEDSIM_BACKGROUND_UH - 0.2)
#define MEDSIM_CONTROLS_UW              (MEDSIM_BACKGROUND_UW - 0.2)
#define MEDSIM_CG_UW                    ((MEDSIM_CONTROLS_UW / 2) - 0.1)
#define MEDSIM_CG_W                     POS_W(MEDSIM_CG_UW)
#define MEDSIM_CG_LEFT_UX               0.1
#define MEDSIM_CG_LEFT_X                POS_X(MEDSIM_CG_LEFT_UX)
#define MEDSIM_CG_RIGHT_UX              (MEDSIM_CG_LEFT_UX + MEDSIM_CG_UW + 0.2)
#define MEDSIM_CG_RIGHT_X               POS_X(MEDSIM_CG_RIGHT_UX)
#define MEDSIM_CG_GRID_W                (MEDSIM_CG_UW / 20)
#define MEDSIM_CG_POS_W(N)              POS_W(N * MEDSIM_CG_GRID_W)
#define MEDSIM_CG_GRID_H                (MEDSIM_CONTROLS_UH / 22)
#define MEDSIM_CG_POS_H(N)              POS_X(N##.##N)

// colors
#define COLOR_BUTTON_BKGD               [0, 0, 0, 0.8]
#define COLOR_BUTTON_TEXT               [1, 1, 1, 1]

#define C_GRID_CUSTOMINFOLEFT_X		    (profilenamespace getvariable ["IGUI_GRID_CUSTOMINFOLEFT_X",IGUI_GRID_CUSTOMINFOLEFT_XDef])
#define C_GRID_CUSTOMINFOLEFT_Y		    (profilenamespace getvariable ["IGUI_GRID_CUSTOMINFOLEFT_Y",IGUI_GRID_CUSTOMINFOLEFT_YDef])
#define C_GRID_CUSTOMINFORIGHT_X		(profilenamespace getvariable ["IGUI_GRID_CUSTOMINFORIGHT_X",IGUI_GRID_CUSTOMINFORIGHT_XDef])
#define C_GRID_CUSTOMINFORIGHT_Y		(profilenamespace getvariable ["IGUI_GRID_CUSTOMINFORIGHT_Y",IGUI_GRID_CUSTOMINFORIGHT_YDef])
#define C_GRID_CUSTOMINFO_WAbs		    (profilenamespace getvariable ["IGUI_GRID_CUSTOMINFORIGHT_W",IGUI_GRID_CUSTOMINFO_WDef])
#define C_GRID_CUSTOMINFO_HAbs		    (profilenamespace getvariable ["IGUI_GRID_CUSTOMINFORIGHT_H",IGUI_GRID_CUSTOMINFO_HDef])

#define ENTVAR(var1) DOUBLES(fr,var1)
#define QENTVAR(var1) QUOTE(ENTVAR(var1))

// CBA xeh PREP override
#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(function) TRIPLES(ADDON,fnc,function) = compile preprocessFileLineNumbers '\MAINPREFIX\PREFIX\SUBPREFIX\COMPONENT_F\functions\DOUBLES(fnc,function).sqf'
#else
    #undef PREP
    #define PREP(function) ['\MAINPREFIX\PREFIX\SUBPREFIX\COMPONENT_F\functions\DOUBLES(fnc,function).sqf', 'TRIPLES(ADDON,fnc,function)'] call SLX_XEH_COMPILE_NEW
#endif

// AFL macros
#define FRACTURE_TYPE ["none", "simple", "compound", "comminuted"]
#define PNUMO_TYPE ["none", "initial", "tension", "hemo"]
#define ARREST_TYPE ["none", "asystole", "pea", "vf", "vt"]
#define CHANCE_TO_BOOL(val) val >= random 1

// CBA macros
#define CBA_PREFIX cba
#define CBA_ADDON(component) DOUBLES(CBA_PREFIX,component)

#define CFUNC(function) TRIPLES(CBA_PREFIX,fnc,function)
#define QCFUNC(function) QUOTE(CFUNC(function))

#define CEFUNC(module,function) TRIPLES(DOUBLES(CBA_PREFIX,module),fnc,function)
#define QCEFUNC(module,function) QUOTE(CEFUNC(module,function))

// KAM macros
#define KAM_PREFIX kat

#define KAM_ADDON(component) DOUBLES(KAM_PREFIX,component)

#define KEFUNC(module,function) TRIPLES(DOUBLES(KAM_PREFIX,module),fnc,function)
#define QKEFUNC(module,function) QUOTE(KEFUNC(module,function))

#define KEGVAR(module,var) TRIPLES(KAM_PREFIX,module,var)
#define QKEGVAR(module,var) QUOTE(KEGVAR(module,var))
#define QQKEGVAR(module,var) QUOTE(QKEGVAR(module,var))

#define KELSTRING(module,string) QUOTE(TRIPLES(STR,DOUBLES(KAM_PREFIX,module),string))
#define KELLSTRING(module,string) localize KELSTRING(module,string)
#define KCSTRING(module,string) QUOTE(TRIPLES($STR,DOUBLES(KAM_PREFIX,module),string))

