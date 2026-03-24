// Models/ExerciseData.swift — Built-in exercises

import Foundation

let builtInExercises: [Exercise] = [
    Exercise(
        id: "basic-pa",
        title: "Basic PA System",
        difficulty: .beginner,
        scenario: "A vocalist needs to perform at a small venue. Connect the signal chain so their voice reaches the audience through the PA speakers.",
        required: ["microphone", "mixer", "power_amp", "speakers"],
        validFlows: [
            ["microphone", "mixer", "power_amp", "speakers"],
        ],
        hints: [
            "Start with the sound source: what captures the vocalist's voice?",
            "The mixer lets you control volume and EQ before sending to the power amp.",
            "Flow: Microphone → Mixer → Power Amplifier → Speakers",
        ]
    ),

    Exercise(
        id: "recording-vocal",
        title: "Studio Vocal Recording",
        difficulty: .beginner,
        scenario: "Record a clean vocal take. Build the signal chain from the microphone to the audio interface for capture into a DAW.",
        required: ["microphone", "preamp", "audio_interface"],
        optional: ["compressor", "equalizer"],
        validFlows: [
            ["microphone", "preamp", "audio_interface"],
            ["microphone", "preamp", "compressor", "audio_interface"],
            ["microphone", "preamp", "equalizer", "audio_interface"],
            ["microphone", "preamp", "equalizer", "compressor", "audio_interface"],
            ["microphone", "preamp", "compressor", "equalizer", "audio_interface"],
        ],
        hints: [
            "The microphone outputs a low-level mic signal that needs boosting first.",
            "A preamp amplifies the mic signal to usable line level.",
            "The audio interface converts the analog signal to digital for recording.",
        ]
    ),

    Exercise(
        id: "guitar-di",
        title: "Guitar to PA via DI",
        difficulty: .intermediate,
        scenario: "An acoustic guitarist wants to connect to the venue's PA system. Use a DI box to properly interface the guitar to the mixer.",
        required: ["guitar", "di_box", "mixer", "power_amp", "speakers"],
        validFlows: [
            ["guitar", "di_box", "mixer", "power_amp", "speakers"],
        ],
        hints: [
            "A guitar outputs an unbalanced instrument-level signal — incompatible directly with most mixers.",
            "A DI (Direct Injection) box converts the unbalanced instrument signal to a balanced XLR signal.",
            "Flow: Guitar → DI Box → Mixer → Power Amp → Speakers",
        ]
    ),

    Exercise(
        id: "guitar-rig",
        title: "Electric Guitar Live Rig",
        difficulty: .intermediate,
        scenario: "Set up an electric guitarist's live rig with effects pedals going through a DI box to the PA system.",
        required: ["guitar", "effects_pedal", "di_box", "mixer", "power_amp", "speakers"],
        validFlows: [
            ["guitar", "effects_pedal", "di_box", "mixer", "power_amp", "speakers"],
        ],
        hints: [
            "Effects pedals work at instrument level — place them before the DI box.",
            "Guitar signals stay at instrument level through the pedal chain.",
            "The DI box interfaces the instrument-level signal to the mixer's mic input.",
        ]
    ),

    Exercise(
        id: "studio-chain",
        title: "Professional Studio Chain",
        difficulty: .advanced,
        scenario: "Build a professional recording chain with full dynamics and EQ processing. Both EQ→Compressor and Compressor→EQ orderings are valid — each produces a different sound.",
        required: ["microphone", "preamp", "compressor", "equalizer", "audio_interface"],
        optional: ["gate", "effects"],
        validFlows: [
            ["microphone", "preamp", "compressor", "equalizer", "audio_interface"],
            ["microphone", "preamp", "equalizer", "compressor", "audio_interface"],
            ["microphone", "preamp", "gate", "compressor", "equalizer", "audio_interface"],
            ["microphone", "preamp", "gate", "equalizer", "compressor", "audio_interface"],
            ["microphone", "preamp", "compressor", "equalizer", "effects", "audio_interface"],
        ],
        hints: [
            "EQ before Comp: shape the tone first, then control dynamics.",
            "Comp before EQ: tame peaks first, then shape the tone of the compressed signal.",
            "A gate (before compressor) can remove noise before dynamic processing.",
        ]
    ),
]
#if DEBUG
import SwiftUI

// MARK: - Preview Helpers

private struct BuiltInExerciseCard: View {
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
                    .background(difficultyColor.opacity(0.15))
                    .foregroundStyle(difficultyColor)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Required")
                    .font(.subheadline.weight(.semibold))
                Text(exercise.required.joined(separator: " → "))
                    .font(.caption)
            }

            if !exercise.optional.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Optional")
                        .font(.subheadline.weight(.semibold))
                    Text(exercise.optional.joined(separator: ", "))
                        .font(.caption)
                }
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

                ForEach(Array(exercise.hints.enumerated()), id: \.offset) { _, hint in
                    Text("• \(hint)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("ID: \(exercise.id)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(exercise.isCustom ? "Custom" : "Built-in")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 440, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .beginner: .green
        case .intermediate: .orange
        case .advanced: .red
        }
    }
}

private struct BuiltInExerciseListPreview: View {
    let title: String
    let exercises: [Exercise]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal)

                Text("Total: \(exercises.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ForEach(exercises) { exercise in
                    BuiltInExerciseCard(exercise: exercise)
                }
            }
            .padding(.vertical)
        }
        .frame(width: 500, height: 760)
    }
}

private struct BuiltInExerciseSummaryPreview: View {
    private var grouped: [(Exercise.Difficulty, [Exercise])] {
        Exercise.Difficulty.allCases.map { difficulty in
            (difficulty, builtInExercises.filter { $0.difficulty == difficulty })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Built-in Exercise Summary")
                .font(.headline)

            Text("Total Exercises: \(builtInExercises.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(grouped, id: \.0) { difficulty, exercises in
                HStack {
                    Circle()
                        .fill(color(for: difficulty))
                        .frame(width: 12, height: 12)

                    Text(difficulty.displayName)
                        .font(.system(size: 14, weight: .semibold))

                    Spacer()

                    Text("\(exercises.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 280, alignment: .leading)
    }

    private func color(for difficulty: Exercise.Difficulty) -> Color {
        switch difficulty {
        case .beginner: .green
        case .intermediate: .orange
        case .advanced: .red
        }
    }
}

private extension Array where Element == Exercise {
    static var previewBeginner: [Exercise] {
        builtInExercises.filter { $0.difficulty == .beginner }
    }

    static var previewIntermediate: [Exercise] {
        builtInExercises.filter { $0.difficulty == .intermediate }
    }

    static var previewAdvanced: [Exercise] {
        builtInExercises.filter { $0.difficulty == .advanced }
    }
}

// MARK: - Previews

#Preview("Exercise Summary") {
    BuiltInExerciseSummaryPreview()
}

#Preview("All Built-in Exercises") {
    BuiltInExerciseListPreview(
        title: "All Built-in Exercises",
        exercises: builtInExercises
    )
}

#Preview("Beginner Exercises") {
    BuiltInExerciseListPreview(
        title: "Beginner Exercises",
        exercises: .previewBeginner
    )
}

#Preview("Intermediate Exercises") {
    BuiltInExerciseListPreview(
        title: "Intermediate Exercises",
        exercises: .previewIntermediate
    )
}

#Preview("Advanced Exercises") {
    BuiltInExerciseListPreview(
        title: "Advanced Exercises",
        exercises: .previewAdvanced
    )
}
#endif
