#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          networking ifupdown
# Required-Start:    mountkernfs $local_fs urandom
# Required-Stop:     $local_fs
# Default-Start:     S
# Default-Stop:      0 6
# Short-Description: Raise network interfaces.
# Description:       Prepare /run/network directory, ifstate file and raise network interfaces, or take them down.
### END INIT INFO

PATH="/sbin:/bin"
RUN_DIR="/run/network"
IFSTATE="$RUN_DIR/ifstate"

[ -x /sbin/ifup ] || exit 0
[ -x /sbin/ifdown ] || exit 0

. /lib/lsb/init-functions

CONFIGURE_INTERFACES=yes
EXCLUDE_INTERFACES=
VERBOSE=no

[ -f /etc/default/networking ] && . /etc/default/networking

[ "$VERBOSE" = yes ] && verbose=-v

process_exclusions() {
    set -- $EXCLUDE_INTERFACES
    exclusions=""
    for d
    do
	exclusions="-X $d $exclusions"
    done
    echo $exclusions
}

process_options() {
    [ -e /etc/network/options ] || return 0
    log_warning_msg "/etc/network/options still exists and it will be IGNORED! Please use /etc/sysctl.conf instead."
}

check_ifstate() {
    if [ ! -d "$RUN_DIR" ] ; then
	if ! mkdir -p "$RUN_DIR" ; then
	    log_failure_msg "can't create $RUN_DIR"
	    exit 1
	fi
    fi
    if [ ! -r "$IFSTATE" ] ; then
	if ! :> "$IFSTATE" ; then
	    log_failure_msg "can't initialise $IFSTATE"
	    exit 1
	fi
    fi
}

check_network_file_systems() {
    [ -e /proc/mounts ] || return 0

    if [ -e /etc/iscsi/iscsi.initramfs ]; then
	log_warning_msg "not deconfiguring network interfaces: iSCSI root is mounted."
	exit 0
    fi

    while read DEV MTPT FSTYPE REST; do
	case $DEV in
	/dev/nbd*|/dev/nd[a-z]*|/dev/etherd/e*)
	    log_warning_msg "not deconfiguring network interfaces: network devices still mounted."
	    exit 0
	    ;;
	esac
	case $FSTYPE in
	nfs|nfs4|smbfs|ncp|ncpfs|cifs|coda|ocfs2|gfs|pvfs|pvfs2|fuse.httpfs|fuse.curlftpfs)
	    log_warning_msg "not deconfiguring network interfaces: network file systems still mounted."
	    exit 0
	    ;;
	esac
    done < /proc/mounts
}

check_network_swap() {
    [ -e /proc/swaps ] || return 0

    while read DEV MTPT FSTYPE REST; do
	case $DEV in
	/dev/nbd*|/dev/nd[a-z]*|/dev/etherd/e*)
	    log_warning_msg "not deconfiguring network interfaces: network swap still mounted."
	    exit 0
	    ;;
	esac
    done < /proc/swaps
}

ifup_hotplug () {
    if [ -d /sys/class/net ]
    then
	    ifaces=$(for iface in $(ifquery --list --allow=hotplug)
			    do
				    link=${iface##:*}
				    link=${link##.*}
				    if [ -e "/sys/class/net/$link" ] && [ "$(cat /sys/class/net/$link/operstate)" = up ]
				    then
					    echo "$iface"
				    fi
			    done)
	    if [ -n "$ifaces" ]
	    then
		ifup $ifaces "$@" || true
	    fi
    fi
}

case "$1" in
start)
	if init_is_upstart; then
		exit 1
	fi
	process_options
	check_ifstate

	if [ "$CONFIGURE_INTERFACES" = no ]
	then
	    log_action_msg "Not configuring network interfaces, see /etc/default/networking"
	    exit 0
	fi
	set -f
	exclusions=$(process_exclusions)
	log_action_begin_msg "Configuring network interfaces"
	if ifup -a $exclusions $verbose && ifup_hotplug $exclusions $verbose
	then
	    log_action_end_msg $?
	else
	    log_action_end_msg $?
	fi
	;;

stop)
	if init_is_upstart; then
		exit 0
	fi
	check_network_file_systems
	check_network_swap

	log_action_begin_msg "Deconfiguring network interfaces"
	if ifdown -a --exclude=lo $verbose; then
	    log_action_end_msg $?
	else
	    log_action_end_msg $?
	fi
	;;

reload)
	process_options

	log_action_begin_msg "Reloading network interfaces configuration"
	state=$(cat /run/network/ifstate)
	ifdown -a --exclude=lo $verbose || true
	if ifup --exclude=lo $state $verbose ; then
	    log_action_end_msg $?
	else
	    log_action_end_msg $?
	fi
	;;

force-reload|restart)
	if init_is_upstart; then
		exit 1
	fi
	process_options

	log_warning_msg "Running $0 $1 is deprecated because it may not re-enable some interfaces"
	log_action_begin_msg "Reconfiguring network interfaces"
	ifdown -a --exclude=lo $verbose || true
	set -f
	exclusions=$(process_exclusions)
	if ifup -a --exclude=lo $exclusions $verbose && ifup_hotplug $exclusions $verbose
	then
	    log_action_end_msg $?
	else
	    log_action_end_msg $?
	fi
	;;

*)
	echo "Usage: /etc/init.d/networking {start|stop|reload|restart|force-reload}"
        echo "   or: ~/dump1090/net {start|stop|reload|restart|force-reload}"
	exit 1
	;;
esac

exit 0

# vim: noet ts=8
