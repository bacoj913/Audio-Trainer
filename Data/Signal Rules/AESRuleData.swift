// Data/AESRuleData.swift — AES3 / AES/EBU digital audio rules
//
// HOW TO ADD A RULE:
//   Append a new SignalRule entry to the array below, following the existing pattern.
//   Use a unique id string prefixed with "aes_".

import Foundation

let aesRules: [SignalRule] = [

    SignalRule(
        id: "aes_termination",
        domain: "aes",
        title: "110 Ω Termination at Chain End",
        detail: "The final device in an AES3 daisy chain must present a 110 Ω termination. Most modern equipment includes built-in switchable termination. Unterminated lines cause reflections that corrupt the digital signal.",
        references: ["AES3-2009 §6.2"]
    ),

    SignalRule(
        id: "aes_max_devices",
        domain: "aes",
        title: "Max 16 Devices per Chain",
        detail: "An AES3 point-to-point or daisy-chained run supports up to 16 receivers before signal integrity degrades. Each device load reduces the drive margin.",
        references: ["AES3-2009 §6.4"]
    ),

    SignalRule(
        id: "aes_cable_length",
        domain: "aes",
        title: "Max Cable Length ≈ 100 m (328 ft)",
        detail: "AES3 on balanced 110 Ω cable is specified to 100 m at the standard sample rate. Longer runs require an AES3 distribution amplifier or transformer-coupled repeater.",
        references: ["AES3-2009 §6.3"]
    ),

    SignalRule(
        id: "aes_pinout_xlr",
        domain: "aes",
        title: "XLR Pinout: Pin 2 Hot, Pin 3 Cold, Pin 1 Shield",
        detail: "AES3 uses the same XLR wiring convention as balanced analog audio:\n• Pin 1 — Shield / Ground\n• Pin 2 — Data+ (hot)\n• Pin 3 — Data− (cold)\nMismatched polarity inverts the data differential and may cause loss of lock.",
        references: ["AES3-2009 §4", "IEC 60268-12"]
    ),

    SignalRule(
        id: "aes_impedance",
        domain: "aes",
        title: "Cable Impedance Must Be 110 Ω",
        detail: "AES3 requires 110 Ω characteristic impedance cable (typically Belden 1800F or equivalent). Using standard 75 Ω video coax or low-impedance mic cable introduces reflections. Starquad cable is acceptable for short runs.",
        references: ["AES3-2009 §5"]
    ),

    SignalRule(
        id: "aes_transformer",
        domain: "aes",
        title: "Transformer Balancing Recommended for Long Runs",
        detail: "On runs exceeding 30 m or in electrically noisy environments, transformer-coupled interfaces reject common-mode noise better than active-balanced circuits. Transformers also prevent ground loops.",
        references: ["AES3-2009 §6.5"]
    ),

    // ── Add more AES rules below ────────────────────────────────────────────
]
