/*
    chg_aps_fnc_toggle
    Toggles APS state (On / Off) and displays status notification
    Author: chelogach & Gemini 3.6 Flash
*/
params ["_veh", "_player"];

if (isNull _veh) exitWith {};

private _currentState = _veh getVariable ["chg_aps_enabled", false];
if !(_currentState isEqualType true) then { _currentState = false; };

private _newState = !_currentState;

_veh setVariable ["chg_aps_enabled", _newState, true];

// Display updated status
[_veh, _player] call chg_aps_fnc_status;
