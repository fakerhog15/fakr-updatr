#!/bin/bash

# kernel_reboot.sh: Check if there's a pending kernel update requiring a reboot to be applied
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# On Fedora/Nobara, a reboot is pending when the running kernel is not the newest installed one
# (or when needs-restarting explicitly reports that a reboot is required).
reboot_required=""

if command -v needs-restarting > /dev/null 2>&1; then
	if ! needs-restarting -r > /dev/null 2>&1; then
		reboot_required="true"
	fi
else
	running_kernel=$(uname -r)
	newest_kernel=$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" --last kernel 2> /dev/null | sed -n '1p')

	if [ -n "${newest_kernel}" ] && [ "${running_kernel}" != "${newest_kernel}" ]; then
		reboot_required="true"
	fi
fi

if [ -n "${reboot_required}" ]; then
	main_msg "$(eval_gettext "Reboot required:\nThere's a pending kernel update on your system requiring a reboot to be applied\n")"
	ask_msg "$(eval_gettext "Would you like to reboot now? [y/N]")"

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")")
			# shellcheck disable=SC2034
			kernel_reboot="true"

			echo

			# shellcheck disable=SC2034
			for sec in {5..1}; do
				# shellcheck disable=SC2154
				tput civis ; echo -ne "${blue}==>${color_off}${bold} $(eval_gettext "Rebooting in \${sec}...\r")${color_off}"
				sleep 1
			done

			if ! systemctl reboot; then
				echo
				error_msg "$(eval_gettext "An error has occurred during the reboot process\nThe reboot has been aborted\n")" && quit_msg
				exit 6
			else
				exit 0
			fi
		;;
		*)
			echo
			warning_msg "$(eval_gettext "The reboot hasn't been performed\nPlease, consider rebooting to finalize the pending kernel update\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No pending kernel update found\n")"
fi
