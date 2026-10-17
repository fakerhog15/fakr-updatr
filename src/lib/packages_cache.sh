#!/bin/bash

# packages_cache.sh: Search for cached package archives and offer to remove them
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

cached_packages_num=0

if command -v dnf5 > /dev/null 2>&1 || command -v dnf > /dev/null 2>&1; then
	# dnf5 stores its cache in /var/cache/libdnf5, dnf(4) in /var/cache/dnf (when "keepcache=1")
	for cache_dir in /var/cache/libdnf5 /var/cache/dnf; do
		if [ -d "${cache_dir}" ]; then
			cached_packages_num=$(( cached_packages_num + $(find "${cache_dir}" -type f -name "*.rpm" 2> /dev/null | wc -l) ))
		fi
	done
fi

if [ "${cached_packages_num}" -gt 0 ]; then
	if [ "${cached_packages_num}" -eq 1 ]; then
		main_msg "$(eval_gettext "Cached Packages:\nThere's a cached package available for removal\n")"
		ask_msg "$(eval_gettext "Would you like to remove it from the cache now? [Y/n]")"
	else
		main_msg "$(eval_gettext "Cached Packages:\nThere are \${cached_packages_num} cached packages available for removal\n")"
		ask_msg "$(eval_gettext "Would you like to remove them from the cache now? [Y/n]")"
	fi

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
			echo
			main_msg "$(eval_gettext "Cleaning package cache...")"
			if command -v dnf5 > /dev/null 2>&1; then
				if ! "${su_cmd}" dnf5 clean all; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the cleanup process\n")"
				fi
			elif command -v dnf > /dev/null 2>&1; then
				if ! "${su_cmd}" dnf clean all; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the cleanup process\n")"
				fi
			fi
		;;
		*)
			echo
			info_msg "$(eval_gettext "The removal hasn't been applied\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No cached package found\n")"
fi
