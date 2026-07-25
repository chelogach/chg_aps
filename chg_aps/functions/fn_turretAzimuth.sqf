/*
    chg_aps_fnc_turretAzimuth
    Calculates turret azimuth heading (in degrees 0..360) for crewed and empty vehicles
    Author: chelogach & Gemini 3.6 Flash
*/
params ["_veh"];

if (isNull _veh) exitWith { 0 };

private _turretWeapons = _veh weaponsTurret [0];
private _facing = if (_turretWeapons isEqualTo []) then {
    vectorDir _veh
} else {
    _veh weaponDirection (_turretWeapons select 0)
};

private _az = (_facing select 0) atan2 (_facing select 1);
if (_az < 0) then { _az = _az + 360; };
_az
