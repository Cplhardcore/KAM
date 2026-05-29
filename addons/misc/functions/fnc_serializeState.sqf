#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Serializes the medical state of a unit into a string.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Serialized state as JSON string <STRING>
 *
 * Example:
 * [player] call ace_medical_fnc_serializeState
 *
 * Public: Yes
 */
params [["_unit", objNull, [objNull]]];

private _state = [] call CBA_fnc_createNamespace;

// For variables, see: EFUNC(medical_status,initUnit)
{
    _x params ["_var"];
    _state setVariable [_var, _unit getVariable _x];
} forEach [
[VAR_BLOOD_VOL, DEFAULT_BLOOD_VOLUME],
[VAR_HEART_RATE, DEFAULT_HEART_RATE],
[VAR_BLOOD_PRESS, [80, 120]],
[VAR_PERIPH_RES, DEFAULT_PERIPH_RES],
[VAR_HEMORRHAGE, 0],
[VAR_PAIN, 0],
[VAR_IN_PAIN, false],
[VAR_PAIN_SUPP, 0],
[VAR_OPEN_WOUNDS, createHashMap],
[VAR_BANDAGED_WOUNDS, createHashMap],
[VAR_STITCHED_WOUNDS, createHashMap],
[VAR_FRACTURES, DEFAULT_FRACTURE_VALUES],
[VAR_TOURNIQUET, DEFAULT_TOURNIQUET_VALUES],
[QACEGVAR(medical,occludedMedications), nil],
[QACEGVAR(medical,ivBags), nil],
[QACEGVAR(medical,triageLevel), 0],
[QACEGVAR(medical,triageCard), []],
[VAR_BODYPART_DAMAGE, DEFAULT_BODYPART_DAMAGE_VALUES],
[VAR_WRAPPED_WOUNDS, createHashMap],
[VAR_COAGED_WOUNDS, createHashMap],
[QACEGVAR(medical,isLimping), false],
[VAR_SPO2, DEFAULT_SPO2],
[VAR_OXYGEN_DEMAND, 0],
[VAR_VASOCONSTRICTION, [1,1,1,1,1,1,1,1,1,1,1,1]],
[QEGVAR(airway,airway_item), ""],
[QEGVAR(airway,airway), false],
[QEGVAR(airway,clearedTime), 0],
[QEGVAR(airway,cricothyrotomy), 0],
[QEGVAR(airway,stomachVolume), 5],
[QEGVAR(airway,catastrophicAirway), [false, false]],
[QEGVAR(airway,obstruction), [0, 0, 0]],
[QEGVAR(airway,occlusion), [0, 0, 0]],
[QEGVAR(airway,occlusionMitigation), [0, 0, 0]],
[QEGVAR(airway,overstretch), false],
[QEGVAR(airway,recovery), false],
[QEGVAR(airway,wasOccluded), [0, 0, 0]],
[QEGVAR(airway,hasPuked), false],
[QEGVAR(airway,hasExternallyPuked), false],
[QEGVAR(airway,airwayStatus), [0, 0, 0]],
[QEGVAR(airway,isVisualized), false],
[QEGVAR(brain,CMR),100], // Cerebral Metabolic Rate (%)
[QEGVAR(brain,CBF),800], // Cerebral Blood Flow
[QEGVAR(brain,CVR),0.1], // Cerebral Vascular Resistance
[QEGVAR(brain,ICP),15], // Intracranial Pressure
[QEGVAR(brain,CPR),100], // Cerebral Perfusion Rate
[QEGVAR(brain,rO2),80], // Brain O2 saturation

[QEGVAR(brain,necrosis),0],
[QEGVAR(brain,deoxygenatedTicks),0],
[QEGVAR(brain,reversibleDamage),0],
[QEGVAR(brain,mapHighTicks),0],
[QEGVAR(brain,autoregFatigue),0],
[QEGVAR(brain,edema),0],
[QEGVAR(brain,bleeding),0],
[QEGVAR(brain,isSwelling),false],
[QEGVAR(brain,concussion),0],
[QEGVAR(breathing,airwayStatus), 100],
[QEGVAR(breathing,pneumothorax), [0, 0]],
[QEGVAR(breathing,hemopneumothorax), [0, 0]],
[QEGVAR(breathing,tensionpneumothorax), [false, false]],
[QEGVAR(breathing,activeChestSeal), [false, false]],
[QEGVAR(breathing,deepPenetratingInjury), [false, false]],
[QEGVAR(breathing,etco2Monitor), []],
[QEGVAR(breathing,breathRate), 15],
[QEGVAR(breathing,nasalCannula), false],
[QEGVAR(breathing,lungSurfaceArea), 400],
[QEGVAR(breathing,chestTube), [0, 0]],
[QEGVAR(breathing,attachedVent), false],
[QEGVAR(breathing,attachedVentGUI), false],
[QEGVAR(breathing,paralysis), 0],
[QEGVAR(breathing,ventRate), 2],
[QEGVAR(breathing,TACO), 0],
[QEGVAR(circulation,cprCount), 2],
[QEGVAR(circulation,CPR_time), 2],
[QEGVAR(circulation,heartRestart), false],
[QEGVAR(circulation,cardiacArrestType), 0],
[QEGVAR(circulation,bodyFluid), DEFAULT_BODY_FLUID],
[QEGVAR(circulation,isPerformingCPR), false],
[QEGVAR(circulation,OxygenationPeriod), 0],
[QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(circulation,defaultHeartRate), 80],
[QEGVAR(circulation,bloodGas), DEFAULT_BLOOD_GAS],
[QEGVAR(circulation,testedBloodGas), [0,0,0,0,0,0,0]],
[QEGVAR(circulation,ABGmenuShow), false],
[QEGVAR(circulation,ht), []],
[QEGVAR(circulation,effusion), 0],
[QEGVAR(circulation,attachedLucas), false],
[QEGVAR(circulation,externalBloodLoss), 0],
[QEGVAR(circulation,attachedLucasState), false],
[QEGVAR(hypothermia,unitTemperature), 37],
[QEGVAR(hypothermia,warmingImpact), 0],
[QEGVAR(hypothermia,handWarmers), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(hypothermia,fluidWarmer), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(hypothermia,spaceBlanket), false],
[QEGVAR(ophthalmology,dustInjuryLight), 0],
[QEGVAR(ophthalmology,dustInjuryHeavy), 0],
[QEGVAR(ophthalmology,eyeInjuries), [1,1]],
[QEGVAR(ophthalmology,eyeInjurySevere), false],


[QEGVAR(pharma,IVBlockStatus),[0,0,0,0,0,0,0,0,0,0,0,0]],

[QEGVAR(pharma,IVLeakStatus),[0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,ivStress),[0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,ivPain),[0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,ivCondition),[0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,IVrate), [1,1,1,1,1,1,1,1,1,1,1,1]],
[QEGVAR(pharma,IVflow), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,IVincomingFlowAmount), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,IVpfh), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,active), false],
[QEGVAR(pharma,IVPharma_PFH), nil],
[QEGVAR(pharma,pressureBag), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(pharma,pressureIVApplied), false],
[QEGVAR(pharma,IVmenuActive), false],

