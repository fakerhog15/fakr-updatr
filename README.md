<p align="center">
  <img src="assets/logo.png" alt="Fakr-Updatr logo" width="280">
</p>

# Fakr-Updatr

An interactive update notifier & applier for **Nobara Linux** (and other Fedora-based systems) that assists you with important pre / post update tasks.
Includes a systray applet for an easy integration with any desktop / graphical environment.

Fakr-Updatr is based on [Cachy-Update](https://github.com/CachyOS/cachy-update) (itself a fork of [arch-update](https://github.com/Antiz96/arch-update)), re-targeted for Fedora/Nobara's `dnf5` / `dnf` / `rpm-ostree` package management.

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [The systray applet](#the-systray-applet)
- [The automated update checks](#the-automated-update-checks)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Description

Features:

- Automatic check and listing of available updates.
- Support for `dnf5`, `dnf` and `rpm-ostree` (Nobara's package backends are detected automatically).
- Check for orphan packages (and offers to remove them if there are).
- Check for cached packages (and offers to clean them if there are).
- Check for a pending kernel update requiring a reboot (and offers to reboot if there is).
- Check for services requiring a post update restart (and offers to do so if there are, via `needs-restarting`).
- Support for `sudo`, `sudo-rs`, `doas` & `run0`.
- Extensive CLI.

Optional support for:

- Flatpak packages (via `flatpak`).
- Desktop notifications (via `libnotify`).
- A systray applet with dynamic icon, update lists and one-click actions.

## Installation

### From Source

Clone the repository and build:

```
git clone https://github.com/fakerhog15/fakr-updatr.git
cd fakr-updatr
make
sudo make install
```

Notes:

- You can pass `WITH_TRAY=false` to both `make` and `sudo make install` to skip building/installing the systray applet (useful for headless machines, no Rust toolchain required).
- Build dependencies: `make`, `scdoc`, `cargo`, `pkgconf`, `gettext`.
- Required runtime dependencies: `bash`, `systemd`, `dnf5` (or `dnf` / `rpm-ostree`), `rpm`, `glib2`, `xdg-utils`, `util-linux`, `diffutils`, `hicolor-icon-theme`.
- Optional: `flatpak`, `libnotify`, `dnf-plugins-core` (provides `needs-restarting`, used for the post-update service restart check).

Once the installation is complete, you may optionally clean up build artifacts:

```
make clean
```

To uninstall:

```
sudo make uninstall
```

## Usage

For desktop machines, the usage consists of starting [the systray applet](#the-systray-applet) and enabling [the automated update checks](#the-automated-update-checks).
For headless machines, Fakr-Updatr includes an extensive CLI:

```
fakr-updatr            # check for updates, list them, then apply them (interactive)
fakr-updatr --check    # only check for updates (used by the timer / tray)
fakr-updatr --list     # only list available updates
fakr-updatr --services # restart services needing a post-upgrade restart
fakr-updatr --help     # full CLI reference
```

### The systray applet

To start the systray applet and enable it automatically at boot, run the following command (preferred method for most environments, uses XDG Autostart):

```
fakr-updatr --tray --enable
```

In case your graphical environment doesn't support XDG Autostart, add the following command to your environment auto-start method instead (the `sleep 3` delay avoids eventual race condition issues at boot):

```
sleep 3 && fakr-updatr --tray
```

The systray icon dynamically changes to indicate the current state of your system ('up to date' or 'updates available'). When clicked, it launches Fakr-Updatr in a terminal window via the `fakr-updatr.desktop` file. The systray applet menu shows further information (like the list of pending updates, time of the last and next checks, ...) and allows to trigger specific actions (like running Fakr-Updatr, check for updates, ...).

**Notes:**

- If clicking the systray applet does nothing, install `xdg-terminal-exec` (available in the Fedora repositories) and create `~/.config/xdg-terminals.list` containing your terminal's `.desktop` file name (e.g. `Alacritty.desktop`).
- GNOME shell does not support systray icons natively, GNOME users need to install the ["AppIndicator and KStatusNotifierItem Support" extension](https://extensions.gnome.org/extension/615/appindicator-support/) for the systray applet to work.

### The automated update checks

To enable automated and periodic checks for available updates, run the following command:

```
fakr-updatr --check --enable
```

By default, a check is performed **at boot and then once a day**. The check cycle can be customized with `systemctl --user edit --full fakr-updatr.timer` and by modifying the `OnUnitActiveSec` value.

## Documentation

- See `fakr-updatr --help` and the `fakr-updatr(1)` man page.
- See the `fakr-updatr.conf(5)` man page for configuration file details.

Certain options can be enabled, disabled or modified via the `fakr-updatr.conf` configuration file. Generate a default one with `fakr-updatr --gen-config`.

## Contributing

Issues and pull requests are welcome at https://github.com/fakerhog15/fakr-updatr.

## License

Fakr-Updatr is licensed under the [GPL-3.0 license](LICENSE) (or any later version of that license).
