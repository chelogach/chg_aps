/*
    chg_aps_fnc_postInit
    Initialization of CBA Per-Frame Handler (50 Hz) and client-dependent CBA Settings
    Author: chelogach & Gemini 3.6 Flash
*/

if (isNil "chg_aps_vehicles") then { chg_aps_vehicles = []; };

// Register custom client setting for volume in CBA Settings
if (isClass (configFile >> "CfgPatches" >> "cba_settings")) then {
    [
        "chg_aps_soundVolume",
        "SLIDER",
        ["APS Sound Volume", "Volume multiplier for APS sound alert in headphones (1.0 = Default, up to 5.0x)"],
        "Chelogach APS",
        [0.1, 5.0, 1.0, 1],
        false // false = client-side setting (independent of server)
    ] call CBA_fnc_addSetting;
};

// Start unified CBA Per-Frame Handler capped at 50 Hz (0.02s)
[{
    if (chg_aps_vehicles isEqualTo []) exitWith {};

    // Clear registry of deleted objects
    if (chg_aps_vehicles findIf { isNull _x } > -1) then {
        chg_aps_vehicles = chg_aps_vehicles select { !isNull _x };
    };

    {
        if (local _x && {alive _x}) then {
            private _enabled = _x getVariable ["chg_aps_enabled", false];
            if (_enabled isEqualType true && {_enabled}) then {
                private _cLeft = _x getVariable ["chg_aps_charges_left", 0];
                private _cRight = _x getVariable ["chg_aps_charges_right", 0];
                if (_cLeft > 0 || _cRight > 0) then {
                    [_x] call chg_aps_fnc_scanArea;
                };
            };
        };
    } forEach chg_aps_vehicles;
}, 0.02, []] call CBA_fnc_addPerFrameHandler;
