#!/bin/bash
# LGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: getopt arguments.

local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_getopt_generic(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
	fu|force-update|update-restart)
		forceupdate=1;
		command_update.sh;;
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
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}u  |Checks and applies updates from SteamCMD."
		echo -e "${blue}force-update\t${default}fu |Bypasses the check and applies updates from SteamCMD."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}validate\t${default}v  |Validate server files with SteamCMD."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
	} | column -s $'\t' -t
	esac
}

fn_getopt_teamspeak3(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	ta|test-alert)
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
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}u  |Checks and applies updates from SteamCMD."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}change-password\t${default}pw |Changes TS3 serveradmin password."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
	} | column -s $'\t' -t
	esac
}

fn_getopt_minecraft(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
	uf|update-functions)
		command_update_functions.sh;;
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
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}u  |Checks and applies updates from mojang.com."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful infomation about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
	} | column -s $'\t' -t
	esac
}

fn_getopt_mumble(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
	uf|update-functions)
		command_update_functions.sh;;
	m|monitor)
		command_monitor.sh;;
	ta|test-alert)
		command_test_alert.sh;;
	dt|details)
		command_details.sh;;
	b|backup)
		command_backup.sh;;
	dev|dev-debug)
		command_dev_debug.sh;;
	i|install)
		command_install.sh;;
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}u  |Checks and applies updates from SteamCMD."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}install\t${default}i  |Install the server."
	} | column -s $'\t' -t
	esac
}

fn_getopt_gmodserver(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
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
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	fd|fastdl)
		command_fastdl.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}u  |Checks and applies updates from SteamCMD."
		echo -e "${blue}force-update\t${default}fu |Bypasses the check and applies updates from SteamCMD."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}validate\t${default}v  |Validate server files with SteamCMD."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
		echo -e "${blue}fastdl\t${default}fd |Generates or update a FastDL folder for your server."
	} | column -s $'\t' -t
	esac
}

fn_getopt_unreal(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	uf|update-functions)
		command_update_functions.sh;;
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
	mc|map-compressor)
		compress_ut99_maps.sh;;
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
		echo -e "${blue}map-compressor\t${default}mc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t
	esac
}


fn_getopt_unreal2(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	u|update)
		command_update.sh;;
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
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	mc|map-compressor)
		compress_unreal2_maps.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update\t${default}Checks and applies updates from SteamCMD."
		echo -e "${blue}force-update\t${default}fu |Bypasses the check and applies updates from SteamCMD."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}validate\t${default}v  |Validate server files with SteamCMD."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
		echo -e "${blue}map-compressor\t${default}mc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t
	esac
}


fn_getopt_ut2k4(){
case "${getopt}" in
	st|start)
		command_start.sh;;
	sp|stop)
		command_stop.sh;;
	r|restart)
		command_restart.sh;;
	uf|update-functions)
		command_update_functions.sh;;
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
	cd|server-cd-key)
		install_ut2k4_key.sh;;
	mc|map-compressor)
		compress_unreal2_maps.sh;;
	dd|detect-deps)
		command_dev_detect_deps.sh;;
	dg|detect-glibc)
		command_dev_detect_glibc.sh;;
	dl|detect-ldd)
		command_dev_detect_ldd.sh;;
	*)
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	{
		echo -e "${blue}start\t${default}st |Start the server."
		echo -e "${blue}stop\t${default}sp |Stop the server."
		echo -e "${blue}restart\t${default}r  |Restart the server."
		echo -e "${blue}update-functions\t${default}uf |Removes all functions so latest can be downloaded."
		echo -e "${blue}monitor\t${default}m  |Checks that the server is running."
		echo -e "${blue}test-alert\t${default}ta |Sends test alert."
		echo -e "${blue}details\t${default}dt |Displays useful information about the server."
		echo -e "${blue}backup\t${default}b  |Create archive of the server."
		echo -e "${blue}console\t${default}c  |Console allows you to access the live view of a server."
		echo -e "${blue}debug\t${default}d  |See the output of the server directly to your terminal."
		echo -e "${blue}install\t${default}i  |Install the server."
		echo -e "${blue}auto-install\t${default}ai |Install the server, without prompts."
		echo -e "${blue}server-cd-key\t${default}cd |Add your server cd key"
		echo -e "${blue}map-compressor\t${default}mc |Compresses all ${gamename} server maps."
	} | column -s $'\t' -t
	esac
}

if [ "${gamename}" == "Mumble" ]; then
	fn_getopt_mumble
elif [ "${engine}" == "lwjgl2" ]; then
	fn_getopt_minecraft
elif [ "${gamename}" == "TeamSpeak 3" ]; then
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
core_exit.sh