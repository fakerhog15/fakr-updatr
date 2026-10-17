#!/bin/bash

# common.sh: Set variables, functions and parameters commonly used across the various Fakr-Updatr stages
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# Display debug traces if the -D / --debug argument is passed
for arg in "${@}"; do
	case "${arg}" in
		-D|--debug)
			set -x
		;;
	esac
done

# Reset the option var if it is equal to -D / --debug (to avoid false negative "invalid option" error)
# shellcheck disable=SC2154
case "${option}" in
	-D|--debug)
		unset option
	;;
esac

# Create state and tmp dirs if they don't exist
# shellcheck disable=SC2154
statedir="${XDG_STATE_HOME:-${HOME}/.local/state}/${name}"
tmpdir="${XDG_RUNTIME_DIR:-/run/user/$UID}/${name}"
mkdir -p "${statedir}" "${tmpdir}" || exit 16

# Declare necessary parameters for translations
# shellcheck disable=SC1091
. gettext.sh
# Using "Fakr-Updatr" as TEXTDOMAIN for translations
# shellcheck disable=SC2154
export TEXTDOMAIN="${_name}"
# Check where the translation files are installed (depending on the PREFIX used during the installation) to see if the default TEXTDOMAINDIR path (/usr/share/locale) should be superseded
if [ -f "${XDG_DATA_HOME}/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${XDG_DATA_HOME}/locale"
elif [ -f "${HOME}/.local/share/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${HOME}/.local/share/locale"
elif [ -f "${XDG_DATA_DIRS}/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${XDG_DATA_DIRS}/locale"
elif [ -f "/usr/local/share/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="/usr/local/share/locale"
fi

# Definition of the colors for the colorized output
if [ -z "${no_color}" ]; then
	bold="\e[1m"
	blue="${bold}\e[34m"
	green="${bold}\e[32m"
	yellow="${bold}\e[33m"
	red="${bold}\e[31m"
	color_off="\e[0m"
fi

# Definition of the main_msg function: Display a message as a main message
main_msg() {
	msg="${1}"
	echo -e "${blue}==>${color_off}${bold} ${msg}${color_off}"
}

# Definition of the info_msg function: Display a message as an information message
info_msg() {
	msg="${1}"
	echo -e "${green}==>${color_off}${bold} ${msg}${color_off}"
}

# Definition of the ask_msg function: Display a message as an interactive question
ask_msg() {
	msg="${1}"
	# shellcheck disable=SC2034
	read -rp $"$(echo -e "${blue}->${color_off}${bold} ${msg}${color_off} ")" answer
}

# Definition of the ask_msg_array function: Display a message as an interactive question with multiple possible answers 
ask_msg_array() {
	msg="${1}"
	# shellcheck disable=SC2034
	read -rp $"$(echo -e "${blue}->${color_off}${bold} ${msg}${color_off} ")" -a answer_array
}

# Definition of the warning_msg function: Display a message as a warning message
warning_msg() {
	msg="${1}"
	echo -e "${yellow}==> $(eval_gettext "WARNING"):${color_off}${bold} ${msg}${color_off}"
}

# Definition of the error_msg function: Display a message as an error message
error_msg() {
	msg="${1}"
	echo -e >&2 "${red}==> $(eval_gettext "ERROR"):${color_off}${bold} ${msg}${color_off}"
}

# Definition of the continue_msg function: Display the continue message
continue_msg() {
	msg="$(eval_gettext "Press \"enter\" to continue ")"
	read -n 1 -r -s -p $"$(info_msg "${msg}")" && echo
}

# Definition of the quit_msg function: Display the quit message
quit_msg() {
	msg="$(eval_gettext "Press \"enter\" to quit ")"
	read -n 1 -r -s -p $"$(info_msg "${msg}")" && echo
}

# Check if flatpak is installed for the optional Flatpak support
if [ -z "${no_flatpak}" ]; then
	# shellcheck disable=SC2034
	flatpak_support=$(command -v flatpak)
	# Disable flatpak support if flatpak is available but no Flatpak package is installed
	if [ -n "${flatpak_support}" ] && [ -z "$(flatpak list --user ; flatpak list --system)" ]; then
		unset flatpak_support
	fi
fi

# Check if notify-send is installed for the optional desktop notification support
if [ -z "${no_notification}" ]; then
	# shellcheck disable=SC2034
	notification_support=$(command -v notify-send)
fi

# Definition of the elevation command to use (depending on which one is installed on the system and if it's not already defined in fakr-updatr.conf)
check_su_cmd () {
	if [ -z "${su_cmd}" ]; then
		if command -v sudo > /dev/null; then
			su_cmd="sudo"
		elif command -v sudo-rs > /dev/null; then
			su_cmd="sudo-rs"
		elif command -v doas > /dev/null; then
			su_cmd="doas"
		elif command -v run0 > /dev/null; then
			su_cmd="run0"
		else
			error_msg "$(eval_gettext "A privilege elevation command is required (sudo, sudo-rs, doas or run0)\n")" && quit_msg
			exit 2
		fi
	else
		if ! command -v "${su_cmd}" > /dev/null; then
			error_msg "$(eval_gettext "The \${su_cmd} command set for privilege escalation in the \${name}.conf configuration file is not found\n")" && quit_msg
			exit 2
		fi
	fi
}

# Definition of the icon_up-to-date function: Change tray icon to "up to date"
icon_up-to-date() {
	# shellcheck disable=SC2154
	echo "fakr-updatr-${tray_icon_style}" > "${statedir}/tray_icon"
}

# Definition of the icon_updates-available function: Change tray icon to "updates available"
icon_updates-available() {
	# shellcheck disable=SC2154
	echo "fakr-updatr_updates-available-${tray_icon_style}${colorblind_mode}" > "${statedir}/tray_icon"
}

# Definition of the list_package_updates function: list pending package updates in the
# "<name> <oldver> -> <newver>" format (mimicking pacman-contrib's checkupdates output, which the rest of the code expects)
list_package_updates() {
	local raw name newver oldver

	# rpm-ostree (Fedora Atomic / image-based) systems
	if command -v rpm-ostree > /dev/null 2>&1 && [ -f /run/ostree-booted ]; then
		if rpm-ostree status 2> /dev/null | grep -q "^[[:space:]]*State:[[:space:]]*staged"; then
			echo "system-upgrade staged -> reboot required"
		fi
		return 0
	fi

	# dnf5 / dnf (regular Fedora / Nobara systems)
	if command -v dnf5 > /dev/null 2>&1; then
		raw=$(timeout "${update_check_timeout}" dnf5 -q check-update 2> /dev/null)
	elif command -v dnf > /dev/null 2>&1; then
		raw=$(timeout "${update_check_timeout}" dnf -q check-update 2> /dev/null)
	else
		return 0
	fi

	# dnf5/dnf "check-update" output format: "<name>.<arch> <evr> <repo>", printed as run as follows:
	# "<name> <oldver> -> <newver>" for use by Fakr-Updatr's display / tray statefiles.
	# Blocks whose headers we may encounter are explicitly skipped.
	printf "%s\n" "${raw}" | while read -r name newver _; do
		[ -z "${name}" ] && continue
		[ -z "${newver}" ] && continue

		case "${name}" in
			Obsoleting | Security | Last | Warning | Updating | Repositories | Error | Failed | Dependencies | Available | Checking | Package) continue ;;
		esac

		# Strip the architecture suffix (e.g. ".x86_64")
		case "${name}" in
			*.x86_64 | *.i686 | *.i586 | *.noarch | *.aarch64 | *.i386 | *.armv7hl | *.ppc64le | *.s390x | *.src) name="${name%.*}" ;;
		esac

		# Strip the epoch prefix from the available version if present (e.g. "1:1.2.3" -> "1.2.3")
		case "${newver}" in
			[0-9]*:*) newver="${newver#*:}" ;;
		esac

		oldver=$(rpm -q --qf "%{VERSION}-%{RELEASE}" "${name}" 2> /dev/null) || oldver="?"

		printf "%s %s -> %s\n" "${name}" "${oldver}" "${newver}"
	done
}

# Definition of commands to always run on exit (e.g. cleanup of files / dirs which have no purpose being kept)
cleanup() {
	# shellcheck disable=SC2154
	[ -n "${kernel_reboot}" ] && tput cnorm
}

trap cleanup EXIT
