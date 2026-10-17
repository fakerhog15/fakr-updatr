# Changelog

All notable changes to this project will be documented in this file.

Fakr-Updatr is based on [Cachy-Update](https://github.com/CachyOS/cachy-update) (itself a fork of [arch-update](https://github.com/Antiz96/arch-update)).
The upstream changelog up to v4.4.3 is available in the history of this file on GitHub.

## [v1.0.0](https://github.com/fakerhog15/fakr-updatr/releases/tag/v1.0.0) - 2026-10-17

### Features

- Initial release of Fakr-Updatr, an interactive update notifier & applier for Nobara Linux (and other Fedora-based systems).
- Re-targeted the update backend from pacman to `dnf5` / `dnf` / `rpm-ostree`.
- Kept the full upstream UI: systray applet (Rust, renamed to `fakr-updatr-tray`), desktop notifications, timed update checks and interactive menus.
- Added a Fedora/Nobara kernel-update reboot check (running kernel vs. newest installed kernel, or `needs-restarting -r`).
- Replaced Arch-specific service restart detection (`checkservices`) with `needs-restarting --services`.
- Removed AUR / ALHP / Arch news / pacnew support.
