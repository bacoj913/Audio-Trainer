// Views/CanvasTabBar.swift — Tab bar for switching between main canvas and rack inner canvases

import SwiftUI

struct CanvasTabBar: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(Array(appState.tabs.enumerated()), id: \.element.id) { idx, tab in
                    CanvasTabButton(
                        tab: tab,
                        isActive: idx == appState.activeTabIndex,
                        canClose: tab.parentRackInstanceId != nil
                    ) {
                        appState.switchTab(index: idx)
                    } onClose: {
                        appState.closeTab(id: tab.id)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(height: 32)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }
}

struct CanvasTabButton: View {
    let tab: CanvasTab
    let isActive: Bool
    let canClose: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: tab.parentRackInstanceId == nil ? "rectangle.on.rectangle" : "server.rack")
                .font(.system(size: 10))
                .foregroundColor(isActive ? .primary : .secondary)

            Text(tab.name)
                .font(.system(size: 11, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive ? .primary : .secondary)
                .lineLimit(1)

            if canClose && (isHovered || isActive) {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isActive
                      ? Color(nsColor: .controlBackgroundColor)
                      : Color.primary.opacity(isHovered ? 0.05 : 0))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isActive ? Color.primary.opacity(0.12) : Color.clear, lineWidth: 1)
        )
        .onHover { isHovered = $0 }
        .onTapGesture { onSelect() }
    }
}
