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
            CommandGroup(replacing: .newItem) {}
        }
    }
}
