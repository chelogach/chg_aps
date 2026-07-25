/*
    chg_aps_fnc_scanArea
    Per-frame scanning with turret sector filtering, CPA algorithm, and 60° elevation limit
    Author: chelogach & Gemini 3.6 Flash
*/
params [["_veh", objNull]];

if (isNull _veh || {!alive _veh}) exitWith {};

private _enabled = _veh getVariable ["chg_aps_enabled", false];
if (!_enabled) exitWith {};

private _nearProjectiles = nearestObjects [_veh, ["RocketCore", "MissileCore", "SubmunitionCore", "ShellCore"], (_veh getVariable ["chg_aps_scanRange", 45])];
if (_nearProjectiles isEqualTo []) exitWith {};

private _vehPos = getPosASL _veh;

// Calculate turret sector boundaries
private _sector = _veh getVariable ["chg_aps_sector", 360];
private _halfSector = _sector / 2;
private _sectorLimited = _halfSector < 180;
private _turretAz = if (_sectorLimited) then { [_veh] call chg_aps_fnc_turretAzimuth } else { 0 };

private _maxDist = (_veh getVariable ["chg_aps_maxInterceptRange", 30]);
private _minDist = (_veh getVariable ["chg_aps_minInterceptRange", 6]);

{
    private _proj = _x;
    if (alive _proj && {!(_proj getVariable ["chg_aps_processed", false])}) then {
        // Ignore projectiles fired by the vehicle itself
        private _shooter = (getShotParents _proj) param [0, objNull];
        if (_shooter == _veh) then { continue };

        private _dist = _veh distance _proj;

        // Realistic APS interception zone: 6 to 30 meters
        if (_dist <= _maxDist && _dist >= _minDist) then {
            private _ammoClass = typeOf _proj;
            private _ammoLower = toLower _ammoClass;

            // Filter out kinetic armor-piercing projectiles (APFSDS / Sabot / 3BM / M829)
            private _isAPFSDS = false;
            private _cfgAmmo = configFile >> "CfgAmmo" >> _ammoClass;

            if (isClass _cfgAmmo) then {
                private _indirect = getNumber (_cfgAmmo >> "indirectHit");
                private _explosive = getNumber (_cfgAmmo >> "explosive");
                if (_indirect == 0 && _explosive == 0) then {
                    _isAPFSDS = true;
                };
            };

            if (!_isAPFSDS) then {
                if (_ammoLower find "apfsds" != -1 || {_ammoLower find "sabot" != -1} || {_ammoLower find "3bm" != -1} || {_ammoLower find "m829" != -1}) then {
                    _isAPFSDS = true;
                };
            };

            // Check HEAT, RPG, ATGM and HE shells (everything except APFSDS and small arms)
            if (!_isAPFSDS) then {
                private _projPos = getPosASL _proj;
                private _projVel = velocity _proj;
                private _speed = vectorMagnitude _projVel;

                if (_speed > 1) then {
                    // Check sectors (turret azimuth and elevation cap up to 60°)
                    private _inSector = true;
                    private _toProj = _projPos vectorDiff _vehPos;
                    private _dist3D = vectorMagnitude _toProj;

                    // Vertical elevation limit (blind spot above +60°)
                    if (_dist3D > 0) then {
                        private _dirProj = _toProj vectorMultiply (1 / _dist3D);
                        private _cosUp = (_dirProj vectorDotProduct (vectorUp _veh)) min 1 max -1;
                        private _elevation = 90 - (acos _cosUp);
                        if (_elevation > 60) then {
                            _inSector = false;
                        };
                    };

                    if (_inSector && _sectorLimited) then {
                        private _projAz = (_toProj select 0) atan2 (_toProj select 1);
                        private _delta = abs ((_projAz - _turretAz + 540) mod 360 - 180);
                        if (_delta > _halfSector) then {
                            _inSector = false;
                        };
                    };

                    if (_inSector) then {
                        // Vector CPA (Closest Point of Approach) algorithm: check if projectile is moving TOWARDS vehicle
                        private _dirNorm = _projVel vectorMultiply (1 / _speed);
                        private _relPos = _vehPos vectorDiff _projPos;
                        private _tClosest = _relPos vectorDotProduct _dirNorm;

                        // If tClosest > 0, projectile is approaching vehicle (not moving away)
                        if (_tClosest > 0) then {
                            // Minimum distance of trajectory path to vehicle center
                            private _cpaPoint = _projPos vectorAdd (_dirNorm vectorMultiply _tClosest);
                            private _cpaDist = _vehPos vectorDistance _cpaPoint;

                            // React ONLY if projectile trajectory passes closer than 4.5m (direct threat to hull)
                            if (_cpaDist <= 4.5) then {
                                _proj setVariable ["chg_aps_processed", true];
                                [_veh, _proj] call chg_aps_fnc_intercept;
                            };
                        };
                    };
                };
            };
        };
    };
} forEach _nearProjectiles;
