#!/bin/bash

# config.sh: Check options set in the fakr-updatr.conf configuration file
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# Define the path to the fakr-updatr.conf configuration file
# shellcheck disable=SC2154
config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/${name}.conf"

# Check options in the fakr-updatr.conf configuration file if it exists
if [ -f "${config_file}" ]; then
	# Check the "NoColor" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	no_color=$(grep -Eq '^[[:space:]]*NoColor[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoVersion" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	no_version=$(grep -Eq '^[[:space:]]*NoVersion[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoFlatpak" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	no_flatpak=$(grep -Eq '^[[:space:]]*NoFlatpak[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoNotification" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	no_notification=$(grep -Eq '^[[:space:]]*NoNotification[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "UpdateCheckTimeout" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	update_check_timeout=$(grep -E '^[[:space:]]*UpdateCheckTimeout[[:space:]]*=[[:space:]]*[0-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "PrivilegeElevationCommand" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	su_cmd=$(grep -E '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|sudo-rs|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "ShowTrayWhenRelevant" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	show_tray_when_relevant=$(grep -Eq '^[[:space:]]*ShowTrayWhenRelevant[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "TrayUpdatesPerPage" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	tray_updates_per_page=$(grep -E '^[[:space:]]*TrayUpdatesPerPage[[:space:]]*=[[:space:]]*[0-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "TrayIconStyle" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	tray_icon_style=$(grep -E '^[[:space:]]*TrayIconStyle[[:space:]]*=[[:space:]]*(blue|light|dark)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "ColorblindMode" option in fakr-updatr.conf
	# shellcheck disable=SC2034
	colorblind_mode=$(grep -Eq '^[[:space:]]*ColorblindMode[[:space:]]*$' "${config_file}" 2> /dev/null && echo "-cb")
fi

# Set the default / fallback value for options that require it (if the fakr-updatr.conf configuration file doesn't exists, if the concerned option is commented or if the set value is invalid)
[ -z "${update_check_timeout}" ] && update_check_timeout="30"
[ -z "${tray_updates_per_page}" ] && tray_updates_per_page="0"
[ -z "${tray_icon_style}" ] && tray_icon_style="blue"
