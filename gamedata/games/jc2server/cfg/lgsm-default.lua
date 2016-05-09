-- Welcome to the JC2-MP server configuration file!

--[[
SERVER OPTIONS

Server-related options.
--]]
Server =
{
    -- The maximum number of players that can be on the server at any
    -- given time. Make sure your connection and server can handle it!
    -- Default value: 5000
    MaxPlayers                  = 5000,
    -- Used to control what IP this server binds to. Unless you're a dedicated
    -- game host, you don't need to worry about this.
    -- Default value: ""
    BindIP                      = "",
    -- The port the server uses.
    -- Default value: 7777
    BindPort                    = 7777,
    -- The time before a player is timed out after temporarily losing
    -- connection, or crashing without properly disconnecting.
    -- Default value (in milliseconds): 10000
    Timeout                     = 10000,

    -- The name of the server, as seen by players and the server browser.
    -- Default value: "JC2-MP Server"
    Name                        = "JC2-MP Server",
    -- The server description, as seen by players and the server browser.
    -- Default value: "No description available"
    Description                 = "No description available.",
    -- The server password.
    -- Default value: ""
    Password                    = "",

    -- Controls whether the server announces its presence to the master server
    -- and therefore to the server browser.
    -- Default value: true
    Announce                    = true,

    -- Controls how often synchronization packets are broadcast by the server
    -- in milliseconds
    -- Default value (in milliseconds): 180
    SyncUpdate                  = 180,

    -- CAUTION: Setting this variable to true unlocks a number of potentially
    -- unsafe operations, which include:
    --  * Native Lua packages (.dll, .so)
    --  * Execution of Lua from arbitrary paths (Access to loadfile/dofile)
    --  * Unbound io functions, allowing for access to the entire file-system
    -- Default value: false
    IKnowWhatImDoing            = false
}

--[[
SYNCRATE OPTIONS

Sync rate options. These values control how often synchronization
packets are sent by the clients, in milliseconds. This lets you
control how frequent the sync comes in, which may result in a
smoother or less laggy experience
--]]
SyncRates =
{
    -- Default value (in milliseconds): 75
    Vehicle                     = 75,
    -- Default value (in milliseconds): 120
    OnFoot                      = 120,
    -- Default value (in milliseconds): 1000
    Passenger                   = 1000,
    -- Default value (in milliseconds): 250
    MountedGun                  = 250,
    -- Default value (in milliseconds): 350
    StuntPosition               = 350
}

--[[
STREAMER OPTIONS

Streamer-related options. The streamer is responsible for controlling the
visibility of objects (including players and vehicles) for other players.

What this means is that if you want to extend the distance at which objects
remain visible for players, you need to change the StreamDistance.
--]]
Streamer =
{
    -- The default distance before objects are streamed out.
    -- Default value (in metres): 500
    StreamDistance              = 500
}

--[[
VEHICLE OPTIONS

Vehicle-related options.
--]]
Vehicle =
{
    -- The number of seconds required for a vehicle to respawn after
    -- vehicle death.
    -- Default value (in seconds): 10
    -- For instant respawn: 0
    -- For no respawning: nil
    DeathRespawnTime            = 10,
    -- Controls whether to remove the vehicle if respawning is turned off,
    -- and the vehicle dies.
    -- Default value: false
    DeathRemove                 = false,

    -- The number of seconds required for a vehicle to respawn after it is
    -- left unoccupied.
    -- Default value (in seconds): 45
    -- For instant respawn: 0
    -- For no respawning: nil
    UnoccupiedRespawnTime       = 45,
    -- Controls whether to remove the vehicle if respawning is turned off,
    -- and the vehicle is left unoccupied.
    -- Default value: false
    UnoccupiedRemove            = false,
}

--[[
PLAYER OPTIONS

Player-related options.
--]]
Player =
{
    -- The default spawn position for players. If you do not use a script
    -- to handle spawns, such as the freeroam script, then this spawn position
    -- will be used.
    -- Default value: Vector3( -6550, 209, -3290 )
    SpawnPosition               = Vector3( -6550, 209, -3290 )
}

--[[
MODULE OPTIONS

Lua module-related options.
--]]
Module =
{
    --[[
    To prevent a large number of errors building up, modules are automatically
    unloaded after a certain number of errors in a given timespan. Each error
    adds to a counter, which is decremented if there has not been an error
    in a certain amount of time.

    This allows you to adjust the number of errors before the module is unloaded,
    as well as the time since the last error for the counter to be decremented.
    --]]

    -- The maximum number of errors before a module is unloaded.
    -- Default value: 5
    MaxErrorCount               = 5,
    -- The time from the last error necessary for the error counter to be decremented.
    -- Default value (in milliseconds): 500
    ErrorDecrementTime          = 500
}

--[[
WORLD OPTIONS

Default settings for worlds.
--]]
World =
{
    -- The default time of day at world creation.
    -- Default value (in hours): 0.0
    Time                        = 0.0,

    -- The increment added to the time of day each second.
    -- Default value (in minutes): 1
    TimeStep                    = 1,

    -- The default weather severity at world creation.
    -- Default value: 0
    WeatherSeverity             = 0
