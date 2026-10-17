#!/bin/bash

# full_upgrade.sh: Execute the series of relevant functions / libraries to perform a complete and proper update of the system
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# Lockfile to detect concurrent runs
# shellcheck disable=SC2154
exec {fd_upgrade}> "/tmp/${name}.lock"

# Warn if another instance is already running
if ! flock -n "${fd_upgrade}"; then
	warning_msg "$(eval_gettext "There's already a running instance of \${_name}\n")"
	ask_msg "$(eval_gettext "Proceed anyway? [y/N]")"

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")")
			echo
		;;
		*)
			echo
			error_msg "$(eval_gettext "The execution has been aborted\n")" && quit_msg
			exit 17
		;;
	esac
fi

# Source the "list_packages" library which displays the list of packages available for updates
# shellcheck source=src/lib/list_packages.sh disable=SC2154
source "${libdir}/list_packages.sh"

# If the user gave the confirmation to proceed to apply updates
if [ -n "${proceed_with_update}" ]; then
	# Source the "list_news" library (no news feed is configured for this distribution, it is a no-op)
	# shellcheck source=src/lib/list_news.sh
	source "${libdir}/list_news.sh"

	# Source the "update" library which updates packages
	# shellcheck source=src/lib/update.sh
	source "${libdir}/update.sh"

	# Record the date of the last successful update
	date +%Y-%m-%d > "${statedir}/last_update_run"
fi

# Source the "orphan_packages" library which displays orphan packages and offers to remove them
# shellcheck source=src/lib/orphan_packages.sh
source "${libdir}/orphan_packages.sh"

# Source the "flatpak_unused_packages" library which displays Flatpak unused packages and offers to remove them (if flatpak support is enabled)
if [ -n "${flatpak_support}" ]; then
	# shellcheck source=src/lib/flatpak_unused_packages.sh
	source "${libdir}/flatpak_unused_packages.sh"
fi

# Source the "packages_cache" library which searches for cached package archives and offers to remove them
# shellcheck source=src/lib/packages_cache.sh
source "${libdir}/packages_cache.sh"

# Source the "kernel_reboot" library which checks if there's a pending kernel update requiring a reboot to be applied (unless we're running from a container)
if ! systemd-detect-virt --container --quiet; then
	# shellcheck source=src/lib/kernel_reboot.sh
	source "${libdir}/kernel_reboot.sh"
fi

# Source the "restart_services" library which displays services requiring a post update restart and offers to restart them if packages were updated
# shellcheck source=src/lib/restart_services.sh
if [ -n "${packages_updated}" ]; then
	source "${libdir}/restart_services.sh"
fi

# Display the "quit" message on successful full upgrade
quit_msg