[QEGVAR(pharma,externalPh), 0],
[QEGVAR(pharma,pH), 0],
[QEGVAR(pharma,opioidFactor), 0],
[QEGVAR(pharma,opioidDepression), 0],

[QEGVAR(pharma,kidneyFail), false],
[QEGVAR(pharma,kidneyArrest), false],
[QEGVAR(pharma,kidneyPressure), false],
[QEGVAR(pharma,kidneyDamage), 0],
[QEGVAR(pharma,liverDamage), 0],
[QEGVAR(pharma,liverFail),false],
[QEGVAR(pharma,hemolysisPFH), -1],
[QEGVAR(pharma,respiratoryRate), 1],
[QEGVAR(pharma,heartContractility), 1],
[QEGVAR(pharma,nauseaMult), 1],
[QEGVAR(pharma,medicationEffectivness), 1],
[QEGVAR(pharma,occludedCAMedications), []],
[QEGVAR(pharma,occludedBlockMedications), []],
[QEGVAR(pharma,serumCalcium), 2.4],
[QEGVAR(pharma,calciumDamage), 0],
[QEGVAR(pharma,externalCa), 0],
[QEGVAR(pharma,calciumVasoMult), 1],
[QEGVAR(pharma,effectiveCa), 2.4],
[QEGVAR(pharma,lastArrhythmia), -1000],
[QEGVAR(pharma,prevCalcium), 0],
[QEGVAR(pharma,kidneyFailTimer), 0],
[QEGVAR(pharma,acidRepo), 1.0],
[QEGVAR(pharma,prevRenalPhysio), [0, 1.2, 2.4, 0]],
[QEGVAR(pharma,prevCalciumPhysio), [0, 1.2, 2.4, 0]],
[QEGVAR(pharma,lactate), 1.2],
[QEGVAR(pharma,microcirculation), 0],
[QEGVAR(pharma,mitoFailure), 0],
[QEGVAR(pharma,lastTimeCoagUpdated), 0],
[QEGVAR(pharma,lastTimeClotUpdated), 0],
[VAR_LOCAL_ANESTHESIA, DEFAULT_LOCAL_ANESTHESIA],
[QEGVAR(triagecard,triageCardCheckboxes), createHashMap],
[QEGVAR(triagecard,triageCardPriority), createHashMap],
[QEGVAR(triagecard,triageCardText), createHashMap],
[QEGVAR(triagecard,triageCardBackCheckboxes), createHashMap],
[QEGVAR(triagecard,triageCardBackText), createHashMap],
[QEGVAR(surgery,fractures), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(surgery,lidocaine), false],
[QEGVAR(surgery,etomidate), false],
[QEGVAR(surgery,sedated), 0],
[QEGVAR(surgery,imaging), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(surgery,reboa), [false, false]],
[QEGVAR(surgery,surgicalBlock), [0,0,0,0,0,0,0,0,0,0,0,0]],
[QEGVAR(vitals,simpleMedical), false],
[QEGVAR(vitals,respiratoryDepth), DEFAULT_RESPIRATORY_DEPTH],
[QEGVAR(vitals,fatigueEnabled), (missionNamespace getVariable [QACEGVAR(advanced_fatigue,enabled), false])],
[QEGVAR(vitals,currentWeight), 80],
[QEGVAR(vitals,mapIntegral), 0],
[QEGVAR(vitals,svMemory), 0.0810542],
[QEGVAR(vitals,csCO2Memory), 40],
[QEGVAR(vitals,breathingState), 0],
[QEGVAR(vitals,biotTimer), 0],
[QEGVAR(vitals,biotState), "breath"],
[QEGVAR(vitals,agonalTimer), 0],
[QEGVAR(vitals,rrMemory), 0],
[QEGVAR(vitals,shockClass), "NONE"],
[QEGVAR(vitals,ataxicRate), 0],
[QEGVAR(vitals,ataxicDepth), 0],
[QEGVAR(vitals,ataxicTimer), 0],
[QEGVAR(vitals,respFatigue), 0],
[QEGVAR(vitals,pao2_prev), 90],
[QEGVAR(vitals,lastTimeUDEUpdated), 0],
[QEGVAR(vitals,catecholamine), 0],
[QEGVAR(vitals,sympatheticTone), 0],
[QEGVAR(vitals,traumaState), 0],
[QEGVAR(vitals,oxygenDebt), 0],
[QEGVAR(vitals,shockState), 0],
[QEGVAR(vitals,skinPerfusion), 1]
];

// Convert medications time to offset
private _medications = _unit getVariable [VAR_MEDICATIONS, []];
{
    _x set [1, _x#1 - CBA_missionTime];
} forEach _medications;
_state setVariable [VAR_MEDICATIONS, _medications];

// Medical statemachine state
private _currentState = [_unit, ACEGVAR(medical,STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
if (_currentState == "Dazed") then { _currentState = "Unconscious"};
_state setVariable [QACEGVAR(medical,statemachineState), _currentState];

// Serialize & return
private _json = [_state] call CBA_fnc_encodeJSON;
_state call CBA_fnc_deleteNamespace;
_json