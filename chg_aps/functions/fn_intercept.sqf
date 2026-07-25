/*
    chg_aps_fnc_intercept
    Performs physical interception of target, consumes charges, and triggers customizable 2D crew notification
    Author: chelogach & Gemini 3.6 Flash
*/
params ["_veh", "_projectile"];

if (isNull _veh || isNull _projectile) exitWith {};
if (!alive _veh || !alive _projectile) exitWith {};

private _enabled = _veh getVariable ["chg_aps_enabled", false];
if (!_enabled) exitWith {};

private _dirToProj = _veh getRelDir _projectile;
private _isLeft = (_dirToProj >= 180 && _dirToProj < 360);

private _chargesLeft = _veh getVariable ["chg_aps_charges_left", 0];
private _chargesRight = _veh getVariable ["chg_aps_charges_right", 0];

private _canIntercept = false;

if (_isLeft && _chargesLeft > 0) then {
    _canIntercept = true;
    _veh setVariable ["chg_aps_charges_left", _chargesLeft - 1, true];
} else {
    if (!_isLeft && _chargesRight > 0) then {
        _canIntercept = true;
        _veh setVariable ["chg_aps_charges_right", _chargesRight - 1, true];
    };
};

if (_canIntercept) then {
    // Detonation point
    private _pos = getPosATL _projectile;

    // Create physical metal plate in mid-air to detonate warhead
    private _plate = "Land_MetalPlate_Single_F" createVehicleLocal _pos;
    _plate setPosATL _pos;
    _plate setVectorDirAndUp [vectorDir _projectile, vectorUp _projectile];

    // Detonate and destroy projectile
    triggerAmmo _projectile;
    _projectile setDamage 1;

    // Cleanup metal plate and remaining projectile debris after 0.05s
    [_plate, _projectile] spawn {
        params ["_p", "_proj"];
        sleep 0.05;
        deleteVehicle _p;
        if (!isNull _proj) then {
            deleteVehicle _proj;
            if (!isNull _proj) then {
                [_proj] remoteExec ["deleteVehicle", _proj];
            };
        };
    };

    // Crew notification (hint popup + customizable 2D sound respecting CBA Settings)
    private _sideStr = if (_isLeft) then {"LEFT"} else {"RIGHT"};
    private _msg = format ["APS System: Target Intercepted (%1)!", _sideStr];

    {
        if (isPlayer _x) then {
            [_msg] remoteExec ["hint", _x];
            // Calculate final volume based on user setting chg_aps_soundVolume (from 1.0 to 5.0x)
            [{
                private _volMult = missionNamespace getVariable ["chg_aps_soundVolume", 1.0];
                private _finalVol = 5.0 * _volMult;
                playSoundUI ["chg_aps_intercept_sound", _finalVol, 1.0];
            }] remoteExec ["call", _x];
        };
    } forEach (crew _veh);
};
