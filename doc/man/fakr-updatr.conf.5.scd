fakr-updatr.conf(5)

# NAME

fakr-updatr.conf - configuration file for *fakr-updatr*(1).

# SYNOPSIS

*$XDG_CONFIG_HOME/fakr-updatr/fakr-updatr.conf* (~/.config/fakr-updatr/fakr-updatr.conf)

# DESCRIPTION

`fakr-updatr.conf` is the configuration file for *fakr-updatr*(1).
It allows certain options to be enabled, disabled or modified.
The configuration file has to be located at `$XDG_CONFIG_HOME/fakr-updatr/fakr-updatr.conf` (or `~/.config/fakr-updatr/fakr-updatr.conf`).

A default / example configuration file, listing every available option with their default value, can be generated with the `--gen-config` option.

The configuration file can be edited by running: `fakr-updatr --edit-config`.

# OPTIONS

*NoColor*
	Do not use color for output.

*NoVersion*
	Do not show versions changes for packages when listing pending updates (including when using the `-l / --list` option, see the *fakr-updatr*(1) man page for more details).

*NoFlatpak*
	Ignore Flatpak packages support.

*NoNotification*
	Do not send desktop notifications for available updates.

*UpdateCheckTimeout=[Timeout]*
	Timeout threshold for the packages updates check requests (including Flatpak packages). The value is expressed in seconds and has to be an integer. Setting this option to "0" results in no timeout (no time limit for requests to complete). Defaults to 30.

*PrivilegeElevationCommand=[Command]*
	Command to be used for privilege elevation. Valid values are `sudo`, `sudo-rs`, `doas` or `run0`. If this option is not set, Fakr-Updatr will use the first command available in the following order: `sudo`, `sudo-rs`, `doas` then `run0`.

*ShowTrayWhenRelevant*
	Set the SNI status of the systray applet to "Passive" when the system is up-to-date and "Active" when there are updates available. This allows related System Tray settings (such as KDE Plasma's "Show when relevant" option) to hide the Fakr-Updatr systray applet when the system is up-to-date and show it only when updates are available. Note that the systray applet must be restarted after enabling or disabling this option for the change to take effect.

*TrayUpdatesPerPage=[Number]*
	Number of updates to display per page in the systray applet update lists. Setting this option to "0" (which is the default) disables pagination and displays every available update at once.

*TrayIconStyle=[Style]*
	Style to be used for the systray applet icon. Valid values are the available style / color variants for the icon set, listed in https://github.com/fakerhog15/fakr-updatr/blob/main/res/icons/README.md. Defaults to "blue". Note that the systray applet must be refreshed for any change made to this option to take effect (which can be done by running a check for update or simply running `fakr-updatr`).

*ColorblindMode*
	Change systray applet icon update variants to a colorblind-friendly yellow. Note that the systray applet must be refreshed after enabling or disabling this option for the change to take effect (which can be done by running a check for update or simply running `fakr-updatr`).

# SEE ALSO

*fakr-updatr*(1)

# BUGS

Please report bugs to the GitHub page: https://github.com/fakerhog15/fakr-updatr/issues

# AUTHOR

Based on Cachy-Update / arch-update by Robin Candau <robincandau@protonmail.com>.
Re-targeted for Fedora / Nobara Linux for the Fakr-Updatr project (https://github.com/fakerhog15/fakr-updatr).
