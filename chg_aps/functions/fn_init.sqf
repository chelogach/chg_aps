/*
    chg_aps_fnc_init
    Universal APS initialization
    Usage: [veh, chargesLeft, chargesRight, sector] call chg_aps_fnc_init;
    Author: chelogach & Gemini 3.6 Flash
*/
params [
    ["_veh", objNull, [objNull]],
    ["_chargesLeft", 3, [0]],
    ["_chargesRight", 3, [0]],
    ["_sector", 360, [0]]
];

if (isNull _veh) exitWith {};

if (isNil {_veh getVariable "chg_aps_enabled"}) then {
    private _enabledDef = missionNamespace getVariable ["chg_aps_enabledByDefault", true];
    _veh setVariable ["chg_aps_enabled", _enabledDef, true];
};

if (isNil {_veh getVariable "chg_aps_charges_left"}) then {
    _veh setVariable ["chg_aps_charges_left", _chargesLeft, true];
};

if (isNil {_veh getVariable "chg_aps_charges_right"}) then {
    _veh setVariable ["chg_aps_charges_right", _chargesRight, true];
};

if (isNil {_veh getVariable "chg_aps_sector"}) then {
    _veh setVariable ["chg_aps_sector", _sector, true];
};

if (isNil "chg_aps_vehicles") then {
    chg_aps_vehicles = [];
};

if !(_veh in chg_aps_vehicles) then {
    chg_aps_vehicles pushBack _veh;
};

if (hasInterface) then {
    if (isClass (configFile >> "CfgPatches" >> "ace_interaction")) then {
        [_veh] call chg_aps_fnc_createAceMenu;
    } else {
        if !(_veh getVariable ["chg_aps_actionsAdded", false]) then {
            _veh setVariable ["chg_aps_actionsAdded", true];

            _veh addAction [
                "APS: On/Off",
                {
                    params ["_target", "_caller"];
                    [_target, _caller] call chg_aps_fnc_toggle;
                },
                nil,
                1.5,
                false,
                true,
                "",
                "alive _target && {_this in crew _target}"
            ];

            _veh addAction [
                "APS: Status check",
                {
                    params ["_target", "_caller"];
                    [_target, _caller] call chg_aps_fnc_status;
                },
                nil,
                1.4,
                false,
                true,
                "",
                "alive _target && {_this in crew _target}"
            ];
        };
    };
};
