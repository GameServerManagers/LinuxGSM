Serious Engine Dedicated Server
===============================

1. Starting and stopping the dedicated server
---------------------------------------------

You can launch the dedicated server either from the Steam client's Tools tab, or by directly starting its executable file. In either case, a Steam client needs to be running on that machine, though the user logged in doesn't have to actually own the game. 

In absence of any further configuration, the server will start the first level of the Coop campaign, with all default settings, on the default port.

The server will pause immediately after the first level is loaded, and wait for players to join, to conserve the game state. When the first player joins, the game will unpause.

When all players disconnect, the server will restart its session from the first level again.

To stop the server, press Ctrl+C in its console window and wait until it shuts down.

2. Server ports
---------------

The server will be immediately visible on your LAN, but to make sure it is also visible on the internet, you need to open the port 27016. Note that this is only game enumeration port, as the game traffic port cannot be specified at the moment, thus this will not alleviate the need for NAT punching. I.e. it is not recommended to run a dedicated server behind a NAT/router that doesn't properly support NAT punching, or otherwise all connections to it will have very high pings. We expect the game traffic port to be specifiable in one of the future updates, but it is not currently possible. 

If you want to allow remote administration (see the section about remote administration below), you need to also forward port 27015 (TCP-only).

You can change the port that the server is running on using the command-line option "+port". The server will use the given port for Rcon administration and the given port +1 for game enumeration (see above). So, e.g. if you use "+port 25600", game enumeration will work on port 25601 and rcon on port 25600. When game traffic specification becomes possible, it will be on port 25600 in the example, but this is currently not supported.

You can change the network interface that the server will bind to using the command-line option "+ip". This is used both fr Rcon administration and for game enumeration. When game traffic specification becomes possible, it will also use this, but this is currently not supported (game traffic chooses an interface automatically).

3. Command line
---------------

Command line options can be used to modify any cvar using this format:

SamHD_DedicatedServer.exe +cvarname1 cvarvalue1 +cvarname2 cvarvalue2 ... +cvarnameN cvarvalueN

Quotes are needed around values that contain spaces. Cvar names in the command line can be either short names (e.g. +level "Path/Level") where available, or long names (+gam_strLevel "Path/Level").

4. Configuration scripts
------------------------

When starting, in addition to the command line option, the server will read configuration parameters from the following sources (in this order):
  * Content/SeriousSamHD/Config/dedicatedserver.cfg,
  * eventual custom script specified via the +exec command line option,
  * eventual per-session script specified via the +gameoptions command line option.
