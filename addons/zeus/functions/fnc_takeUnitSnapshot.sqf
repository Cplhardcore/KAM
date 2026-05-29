#include "..\script_component.hpp"
/*
 * Author: Cplhardcore
 * outputs current unit state to that units RPT for debug tracing
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [LOGIC] call kat_zeus_fnc_toggleAIDeathModule;
 *
 * Public: Yes
 */

params ["_logic"];
if !(local _logic) exitWith {};

private _mouseOver = GETMVAR(bis_fnc_curatorObjectPlaced_mouseOver,[""]);

if ((_mouseOver select 0) != "OBJECT") then {
    [ACELSTRING(zeus,NothingSelected)] call FUNC(showMessage);
} else {
    private _unit = effectiveCommander (_mouseOver select 1);
    if !(_unit isKindOf "CAManBase") then {
        [ACELSTRING(zeus,OnlyInfantry)] call FUNC(showMessage);
    } else {
        diag_log str _unit;
private _pain = _unit getVariable [VAR_PAIN, 0];
private _bloodVol = _unit getVariable [VAR_BLOOD_VOL, DEFAULT_BLOOD_VOLUME];

private _tourniquet = _unit getVariable [VAR_TOURNIQUET, DEFAULT_TOURNIQUET_VALUES];

private _openWounds = _unit getVariable [VAR_OPEN_WOUNDS, []];
private _bandagedWounds = _unit getVariable [VAR_BANDAGED_WOUNDS, []];
private _stitchedWounds = _unit getVariable [VAR_STITCHED_WOUNDS, []];
private _wrappedWounds = _unit getVariable [VAR_WRAPPED_WOUNDS, []];
private _coagWounds = _unit getVariable [VAR_COAGED_WOUNDS, []];
private _isLimping = _unit getVariable [QACEGVAR(medical,isLimping), false];
private _fractures = _unit getVariable [VAR_FRACTURES, DEFAULT_FRACTURE_VALUES];

private _heartRate = _unit getVariable [VAR_HEART_RATE, DEFAULT_HEART_RATE];
private _bloodPress = _unit getVariable [VAR_BLOOD_PRESS, [80, 120]];
private _periphRes = _unit getVariable [VAR_PERIPH_RES, DEFAULT_PERIPH_RES];
private _spo2 = _unit getVariable [VAR_SPO2, DEFAULT_SPO2];
private _oxygenDemand = _unit getVariable [VAR_OXYGEN_DEMAND, 0];

private _ivBags = _unit getVariable [QACEGVAR(medical,ivBags), []];

private _bodypartDamage = _unit getVariable [VAR_BODYPART_DAMAGE, DEFAULT_BODYPART_DAMAGE_VALUES];
private _occludedMedications = _unit getVariable [QACEGVAR(medical,occludedMedications), []];
private _hemorrhage = _unit getVariable [VAR_HEMORRHAGE, 0];
private _inPain = _unit getVariable [VAR_IN_PAIN, false];
private _painSupp = _unit getVariable [VAR_PAIN_SUPP, 0];
private _medications = _unit getVariable [VAR_MEDICATIONS, []];
private _triageCard = _unit getVariable [QACEGVAR(medical,triageCard), []];
private _vasoconstriction = _unit getVariable [VAR_VASOCONSTRICTION, [1,1,1,1,1,1,1,1,1,1,1,1]];


diag_log format [
    "[Wounds] OpenWounds: %1 | BandagedWounds: %2 | StitchedWounds: %3 | WrappedWounds: %4 | CoagWounds: %5",
    _openWounds,
    _bandagedWounds,
    _stitchedWounds,
    _wrappedWounds,
    _coagWounds
];

diag_log format [
    "[Vitals] Pain: %1 | BloodVol: %2 | Tourniquet: %3 | OccludedMedications: %4 | IsLimping: %5 | Fractures: %6 | HeartRate: %7 | BloodPress: %8 | PeriphRes: %9 | SpO2: %10 | OxygenDemand: %11 | IVBags: %12 | BodypartDamage: %13 | Hemorrhage: %14 | InPain: %15 | PainSupp: %16 | Medications: %17 | TriageCard: %18 | Vasoconstriction: %19",
    _pain,
    _bloodVol,
    _tourniquet,
    _occludedMedications,
    _isLimping,
    _fractures,
    _heartRate,
    _bloodPress,
    _periphRes,
    _spo2,
    _oxygenDemand,
    _ivBags,
    _bodypartDamage,
    _hemorrhage,
    _inPain,
    _painSupp,
    _medications,
    _triageCard,
    _vasoconstriction
];


private _airwayItem = _unit getVariable [QEGVAR(airway,airway_item), ""];
private _airway = _unit getVariable [QEGVAR(airway,airway), false];
private _clearedTime = _unit getVariable [QEGVAR(airway,clearedTime), 0];
private _cricothyrotomy = _unit getVariable [QEGVAR(airway,cricothyrotomy), 0];
private _catastrophicAirway = _unit getVariable [QEGVAR(airway,catastrophicAirway), [false, false]];
private _obstruction = _unit getVariable [QEGVAR(airway,obstruction), [0, 0, 0]];
private _occlusion = _unit getVariable [QEGVAR(airway,occlusion), [0, 0, 0]];
private _occlusionMitigation = _unit getVariable [QEGVAR(airway,occlusionMitigation), [false, false, false]];
private _overstretch = _unit getVariable [QEGVAR(airway,overstretch), false];
private _recovery = _unit getVariable [QEGVAR(airway,recovery), false];
private _wasOccluded = _unit getVariable [QEGVAR(airway,wasOccluded), [0, 0, 0]];
private _hasPuked = _unit getVariable [QEGVAR(airway,hasPuked), false];
private _airwayStatus = _unit getVariable [QEGVAR(airway,airwayStatus), [0, 0, 0]];
private _isVisualized = _unit getVariable [QEGVAR(airway,isVisualized), false];
diag_log format [
    "[Airways] AirwayItem: %1 | Airway: %2 | ClearedTime: %3 | Cricothyrotomy: %4 | CatastrophicAirway: %5 | Obstruction: %6 | Occlusion: %7 | OcclusionMitigation: %8 | Overstretch: %9 | Recovery: %10 | WasOccluded: %11 | HasPuked: %12 | AirwayStatus: %13 | IsVisualized: %14",
    _airwayItem,
    _airway,
    _clearedTime,
    _cricothyrotomy,
    _catastrophicAirway,
    _obstruction,
    _occlusion,
    _occlusionMitigation,
    _overstretch,
    _recovery,
    _wasOccluded,
    _hasPuked,
    _airwayStatus,
    _isVisualized
];
private _airwayStatus = _unit getVariable [QEGVAR(breathing,airwayStatus), 100];
private _pneumothorax = _unit getVariable [QEGVAR(breathing,pneumothorax), [0, 0]];
private _pneumothoraxSurfaceArea = _unit getVariable [QEGVAR(breathing,pneumothoraxSurfaceArea), [0, 0]];
private _hemopneumothorax = _unit getVariable [QEGVAR(breathing,hemopneumothorax), [0, 0]];
private _tensionpneumothorax = _unit getVariable [QEGVAR(breathing,tensionpneumothorax), [false, false]];
private _activeChestSeal = _unit getVariable [QEGVAR(breathing,activeChestSeal), [false, false]];
private _deepPenetratingInjury = _unit getVariable [QEGVAR(breathing,deepPenetratingInjury), [false, false]];
private _etco2Monitor = _unit getVariable [QEGVAR(breathing,etco2Monitor), []];
private _breathRate = _unit getVariable [QEGVAR(breathing,breathRate), 15];
private _nasalCannula = _unit getVariable [QEGVAR(breathing,nasalCannula), false];
private _lungSurfaceArea = _unit getVariable [QEGVAR(breathing,lungSurfaceArea), 400];
private _chestTube = _unit getVariable [QEGVAR(breathing,chestTube), [0, 0]];
private _attachedVent = _unit getVariable [QEGVAR(breathing,attachedVent), false];
private _attachedVentGUI = _unit getVariable [QEGVAR(breathing,attachedVentGUI), false];
private _paralysis = _unit getVariable [QEGVAR(breathing,paralysis), 0];
private _ventRate = _unit getVariable [QEGVAR(breathing,ventRate), 2];
private _trali = _unit getVariable [QEGVAR(breathing,TACO), 0];

diag_log format [
    "[Respiratory] AirwayStatus: %1 | Pneumothorax: %2 | PneumothoraxSurfaceArea: %3 | Hemopneumothorax: %4 | TensionPneumothorax: %5 | ActiveChestSeal: %6 | DeepPenetratingInjury: %7 | ETCO2Monitor: %8 | BreathRate: %9 | NasalCannula: %10 | LungSurfaceArea: %11 | ChestTube: %12 | AttachedVent: %13 | AttachedVentGUI: %14 | Paralysis: %15 | VentRate: %16 | TRALI: %17",
    _airwayStatus,
    _pneumothorax,
    _pneumothoraxSurfaceArea,
    _hemopneumothorax,
    _tensionpneumothorax,
    _activeChestSeal,
    _deepPenetratingInjury,
    _etco2Monitor,
    _breathRate,
    _nasalCannula,
    _lungSurfaceArea,
    _chestTube,
    _attachedVent,
    _attachedVentGUI,
    _paralysis,
    _ventRate,
    _trali
];
private _cprCount = _unit getVariable [QEGVAR(circulation,cprCount), 2];
private _heartRestart = _unit getVariable [QEGVAR(circulation,heartRestart), false];
private _cardiacArrestType = _unit getVariable [QEGVAR(circulation,cardiacArrestType), 0];

private _bloodPressureChange = _unit getVariable [VAR_BLOODPRESSURE_CHANGE, 0];

private _bodyFluid = _unit getVariable [QEGVAR(circulation,bodyFluid), DEFAULT_BODY_FLUID];

private _isPerformingCPR = _unit getVariable [QEGVAR(circulation,isPerformingCPR), false];
private _oxygenationPeriod = _unit getVariable [QEGVAR(circulation,OxygenationPeriod), 0];

private _tourniquetTime = _unit getVariable [QEGVAR(circulation,tourniquetTime), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _defaultHeartRate = _unit getVariable [QEGVAR(circulation,defaultHeartRate), 80];

private _bloodGas = _unit getVariable [QEGVAR(circulation,bloodGas), DEFAULT_BLOOD_GAS];
private _testedBloodGas = _unit getVariable [QEGVAR(circulation,testedBloodGas), [0,0,0,0,0,0,0]];

private _ABGmenuShow = _unit getVariable [QEGVAR(circulation,ABGmenuShow), false];

private _ht = _unit getVariable [QEGVAR(circulation,ht), []];
private _effusion = _unit getVariable [QEGVAR(circulation,effusion), 0];

private _attachedLucas = _unit getVariable [QEGVAR(circulation,attachedLucas), false];
private _attachedLucasState = _unit getVariable [QEGVAR(circulation,attachedLucasState), false];

diag_log format [
    "[Cardiac] CPRCount: %1 | HeartRestart: %2 | CardiacArrestType: %3 | BloodPressureChange: %4 | BodyFluid: %5 | IsPerformingCPR: %6 | OxygenationPeriod: %7 | TourniquetTime: %8 | DefaultHeartRate: %9 | BloodGas: %10 | TestedBloodGas: %11 | ABGmenuShow: %12 | HT: %13 | Effusion: %14 | AttachedLucas: %15 | AttachedLucasState: %16",
    _cprCount,
    _heartRestart,
    _cardiacArrestType,
    _bloodPressureChange,
    _bodyFluid,
    _isPerformingCPR,
    _oxygenationPeriod,
    _tourniquetTime,
    _defaultHeartRate,
    _bloodGas,
    _testedBloodGas,
    _ABGmenuShow,
    _ht,
    _effusion,
    _attachedLucas,
    _attachedLucasState
];
private _dustInjuryLight = _unit getVariable [QEGVAR(ophthalmology,dustInjuryLight), 0];
private _dustInjuryHeavy = _unit getVariable [QEGVAR(ophthalmology,dustInjuryHeavy), 0];
private _eyeInjuries = _unit getVariable [QEGVAR(ophthalmology,eyeInjuries), [1,1]];
private _eyeInjurySevere = _unit getVariable [QEGVAR(ophthalmology,eyeInjurySevere), false];

diag_log format [
    "[Ophthalmology] DustInjuryLight: %1 | DustInjuryHeavy: %2 | EyeInjuries: %3 | EyeInjurySevere: %4",
    _dustInjuryLight,
    _dustInjuryHeavy,
    _eyeInjuries,
    _eyeInjurySevere
];

private _alphaAction = _unit getVariable [QEGVAR(pharma,alphaAction), [1,1,1,1,1,1,1,1,1,1,1,1]];

private _IV = _unit getVariable [QEGVAR(pharma,IV), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVflow = _unit getVariable [QEGVAR(pharma,IVflow), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVrate = _unit getVariable [QEGVAR(pharma,IVrate), [0,0,0,0,0,0,0,0,0,0,0,0]];

private _IVincomingFlowAmount = _unit getVariable [QEGVAR(pharma,IVincomingFlowAmount), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _IVpfh = _unit getVariable [QEGVAR(pharma,IVpfh), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _active = _unit getVariable [QEGVAR(pharma,active), false];
private _IVPharma_PFH = _unit getVariable [QEGVAR(pharma,IVPharma_PFH), 0];

private _IVmenuActive = _unit getVariable [QEGVAR(pharma,IVmenuActive), false];

private _externalPh = _unit getVariable [QEGVAR(pharma,externalPh), 0];
private _pH = _unit getVariable [QEGVAR(pharma,pH), 0];

private _opioidFactor = _unit getVariable [QEGVAR(pharma,opioidFactor), 0];
private _opioidDepression = _unit getVariable [QEGVAR(pharma,opioidDepression), 0];

private _kidneyFail = _unit getVariable [QEGVAR(pharma,kidneyFail), false];
private _kidneyArrest = _unit getVariable [QEGVAR(pharma,kidneyArrest), false];
private _kidneyPressure = _unit getVariable [QEGVAR(pharma,kidneyPressure), false];

private _respiratoryRate = _unit getVariable [QEGVAR(pharma,respiratoryRate), 1];
private _heartContractility = _unit getVariable [QEGVAR(pharma,heartContractility), 1];
private _nauseaMult = _unit getVariable [QEGVAR(pharma,nauseaMult), 1];

private _localAnesthesia = _unit getVariable [VAR_LOCAL_ANESTHESIA, DEFAULT_LOCAL_ANESTHESIA];
private _activeEtomidateLoadingDose = _unit getVariable [QEGVAR(pharma,activeEtomidateLoadingDose), false];
diag_log format [
    "[IV/Pharma] AlphaAction: %1 | IV: %2 | IVflow: %3 | IVrate: %4 | IVincomingFlowAmount: %5 | IVpfh: %6 | Active: %7 | IVPharma_PFH: %8 | IVmenuActive: %9 | ExternalPh: %10 | pH: %11 | OpioidFactor: %12 | OpioidDepression: %13 | KidneyFail: %14 | KidneyArrest: %15 | KidneyPressure: %16 | RespiratoryRate: %17 | HeartContractility: %18 | NauseaMult: %19 | LocalAnesthesia: %20 | ActiveEtomidateLoadingDose: %21",
    _alphaAction,
    _IV,
    _IVflow,
    _IVrate,
    _IVincomingFlowAmount,
    _IVpfh,
    _active,
    _IVPharma_PFH,
    _IVmenuActive,
    _externalPh,
    _pH,
    _opioidFactor,
    _opioidDepression,
    _kidneyFail,
    _kidneyArrest,
    _kidneyPressure,
    _respiratoryRate,
    _heartContractility,
    _nauseaMult,
    _localAnesthesia,
    _activeEtomidateLoadingDose
];
private _fractures = _unit getVariable [QEGVAR(surgery,fractures), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _lidocaine = _unit getVariable [QEGVAR(surgery,lidocaine), false];
private _etomidate = _unit getVariable [QEGVAR(surgery,etomidate), false];
private _sedated = _unit getVariable [QEGVAR(surgery,sedated), 0];
private _imaging = _unit getVariable [QEGVAR(surgery,imaging), [0,0,0,0,0,0,0,0,0,0,0,0]];
private _reboa = _unit getVariable [QEGVAR(surgery,reboa), false];
private _surgicalBlock = _unit getVariable [QEGVAR(surgery,surgicalBlock), [0,0,0,0,0,0,0,0,0,0,0,0]];

diag_log format [
    "[Ortho/Anesthesia] Fractures: %1 | Lidocaine: %2 | Etomidate: %3 | Sedated: %4 | Imaging: %5 | REBOA: %6 | SurgicalBlock: %7",
    _fractures,
    _lidocaine,
    _etomidate,
    _sedated,
    _imaging,
    _reboa,
    _surgicalBlock
];
private _traumaState      = _unit getVariable [QGVAR(traumaState), 0];
private _skinPerfusion    = _unit getVariable [QGVAR(skinPerfusion), 0];
private _shockState       = _unit getVariable [QGVAR(shockState), 0];
private _oxygenDebt       = _unit getVariable [QGVAR(oxygenDebt), 0];
private _sympatheticTone  = _unit getVariable [QGVAR(sympatheticTone), 0];

diag_log format [
    "[SHOCK] Trauma: %1 | SkinPerfusion: %2 | ShockState: %3 | OxygenDebt: %4 | SympatheticTone: %5",
    _traumaState,
    _skinPerfusion,
    _shockState,
    _oxygenDebt,
    _sympatheticTone
];

private _externalPh       = _unit getVariable [QGVAR(externalPh), 0];
private _lactate          = _unit getVariable [QGVAR(lactate), 1.2];
private _microcirculation = _unit getVariable [QGVAR(microcirculation), 0];
private _mitoFailure      = _unit getVariable [QGVAR(mitoFailure), 0];
private _acidRepo         = _unit getVariable [QGVAR(acidRepo), 1.0];

private _kidneyDamage     = _unit getVariable [QGVAR(kidneyDamage), 0];
private _kidneyFail       = _unit getVariable [QGVAR(kidneyFail), false];
private _kidneyArrest     = _unit getVariable [QGVAR(kidneyArrest), false];
private _kidneyFailTimer  = _unit getVariable [QGVAR(kidneyFailTimer), 0];

private _prevRenal        = _unit getVariable [QGVAR(prevRenalPhysio), [0,1.2,2.4,0]];

diag_log format [
    "[RENAL] ExternalPh: %1 | Lactate: %2 | Micro: %3 | Mito: %4 | AcidRepo: %5 | KidneyDamage: %6 | KidneyFail: %7 | KidneyArrest: %8 | KidneyFailTimer: %9 | PrevRenal: %10",
    _externalPh,
    _lactate,
    _microcirculation,
    _mitoFailure,
    _acidRepo,
    _kidneyDamage,
    _kidneyFail,
    _kidneyArrest,
    _kidneyFailTimer,
    _prevRenal
];

private _serumCalcium     = _unit getVariable [QGVAR(serumCalcium), 0];
private _effectiveCa      = _unit getVariable [QGVAR(effectiveCa), 2.4];
private _externalCa       = _unit getVariable [QGVAR(externalCa), 0];

private _calciumDamage    = _unit getVariable [QGVAR(calciumDamage), 0];
private _liverDamage      = _unit getVariable [QGVAR(liverDamage), 0];
private _liverFail        = _unit getVariable [QGVAR(liverFail), false];

private _lastArrhythmia   = _unit getVariable [QGVAR(lastArrhythmia), -1000];
private _prevCalcium      = _unit getVariable [QGVAR(prevCalciumPhysio), [0,1.2,2.4,0]];

diag_log format [
    "[CALCIUM] SerumCa: %1 | EffectiveCa: %2 | ExternalCa: %3 | CalciumDamage: %4 | LiverDamage: %5 | LiverFail: %6 | LastArrhythmia: %7 | PrevCalcium: %8",
    _serumCalcium,
    _effectiveCa,
    _externalCa,
    _calciumDamage,
    _liverDamage,
    _liverFail,
    _lastArrhythmia,
    _prevCalcium
];

private _simpleMedical     = _unit getVariable [QGVAR(simpleMedical), false];
private _respiratoryDepth  = _unit getVariable [QGVAR(respiratoryDepth), DEFAULT_RESPIRATORY_DEPTH];
private _fatigueEnabled    = _unit getVariable [QGVAR(fatigueEnabled), false];
private _currentWeight     = _unit getVariable [QGVAR(currentWeight), 0];

private _mapIntegral       = _unit getVariable [QGVAR(mapIntegral), 0];
private _svMemory          = _unit getVariable [QGVAR(svMemory), 0.0810542];
private _csCO2Memory       = _unit getVariable [QGVAR(csCO2Memory), 40];

private _breathingState    = _unit getVariable [QGVAR(breathingState), 0];
private _biotTimer         = _unit getVariable [QGVAR(biotTimer), 0];
private _biotState         = _unit getVariable [QGVAR(biotState), "breath"];

private _agonalTimer       = _unit getVariable [QGVAR(agonalTimer), 0];
private _rrMemory          = _unit getVariable [QGVAR(rrMemory), 0];

diag_log format [
    "[RESP/CORE] SimpleMedical: %1 | RespDepth: %2 | Fatigue: %3 | Weight: %4 | MAPIntegral: %5 | SV: %6 | CO2Memory: %7 | BreathingState: %8 | BiotTimer: %9 | BiotState: %10 | AgonalTimer: %11 | RRMemory: %12",
    _simpleMedical,
    _respiratoryDepth,
    _fatigueEnabled,
    _currentWeight,
    _mapIntegral,
    _svMemory,
    _csCO2Memory,
    _breathingState,
    _biotTimer,
    _biotState,
    _agonalTimer,
    _rrMemory
];

private _shockClass        = _unit getVariable [QGVAR(shockClass), "NONE"];
private _sympatheticTone   = _unit getVariable [QGVAR(sympatheticTone), 0];
private _catecholamine     = _unit getVariable [QGVAR(catecholamine), 0];

private _traumaState       = _unit getVariable [QGVAR(traumaState), 0];
private _oxygenDebt        = _unit getVariable [QGVAR(oxygenDebt), 0];
private _shockState        = _unit getVariable [QGVAR(shockState), 0];
private _skinPerfusion     = _unit getVariable [QGVAR(skinPerfusion), 1];

diag_log format [
    "[SHOCK/AUTO] ShockClass: %1 | SympatheticTone: %2 | Catecholamine: %3 | Trauma: %4 | OxygenDebt: %5 | ShockState: %6 | SkinPerfusion: %7",
    _shockClass,
    _sympatheticTone,
    _catecholamine,
    _traumaState,
    _oxygenDebt,
    _shockState,
    _skinPerfusion
];

private _ataxicRate    = _unit getVariable [QGVAR(ataxicRate), 0];
private _ataxicDepth   = _unit getVariable [QGVAR(ataxicDepth), 0];
private _ataxicTimer   = _unit getVariable [QGVAR(ataxicTimer), 0];

private _respFatigue   = _unit getVariable [QGVAR(respFatigue), 0];
private _pao2_prev     = _unit getVariable [QGVAR(pao2_prev), 90];

private _lastUDE       = _unit getVariable [QGVAR(lastTimeUDEUpdated), 0];

diag_log format [
    "[RESP DYSFUNC] AtaxicRate: %1 | AtaxicDepth: %2 | AtaxicTimer: %3 | RespFatigue: %4 | PaO2_prev: %5 | LastUDE: %6",
    _ataxicRate,
    _ataxicDepth,
    _ataxicTimer,
    _respFatigue,
    _pao2_prev,
    _lastUDE
];

private _CMR  = _unit getVariable [QGVAR(CMR), 100];
private _CBF  = _unit getVariable [QGVAR(CBF), 800];
private _CVR  = _unit getVariable [QGVAR(CVR), 0.1];
private _ICP  = _unit getVariable [QGVAR(ICP), 15];
private _CPR  = _unit getVariable [QGVAR(CPR), 100];
private _rO2  = _unit getVariable [QGVAR(rO2), 80];

diag_log format [
    "[CNS] CMR: %1 | CBF: %2 | CVR: %3 | ICP: %4 | CPR: %5 | rO2: %6",
    _CMR,
    _CBF,
    _CVR,
    _ICP,
    _CPR,
    _rO2
];

private _necrosis           = _unit getVariable [QGVAR(necrosis), 0];
private _deoxygenatedTicks  = _unit getVariable [QGVAR(deoxygenatedTicks), 0];
private _reversibleDamage   = _unit getVariable [QGVAR(reversibleDamage), 0];

private _mapHighTicks       = _unit getVariable [QGVAR(mapHighTicks), 0];
private _autoregFatigue     = _unit getVariable [QGVAR(autoregFatigue), 0];

private _edema              = _unit getVariable [QGVAR(edema), 0];
private _bleeding           = _unit getVariable [QGVAR(bleeding), 0];
private _isSwelling         = _unit getVariable [QGVAR(isSwelling), false];

diag_log format [
    "[CNS DAMAGE] Necrosis: %1 | DeoxyTicks: %2 | Reversible: %3 | MAPHighTicks: %4 | AutoregFatigue: %5 | Edema: %6 | Bleeding: %7 | Swelling: %8",
    _necrosis,
    _deoxygenatedTicks,
    _reversibleDamage,
    _mapHighTicks,
    _autoregFatigue,
    _edema,
    _bleeding,
    _isSwelling
];


private _respiratorydepth = _unit getVariable [QEGVAR(vitals,respiratoryDepth), DEFAULT_RESPIRATORY_DEPTH];
private _currentWeight = _unit getVariable [QEGVAR(vitals,currentWeight), 80];
diag_log format [
    "[Vitals] Respiratory Depth: %1 Current Weight: %2",
    _respiratorydepth,
    _currentWeight
];
private _currentVersion = QUOTE(VERSION_STR);
diag_log format [
    "[Version] Current Version: %1",
    _currentVersion
];

deleteVehicle _logic;
    };
};
deleteVehicle _logic;
