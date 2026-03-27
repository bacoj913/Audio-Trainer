// Data/IntercomRuleData.swift — Intercom system signal rules
//
// HOW TO ADD A RULE:
//   Append a new SignalRule entry to the array below, following the existing pattern.
//   Use a unique id string prefixed with "intercom_".

import Foundation

let intercomRules: [SignalRule] = [

    SignalRule(
        id: "intercom_2w_vs_4w",
        domain: "intercom",
        title: "2-Wire vs. 4-Wire Systems",
        detail: "2-wire (party line): all stations share a single pair carrying both send and receive audio simultaneously. All stations hear each other at all times.\n\n4-wire (point-to-point / matrix): separate pairs for send and receive. Required for matrix intercoms and switched routing. Provides better audio quality and isolation.",
        references: []
    ),

    SignalRule(
        id: "intercom_partyline_power",
        domain: "intercom",
        title: "Party Line: ~30 V DC Bus Power",
        detail: "Clear-Com and compatible 2-wire party line systems supply approximately 30 V DC on the intercom cable to power beltpacks. Do not connect party line outputs directly to 4-wire inputs — the DC voltage will damage equipment without isolation.",
        references: ["Clear-Com RS-501 spec"]
    ),

    SignalRule(
        id: "intercom_xlr_convention",
        domain: "intercom",
        title: "XLR-3 Wiring for 2-Wire Party Line",
        detail: "Standard Clear-Com / RTS 2-wire party line XLR-3 pinout:\n• Pin 1 — Shield / Ground\n• Pin 2 — Audio + DC power\n• Pin 3 — Return\n\nNote: some manufacturers use XLR-4 or XLR-5 for 4-wire; always verify the frame's wiring guide.",
        references: []
    ),

    SignalRule(
        id: "intercom_max_beltpacks",
        domain: "intercom",
        title: "Party Line: Typical Max ~10 Beltpacks per Channel",
        detail: "A single party line channel can drive a limited number of beltpacks before audio level or DC power degrades. Typical limit is ~10 beltpacks per channel at standard line length. Use a party line amplifier or split the channel for larger systems.",
        references: []
    ),

    SignalRule(
        id: "intercom_4w_impedance",
        domain: "intercom",
        title: "4-Wire Input/Output Levels and Impedance",
        detail: "4-wire intercom ports are typically balanced line level (+4 dBu nominal). Input impedance is usually ≥10 kΩ; output impedance ≤200 Ω. Match levels carefully when interfacing with broadcast consoles or matrix systems.",
        references: []
    ),

    // ── Add more intercom rules below ──────────────────────────────────────
]
