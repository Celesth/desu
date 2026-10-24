# DESU

DESU is a small, monochrome desktop shell for Arch Linux, built with
[Quickshell](https://quickshell.outfoxxed.me/) and Hyprland. It keeps the bar
rectangular and event-driven, with optional helpers for audio, recording,
clipboard history, launchers, and wallpapers.

The current release is `0.2.0`. DESU favors low startup cost and a small
dependency surface: Quickshell, Hyprland, Fuzzel, `wl-clipboard`, and
`cliphist` are the core pieces. `gpu-screen-recorder`, `wf-recorder`, `awww`,
`swww`, ImageMagick, and `pavucontrol` are optional.

## Install

Clone the repository anywhere and run:

```sh
./install.sh
desu doctor
```

The installer copies the payload to `~/.config/desu` and the CLI to
`~/.local/bin/desu`. Existing targets are moved to timestamped backups before
they are changed. Use `--bin-dir` or `--config-dir` for another XDG-compatible
location. Add `--hyprland` to back up and replace the Lua main config at
`~/.config/hypr/hyprland.lua`.

DESU includes a self-contained Lua Hyprland config with `SUPER` as the main
modifier. `SUPER` release opens the mouse-interactable app list in Fuzzel.
`SUPER+Shift+D` opens DESU actions; clipboard, wallpaper, recorder, audio, and
notifications are also available directly on `SUPER+C/W/R/A/N`. `SUPER+Return`
opens the terminal, `SUPER+Shift+S` takes a screenshot, and `SUPER` plus mouse
wheel changes workspace. `--hyprland` backs up the current Lua main config
before installing this one. `desu start` also works manually; it refuses to
start outside a Wayland session.

## Commands

```text
desu start|stop|restart|status|reload|logs
desu recorder start|stop|toggle|status|backends
desu wallpaper select|set|restore|list|status|backends
desu clipboard [show|clear]
desu audio                 # opens pavucontrol
desu launcher              # opens the app list in Fuzzel
desu launcher actions      # opens DESU actions in Fuzzel
desu doctor|config|version
```

The CLI talks to the running shell through Quickshell IPC, selected by its
exact process ID. Runtime files are kept under `$XDG_RUNTIME_DIR/desu` with
mode `700`; shell logs and persistent selections use XDG state/cache paths.

## Configuration

Edit `~/.config/desu/config`, or set `DESU_*` variables for one invocation.
The repository copy is at `config/desu/config`. Important options include:

- `DESU_BAR_EDGE`, `DESU_BAR_HEIGHT`, and `DESU_FONT`
- `DESU_WALLPAPER_DIR` and `DESU_WALLPAPER_BACKEND`
- `DESU_RECORDER_BACKEND`, `DESU_RECORDER_OUTPUT_DIR`, and `DESU_RECORDER_FPS`

The palette is centralized in `config/quickshell/services/Theme.qml`.

## Clipboard and recording

DESU starts one text and one image `wl-paste --watch cliphist store` watcher
when the shell starts. `desu clipboard` presents `cliphist list` in Fuzzel and
restores the selected entry with `cliphist decode`, preserving detected MIME
types where possible. `desu clipboard clear` uses `cliphist wipe`.

Recording prefers `gpu-screen-recorder` and falls back to `wf-recorder`.
Backend selection, output paths, and failures are exposed by
`desu recorder status` and `desu doctor`.

## Uninstall

```sh
./uninstall.sh
```

The installed command and payload are moved to recoverable backups. State and
cache remain untouched. `./uninstall.sh --purge` removes only DESU state and
cache after an explicit request.

## Development

The repo can be run in place with `DESU_CONFIG_HOME=/path/to/config-home ./desu
start`, or directly with `quickshell -p config/quickshell`. Run
`tests/test-cli.sh` for the dependency-free smoke checks. See
`docs/CHANGELOG.md` for release notes.
