class CfgVehicles {
    #include "vehicle_stretcher.hpp"
    class Land_IntravenStand_01_base_F;

    class Land_IntravenStand_01_empty_F: Land_IntravenStand_01_base_F {
        ace_cargo_size = 2;
        ace_cargo_canLoad = 1;

        // Dragging
        ace_dragging_canDrag = 1;
        ace_dragging_dragPosition[] = {0, 1.2, 1};
        ace_dragging_dragDirection = 0;

        // Carrying
        ace_dragging_canCarry = 1;
        ace_dragging_carryPosition[] = {0, 1.2, 1};
        ace_dragging_carryDirection = 0;
    };
    class Land_IntravenStand_01_1bag_F: Land_IntravenStand_01_base_F {
        ace_cargo_size = 2;
        ace_cargo_canLoad = 1;

        // Dragging
        ace_dragging_canDrag = 1;
        ace_dragging_dragPosition[] = {0, 1.2, 1};
        ace_dragging_dragDirection = 0;

        // Carrying
        ace_dragging_canCarry = 1;
        ace_dragging_carryPosition[] = {0, 1.2, 1};
        ace_dragging_carryDirection = 0;
    };
    class Land_IntravenStand_01_2bags_F: Land_IntravenStand_01_base_F {
        ace_cargo_size = 2;
        ace_cargo_canLoad = 1;

        // Dragging
        ace_dragging_canDrag = 1;
        ace_dragging_dragPosition[] = {0, 1.2, 1};
        ace_dragging_dragDirection = 0;

        // Carrying
        ace_dragging_canCarry = 1;
        ace_dragging_carryPosition[] = {0, 1.2, 1};
        ace_dragging_carryDirection = 0;
    };

    class weapon_bag_base;
    class kat_stretcherBag: weapon_bag_base {
        class assembleInfo {
            displayName = CSTRING(Stretcher_Display);
            assembleTo = "kat_stretcher";
            base = "";
            primary = 1;
            dissasembleTo[] = {};
        };
        author = "Katalam";
        scope = 2;
        editorCategory = "EdCat_Equipment";
        editorSubcategory = "EdSubcat_DismantledWeapons";
        displayName = CSTRING(StretcherPacked_Display);
        mass = 60;
    };

    class Tank_F;
    class kat_stretcher: Tank_F {
        explosionEffect = "";
        fuelExplosionPower = 0;
        editorForceEmpty = 1;
        editorSubcategory = "edSubcat_Storage";
        crew = "C_man_1";
        icon = "iconObject_1x1";
        hasDriver = 0;
        scope = 2;
        side = 3;
        faction = "CIV_F";
        accuracy = 0.001;
        camouflage = 10;
        armor = 20;
        displayName = CSTRING(Stretcher_Display);
        model = QPATHTOF(models\stretcher\vurtual_stretcher.p3d);
        simulation = "tankX";
        crewVulnerable = 1;
        explosionShielding = 0;
        irTarget = 0;
        allowTabLock = 0;
        memoryPointsGetInCargo = "pos cargo";
        memoryPointsGetInCargoDir = "pos cargo dir";
        cargoAction[] = {"kat_stretcher"};
        tf_isolatedAmount = 0;
        numberPhysicalWheels = 0;
        hideProxyInCombat = 0;
        hideWeaponsCargo = "true";
        ejectDeadCargo = 0;
        class Damage {
            tex[] = {};
            mat[] = {
                QPATHTOF(models\stretcher\seat.rvmat),
                QPATHTOF(models\stretcher\seat_destruct.rvmat)
            };
        };
        class animationSources {
            class seat_hide {
                source = "user";
                initPhase = 0;
                animPeriod = 0.1;
                displayName = "Hide Stretcher";
                forceAnimatePhase = 1;
                forceAnimate[] = {"legs_hide", 1};
            };
        };
        maximumLoad = 0;
        transportMaxBackpacks = 0;
        transportMaxMagazines = 64;
        class TransportItems;
        class Turrets {};
        transportSoldier = 1;
        ace_cargo_canLoad = 0;
        ace_Cargo_hasCargo = 0;
        ace_dragging_canDrag = 1;
        ace_dragging_canCarry = 1;
        ace_dragging_dragPosition[] = {0,1.7,0};
        ace_dragging_carryPosition[] = {0, 1.7, 0};
        ace_dragging_dragDirection = 0;
        ace_Carry_carryDirection = 0;
        ace_cookoff_probability = 0;
        slingLoadCargoMemoryPoints[] = {"SlingLoadCargo1", "SlingLoadCargo2", "SlingLoadCargo3", "SlingLoadCargo4"};
        destrType = "destructDefault";
        fuelCapacity = 0;

