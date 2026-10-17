fakr-updatr(1)

# NAME

Fakr-Updatr - An interactive update notifier & applier for Nobara Linux (and other Fedora-based systems) that assists you with important pre / post update tasks.

# SYNOPSIS

*fakr-updatr* [OPTION]

# DESCRIPTION

Fakr-Updatr is an interactive update notifier & applier for Nobara Linux (and other Fedora-based systems) that assists you with important pre / post update tasks.
It is based on Cachy-Update (itself a fork of arch-update), re-targeted for Fedora/Nobara's `dnf5` / `dnf` / `rpm-ostree` package management.

Fakr-Updatr is designed to follow usual system maintenance steps.

Features:

- Check for and list available updates.
- Support for `dnf5`, `dnf` and `rpm-ostree` (detected automatically).
- Check for orphan packages (and offers to remove them if there are).
- Check for cached packages (and offers to clean them if there are).
- Check for a pending kernel update requiring a reboot (and offers to reboot if there is).
- Check for services requiring a post update restart (and offers to restart them if there are, via `needs-restarting`).
- Support for `sudo`, `sudo-rs`, `doas` & `run0`.
- Extends to an extensive CLI.

Optional support for:

- Flatpak packages (via `flatpak`).
- Desktop notifications (via `libnotify`).
- A systray applet (via the `fakr-updatr-tray` binary).

# OPTIONS

*-c*, *--check*
	Check for available updates, change the systray icon and send a desktop notification containing the number of available updates (if there are new available updates compared to the last check).
	Add the *--enable* argument to enable automated update checks.

*-l*, *--list*
	Display the list of pending updates.

*-s*, *--services*
	Check for services requiring a post upgrade restart.

*-D*, *--debug*
	Display debug traces and messages for troubleshooting purposes.

*--flatpak*
	Also check for available Flatpak packages updates.

*--no-color*
	Do not use color for output.

*--no-version*
	Do not show versions changes for packages when listing pending updates.

*--tray*
	Start the Fakr-Updatr systray applet (optionally with the *--enable* argument, which enables it to start automatically at boot).

*--enable*
	Can be passed alongside the *-c / --check* and *--tray* options, to respectively enable automated update checks or the systray applet.

*--gen-config*
	Generate a default / example `fakr-updatr.conf` configuration file (see the *fakr-updatr.conf*(5) man page for more details).

*--edit-config*
	Edit `fakr-updatr.conf` with the editor defined in the `$EDITOR` environment variable (see the *fakr-updatr.conf*(5) man page for more details).

*--show-config*
	Display the current `fakr-updatr.conf` (see the *fakr-updatr.conf*(5) man page for more details).

*-h*, *--help*
	Display the help message.

*-V*, *--version*
	Display the version number.

# USAGE

For desktop machines, the usage consists of starting the systray applet and enabling automated update checks.
For headless machines, Fakr-Updatr includes an extensive CLI.

## The systray applet

To start the systray applet and enable it automatically at boot (preferred method for most environments, uses XDG Autostart):

```
fakr-updatr --tray --enable
```

In case your graphical environment doesn't support XDG Autostart, add the following command to your environment auto-start method instead (the `sleep 3` delay avoids eventual race condition issues at boot):

```
sleep 3 && fakr-updatr --tray
```

The systray icon dynamically changes to indicate the current state of your system ("up to date" or "updates available"). When clicked, it launches `fakr-updatr` in a terminal window via the `fakr-updatr.desktop` file.

The systray applet menu shows further information (like the list of pending updates, time of the last and next checks, ...) and allows to trigger specific actions (like running Fakr-Updatr, check for updates, ...).

## The automated update checks

To enable automated and periodic checks for available updates:

```
fakr-updatr --check --enable
```

By default, a check is performed at boot and then once a day.
If you want to customize the check cycle, run `systemctl --user edit --full fakr-updatr.timer` and modify the `OnUnitActiveSec` value to your liking.

For instance, if you want Fakr-Updatr to check for new updates every 4 hours instead:

```
[Timer]
OnUnitActiveSec=
OnUnitActiveSec=4h
```

In case you want Fakr-Updatr to check for new updates only once at boot, you can simply delete the `OnUnitActiveSec` line completely.

# TIPS & TRICKS AND TROUBLESHOOTING

## Run Fakr-Updatr in a specific terminal emulator

"gio" (used to launch the `fakr-updatr` terminal application via the `fakr-updatr.desktop` file when the systray applet is clicked) currently has a default limited list of known terminal emulators.
As such, if you don't have any of these "known" terminal emulators installed on your system, you might face an issue where clicking the systray applet does nothing.
In that case, install `xdg-terminal-exec`, create the `~/.config/xdg-terminals.list` file and add the name of the `.desktop` file of your terminal emulator of choice in it (e.g. `Alacritty.desktop`).

## GNOME shell doesn't show the systray applet

GNOME shell does not support systray icons natively. GNOME users need to install the "AppIndicator and KStatusNotifierItem Support" extension (https://extensions.gnome.org/extension/615/appindicator-support/) for the systray applet to work.

# EXIT CODES

*0* Successful run.

*1* Invalid option.

*2* A privilege elevation command is required (`sudo`, `sudo-rs`, `doas` or `run0`).

*3* Error when launching the Fakr-Updatr systray applet.

*4* The update has been aborted.

*5* Error during the update process.

*6* Error during the reboot process.

*7* No update available.

*8* No Flatpak update available.

*9* No AUR update available.

*10* No news available.

*11* No service requiring a post upgrade restart available.

*12* No orphan package available.

*13* No unused Flatpak package available.

*14* Libraries directory not found.

*15* Error with the diff program.

*16* Error while creating directories / state files.

*17* User didn't give the confirmation to proceed after being warned that another instance of Fakr-Updatr is already running.

*18* Error when running Fakr-Updatr from the desktop notification action.

# SEE ALSO

*dnf*(8),
*dnf5*(8),
*rpm*(8),
*rpm-ostree*(1),
*flatpak*(1),
*notify-send*(1),
*systemctl*(1),
*fakr-updatr.conf*(5)

# BUGS

Please report bugs to the GitHub page: https://github.com/fakerhog15/fakr-updatr/issues

# AUTHOR

Based on Cachy-Update / arch-update by Robin Candau <robincandau@protonmail.com>.
Re-targeted for Fedora / Nobara Linux for the Fakr-Updatr project (https://github.com/fakerhog15/fakr-updatr).
