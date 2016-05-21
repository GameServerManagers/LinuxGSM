#!/bin/bash
# LGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: getopt arguments.

fn_getopt_generic(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	u|update)
		update_check.sh;;
	fu|force-update|update-restart)
		forceupdate=1;
		update_check.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	v|validate)
		command_validate.sh;;
	m|monitor)
		command_monitor.sh;;
	ta|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	c|console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate\t\e[0mu  |Checks and applies updates from SteamCMD."
		echo -e "\e[34mforce-update\t\e[0mfu |Bypasses the check and applies updates from SteamCMD."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mvalidate\t\e[0mv  |Validate server files with SteamCMD."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
	} | column -s $'\t' -t 
	esac
exit
}

fn_getopt_teamspeak3(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	u|update)
		update_check.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	pw|change-password)
		command_ts3_server_pass.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate\t\e[0mu  |Checks and applies updates from SteamCMD."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mchange-password\t\e[0mpw |Changes TS3 serveradmin password."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
	} | column -s $'\t' -t 
	esac
exit
}

fn_getopt_mumble(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	b|backup)
		command_backup.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
	} | column -s $'\t' -t 
	esac
exit
}

fn_getopt_gmodserver(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	u|update)
		update_check.sh;;
	fu|force-update|update-restart)
		forceupdate=1;
		update_check.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	v|validate)
		command_validate.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	c|console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;
	fd|fastdl)
		command_fastdl.sh;;
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate\t\e[0mChecks and applies updates from SteamCMD."
		echo -e "\e[34mforce-update\t\e[0mfu |Bypasses the check and applies updates from SteamCMD."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mvalidate\t\e[0mv  |Validate server files with SteamCMD."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
		echo -e "\e[34mfastdl\t\e[0mfd |Generates or update a FastDL folder for your server."
	} | column -s $'\t' -t 
	esac
exit
}

fn_getopt_unreal(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	c|console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;		
	mc|map-compressor)
		compress_ut99_maps.sh;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;		
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
		echo -e "\e[34mmap-compressor\t\e[0mmc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t 
	esac
exit
}


fn_getopt_unreal2(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	u|update)
		update_check.sh;;
	fu|force-update|update-restart)
		forceupdate=1;
		update_check.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	v|validate)
		command_validate.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	c|console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;
	mc|map-compressor)
		compress_unreal2_maps.sh;;
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate\t\e[0mChecks and applies updates from SteamCMD."
		echo -e "\e[34mforce-update\t\e[0mfu |Bypasses the check and applies updates from SteamCMD."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mvalidate\t\e[0mv  |Validate server files with SteamCMD."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
		echo -e "\e[34mmap-compressor\t\e[0mmc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t 
	esac
exit
}


fn_getopt_ut2k4(){
case "$getopt" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		fn_restart;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	et|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	c|console)
		command_console.sh;;
	d|debug)
		command_debug.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;		
	i|install)
		command_install.sh;;
	ai|auto-install)
		fn_autoinstall;;
	cd|server-cd-key)
		install_ut2k4_key.sh;;				
	mc|map-compressor)
		compress_unreal2_maps.sh;;
	dd|depsdetect)
		command_dev_detect_deps.sh;;		
	*)
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	{
		echo -e "\e[34mstart\t\e[0mst |Start the server."
		echo -e "\e[34mstop\t\e[0msp |Stop the server."
		echo -e "\e[34mrestart\t\e[0mr  |Restart the server."
		echo -e "\e[34mupdate-functions\t\e[0muf |Removes all functions so latest can be downloaded."
		echo -e "\e[34mmonitor\t\e[0mm  |Checks that the server is running."
		echo -e "\e[34mtest-alert\t\e[0mta |Sends test alert."
		echo -e "\e[34mdetails\t\e[0mdt |Displays useful infomation about the server."
		echo -e "\e[34mbackup\t\e[0mb  |Create archive of the server."
		echo -e "\e[34mconsole\t\e[0mc  |Console allows you to access the live view of a server."
		echo -e "\e[34mdebug\t\e[0md  |See the output of the server directly to your terminal."
		echo -e "\e[34minstall\t\e[0mi  |Install the server."
		echo -e "\e[34mauto-install\t\e[0mai |Install the server, without prompts."
		echo -e "\e[34mserver-cd-key\t\e[0mcd |Add your server cd key"		
		echo -e "\e[34mmap-compressor\t\e[0mmc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t 
	esac
exit
}

if [ "${gamename}" == "Mumble" ]; then
	fn_getopt_mumble
elif [ "${gamename}" == "Teamspeak 3" ]; then
	fn_getopt_teamspeak3
elif [ "${gamename}" == "Garry's Mod" ]; then
	fn_getopt_gmodserver
elif [ "${engine}" == "unreal2" ]; then
	if [ "${gamename}" == "Unreal Tournament 2004" ]; then
		fn_getopt_ut2k4
	else
		fn_getopt_unreal2
	fi
elif [ "${engine}" == "unreal" ]; then
	fn_getopt_unreal
else
	fn_getopt_generic
fi
