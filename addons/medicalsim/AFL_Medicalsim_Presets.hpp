class AFL_Medicalsim_Presets {
    // Base preset. Comments use interval notation.
    class Base {
        // Wounds
        // {N} for number of wounds per bodyPart: [0,10]
        // {L, M, H} for range random chance: [0,10], [0,10], [0,10]
        wounds[] = {
            {0}, // Head
            {0}, // Neck
            {0}, // Chest
            {0}, // Torso
            {0}, // Upper Left Arm
            {0}, // Left Arm
            {0}, // Upper Right Arm
            {0}, // Right Arm
            {0}, // Upper Left Leg
            {0}, // Left Leg
            {0}, // Upper Right Leg
            {0}  // Right Leg
        };
        damageTypes[] = { 
            "medicalsim"
        };
        // Circulation
        // ARREST_TYPE ["none", "asystole", "pea", "vf", "vt"]
        arrestType = 0; // Chance: [0,1); Type: [1..4]
        refractory = 0; // Chance: [0,1);

        // Airway
        occluded[] = {0, 0, 0};
        obstructed[] = {0, 0, 0};
        catastrophic[] = {0, 0};

        concussion = 0; 
        icp = 15; 
        // Pneumothroax
        // PNUMO_TYPE ["none", "initial", "tension", "hemo"]
        ptxStrength[] = {0, 0};
        tptxEnable[] = {0, 0}; 
        hptxStrength[] = {0, 0};
        ptxTamponade = 0;

        // Fractures
        // {N} for fracture type: [0..3]
        // {Chance, Advanced fracture chance}: [0,1], [0,1]
        // FRACTURE_TYPE ["none", "simple", "compound", "comminuted"]
        fractures[] = {
            {0}, // Head (Unused)
            {0}, // Neck (Unused)
            {0}, // Chest (Unused)
            {0}, // Torso (Unused)
            {0}, // Upper Left Arm
            {0}, // Left Arm
            {0}, // Upper Right Arm
            {0}, // Right Arm
            {0}, // Upper Left Leg
            {0}, // Left Leg
            {0}, // Upper Right Leg
            {0}  // Right Leg
        };

        // Misc
        uncon = 0; // Chance: [0,1]
    };

    class Riflemaid : Base {
        wounds[] = {
            {0},
            {0},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5}
        };
    };

    class Easy : Base {
        wounds[] = {
            {0},
            {0},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5},
            {1, 2, 5}
        };

        uncon = 0.5;
    };

    class Medium : Easy {
        uncon = 1;
        occluded[] = {0.5, 0.5, 0.5};
        obstructed[] = {0.5, 0.25, 0};
    };

    class Hard : Base {
        wounds[] = {
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5}
        };
        fractures[] = {
            {0},
            {0},
            {0},
            {0},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25},
            {0.5, 0.25}
        };
        occluded[] = {0.75, 0.75, 0.75};
        obstructed[] = {0.5, 0.5, 0};
        catastrophic[] = {0.5, 0.5};

        arrestType = 0.5;
        ptxStrength[] = {0.6, 0.6}; // Strength: [1..16]
        tptxEnable[] = {0.4, 0.4}; // true/false
        hptxStrength[] = {0.2, 0.2};
        ptxTamponade = 0;

        uncon = 1;
    };

    class Very_Hard : Hard {
        wounds[] = {
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 2, 5},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10},
            {0, 5, 10}
        };
        fractures[] = {
            {0}, //(Unused)
            {0}, //(Unused)
            {0}, //(Unused)
            {0}, //(Unused)
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5},
            {0.5, 0.5}
        };
        ptxTamponade = 0.1;
    };

    class Fractures : Base {
        fractures[] = {
            {0}, //(Unused)
            {0}, //(Unused)
            {0}, //(Unused)
            {0}, //(Unused)
            {1, 0.5},
            {1, 0.5},
            {1, 0.5},
            {1, 0.5},
            {1, 0.5},
            {1, 0.5},
            {1, 0.5},
            {1, 0.5}
        };
    };
};
