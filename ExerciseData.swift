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
