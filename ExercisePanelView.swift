// Views/ExercisePanelView.swift — Exercise mode right panel

import SwiftUI
import UniformTypeIdentifiers

struct ExercisePanelView: View {
    @EnvironmentObject var appState: AppState
    @State private var resultMsg: String? = nil
    @State private var resultSuccess: Bool = false
    @State private var shownHint: String? = nil
    @State private var showingImporter = false
    @State private var showingExporter = false

    private var ex: Exercise { appState.currentExercise }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Navigation bar
            HStack {
                Button { appState.prevExercise(); clear() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(appState.exerciseIndex > 0 ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(appState.exerciseIndex == 0)

                Spacer()

                Text("\(appState.exerciseIndex + 1) of \(appState.exercises.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Button { appState.nextExercise(); clear() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(appState.exerciseIndex < appState.exercises.count - 1 ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(appState.exerciseIndex >= appState.exercises.count - 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(Divider(), alignment: .bottom)

            // Difficulty + Title + Scenario
            InspectorSection(title: "") {
                VStack(alignment: .leading, spacing: 6) {
                    DifficultyPill(difficulty: ex.difficulty)
                    Text(ex.title)
                        .font(.system(size: 13, weight: .semibold))
                    Text(ex.scenario)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Required components checklist
            InspectorSection(title: "REQUIRED COMPONENTS") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(ex.required, id: \.self) { type in
                        let comp = Components.all[type]
                        let done = appState.placedTypes.contains(type)
                        HStack(spacing: 6) {
                            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 13))
                                .foregroundColor(done ? .green : .secondary)
                            if let comp {
                                ComponentIcon(name: comp.iconName)
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(.secondary)
                            }
                            Text(comp?.name ?? type)
                                .font(.system(size: 11))
                                .foregroundColor(done ? .primary : .secondary)
                        }
                    }
                }
            }

            // Current connections
            InspectorSection(title: "CURRENT CONNECTIONS") {
                if appState.connections.isEmpty {
                    Text("No connections yet")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(appState.connections) { conn in
                            if let fromInst = appState.instances.first(where: { $0.id == conn.fromId }),
                               let toInst   = appState.instances.first(where: { $0.id == conn.toId }),
                               let fromComp = Components.all[fromInst.type],
                               let toComp   = Components.all[toInst.type] {
                                HStack(spacing: 4) {
                                    Text(fromComp.name)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 9))
                                        .foregroundColor(.blue)
                                    Text(toComp.name)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                }
                                .foregroundColor(.primary.opacity(0.75))
                            }
                        }
                    }
                }
            }

            // Action buttons
            InspectorSection(title: "") {
                VStack(spacing: 6) {
                    Button("Check Signal Flow") {
                        let result = appState.checkFlow()
                        resultSuccess = result.success
                        resultMsg = result.message
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Show Hint") {
                        shownHint = appState.nextHint()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Reset Exercise") {
                        appState.resetExercise()
                        clear()
                    }
                    .buttonStyle(TertiaryButtonStyle())
                }
            }

            // Hint box
            if let hint = shownHint {
                InspectorSection(title: "") {
                    HStack(alignment: .top, spacing: 6) {
                        Text("💡")
                        Text(hint)
                            .font(.system(size: 11))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }

            // Result box
            if let msg = resultMsg {
                InspectorSection(title: "") {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: resultSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(resultSuccess ? .green : .red)
                        Text(msg)
                            .font(.system(size: 11))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)
                    .background((resultSuccess ? Color.green : Color.red).opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }

            // Exercise Tools
            InspectorSection(title: "EXERCISE TOOLS") {
                VStack(spacing: 5) {
                    Button("+ Create Exercise") { appState.showExerciseBuilder = true }
                        .buttonStyle(SecondaryButtonStyle())

                    Button("Export Exercises") { exportExercises() }
                        .buttonStyle(SecondaryButtonStyle())

                    Button("Import Exercises") { showingImporter = true }
                        .buttonStyle(SecondaryButtonStyle())
                        .fileImporter(
                            isPresented: $showingImporter,
                            allowedContentTypes: [.json],
                            allowsMultipleSelection: false
                        ) { result in
                            importExercises(result: result)
                        }
                }
            }

            Spacer(minLength: 12)
        }
    }

    private func clear() {
        resultMsg = nil
        shownHint = nil
    }

    private func exportExercises() {
        let custom = appState.exercises.filter { $0.isCustom }
        guard !custom.isEmpty,
              let data = try? JSONEncoder().encode(custom) else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "signal-flow-exercises.json"
        panel.allowedContentTypes = [.json]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }

    private func importExercises(result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first,
              let data = try? Data(contentsOf: url),
              let imported = try? JSONDecoder().decode([Exercise].self, from: data) else { return }
        var added = 0
        for var ex in imported {
            ex.isCustom = true
            if !appState.exercises.contains(where: { $0.id == ex.id }) {
                appState.exercises.append(ex)
                added += 1
            }
        }
        appState.persistCustomExercises()
        if added > 0 {
            appState.exerciseIndex = appState.exercises.count - 1
        }
    }
}

// MARK: - Difficulty Pill
struct DifficultyPill: View {
    let difficulty: Exercise.Difficulty

    var body: some View {
        Text(difficulty.displayName)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(pillColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(pillColor.opacity(0.12))
            .clipShape(Capsule())
    }

    var pillColor: Color {
        switch difficulty {
        case .beginner:     return .green
        case .intermediate: return .orange
        case .advanced:     return .red
        }
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.primary.opacity(0.15), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
// MARK: - Previews

private extension AppState {
    static var exercisePanelPreviewState: AppState {
        let state = AppState()
        return state
    }
}

#Preview("Exercise Panel") {
    ExercisePanelView()
        .environmentObject(AppState.exercisePanelPreviewState)
        .frame(width: 280, height: 760)
}

#Preview("Difficulty Pill - Beginner") {
    DifficultyPill(difficulty: .beginner)
        .padding()
        .frame(width: 140, height: 60)
}

#Preview("Difficulty Pill - Intermediate") {
    DifficultyPill(difficulty: .intermediate)
        .padding()
        .frame(width: 160, height: 60)
}

#Preview("Difficulty Pill - Advanced") {
    DifficultyPill(difficulty: .advanced)
        .padding()
        .frame(width: 140, height: 60)
}

#Preview("Button Styles") {
    VStack(spacing: 10) {
        Button("Check Signal Flow") { }
            .buttonStyle(PrimaryButtonStyle())

        Button("Show Hint") { }
            .buttonStyle(SecondaryButtonStyle())

        Button("Reset Exercise") { }
            .buttonStyle(TertiaryButtonStyle())
    }
    .padding()
    .frame(width: 260, height: 160)
}
