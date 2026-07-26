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
    [
        "chg_aps_enabledByDefault",
        "CHECKBOX",
        ["APS Enabled by Default", "Whether APS should be enabled by default for new vehicles"],
        "Chelogach APS",
        true,
        1 
    ] call CBA_fnc_addSetting;
};

// Start unified CBA Per-Frame Handler capped at 50 Hz (0.02s)
[{
    for "_i" from (count chg_aps_vehicles - 1) to 0 step -1 do {
        private _veh = chg_aps_vehicles select _i;
        if (!(_veh isEqualType objNull) || {isNull _veh || {!(alive _veh)}}) then {
            chg_aps_vehicles deleteAt _i;
            continue;
        };

        if (local _veh) then {
            private _enabled = _veh getVariable ["chg_aps_enabled", false];
            if (_enabled isEqualType true && {_enabled}) then {
                private _cLeft = _veh getVariable ["chg_aps_charges_left", 0];
                private _cRight = _veh getVariable ["chg_aps_charges_right", 0];
                if (_cLeft > 0 || _cRight > 0) then {
                    [_veh] call chg_aps_fnc_scanArea;
                };
            };
        };
    };
}, 0.02, []] call CBA_fnc_addPerFrameHandler;

// CBA Events
["CHG_APS_interceptNotification", {
    if !(hasInterface) exitWith {};
    params [["_isLeft", true, [true]]];
    
    private _sideStr = if (_isLeft) then {"LEFT"} else {"RIGHT"};
    private _msg = format ["APS System: Target Intercepted (%1)!", _sideStr];
    
    private _volMult = missionNamespace getVariable ["chg_aps_soundVolume", 1.0];
    if !(_volMult isEqualType 0) then { _volMult = 1.0; };
    private _finalVol = 5.0 * _volMult;

    hint _msg;
    playSoundUI ["chg_aps_intercept_sound", _finalVol, 1.0];
}] call CBA_fnc_addEventHandler;