The first two are read once on boot, the last one is read on each session start and restart. (When all player's disconnect, the server will load this again before starting the first level.)
  
All of those scripts are fully-featured console scripts, i.e. they use the Lua programming language, so you can put ifs, functions and other programming constructs in them. For a full syntax description and other documentation regarding the Lua programming language, please visit: http://www.lua.org .

Dedicated server does not load or save any .ini files.

5. Most relevant command line options and cvars
-----------------------------------------------
(long name shown in parentheses)
  * +gamemode (gam_idGameMode) - Valid values are:
    (cooperative group)
      Cooperative (this is the default)
      CooperativeCoinOp
      TeamSurvival
    (versus group)
      BeastHunt
      CaptureTheFlag
      Deathmatch
      InstantKill
      LastManStanding
      LastTeamStanding
      MyBurden
      TeamBeastHunt
      TeamDeathmatch
  Note that players can vote to change the game mode, but they cannot switch a server from Cooperative modes to Versus modes or vice versa.
  IMPORTANT: Changing this option resets all other gam_ options to defaults for that game mode. If you are also customizing other gam_ options from a script or via Rcon, make sure you change gam_idGameMode first, and then change all others!
  * +level (gam_strLevel) - Specifies which level to start. Path is relative to the folder the game was installed in. If not specified, the server will start the default first level. 
  * +maxplayers (gam_ctMaxPlayers) - Max number of players in the session. Cannot be higher than 16.
  * +port (prj_uwPort) - Specifies the port number to start the server on. Default is 27015. 
  * +ip (net_strLocalHost) - Specifies the network interface to start the server on. Default is empty, meaning automatic.
  * +fps (prj_iDedicatedFPS) - Specifies the framerate the dedicated server will run in (min 10). 
  * +exec (prj_strExecCfg) - Specifies the configuration file to execute when the server first starts. 
  * +gameoptions (prj_strOptionsScript) - Specifies the game options script to execute. It is executed whenever the server (re)starts the first level. 
  * +sessionname (prj_strMultiplayerSessionName) - Session name that will be displayed in the server browser. If you don't set this, current username from Windows will be shown.
  * +rconpass (rcts_strAdminPassword) - Password used to connect to the server via Rcon (see "Remote administration" above).
  * +logfile (prj_strLogFile) - Save the DedicatedServer.log into a different file. Useful if you want to run multiple servers from the same installation.
  
NOTE: You can use any of the standard game options like gam_bInifiniteAmmo that customize the gameplay, but note that gam_bCustomizeDifficulty is required for them to take effect!

6. Some other useful console variables and functions
----------------------------------------------------

  * gamListPlayers() - print the list of all players to the console in format: 'playerindex: playername' 
  * gamKickByName() - kick the client with the given player name out of the game
  * gamKickByIndex() - kick the client with the given index out of the game
  * gamBanByName() - ban the client with the given player name out of the game
  * gamBanByIndex() - ban the client with the given index out of the game

  * gamRestartServer() - restarts the dedicated server (disconnects all players) so any changes to game settings or other server options can take effect
  * gamRestartGame() -  restart game with new session params without disconnecting players
  * samRestartMap() - restart the current map (without disconnecting all players) so any changes to game difficulty and similar options can take effect
  * gamStop() - stops the current game
  * gamStart() - start game with new session params without disconnecting players
  * samVotePass() - force the current vote to pass
  * samVoteFail() - force the current vote to fail

  * ser_iMaxClientBPS - limit the bandwidth used by each individual client on the server. This caps the cli_iMaxBPS on the server side.
  * prj_strMapList - Semicolon separated list of maps used for multiplayer map rotation.
  * prj_strMapListFile - Path to the file containing a list of maps used for multiplayer map rotation.
  * prj_strDefaultMapDir - Default map folder to use for the map list (specified either by prj_strMapList or prj_strMapListFile). To make it posible to specify map names in a short form, if a '#' prefix is used in a map path, the '#' char will be replaced by the value of this cvar.

All other cvars and cfuncs can be used, most notable are cvars with "gam_" prefix which can be used to setup difficulty options and similar. To get the list of those or more details about them, use the game client's console with its autocompletion and help.

7. Remote administration (RCon)
-------------------------------

Remote administration of Serious Sam HD dedicated servers is implemented via the Telnet protocol. Use any telnet client (e.g. telnet.exe) to connect to the IP and port the server is running on (default is 27015). 

Example:
C:\> telnet my.server.ip 27015 

(*) NOTE: On Vista and Win7, the telnet command is not installed by default. You need to enable it using the "Turn Windows features on or off" section of the Control Panel.

You need to specify the rcon password (using the +rconpass "password" command-line option) when starting the server, otherwise it won't allow you to connect to it via Rcon. Also make sure the appropriate port is open, as explained above.

After entering the correct rcon password, the telnet client will behave similarly to the in-game console (except that SHIFT+TAB combo doesn't work). Additionally you can type a question mark ("?"), followed by a cvar or cfunc to get the help about it.

8. Example configuration script
-------------------------------

Here's an example config script. Put that in a text file named "server.cfg" in the root of the game installation (parent of Bin/), and specify "+exec server.cfg" in the command line (without quotes).

--------8<----- cut here -----------

rconpass = "SuperSecretPassword"; -- MAKE SURE YOU CHANGE THIS!!!!
sessionname = "My Server Name" -- set this to the name of your server

gam_ctMaxPlayers = 8
gamemode="Deathmatch"
gam_bAutoCycleMaps = 1

local prj_strMapList = {
  "#SunPalace.wld",   -- put a list of map file names for rotation here
}

--------8<------cut here ----------