#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * Handles the overdose effect of Lorazepam
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kat_pharma_fnc_treatmentAdvanced_LorazepamOverdoseLocal;
 *
 * Public: No
 */
params ["_patient"];
private _doseLevel = ([_patient, "LorazepamOverdose", false] call ACEFUNC(medical_status,getMedicationCount)) select 1;
if (_doseLevel < 0.01) then {
    private _hrAdjust = -50 + floor random ((-30 - -50) + 1);
    [_patient, "LorazepamOverdose", 30, 1200, _hrAdjust, 0, 0, 0, 0.2, 0, 0, 0.3] call EFUNC(vitals,addMedicationAdjustment);
};

if (random(100) < 25) then {
[{
    params ["_args", "_idPFH"];
    _args params ["_patient"];
   if (_patient getVariable [QEGVAR(circulation,cardiacArrestType), 0] == 0) then {
            [QACEGVAR(medical,FatalVitals), _patient] call CBA_fnc_localEvent;
    };
}, [_patient], 15] call CBA_fnc_waitAndExecute;
};


/*if (EGVAR(feedback,effectOverdose)) then
    {
    PP_wetD = ppEffectCreate ["WetDistortion",300];
    PP_wetD ppEffectEnable true;
    PP_wetD ppEffectAdjust [10,0.2,0.2,1.84,1.46,0.33,0.86,0.05,0.05,0.05,0.05,0.1,0.1,0.2,0.2];
    PP_wetD ppEffectCommit 0;
    [{PP_wetD ppEffectEnable false; PP_wetD ppEffectCommit 0;}, [], 600] call CBA_fnc_waitAndExecute;};*/
