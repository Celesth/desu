# DESU

DESU is a small monochrome desktop shell for Arch Linux, built around
[Quickshell](https://quickshell.outfoxxed.me/) and Hyprland. It provides a
rectangular status bar, an app launcher, notifications, MPRIS controls,
clipboard history, wallpaper selection, audio controls, and screen recording.

![DESU on an empty Hyprland workspace](docs/screenshots/desu-empty-workspace.png)

## Features

- Lightweight Quickshell bar with workspaces, active window, system tray,
  audio, MPRIS, notifications, and clock controls.
- Mouse-interactable Fuzzel launcher with apps as the default view.
- Clipboard history through `cliphist` and `wl-clipboard`.
- Wallpaper management through `awww` with a clickable selector and restore
  support.
- Screen recording with `gpu-screen-recorder` or `wf-recorder` fallback.
- Modular Lua Hyprland configuration with `SUPER` as the main modifier.
- Matching Kitty, btop, Starship, and Fastfetch configuration.

## Requirements

Required:

- Arch Linux or another Linux distribution with Wayland
- Hyprland 0.55 or newer
- Quickshell
- `fuzzel`, `wl-clipboard`, and `cliphist`
- `awww` and `awww-daemon`
- `kitty` and `starship`

Optional integrations are detected automatically: `pavucontrol`,
`gpu-screen-recorder`, `wf-recorder`, ImageMagick, `playerctl`, and
`network-manager-applet`.

## Install

```sh
git clone https://github.com/Celesth/desu.git
cd desu
./install.sh --hyprland
desu doctor
```

The installer copies the shell payload to `~/.config/desu` and the command to
`~/.local/bin/desu`. Existing files are moved to timestamped backups before
they are changed. Add `--bin-dir DIR` or `--config-dir DIR` to customize the
installation locations.

The `--hyprland` option installs the Lua entrypoint at
`~/.config/hypr/hyprland.lua` and its modules at `~/.config/hypr/desu/`.
Reload Hyprland after installation if it does not reload automatically:

```sh
hyprctl reload
```

## Keybindings

| Binding | Action |
| --- | --- |
| `SUPER` release | Open the app launcher |
| `SUPER + Return` | Open terminal |
| `SUPER + V` | Open clipboard history |
| `SUPER + W` or `SUPER + Ctrl + T` | Open wallpaper selector |
| `SUPER + Shift + D` | Open DESU actions |
| `SUPER + Shift + S` | Screenshot region |
| `SUPER + N` | Toggle notifications |
| `SUPER + A` | Open audio mixer |
| `SUPER + R` | Toggle screen recording |
| `SUPER + Shift + K` | Terminate the focused window |
| `SUPER + mouse wheel` | Change workspace |
| `SUPER + Alt + mouse wheel` | Move the focused window between workspaces |
| `SUPER + left mouse` | Drag a window |
| `SUPER + 1–0` or keypad numbers | Switch workspace |
| `SUPER + Shift + 1–0` or keypad numbers | Move window to workspace |

## Commands

```text
desu start|stop|restart|status|reload|logs
desu launcher [actions]
desu clipboard [show|clear]
desu wallpaper select|set|restore|list|status|backends
desu recorder start|stop|toggle|status|backends
desu audio
desu screenshot [region|full]
desu doctor|config|version
```

Run `desu doctor` to inspect dependencies, paths, permissions, and Quickshell
IPC state.

## Configuration

Edit the installed settings at `~/.config/desu/config`. The repository
template is `config/desu/config`. Useful options include:

- `DESU_BAR_EDGE`, `DESU_BAR_HEIGHT`, and `DESU_FONT`
- `DESU_WALLPAPER_DIR` and `DESU_WALLPAPER_BACKEND`
- `DESU_RECORDER_BACKEND`, `DESU_RECORDER_OUTPUT_DIR`, and `DESU_RECORDER_FPS`

The Hyprland configuration is intentionally split into focused modules:

```text
config/hyprland/hyprland.lua       entrypoint and module loader
config/hyprland/desu/core.lua      general settings, environment, monitor
config/hyprland/desu/lifecycle.lua startup and wallpaper restoration
config/hyprland/desu/bindings.lua  keyboard and mouse bindings
config/hyprland/desu/rules.lua     window rules
```

## Development

Run the shell directly from the repository with:

```sh
DESU_CONFIG_HOME="$PWD/config" ./desu start
```

Run the smoke tests with:

```sh
tests/test-cli.sh
```

See `docs/CHANGELOG.md` for release notes.

## Uninstall

```sh
./uninstall.sh
```

Uninstall moves the installed command and payload to recoverable backups.
Runtime state and cache remain untouched unless `--purge` is explicitly used.
