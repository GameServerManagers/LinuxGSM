#!/bin/bash
# LGSM command_stop.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

# Description: Stops the server.

local modulename="Stopping"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

sdtd_telnet(){
    sdtdshutdown=$( expect -c '
    proc abort {} {
        puts "Timeout or EOF\n"
        exit 1
    }
    spawn telnet '"${telnetip}"' '"${telnetport}"'
    expect {
        "password:"     { send "'"${telnetpass}"'\r" }
        default         abort
    }
    expect {
        "session."  { send "shutdown\r" }
        default         abort
    }
    expect { eof }
    puts "Completed.\n"
    ')
}

fn_stop_teamspeak3(){
check.sh
fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1
info_ts3status.sh
if [ "${ts3status}" = "No server running (ts3server.pid is missing)" ]; then
    fn_printfail "${servername} is already stopped"
    fn_scriptlog "${servername} is already stopped"
else
    ${filesdir}/ts3server_startscript.sh stop > /dev/null 2>&1
    fn_printok "${servername}"
    fn_scriptlog "Stopped ${servername}"
fi
# Remove lock file
rm -f "${lgsmdir}/${lockselfname}"
sleep 1
echo -en "\n"
}

fn_stop_tmux(){
check.sh
info_config.sh
fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1

if [ "${gamename}" == "7 Days To Die" ] ; then
    # if game is 7 Days To Die, we need special, graceful shutdown via telnet connection.
    # Set below variable to be called for expect to operate correctly..
    fn_printdots "Attempting graceful shutdown via telnet"
    fn_scriptlog "Attempting graceful shutdown via telnet"
    sleep 1
    telnetip=127.0.0.1
    sdtd_telnet

    # If failed using localhost will use servers ip
    refused=$(echo -en "\n ${sdtdshutdown}"| grep "Timeout or EOF")
    if [ -n "${refused}" ]; then
        telnetip=${ip}
        fn_printwarn "Attempting graceful shutdown via telnet: localhost failed"
        fn_scriptlog "Warning! Attempting graceful shutdown failed using localhost"
        sleep 5
        echo -en "\n"
        fn_printdots "Attempting graceful shutdown via telnet: using ${telnetip}"
        fn_scriptlog "Attempting graceful shutdown via telnet using ${telnetip}"
        sdtd_telnet
        sleep 1
    fi

    refused=$(echo -en "\n ${sdtdshutdown}"| grep "Timeout or EOF")
    completed=$(echo -en "\n ${sdtdshutdown}"| grep "Completed.")
    if [ -n "${refused}" ]; then
        fn_printfail "Attempting graceful shutdown via telnet"
         fn_scriptlog "Attempting graceful shutdown failed"
         fn_scriptlog "${refused}"
    elif [ -n "${completed}" ]; then
        fn_printok "Attempting graceful shutdown via telnet"
        fn_scriptlog "Attempting graceful shutdown succeeded"
    else
         fn_printfail "Attempting graceful shutdown via telnet: Unknown error"
         fn_scriptlog "Attempting graceful shutdown failed"
         fn_scriptlog "Unknown error"
    fi
    sleep 1
    echo -en "\n\n"
    echo -en "Telnet output:"
    echo -en "\n ${sdtdshutdown}"
    echo -en "\n\n"
    sleep 1
    fn_printdots "${servername}"
    fn_scriptlog "${servername}"
    sleep 5
    pid=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
    if [ "${pid}" == "0" ]; then
        fn_printok "${servername} is already stopped using graceful shutdown"
        fn_scriptlog "${servername} is already stopped using graceful shutdown"
    else
        tmux kill-session -t "${servicename}"
        fn_printok "${servername}"
        fn_scriptlog "Stopped ${servername}"
    fi

else
    pid=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
    if [ "${pid}" == "0" ]; then
        fn_printfail "${servername} is already stopped"
        fn_scriptlog "${servername} is already stopped"
    else

        if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
            sleep 1
            fn_printdots "Attempting graceful shutdown"
            fn_scriptlog "Attempting graceful shutdown"
            tmux send -t "${servicename}" quit ENTER > /dev/null 2>&1
            counter=0
            while [ "${pid}" != "0" -a $counter -lt 30 ]; do
                pid=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
                sleep 1
                let counter=counter+1
                if [  "${counter}" -gt "1" ]; then
                    fn_printdots "Attempting graceful shutdown: ${counter}"
                fi    
            done
            pid=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
            if [ "${pid}" == "0" ]; then
                fn_printok "Attempting graceful shutdown"
            else
                fn_printfail "Attempting graceful shutdown"
            fi
        fi

        tmux kill-session -t "${servicename}" > /dev/null 2>&1
        fn_printok "${servername}"
        fn_scriptlog "Stopped ${servername}"
    fi
fi
    # Remove lock file
    rm -f "${lgsmdir}/${lockselfname}"
    sleep 1
    echo -en "\n"
}

if [ "${gamename}" == "Teamspeak 3" ]; then
    fn_stop_teamspeak3
else
    fn_stop_tmux
fi
