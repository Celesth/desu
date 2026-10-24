pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Native PipeWire control. `wpctl`/`pactl` are not polled; PipeWire updates
// the bindings when the sink changes. pavucontrol is only the full mixer UI.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool available: audio !== null && audio !== undefined
    readonly property bool muted: available ? audio.muted : false
    readonly property int percent: available ? Math.round(audio.volume * 100) : 0

    readonly property string label: {
        if (!available) return "AUDIO";
        if (muted) return "MUTE";
        return "VOL " + percent + "%";
    }

    function step(delta) {
        if (!available) return;
        const next = audio.volume + delta;
        audio.volume = Math.max(0, Math.min(1.5, next));
    }

    function toggleMute() {
        if (!available) return;
        audio.muted = !audio.muted;
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
