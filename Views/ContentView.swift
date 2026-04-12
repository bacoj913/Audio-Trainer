// Views/ContentView.swift — Root layout: custom title bar + body

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            TitleBarView()
            AppBodyView()
        }
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        .sheet(isPresented: $appState.showExerciseBuilder) {
            ExerciseBuilderView()
                .environmentObject(appState)
            
        }
    }
}

// MARK: - Title Bar
struct TitleBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {

            // Centered title
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .medium))
                Text("Audio Signal Flow Practice Tool")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.primary.opacity(0.75))

            // Right controls
            HStack(spacing: 10) {
                // Segmented control
                SegmentedModeControl()

                // Dark mode toggle
                Button {
                    appState.toggleDarkMode()
                } label: {
                    Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle dark mode")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal,16)
        .frame(height: 38)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }
}

// MARK: - Segmented Mode Control
struct SegmentedModeControl: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 1) {
            ForEach([("Free Build", AppMode.free), ("Exercises", .exercise), ("RF Planner", .rf), ("Intercom", .intercom)], id: \.0) { label, mode in
                Button(label) { appState.mode = mode }
                    .buttonStyle(SegmentButtonStyle(isActive: appState.mode == mode))
            }
        }
        .padding(2)
        .background(Color.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SegmentButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: isActive ? .semibold : .medium))
            .foregroundColor(isActive ? .primary : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(isActive ? Color(nsColor: .controlBackgroundColor) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: isActive ? .black.opacity(0.12) : .clear, radius: 3, x: 0, y: 1)
            
    }
}

// MARK: - Toolbar
struct ToolbarBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 4) {
            ToolbarButton(icon: "trash", label: "Clear") {
                appState.clearCanvas()
            }
            ToolbarButton(icon: "square.grid.3x3", label: "Clean Up") {
                appState.autoLayout()
            }
            ToolbarButton(icon: "arrow.up.left.and.arrow.down.right", label: "Reset Zoom") {
                appState.resetCanvasView()
            }
            .help("Reset zoom and pan (⌘0)")
            .keyboardShortcut("0", modifiers: .command)

            Rectangle()
                .fill(Color.primary.opacity(0.12))
                .frame(width: 1, height: 18)
                .padding(.horizontal, 4)
                
            Text(appState.connectingFromId != nil
                 ? "Click an input port to connect  |  Click a connected input to disconnect"
                 : "Drag components from the sidebar  |  Pinch to zoom  |  Drag background to pan")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Spacer()

            // Zoom level indicator
            if appState.canvasScale != 1.0 {
                Text("\(Int(appState.canvasScale * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
        
    }
}

struct ToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Body (switches between main canvas and RF planner)
struct AppBodyView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.mode {
            case .rf:
                RFPlannerView()
                    .environmentObject(appState.rfState)
            case .intercom:
                IntercomPlannerView()
                    .environmentObject(appState.intercomState)
            default:
                VStack(spacing: 0) {
                    ToolbarBarView()
                    HStack(spacing: 0) {
                        SidebarView()
                            .frame(width: 210)
                        Divider()
                        // Canvas area: tab bar + canvas/rack/dante view
                        VStack(spacing: 0) {
                            // Always show tab bar so Dante tab is always reachable
                            CanvasTabBar()
                            // Route to the right view
                            if appState.isDanteControllerActive {
                                DanteControllerView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if appState.activeTab.parentRackInstanceId != nil {
                                RackCanvasView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                CanvasView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        InspectorView()
                            .frame(width: 220)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
// MARK: - Previews

private extension AppState {
    static var previewState: AppState {
        let state = AppState()
        return state
    }

    static var previewDarkState: AppState {
        let state = AppState()
        state.isDarkMode = true
        return state
    }

    static var previewExerciseState: AppState {
        let state = AppState()
        state.mode = .exercise
        return state
    }

    static var previewRFState: AppState {
        let state = AppState()
        state.mode = .rf
        return state
    }
}

#Preview("ContentView - Free Build") {
    ContentView()
        .environmentObject(AppState.previewState)
        .frame(width: 1400, height: 900)
}

#Preview("ContentView - Dark Mode") {
    ContentView()
        .environmentObject(AppState.previewDarkState)
        .frame(width: 1400, height: 900)
}

#Preview("ContentView - Exercises") {
    ContentView()
        .environmentObject(AppState.previewExerciseState)
        .frame(width: 1400, height: 900)
}

#Preview("ContentView - RF Planner") {
    ContentView()
        .environmentObject(AppState.previewRFState)
        .frame(width: 1400, height: 900)
}

#Preview("Title Bar") {
    TitleBarView()
        .environmentObject(AppState.previewState)
        .frame(width: 1000, height: 52)
}

#Preview("Toolbar") {
    ToolbarBarView()
        .environmentObject(AppState.previewState)
        .frame(width: 1000, height: 38)
}

#Preview("App Body - Free Build") {
    AppBodyView()
        .environmentObject(AppState.previewState)
        .frame(width: 1400, height: 850)
}

#Preview("App Body - RF Planner") {
    AppBodyView()
        .environmentObject(AppState.previewRFState)
        .frame(width: 1400, height: 850)
}

#Preview("Segmented Control") {
    SegmentedModeControl()
        .environmentObject(AppState.previewState)
        .padding()
        .frame(width: 320, height: 60)
}

#Preview("Toolbar Button") {
    ToolbarButton(icon: "trash", label: "Clear") { }
        .padding()
        .frame(width: 140, height: 60)
}
