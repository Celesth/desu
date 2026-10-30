//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "services"
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {
                required property var modelData
                screen: modelData
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            NotificationPanel {
                required property var modelData
                screen: modelData
            }
        }
    }

    WallpaperSelector {}
    BarSettings {}
    PowerMenu {}
    SystemMonitorPanel {}

    // This is the control surface used by the `desu` CLI through
    // `quickshell ipc --pid <pid> call desu ...`. Quickshell owns the socket,
    // validates the target/function/argument types, and keeps it under
    // $XDG_RUNTIME_DIR with the current user's permissions.
    IpcHandler {
        target: "desu"

        function ping(): string {
            return "pong";
        }

        function status(): string {
            return JSON.stringify({
                version: Settings.version,
                pid: Quickshell.processId,
                screens: Quickshell.screens.length,
                recorder: Recorder.state,
                wallpaperSelector: Wallpapers.open,
                systemMonitor: SystemMonitor.open,
                theme: Theme.name
            });
        }

        function reload(): string {
            Qt.callLater(() => Quickshell.reload(true));
            return "reloading";
        }

        function wallpaperOpen(): string {
            Wallpapers.show();
            return "ok";
        }

        function wallpaperClose(): string {
            Wallpapers.hide();
            return "ok";
        }

        function wallpaperRefresh(): string {
            Wallpapers.refresh();
            return "ok";
        }

        function notificationToggle(): string {
            Notifications.toggle();
            return "ok";
        }

        function notificationOpen(): string {
            Notifications.openPanel();
            return "ok";
        }

        function notificationClose(): string {
            Notifications.closePanel();
            return "ok";
        }

        function powerToggle(): string {
            Power.toggle();
            return "ok";
        }

        function powerOpen(): string {
            Power.show();
            return "ok";
        }

        function powerClose(): string {
            Power.hide();
            return "ok";
        }

        function systemMonitorToggle(): string {
            SystemMonitor.open = !SystemMonitor.open;
            return "ok";
        }

        function wallpaperApply(path: string): string {
            if (!path.length) return "error: empty path";
            Wallpapers.apply(path);
            return "requested";
        }

        function clipboardOpen(): string {
            Desktop.openClipboard();
            return "ok";
        }

        function launcherOpen(): string {
            Desktop.openLauncher();
            return "ok";
        }

        function audioMixer(): string {
            Desktop.openMixer();
            return "ok";
        }

        function audioVolume(delta: real): int {
            AudioService.step(delta);
            return AudioService.percent;
        }

        function audioMute(): bool {
            AudioService.toggleMute();
            return AudioService.muted;
        }

        function recorderStart(): string {
            Recorder.start();
            return "requested";
        }

        function recorderStop(): string {
            Recorder.stop();
            return "requested";
        }

        function recorderStatus(): string {
            return JSON.stringify({
                state: Recorder.state,
                active: Recorder.active,
                backend: Recorder.backend,
                output: Recorder.output,
                elapsed: Recorder.elapsed,
                error: Recorder.error
            });
        }

        function notify(message: string): string {
            Desktop.notify(message, false);
            return "ok";
        }
    }
}
