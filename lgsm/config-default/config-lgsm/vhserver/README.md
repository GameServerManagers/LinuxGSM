A Saga of how a Viking <strike>wrote</strike> *bash*ed some <strike>scripts</strike> runes together that led him on a journey to the missing tenth (or so) missing realm of Valheim!
... *pausing for effect* ...

Upon the whims of Odin, I was chosen to undergo the trial of Valheim, where, by chance, I met my liege, Sir Gloor, an outstanding burly Viking Warrior and Shaman (long beard, pointy hat), who had long discovered the secrets of Valheim, due to his divine connections. Blah blah blah ...etc. etc. etc., (skip the prologue)....booorrrriiinnngggg. Anyways, in order to be able to set out on adventures on dedicated servers, I'll point out some viking-ways to get you set up. First, you'll need 5 wood and 2 stones...

I won't go into to much detail, as lot of the knowledge to run on a server is similar to the rest in Linuxgsm. So I will point to links to their site as I go along.
First the game has it's own parameters for starting that should be set. Like other games managed with Linuxgsm, these can be found in the corresponding game folder, in Valheim's case: lgsm/config-default/config-lgsm/vhserver/_default.cfg. You shouldn't edit this file, as a copy will be made elsewhere upon installing the server, at lgsm/conifg-lgsm/vhserver/_default.cfg. Note: this file is always checked by the code if it has been changed, and will always be reset to match the version of github.

I will suggest setting the following in the common.cfg, which will apply to all game instances created:
- steamuser=

(In the _default.cfg, I mention at the steam section, that you should login prior to install, as the default is to log on anonymously, which is, at the time of this writting, not allowed, as the server requires username and password. You should only need to set your username within the configuration file (common.cfg or '*instance*.cfg), and after logging on manually into steamcmd and entering your password once, it should remember the server as trustworthy. You may need to enter it manually again later, depending, otherwise you can add steampass="" in the file as well. It's just a matter of security, depending if you are willing to risk your steam account, should the server be compromised.)

And then for specific game instances (i.e. vhserver, vhserver-2, etc.), you should
- name (server name as it appears in steam server list)
- world (the save name of the game world found under .config/unity3d/IronGate/Valheim/worlds/ )
- password
- public (if you wish to change the default value: public)

Technically, you can choose which settings are global for all servers (common.cfg) or localised for just a specific instance (*instance*.cfg). It is up to you to sharpen your axe and make the best choice for your situation. For example, I've chosen to make notification "global", turning them on in the common.cfg, so all games will be reported.

Depending if you have a beta branch:
- branch
- branchpassword			(this is presently lacking in the parent branch of Linuxgsm, but works for Valheim! Viking Power!)

There are suggestions and steps to backing up the the entire server setup of Linuxgsm: https://docs.linuxgsm.com/commands/backup
I have done that, but I have also included, similarly, the automating backups of the actual world file (.config/unity3d/IronGate/Valheim/worlds/). Here is an example:
#!/bin/bash
cd /home/<user>/.config/unity3d/IronGate/Valheim/worlds/

files=`ls ./*.fwl`
for i in $files
do 
file=`basename -s .fwl $i`
tar -czf "$1_$file.tar.gz" $file.fwl $file.db
done;

This script combines to the files need for the world into one tar file, and does so for every unique world file. It takes a name as a parameter and places it in front of the world's name. So I have a monthly back up called Monthly_<world_name>.tar.gz, that automatically overwrites itself every month. And similarly, the daily backup overwrites itself everyday. You can customize it as needed. This is an excerpt from cronjob:
# Valheim World Backups
0 0 * * * /home/<user>/<script_name>.sh Daily >/dev/null 2>&1
0 1 1 * * /home/<user>/<script_name>.sh Monthly >/dev/null 2>&1

#$@&%*! *swearing after smashing a finger with the hammer while chiseling the words out*

Presently, gamedig does not support Valheim, so I've set the default to check the session value, which is adequet. 

At this time in writing, I've added alert notification for rocketchat, which on the main repository is presently lacking.


All is as Odin wishes,

A Saga, by the IT Viking
