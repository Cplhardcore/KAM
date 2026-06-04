#define COMPONENT misc
#define COMPONENT_BEAUTIFIED MISC
#include "\x\kat\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MISC
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MISC
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MISC
#endif

#include "\x\kat\addons\main\script_macros.hpp"

#define MEDICAL_TREATMENT_ITEMS (call (uiNamespace getVariable [QACEGVAR(medical_treatment,treatmentItems), {[]}]))

// Animations that would be played slower than this are instead played exactly as slow as this. (= Progress bar will take longer than the slowed down animation).
#define ANIMATION_SPEED_MIN_COEFFICIENT 0.5

// Animations that would be played faster than this are instead skipped. (= Progress bar too quick for animation).
#define ANIMATION_SPEED_MAX_COEFFICIENT 2.5

#define THROWSTYLE_NORMAL_DIR [0, 70, 500]
#define THROWSTYLE_HIGH_DIR [0, 200, 500]
#define THROWSTYLE_HIGH_VEL_COEF 2
#define THROWSTYLE_DROP_VEL 2
#define THROWSTYLE_DROP_STEP 0.1
#define THROWSTYLE_HIGH_TORQUE_COEF 1
#define THROWSTYLE_DROP_TORQUE_COEF .2

#define THROW_SPEED_DEFAULT 18
#define THROW_MODIFER_DEFAULT 1
#define THROW_MODIFER_MIN 0
#define THROW_MODIFER_MAX 1
#define THROW_MODIFER_STEP (1/GVAR(throwStepSetting))
#define DROP_DISTANCE_DEFAULT 0.2

#define PICK_UP_DISTANCE 10