        //pretend static weapon since some mods don't like unconscious people in static weapons
        nameSound = "veh_static_s";
        vehicleClass = "static";
        unitInfoType = "RscUnitInfoStatic";
        crewExplosionProtection = 0;
        class DestructionEffects {};
        class VehicleTransport {
            class Cargo {
                parachuteClass              = "B_Parachute_02_F";
                parachuteHeightLimit        = 5;
                canBeTransported            = 1;
                dimensions[]                = {"VTV_Cargo_Base", "VTV_Cargo_Corner"};
            };
        };
        class EventHandlers {
            init = QUOTE(_this call FUNC(stretcher));
        };
    };
    class Land_Stretcher_01_base_F;
    class Land_Stretcher_01_olive_F: Land_Stretcher_01_base_F {
        ace_cargo_canLoad = 1;
        ace_Cargo_hasCargo = 0;
        ace_dragging_canDrag = 1;
        ace_dragging_canCarry = 1;
        ace_dragging_dragPosition[] = {0,1.7,0};
        ace_dragging_carryPosition[] = {0, 1.7, 0};
        ace_dragging_dragDirection = 0;
        ace_Carry_carryDirection = 0;
        ace_cookoff_probability = 0;
        class VehicleTransport {
            class Cargo {
                parachuteClass              = "B_Parachute_02_F";
                parachuteHeightLimit        = 5;
                canBeTransported            = 1;
                dimensions[]                = {"VTV_Cargo_Base", "VTV_Cargo_Corner"};
            };
        };
    };
    class NATO_Box_Base;
	class Medic_Bag_Crate: NATO_Box_Base {
		scope = 2;
        scopeCurator = 2;
        scopeArsenal = 2;
		author = "Digii, Miss Heda";
		vehicleClass = "Ammo";
		displayName = CSTRING(Medic_Bag_Display);
		model = QPATHTOF(models\medicBag\medicbag.p3d);
		editorPreview = QPATHTOF(ui\MedicBagEditorPreview.paa);
		icon = "iconCrateWpns";
        maximumLoad = 480;
        // maximumLoad = GVAR(medicBagSize);
        class ACE_Actions {
            class ACE_MainActions {
                displayName = ACECSTRING(interaction,MainAction);
                selection = "";
                distance = 2;
                condition = "true";

                class ACE_OpenBox {
                    displayName = ACECSTRING(interaction,OpenBox);
                    condition = QUOTE(alive _target && {!lockedInventory _target} && {getNumber (configOf _target >> 'disableInventory') == 0});
                    statement = QUOTE(_player action [ARR_2(QUOTE(QUOTE(Gear)), _target)]);
                    showDisabled = 0;
                };

                class GVAR(SLINGOPTIONS) {
                    displayName = CSTRING(Medic_Bag_Sling_on);
                    condition = QUOTE((!(_player getVariable[ARR_2(QQGVAR(hasMedicBagSlinged), false)])) && !(_target getVariable [ARR_2(QQGVAR(FieldAidStationIsBuild), false)]));
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = "";
                    showDisabled = 0;
                    icon = QPATHTOF(ui\MedicBagSling.paa);

                    class GVAR(SlingMedicBagFront) {
                        displayName = CSTRING(Medic_Bag_Sling_on_front);
                        condition = QUOTE(_target getVariable [ARR_2(QQGVAR(isMedBagDown), false)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, _target, 0)] call FUNC(medicBagSling));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa);
                    }; 

