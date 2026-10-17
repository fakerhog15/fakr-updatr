#!/bin/bash

# update.sh: Update packages and state files
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

if [ -n "${packages}" ]; then
	echo
	main_msg "$(eval_gettext "Updating Packages...\n")"

	# shellcheck disable=SC2154
	if command -v rpm-ostree > /dev/null 2>&1 && [ -f /run/ostree-booted ]; then
		if ! "${su_cmd}" rpm-ostree upgrade; then
			echo
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		else
			true > "${statedir}/last_updates_check_packages"
			cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
			packages_updated="true"
		fi
	elif command -v dnf5 > /dev/null 2>&1; then
		if ! "${su_cmd}" dnf5 upgrade -y; then
			echo
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		else
			true > "${statedir}/last_updates_check_packages"
			cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
			packages_updated="true"
		fi
	elif command -v dnf > /dev/null 2>&1; then
		if ! "${su_cmd}" dnf upgrade -y; then
			echo
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		else
			true > "${statedir}/last_updates_check_packages"
			cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
			packages_updated="true"
		fi
	else
		error_msg "$(eval_gettext "No supported package manager found (dnf5, dnf, or rpm-ostree)\n")" && quit_msg
		exit 5
	fi
fi

if [ -n "${flatpak_packages}" ]; then
	echo
	main_msg "$(eval_gettext "Updating Flatpak Packages...\n")"

	if ! flatpak update; then
		echo
		warning_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")"
		error_during_update="true"
	else
		true > "${statedir}/last_updates_check_flatpak"
		cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
	fi
fi

if [ -z "${error_during_update}" ]; then
	icon_up-to-date
	echo
	info_msg "$(eval_gettext "The update has been applied\n")"
fi
