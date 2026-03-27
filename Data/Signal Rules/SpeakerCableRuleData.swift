// Data/SpeakerCableRuleData.swift — Multipin speaker cable wiring rules
//
// HOW TO ADD A RULE:
//   Append a new SignalRule entry to the array below, following the existing pattern.
//   Use a unique id string prefixed with "speakon_".

import Foundation

let speakonRules: [SignalRule] = [

    SignalRule(
        id: "speakon_nl4_pinout",
        domain: "speakon",
        title: "Speakon NL4 Pinout",
        detail: "Neutrik Speakon NL4 carries two speaker channels:\n• 1+ / 1− — Channel A (positive / negative)\n• 2+ / 2− — Channel B (positive / negative)\n\nCommon use: bi-amp speakers, or dual-voice-coil subwoofers. Channel A is typically woofer/full-range; Channel B is HF driver.",
        references: ["Neutrik NL4FC datasheet"]
    ),

    SignalRule(
        id: "speakon_nl8_pinout",
        domain: "speakon",
        title: "Speakon NL8 Pinout",
        detail: "Neutrik Speakon NL8 carries four speaker channels:\n• 1+ / 1− — Channel A\n• 2+ / 2− — Channel B\n• 3+ / 3− — Channel C\n• 4+ / 4− — Channel D\n\nUsed in touring arrays for 3- or 4-way active systems and amplifier loop-through wiring.",
        references: ["Neutrik NL8FC datasheet"]
    ),

    SignalRule(
        id: "speakon_xlr5_pinout",
        domain: "speakon",
        title: "XLR-5 Speaker Cable Wiring (2-channel)",
        detail: "XLR-5 is used by some manufacturers (e.g. d&b audiotechnik) for 2-channel amplifier outputs:\n• Pin 1 — Ground / Shield\n• Pin 2 — Channel A positive\n• Pin 3 — Channel A negative\n• Pin 4 — Channel B positive\n• Pin 5 — Channel B negative\n\nWiring varies by manufacturer — always verify with the amplifier's service manual.",
        references: []
    ),

    SignalRule(
        id: "speakon_wire_gauge",
        domain: "speakon",
        title: "Minimum Wire Gauge for Long/High-Power Runs",
        detail: "Speaker cable resistance causes power loss and damping factor reduction. General guidelines:\n• Up to 10 m at ≤1 kW: 2.5 mm² (13 AWG)\n• 10–30 m at ≤1 kW: 4 mm² (11 AWG)\n• 30+ m or high power: 6 mm² (9 AWG) or larger\n\nKeep cable resistance below 5% of nominal load impedance.",
        references: []
    ),

    SignalRule(
        id: "speakon_impedance_matching",
        domain: "speakon",
        title: "Impedance Matching: Protect the Amplifier",
        detail: "Always verify the combined load impedance seen by each amplifier channel:\n• 4 Ω minimum: most touring amplifiers in low-Z mode\n• 8 Ω typical: full-range cabinets\n• 16 Ω: 70 V / 100 V distributed systems\n\nParalleling speakers halves the impedance. Running below the rated minimum causes overheating and clipping distortion.",
        references: []
    ),

    SignalRule(
        id: "speakon_polarity",
        domain: "speakon",
        title: "Phase/Polarity: Positive In → Cone Out",
        detail: "Convention: positive amplifier output (1+) drives the speaker cone forward (compression). Reversed polarity cancels low frequencies when multiple speakers are used together. Always test polarity with a pulse or phone app before flying a system.",
        references: []
    ),

    // ── Add more speaker cable rules below ─────────────────────────────────
]
