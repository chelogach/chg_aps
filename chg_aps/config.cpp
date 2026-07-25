// Modular Active Protection System (APS)
// Author: chelogach

class CfgPatches {
  class chg_aps {
    units[] = {};
    weapons[] = {};
    requiredVersion = 0.1;
    requiredAddons[] = {"A3_Data_F", "cba_main"};
    author = "chelogach & Gemini 3.6 Flash";
  };
};

class CfgSounds {
  sounds[] = {};
  class chg_aps_intercept_sound {
    name = "chg_aps_intercept_sound";
    sound[] = {"\chg_aps\sounds\aps_warning.wav", 5.0, 1};
    titles[] = {};
  };
};

class CfgFunctions {
  class chg_aps {
    class functions {
      file = "chg_aps\functions";
      class init {};
      class postInit {};
      class scanArea {};
      class intercept {};
      class toggle {};
      class status {};
      class turretAzimuth {};
      class createAceMenu {};
    };
  };
};

class Extended_PostInit_EventHandlers {
  class chg_aps_postinit {
    init = "call chg_aps_fnc_postInit;";
  };
};
