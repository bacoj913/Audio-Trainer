// AudioSignalFlowTrainerApp.swift
// Audio Signal Flow Trainer — Swift/SwiftUI rewrite

import SwiftUI

@main
struct AudioSignalFlowTrainerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 780)
        .commands {
            // MARK: File menu
            CommandGroup(replacing: .newItem) {
                Button("New") {
                    AppState.shared?.newProject()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Open…") {
                    AppState.shared?.openProject()
                }
                .keyboardShortcut("o", modifiers: .command)

                Divider()

                Button("Save") {
                    AppState.shared?.saveProject()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Save As…") {
                    AppState.shared?.saveProjectAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }

            // MARK: Edit menu additions
            CommandGroup(after: .pasteboard) {
                Divider()
                Button("Clear Canvas") {
                    AppState.shared?.newProject()
                }
            }
        }
    }
}
