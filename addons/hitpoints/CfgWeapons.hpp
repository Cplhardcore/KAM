class CfgWeapons {
    class ItemCore;
    class ACE_ItemCore;
    class CBA_MiscItem_ItemInfo;
    class KAT_Hemostatic_Injector: ACE_ItemCore {
        scope = 2;
        author = "Cplhardcore";
        displayName = CSTRING(Hemostat_Display);
        picture = QPATHTOF(ui\hemostat.paa);
        model = "\A3\Structures_F_EPA\Items\Medical\Bandage_F.p3d";
        descriptionShort = CSTRING(Hemostat_Desc_Short);
        descriptionUse = CSTRING(Hemostat_Desc_Use);
        ACE_isMedicalItem = 1;
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 0.6;
        };
    };
};