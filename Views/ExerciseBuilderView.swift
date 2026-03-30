// Views/ExerciseBuilderView.swift — Custom exercise builder sheet modal

import SwiftUI

struct ExerciseBuilderView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var title: String = ""
    @State private var difficulty: Exercise.Difficulty = .beginner
    @State private var scenario: String = ""
    @State private var requiredText: String = ""     // comma-separated component IDs
    @State private var flowLines: [String] = [""]   // one flow per entry, space-separated IDs
    @State private var hints: [String] = [""]

    @State private var validationError: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Create Exercise")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .overlay(Divider(), alignment: .bottom)

            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Title
                    BuilderField(label: "Title") {
                        TextField("e.g. Basic Vocal Chain", text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .padding(7)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))
                    }

                    // Difficulty
                    BuilderField(label: "Difficulty") {
                        Picker("", selection: $difficulty) {
                            ForEach(Exercise.Difficulty.allCases, id: \.self) { d in
                                Text(d.displayName).tag(d)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }

                    // Scenario
                    BuilderField(label: "Scenario Description") {
                        TextEditor(text: $scenario)
                            .font(.system(size: 12))
                            .frame(minHeight: 60, maxHeight: 100)
                            .padding(6)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))
                    }

                    // Required Components
                    BuilderField(
                        label: "Required Components",
                        caption: "Comma-separated component IDs, e.g. microphone, mixer, speaker"
                    ) {
                        TextField("microphone, preamp, speaker", text: $requiredText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(7)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))
                    }

                    // Valid Signal Flows
                    BuilderField(
                        label: "Valid Signal Flows",
                        caption: "Each line is one valid flow: space-separated component IDs in signal order"
                    ) {
                        VStack(spacing: 6) {
                            ForEach(flowLines.indices, id: \.self) { idx in
                                HStack(spacing: 6) {
                                    TextField("microphone preamp mixer speaker", text: $flowLines[idx])
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 12, design: .monospaced))
                                        .padding(7)
                                        .background(Color(nsColor: .controlBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                                    Button {
                                        flowLines.remove(at: idx)
                                        if flowLines.isEmpty { flowLines = [""] }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(flowLines.count == 1)
                                    .opacity(flowLines.count == 1 ? 0.3 : 1)
                                }
                            }

                            Button {
                                flowLines.append("")
                            } label: {
                                Label("Add Flow", systemImage: "plus")
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Hints
                    BuilderField(
                        label: "Hints",
                        caption: "Each entry is one hint shown progressively"
                    ) {
                        VStack(spacing: 6) {
                            ForEach(hints.indices, id: \.self) { idx in
                                HStack(spacing: 6) {
                                    TextField("Hint \(idx + 1)", text: $hints[idx])
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 12))
                                        .padding(7)
                                        .background(Color(nsColor: .controlBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                                    Button {
                                        hints.remove(at: idx)
                                        if hints.isEmpty { hints = [""] }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(hints.count == 1)
                                    .opacity(hints.count == 1 ? 0.3 : 1)
                                }
                            }

                            Button {
                                hints.append("")
                            } label: {
                                Label("Add Hint", systemImage: "plus")
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Validation error
                    if let err = validationError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            Text(err)
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(20)
            }

            // Footer
            Divider()
            HStack(spacing: 10) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(TertiaryButtonStyle())

                Spacer()

                Button("Save Exercise") {
                    saveExercise()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 160)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 520, height: 640)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Save
    private func saveExercise() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            validationError = "Title is required."
            return
        }

        let reqComponents = requiredText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let flows: [[String]] = flowLines
            .map { $0.split(separator: " ").map(String.init) }
            .filter { !$0.isEmpty }

        guard !flows.isEmpty else {
            validationError = "At least one valid signal flow is required."
            return
        }

        let filteredHints = hints.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let newId = "custom-\(UUID().uuidString.prefix(8).lowercased())"
        let ex = Exercise(
            id: newId,
            title: trimmedTitle,
            difficulty: difficulty,
            scenario: scenario.trimmingCharacters(in: .whitespaces),
            required: reqComponents,
            validFlows: flows,
            hints: filteredHints,
            isCustom: true
        )

        appState.exercises.append(ex)
        appState.persistCustomExercises()
        appState.exerciseIndex = appState.exercises.count - 1
        appState.mode = .exercise
        dismiss()
    }
}

// MARK: - Builder Field Helper
struct BuilderField<Content: View>: View {
    let label: String
    var caption: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            content

            if let cap = caption {
                Text(cap)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
}

// MARK: - Previews

#Preview("Exercise Builder Sheet") {
    ExerciseBuilderView()
        .environmentObject(AppState())
        .frame(width: 600, height: 700)
}
