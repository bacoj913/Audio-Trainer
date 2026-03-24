// Models/Exercise.swift — Exercise model (Codable for UserDefaults persistence)

import Foundation

struct Exercise: Identifiable, Codable {
    var id: String
    var title: String
    var difficulty: Difficulty
    var scenario: String
    var required: [String]          // component type IDs
    var optional: [String]          // optional component type IDs
    var validFlows: [[String]]       // each flow is an ordered list of component type IDs
    var hints: [String]
    var isCustom: Bool

    init(id: String, title: String, difficulty: Difficulty, scenario: String,
         required: [String], optional: [String] = [], validFlows: [[String]],
         hints: [String], isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.scenario = scenario
        self.required = required
        self.optional = optional
        self.validFlows = validFlows
        self.hints = hints
        self.isCustom = isCustom
    }

    enum Difficulty: String, Codable, CaseIterable {
        case beginner, intermediate, advanced

        var displayName: String { rawValue.capitalized }

        var color: String {
            switch self {
            case .beginner:     return "green"
            case .intermediate: return "orange"
            case .advanced:     return "red"
            }
        }
    }
}
#if DEBUG
import SwiftUI

// MARK: - Preview Helpers

private struct DifficultyPreviewRow: View {
    let difficulty: Exercise.Difficulty

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color(for: difficulty))
                .frame(width: 14, height: 14)

            Text(difficulty.displayName)
                .font(.system(size: 14, weight: .semibold))

            Spacer()

            Text(difficulty.color)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func color(for difficulty: Exercise.Difficulty) -> Color {
        switch difficulty {
        case .beginner: .green
        case .intermediate: .orange
        case .advanced: .red
        }
    }
}

private struct ExercisePreviewCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.title)
                        .font(.headline)

                    Text(exercise.scenario)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(exercise.difficulty.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(pillColor.opacity(0.15))
                    .foregroundStyle(pillColor)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Required")
                    .font(.subheadline.weight(.semibold))
                Text(exercise.required.isEmpty ? "None" : exercise.required.joined(separator: ", "))
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Optional")
                    .font(.subheadline.weight(.semibold))
                Text(exercise.optional.isEmpty ? "None" : exercise.optional.joined(separator: ", "))
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Valid Flows")
                    .font(.subheadline.weight(.semibold))

                ForEach(Array(exercise.validFlows.enumerated()), id: \.offset) { index, flow in
                    Text("\(index + 1). " + flow.joined(separator: " → "))
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Hints")
                    .font(.subheadline.weight(.semibold))

                ForEach(Array(exercise.hints.enumerated()), id: \.offset) { index, hint in
                    Text("• \(hint)")
                        .font(.caption)
                }
            }

            HStack {
                Label(exercise.isCustom ? "Custom" : "Built-in", systemImage: exercise.isCustom ? "person.crop.rectangle" : "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("ID: \(exercise.id)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 420, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
        .padding()
    }

    private var pillColor: Color {
        switch exercise.difficulty {
        case .beginner: .green
        case .intermediate: .orange
        case .advanced: .red
        }
    }
}

// MARK: - Sample Data

private extension Exercise {
    static let previewBeginner = Exercise(
        id: "preview_beginner",
        title: "Basic Vocal Chain",
        difficulty: .beginner,
        scenario: "Build a simple signal flow from a vocal microphone to a powered speaker.",
        required: ["mic", "console", "speaker"],
        optional: ["eq", "compressor"],
        validFlows: [
            ["mic", "console", "speaker"],
            ["mic", "console", "eq", "speaker"]
        ],
        hints: [
            "Start with the source.",
            "Route the signal through the mixer before the output.",
            "Optional processors can sit between console and speaker."
        ],
        isCustom: false
    )

    static let previewAdvanced = Exercise(
        id: "preview_advanced",
        title: "Wireless Monitor System",
        difficulty: .advanced,
        scenario: "Assemble a monitor path using a wireless IEM transmitter fed from the console.",
        required: ["console", "iem_tx", "bodypack", "iem"],
        optional: ["antenna_combiner", "splitter"],
        validFlows: [
            ["console", "iem_tx", "bodypack", "iem"],
            ["console", "antenna_combiner", "iem_tx", "bodypack", "iem"]
        ],
        hints: [
            "The console is the source of the monitor send.",
            "The bodypack receives from the transmitter.",
            "Support RF accessories are not always required."
        ],
        isCustom: true
    )
}

// MARK: - Previews

#Preview("Difficulties") {
    VStack(spacing: 8) {
        ForEach(Exercise.Difficulty.allCases, id: \.self) { difficulty in
            DifficultyPreviewRow(difficulty: difficulty)
        }
    }
    .padding()
    .frame(width: 240)
}

#Preview("Exercise - Beginner") {
    ExercisePreviewCard(exercise: .previewBeginner)
}

#Preview("Exercise - Advanced") {
    ExercisePreviewCard(exercise: .previewAdvanced)
}
#endif
