#!/bin/bash

# fakr-updatr: An interactive update notifier & applier for Fedora/Nobara that assists you with important pre / post update tasks
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# General variables
name="fakr-updatr"
_name="Fakr-Updatr"
version="1.0.0"
option="${1}"

# Define the directory containing libraries
if [ -n "${FAKR_UPDATR_LIBDIR}" ]; then
	libdir="${FAKR_UPDATR_LIBDIR}"
elif [ -d "${XDG_DATA_HOME}/${name}/lib" ]; then
	libdir="${XDG_DATA_HOME}/${name}/lib"
elif [ -d "${HOME}/.local/share/${name}/lib" ]; then
	libdir="${HOME}/.local/share/${name}/lib"
elif [ -d "${XDG_DATA_DIRS}/${name}/lib" ]; then
	libdir="${XDG_DATA_DIRS}/${name}/lib"
elif [ -d "/usr/local/share/${name}/lib" ]; then
	libdir="/usr/local/share/${name}/lib"
elif [ -d "/usr/share/${name}/lib" ]; then
	libdir="/usr/share/${name}/lib"
else
	echo -e >&2 "ERROR: Libraries directory not found"
	exit 14
fi

# Source the "config" library which checks options set in the fakr-updatr.conf configuration file
# shellcheck source=src/lib/config.sh
source "${libdir}/config.sh"

# Source the "common" library which sets variables, functions and parameters commonly used across the various Fakr-Updatr stages
# shellcheck source=src/lib/common.sh
source "${libdir}/common.sh"

# Source the different libraries depending on the option(s) passed
case "${option}" in
	"")
		# Check for requirements
		check_su_cmd

		# Source the "full_upgrade" library which executes the series of relevant functions / libraries to perform a complete and proper update of the system
		# shellcheck source=src/lib/full_upgrade.sh
		source "${libdir}/full_upgrade.sh"
	;;
	-d|--devel)
		# AUR support doesn't exist on Fedora/Nobara: inform and exit
		error_msg "$(eval_gettext "AUR support is not available on this system\n")" && quit_msg
		exit 1
	;;
	-c|--check)
		# Source the "check" library which checks for available updates
		# shellcheck source=src/lib/check.sh
		source "${libdir}/check.sh"
	;;
	-l|--list)
		# Set that the "-l / --list" option is used (required for the "list_packages" library to only print the list of packages available for update without asking for the user confirmation to apply them)
		list_option="true"

		# Source the "list_packages" library which displays the list of packages available for updates
		# shellcheck source=src/lib/list_packages.sh
		source "${libdir}/list_packages.sh"
	;;
	-n|--news)
		# News feed is not configured for this distribution yet
		info_msg "$(eval_gettext "News feature not configured for this distribution")"
		exit 0
	;;
	-s|--services)
		# Check for requirements
		check_su_cmd

		# Source the "restart_services" library which displays services requiring a post upgrade restart (and offers to do so if there are)
		# shellcheck source=src/lib/restart_services.sh
		source "${libdir}/restart_services.sh"
	;;
	--gen-config)
		# Check if the user specified to overwrite any existing "fakr-updatr.conf" configuration file
		if [ "${2}" == "--force" ]; then
			overwrite_config_file="true"
		fi

		# Source the "gen-config" library which generates a default "fakr-updatr.conf" configuration file (if it doesn't exists yet)
		# shellcheck source=src/lib/gen-config.sh
		source "${libdir}/gen-config.sh"
	;;
	--show-config)
		# Source the "show-config" library which displays the current "fakr-updatr.conf" configuration file
		# shellcheck source=src/lib/show-config.sh
		source "${libdir}/show-config.sh"
	;;
	--edit-config)
		# Source the "edit-config" library which edits the current "fakr-updatr.conf" configuration file
		# shellcheck source=src/lib/edit-config.sh
		source "${libdir}/edit-config.sh"
	;;
	--tray)
		# Source the "tray" library which starts the Fakr-Updatr systray applet
		# shellcheck source=src/lib/tray.sh
		source "${libdir}/tray.sh"
	;;
	-h|--help)
		# Source the "help" library which displays the help message
		# shellcheck source=src/lib/help.sh
		source "${libdir}/help.sh"
	;;
	-V|--version)
		# Source the "version" library which displays version information
		# shellcheck source=src/lib/version.sh
		source "${libdir}/version.sh"
	;;
	*)
		# Source the "invalid_option" library which displays an error when an invalid option is passed
		# shellcheck source=src/lib/invalid_option.sh
		source "${libdir}/invalid_option.sh"
	;;
esac
