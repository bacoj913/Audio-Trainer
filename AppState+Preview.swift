// AppState+Preview.swift — Helpers for SwiftUI previews

import SwiftUI

#if DEBUG

extension AppState {
    /// Minimal, deterministic AppState for previews.
    static func preview() -> AppState {
        AppState()
    }

    /// Free mode with a tiny example chain for richer UI previews.
    static func previewFreeWithChain() -> AppState {
        let s = AppState()
        s.mode = .free
        let mic   = s.addInstance(type: "microphone", position: CGPoint(x: 40,  y: 120))
        let pre   = s.addInstance(type: "preamp",     position: CGPoint(x: 220, y: 110))
        let mixer = s.addInstance(type: "mixer",      position: CGPoint(x: 400, y: 100))
        s.connections.append(NodeConnection(fromId: pre.id, fromPortIndex: 0, toId: mixer.id, toPortIndex: 0))
        s.connections.append(NodeConnection(fromId: mic.id, fromPortIndex: 0, toId: pre.id,   toPortIndex: 0))
        return s
    }

    /// Exercise mode at a given index.
    static func previewExercise(index: Int = 0) -> AppState {
        let s = AppState()
        s.mode = .exercise
        s.loadExercise(min(index, s.exercises.count - 1))
        return s
    }
}

#endif
