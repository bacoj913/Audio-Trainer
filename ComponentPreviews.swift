// Previews/ComponentPreviews.swift — Centralized SwiftUI previews for components

import SwiftUI

#if os(macOS)

private extension View {
    func canvasPreviewFrame() -> some View {
        self
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview("Component — Sound Devices 702") {
    let appState = AppState.preview()
    let instance = NodeInstance(type: "preamp", position: CGPoint(x: 40, y: 40))
    return ZStack {
        NodeView(instance: instance)
            .environmentObject(appState)
    }
    .coordinateSpace(name: "canvas")
    .canvasPreviewFrame()
}

#Preview("Component — Microphone") {
    let appState = AppState.preview()
    let instance = NodeInstance(type: "microphone", position: CGPoint(x: 40, y: 40))
    return ZStack {
        NodeView(instance: instance)
            .environmentObject(appState)
    }
    .coordinateSpace(name: "canvas")
    .canvasPreviewFrame()
}

#endif