                    class GVAR(SlingMedicBagBack) {
                        displayName = CSTRING(Medic_Bag_Sling_on_back);
                        condition = QUOTE(_target getVariable [ARR_2(QQGVAR(isMedBagDown), false)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, _target, 1)] call FUNC(medicBagSling));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa);
                    }; 
                };

                class GVAR(TransferMedicItems) {
                    displayName = CSTRING(TransferMedicBagItems);
                    condition = QUOTE(!(_player getVariable [ARR_2(QQGVAR(hasMedicBagSlinged), false)]));
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = QUOTE([ARR_2(_player, _target)] call FUNC(putItemsInMedicBag));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\MedicBagTransferItems.paa);
                };    
            
                class GVAR(BuildFieldAidStation) {
                    displayName = CSTRING(BuildFieldAidStation);
                    condition = QUOTE(_target getVariable [ARR_2(QQGVAR(isMedBagDown), false)] && !(_target getVariable [ARR_2(QQGVAR(FieldAidStationIsBuild), false)]));
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = QUOTE([ARR_2(_player, _target)] call FUNC(buildFieldAidStation));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\FieldAidStation.paa);
                }; 

                class GVAR(RemoveFieldAidStation) {
                    displayName = CSTRING(RemoveFiledAidStation);
                    condition = QUOTE(_target getVariable [ARR_2(QQGVAR(FieldAidStationIsBuild), false)]);
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = QUOTE([ARR_2(_player, _target)] call FUNC(removeFieldAidStation));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\PackFieldAidStation.paa);
                }; 

                class ACE_AttachVehicle { 
                    displayName = ACECSTRING(attach,AttachDetach); 
                    condition = QUOTE(_this call ACEFUNC(attach,canAttach)); 
                    insertChildren = QUOTE(_this call ACEFUNC(attach,getChildrenActions)); 
                    exceptions[] = {"isNotSwimming"}; 
                    showDisabled = 0; 
                    icon = "z\ace\addons\attach\UI\attach_ca.paa";
                }; 
                
                class ACE_DetachVehicle { 
                    displayName = ACECSTRING(attach,Detach); 
                    condition = QUOTE(_this call ACEFUNC(attach,canDetach)); 
                    statement = QUOTE(_this call ACEFUNC(attach,detach) ); 
                    exceptions[] = {"isNotSwimming"}; 
                    showDisabled = 0; 
                    icon = "z\ace\addons\attach\UI\detach_ca.paa"; 
                }; 

                class GVAR(PickUpMedicBag) {
                    displayName = CSTRING(Medic_Bag_Pick_up);
                    condition = QUOTE((_target getVariable [ARR_2(QQGVAR(isMedBagDown), false)]) && !(_target getVariable [ARR_2(QQGVAR(FieldAidStationIsBuild), false)]));
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = QUOTE([ARR_3(_player, _target, 'Medic_Bag')] call FUNC(medicBagPickUp));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\MedicBagPickUp.paa);
                }; 

                class GVAR(UnslingManuel) {
                    displayName = CSTRING(Medic_Bag_Sling_off);
                    condition = QUOTE((_target getVariable [ARR_2(QQGVAR(hasMedicBagSlinged), true)]) && !(_target getVariable [ARR_2(QQGVAR(isMedBagDown), true)]));
                    exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                    statement = QUOTE([ARR_3(_player, _target, 'Medic_Bag')] call FUNC(medicBagPutDown));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\MedicBagSling.paa);
                }; 

            };
        };

        ACEGVAR(dragging,dragPosition)[] = {0, 1, 0};
        ACEGVAR(dragging,dragDirection) = 0;

        ACEGVAR(dragging,carryPosition)[] = {0, 1, 0};
        ACEGVAR(dragging,carryDirection) = 0;

        ACEGVAR(cargo,noRename) = 1;
	};
    class Items_base_F;
	class Medic_Bag_Sling: Items_base_F {
		scope = 2;
        scopeCurator = 2;
        scopeArsenal = 2;
		author = "Digii, Miss Heda";
		model = QPATHTOF(models\medicBag\medicbagsling.p3d);
		icon = "iconCrateWpns";
	};
    class Items_base_F;
	class Kat_armband: Items_base_F {
		scope = 2;
        scopeCurator = 2;
        scopeArsenal = 2;
		author = "Miss Heda, vccv9040 (Swedish Forces Pack)";
        editorPreview = QPATHTOF(ui\ArmbandWhiteCross.paa);
        model = QPATHTOF(models\armband\Armband.p3d);
	};
    class Man;
    class CAManBase: Man {
        class ACE_SelfActions
		{
			class ACE_Equipment
			{
				class MedicBagPlaceDown
				{
					displayName = CSTRING(Medic_Bag_Place_Down);
					condition = QUOTE([ARR_2(_player, ""Medic_Bag"")] call ACEFUNC(common,hasItem));
					statement = QUOTE([ARR_3(_player, ""Medic_Bag"", ""Medic_Bag_Crate"")] call FUNC(medicBagSpawn));
					icon = QPATHTOF(ui\MedicBagIcon.paa);
					showDisabled = 0;
					priority = 2.500000;
				};

                class SlingArmband {
					displayName = "Sling Armband";   //TODO
					condition = QUOTE([ARR_2(_player, ""Kat_armband_facewear"")] call ACEFUNC(common,hasItem));
					statement = "";
					icon = QPATHTOF(ui\MedicBagIcon.paa); //TODO
					showDisabled = 1;

                    class LeftArm {
                        displayName = "Left Arm";
                        condition = QUOTE(_player getVariable [ARR_2(QQGVAR(isLeftArmFree), true)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, ""Kat_armband_facewear"", 0)] call FUNC(slingArmband));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa); //TODO
                    }; 

                    class RightArm {
                        displayName = "Right Arm";
                        condition = QUOTE(_player getVariable [ARR_2(QQGVAR(isRightArmFree), true)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, ""Kat_armband_facewear"", 1)] call FUNC(slingArmband));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa); //TODO
                    }; 

                    class LeftLeg {
                        displayName = "Left Leg";
                        condition = QUOTE(_player getVariable [ARR_2(QQGVAR(isLeftLegFree), true)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, ""Kat_armband_facewear"", 2)] call FUNC(slingArmband));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa); //TODO
                    }; 

                    class RightLeg {
                        displayName = "Right Leg";
                        condition = QUOTE(_player getVariable [ARR_2(QQGVAR(isRightLegFree), true)]);
                        exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                        statement = QUOTE([ARR_3(_player, ""Kat_armband_facewear"", 3)] call FUNC(slingArmband));
                        showDisabled = 0;
                        icon = QPATHTOF(ui\MedicBagSling.paa); //TODO
                    }; 
                };
            };
		};
        class ACE_Actions {
            class ACE_ArmLeft {
                class SalineIV;
                class SalineIV_Stand: SalineIV {
                    displayName = CSTRING(Display_IVStand);
                    condition = "[_player, _target, 'hand_l', 'SalineIV_Stand'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_l', 'SalineIV_Stand'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_500: SalineIV {
                    displayName = CSTRING(Display_IVStand_500);
                    condition = "[_player, _target, 'hand_l', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_l', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_250: SalineIV {
                    displayName = CSTRING(Display_IVStand_250);
                    condition = "[_player, _target, 'hand_l', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_l', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_treatment";
                };
            };
            class ACE_ArmRight {
                class SalineIV;
                class SalineIV_Stand: SalineIV {
                    displayName = CSTRING(Display_IVStand);
                    condition = "[_player, _target, 'hand_r', 'SalineIV_Stand'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_r', 'SalineIV_Stand'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_500: SalineIV {
                    displayName = CSTRING(Display_IVStand_500);
                    condition = "[_player, _target, 'hand_r', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_r', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_250: SalineIV {
                    displayName = CSTRING(Display_IVStand_250);
                    condition = "[_player, _target, 'hand_r', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'hand_r', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_treatment";
                };
            };
            class ACE_LegLeft {
                class SalineIV;
                class SalineIV_Stand: SalineIV {
                    displayName = CSTRING(Display_IVStand);
                    condition = "[_player, _target, 'leg_l', 'SalineIV_Stand'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_l', 'SalineIV_Stand'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_500: SalineIV {
                    displayName = CSTRING(Display_IVStand_500);
                    condition = "[_player, _target, 'leg_l', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_l', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_250: SalineIV {
                    displayName = CSTRING(Display_IVStand_250);
                    condition = "[_player, _target, 'leg_l', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_l', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_treatment";
                };
            };
            class ACE_LegRight {
                class SalineIV;
                class SalineIV_Stand: SalineIV {
                    displayName = CSTRING(Display_IVStand);
                    condition = "[_player, _target, 'leg_r', 'SalineIV_Stand'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_r', 'SalineIV_Stand'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_500: SalineIV {
                    displayName = CSTRING(Display_IVStand_500);
                    condition = "[_player, _target, 'leg_r', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_r', 'SalineIV_Stand_500'] call ace_medical_treatment_fnc_treatment";
                };
                class SalineIV_Stand_250: SalineIV {
                    displayName = CSTRING(Display_IVStand_250);
                    condition = "[_player, _target, 'leg_r', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_canTreatCached";
                    statement = "[_player, _target, 'leg_r', 'SalineIV_Stand_250'] call ace_medical_treatment_fnc_treatment";
                };
            };
        };
    };
};
