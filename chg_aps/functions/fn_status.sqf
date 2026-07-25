/*
    chg_aps_fnc_status
    Displays APS status, coverage sector, and remaining charge count
    Author: chelogach & Gemini 3.6 Flash
*/
params ["_veh", "_player"];

if (isNull _veh) exitWith {};

private _enabled = _veh getVariable ["chg_aps_enabled", false];
if !(_enabled isEqualType true) then { _enabled = false; };

private _chargesLeft = _veh getVariable ["chg_aps_charges_left", 3];
private _chargesRight = _veh getVariable ["chg_aps_charges_right", 3];
private _sector = _veh getVariable ["chg_aps_sector", 360];

private _statusStr = if (_enabled) then {"ACTIVE"} else {"DEACTIVATED"};

private _msg = format [
    "--- Active Protection System (APS) ---\nStatus: %1\nProtection Sector: %2°\nCharges Left Side: %3\nCharges Right Side: %4",
    _statusStr,
    _sector,
    _chargesLeft,
    _chargesRight
];

if (!isNull _player) then {
    [_msg] remoteExec ["hint", _player];
} else {
    hint _msg;
};
