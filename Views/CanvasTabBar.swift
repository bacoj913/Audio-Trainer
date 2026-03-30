// Views/CanvasTabBar.swift — Tab bar for switching between main canvas and rack inner canvases

import SwiftUI

struct CanvasTabBar: View {
    @EnvironmentObject var appState: AppState

    private let danteSlotWidth: CGFloat = 110

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(appState.tabs.enumerated()), id: \.element.id) { idx, tab in
                        CanvasTabButton(
                            tab: tab,
                            isActive: !appState.isDanteControllerActive && idx == appState.activeTabIndex,
                            canClose: tab.parentRackInstanceId != nil
                        ) {
                            appState.isDanteControllerActive = false
                            appState.switchTab(index: idx)
                        } onClose: {
                            appState.closeTab(id: tab.id)
                        }
                    }
                }
                .padding(.leading, 8)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()

            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(width: 1, height: 18)

                DanteTabButton(isActive: appState.isDanteControllerActive) {
                    appState.isDanteControllerActive = true
                }
            }
            .frame(width: danteSlotWidth, alignment: .trailing)
            .padding(.trailing, 8)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 32)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }
}
// MARK: - Dante Tab Button

private struct DanteTabButton: View {
    let isActive: Bool
    let onSelect: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "network")
                .font(.system(size: 10))
                .foregroundColor(isActive ? Color.signalTypeColor("dante") : .secondary)
            Text("Dante")
                .font(.system(size: 11, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive ? .primary : .secondary)
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

// MARK: - Previews

private extension AppState {
    static var singleTabState: AppState { AppState() }

    static var multiTabState: AppState {
        let s = AppState()
        let rackInst = s.addInstance(type: "rack_8u", position: .zero)
        s.openRackTab(for: rackInst.id)
        return s
    }

    static var danteActiveState: AppState {
        let s = AppState()
        s.isDanteControllerActive = true
        return s
    }
}

#Preview("Tab Bar – Single Tab") {
    CanvasTabBar()
        .environmentObject(AppState.singleTabState)
        .frame(width: 700)
}

#Preview("Tab Bar – Multiple Tabs") {
    CanvasTabBar()
        .environmentObject(AppState.multiTabState)
        .frame(width: 700)
}

#Preview("Tab Bar – Dante Active") {
    CanvasTabBar()
        .environmentObject(AppState.danteActiveState)
        .frame(width: 700)
}

#Preview("Canvas Tab Button – Active") {
    HStack(spacing: 4) {
        CanvasTabButton(
            tab: CanvasTab(name: "Main"),
            isActive: true,
            canClose: false,
            onSelect: {},
            onClose: {}
        )
        CanvasTabButton(
            tab: CanvasTab(name: "FOH Rack", parentRackInstanceId: UUID()),
            isActive: false,
            canClose: true,
            onSelect: {},
            onClose: {}
        )
    }
    .padding()
    .frame(width: 320, height: 48)
}
