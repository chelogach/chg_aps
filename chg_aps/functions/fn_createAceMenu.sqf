/*
    chg_aps_fnc_createAceMenu
    Dynamic creation of ACE Self-Actions menu for a vehicle object
    Author: chelogach & Gemini 3.6 Flash
*/
params [["_veh", objNull, [objNull]]];

if (isNull _veh) exitWith {};

if (!isClass (configFile >> "CfgPatches" >> "ace_main")) exitWith {};

if (_veh getVariable ["chg_aps_aceActionsAdded", false]) exitWith {};

if (isNil "ace_interact_menu_fnc_createAction") exitWith {
    // Delay execution until ACE3 is fully loaded on client
    [_veh] spawn {
        params ["_v"];
        waitUntil { !isNil "ace_interact_menu_fnc_createAction" };
        [_v] call chg_aps_fnc_createAceMenu;
    };
};

_veh setVariable ["chg_aps_aceActionsAdded", true];

private _apsMenu = [
    "CHG_APS_Menu",
    "APS System",
    "",
    {},
    { params ["_target", "_player"]; (alive _target) && (_player in crew _target) }
] call ace_interact_menu_fnc_createAction;

private _apsToggle = [
    "CHG_APS_Toggle",
    "Toggle APS",
    "",
    { _this call chg_aps_fnc_toggle; },
    { params ["_target"]; alive _target }
] call ace_interact_menu_fnc_createAction;

private _apsStatus = [
    "CHG_APS_Status",
    "APS Status",
    "",
    { _this call chg_aps_fnc_status; },
    { params ["_target"]; alive _target }
] call ace_interact_menu_fnc_createAction;

[_veh, 1, ["ACE_SelfActions"], _apsMenu] call ace_interact_menu_fnc_addActionToObject;
[_veh, 1, ["ACE_SelfActions", "CHG_APS_Menu"], _apsToggle] call ace_interact_menu_fnc_addActionToObject;
[_veh, 1, ["ACE_SelfActions", "CHG_APS_Menu"], _apsStatus] call ace_interact_menu_fnc_addActionToObject;
