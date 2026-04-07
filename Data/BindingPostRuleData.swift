// Data/BindingPostRuleData.swift — Rules for banana jack binding post connections

import Foundation

let bindingPostRules: [SignalRule] = [

    SignalRule(
        id: "bp_ground_tab_direction",
        domain: "bindingPost",
        title: "Banana Jack Ground Tab Direction",
        detail: """
        Binding post amplifiers expect the banana plug inserted in a specific orientation \
        depending on the module loaded. The colored ground tab on the banana jack must face \
        the correct direction for the module's wiring convention. \
        PA and fill modules typically use ground-tab-left (standard), while monitor modules \
        may require ground-tab-right depending on the amplifier's wiring. \
        Inserting the banana backwards will not physically break anything, but it indicates \
        incorrect cable seating practice and can cause phase issues.
        """,
        references: ["Lab.gruppen PLM Series User Guide"],
        exerciseValidation: { conn, appState in
            // Only applies to binding post outputs
            let fromInst = appState.instances.first { $0.id == conn.fromId }
            guard let fromInst,
                  let comp = Components.all[fromInst.type],
                  comp.outputs.indices.contains(conn.fromPortIndex),
                  comp.outputs[conn.fromPortIndex] == "bindingpost"
            else { return nil }  // not a binding post — rule doesn't apply

            guard let preset = fromInst.selectedPreset,
                  let expected = comp.presetBananaOrientations[preset]
            else { return nil }  // no preset set — can't validate

            // Orientation stored on the instance via the BananaOrientationPicker
            let actual = fromInst.bananaOrientations[conn.fromPortIndex]
            guard let actual else { return nil }  // not yet set

            return actual == expected
        }
    ),

    SignalRule(
        id: "bp_polarity",
        domain: "bindingPost",
        title: "Binding Post Polarity",
        detail: """
        Red binding posts are positive (+), black binding posts are negative (−/ground). \
        Connect the positive (red/tip) banana plug to the red post and the negative (black/sleeve) \
        to the black post. Reversed polarity causes speaker phase inversion which degrades \
        summation between speaker arrays and can cause cancellation in the coverage area.
        """,
        references: ["IEC 60268-3", "AES2-2012"]
    ),

    SignalRule(
        id: "bp_insertion_depth",
        domain: "bindingPost",
        title: "Full Banana Insertion",
        detail: """
        Banana plugs must be fully seated in the binding post. A partially inserted plug creates \
        a high-resistance joint that can arc under high power, generating heat and potentially \
        damaging the amplifier output stage or causing intermittent signal loss. \
        Listen for crackling or distortion which can indicate a poor contact.
        """,
        references: []
    ),
]
