<h1>Linux Game Server Manager</h1>

<a href="http://danielgibbs.co.uk/scripts"><img src="http://danielgibbs.co.uk/wp-content/uploads/2014/02/linux-game-server-manager-full.png" alt="linux game server manager" width="600" /></a>

The Linux Game Server Managers are command line tools for quick, simple deployment and management of various dedicated game servers and voice comms servers.

<h2>Main features</h2>

<ul>
	<li>Server installer (SteamCMD).</li>
	<li>Start/Stop/Restart server.</li>
	<li>Server update (SteamCMD).</li>
	<li>Server monitor (including email notification).</li>
	<li>Server backup.</li>
	<li>Server console.</li>
</ul>
<h2>Compatibility</h2>
The Linux Game Server Manager is tested to work on the following Linux systems.
<ul>
	<li>Debian based distros (Ubuntu, Mint etc.).</li>
	<li>Redhat based distros (CentOS, Fedora etc.).</li>
</ul>
The scripts are written in BASH and Python and would probably work with other distros.

<h2>"I've found a bug", "Something isn't working for me"</h2>
Before submitting an issue about a script error, try deleting the "functions" folder located where the script is. (ie. /home/tf2/tf2server would be /home/tf2/functions)
This will grab the latest scripts from the repository meaning that if we've already fixed the bug you would be asking about, you'd get the patch that way.

<h2>FAQ</h2>
<strong>Q: How do I install a script on my Linux server?</strong>
- Full documentation and instructions can be found here.
<b><a href="http://danielgibbs.co.uk/scripts">http://danielgibbs.co.uk/lgsm</a></b>

<strong>Q: There's a feature that I'd like to see implemented, how can I get it put in?</strong>
- Create an issue report and we'll tag it as an enhancement, if you are able to program in Bash feel free to send us a pull request, it's much likely to be included as well as faster that way.

<strong>Q: Can you go on my server through SSH and install the server for me?</strong>
- Unfortunately, no, the scripts are very easy to install and shouldn't require much help in the first place. If there's a error that you're experiencing, send us an issue report.
