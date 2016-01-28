<h1>NEW FORK, NEW RULES</h1>
Use the new lgsm-core script as a starting point (<a href="https://github.com/jaredballou/linuxgsm/blob/master/_MasterScript/lgsm-core">GitHub HTML</a> - <a href="https://raw.githubusercontent.com/jaredballou/linuxgsm/master/_MasterScript/lgsm-core">Direct Download</a>).
Running that script launches the installer, which pulls the list of games from the gamedata directory.
Select the game server you wish to install, and it will ask a few questions as to where to install it.
At this point, the script itself is deployed. Now continue on with the normal instructions.
<h2>Benefits of the new fork</h2>
<ul>
<li>One script to rule them all.
</li><li>Game server support provided via extensible gamedata system to reduce duplication and increase ability to support more games
</li><li>Decent enough config backend that exposes most of what game server admins want in flat files
</li><li>Creates lgsm/cfg/servers directory to control the LGSM script. The files in this directory are:
<ul>
<li>_default.cfg - Generated regularly by the main script, this will always be overwritten so do not edit it if you want to keep your changes!
</li><li>_common.cfg - The config executed by all your instances. Put defaults for your deployment here, for example ip is a common setting.
</li><li>$instance.cfg - These configs are created for each instance of LGSM. For example, if I install insserver and create another instance by symlinking to it with "inspvpserver", I will have insserver.cfg and inspvpserver.cfg files here. These files will never be overwritten by the LGSM.
</li>
</ul>
</li><li>Better GitHub integration - Supports using Git hashes to check for updated files. Self-bootstrapping sort of works....
</li><li>Config files for defaults are in a central location, but will be templated and moved to gamedata at some point.
</li><li>Dependencies handled in standard way via gamedata files. Different versions of the files are referenced by MD5 hashes for a widely supported method of identifying binary content.
</li><li>SteamCMD and server support for beta and workshop files
</li><li><b>sourcemod</b> command to install latest MetaMod and SourceMod to your game server instance
</li>
</ul>
Probably a lot more, this started off as a POC of hacks and has sort of morphed into a major undertaking all its own. Below is the original upstream README, since the function of the script has been kept as close as possible to legacy.

<h1>Linux Game Server Managers</h1>
<a href="http://gameservermanagers.com"><img src="https://github.com/dgibbs64/linuxgsm/blob/master/images/logo/lgsm-full-light.png" alt="linux Game Server Managers" width="600" /></a>

[![Build Status](https://travis-ci.org/dgibbs64/linuxgsm.svg?branch=master)](https://travis-ci.org/dgibbs64/linuxgsm)
[![Under Development](https://badge.waffle.io/dgibbs64/linuxgsm.svg?label=Under%20Development&title=Under%20Development)](http://waffle.io/dgibbs64/linuxgsm)

The Linux Game Server Managers are command line tools for quick, simple deployment and management of various dedicated game servers and voice comms servers.

<h2>Hassle-Free Dedicated Servers</h2>
Game servers traditionally are not easy to manage yourself. Admins often have to spend hours just messing around trying to get their server working. LGSM is designed to be a simple as possible allowing Admins to spend less time on management and more time on the fun stuff.

<h2>Main features</h2>
<ul>
	<li>Backup</li>
	<li>Console</li>
	<li>Details</li>
	<li>Installer (SteamCMD)</li>
	<li>Monitor (including email notification)</li>
	<li>Update (SteamCMD)</li>
	<li>Start/Stop/Restart server</li>
</ul>
<h2>Compatibility</h2>
The Linux Game Server Managers are tested to work on the following Linux distros.
<ul>
	<li>Debian based (Ubuntu, Mint etc.).</li>
	<li>Redhat based (CentOS, Fedora etc.).</li>
</ul>
Other distros are likely to work but are not fully tested.
<h3>Specific Requirements</h3>
<ul>
	<li><a href="https://github.com/dgibbs64/linuxgsm/wiki/Glibc">GLIBC</a> >= 2.15 recommended [<a href="https://github.com/dgibbs64/linuxgsm/wiki/Glibc#server-requirements">specific requirements</a>].</li>
	<li><a href="https://github.com/dgibbs64/linuxgsm/wiki/Tmux">Tmux</a> >= 1.6 recommended (Avoid Tmux 1.8).</li>
</ul>
<h2>FAQ</h2>
All FAQ can be found here.

<a href="https://github.com/dgibbs64/linuxgsm/wiki/FAQ">https://github.com/dgibbs64/linuxgsm/wiki/FAQ</a>
<h2>Donate</h2>
If you want to donate to the project you can via PayPal, Flattr or Gratipay. I have had a may kind people show their support by sending me a donation. Any donations you send help cover my server costs and buy me a drink. Cheers!
<ul>
<li><a href="http://gameservermanagers.com/#donate">Donate</a></li>
</ul>
<h2>Useful Links</h2>
<ul>
	<li><a href="http://gameservermanagers.com">Homepage</li>
	<li><a href="https://github.com/dgibbs64/linuxgsm/wiki">Wiki</li>
	<li><a href="https://github.com/dgibbs64/linuxgsm">GitHub Code</li>
	<li><a href="https://github.com/dgibbs64/linuxgsm/issues">GitHub Issues</li>
	<li><a href="http://steamcommunity.com/groups/linuxgsm">Steam Group</li>
	<li><a href="https://twitter.com/dangibbsuk">Twitter</li>
	<li><a href="https://www.facebook.com/linuxgsm">Facebook</li>
	<li><a href="https://plus.google.com/+Gameservermanagers1">Google+</li>
</ul>

