// Models/SignalRules.swift — Signal type rule framework
//
// HOW TO ADD RULES:
//   1. Open the matching Data/ rule file (AESRuleData.swift, IntercomRuleData.swift,
//      or SpeakerCableRuleData.swift).
//   2. Append a new SignalRule(...) entry to the array.
//   3. The inspector picks it up automatically — no changes needed here.
//
// To add a new DOMAIN (e.g. "dante", "madi"):
//   1. Create Data/<Domain>RuleData.swift following the existing pattern.
//   2. Add the new array to SignalRules.list below.
//   3. Add a case to the `RuleDomain` enum below.

import SwiftUI

// MARK: - Rule domain labels shown in the inspector picker
enum RuleDomain: String, CaseIterable, Identifiable {
    case aes         = "aes"
    case intercom    = "intercom"
    case speakon     = "speakon"
    case bindingPost = "bindingPost"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aes:         return "AES"
        case .intercom:    return "Intercom"
        case .speakon:     return "Speaker Cable"
        case .bindingPost: return "Binding Posts"
        }
    }

    var color: Color {
        switch self {
        case .aes:         return Color(.systemPurple)
        case .intercom:    return Color(.systemTeal)
        case .speakon:     return Color(.black)
        case .bindingPost: return Color(.systemOrange)
        }
    }
}

// MARK: - Rule model
struct SignalRule: Identifiable {
    /// Unique identifier — use snake_case, e.g. "aes_termination"
    let id: String
    /// Must match a RuleDomain.rawValue: "aes" | "intercom" | "speakon" | "bindingPost"
    let domain: String
    /// Short headline shown collapsed
    let title: String
    /// Full explanation shown when expanded
    let detail: String
    /// Optional spec references, e.g. ["AES3-2009", "IEC 60268-3"]
    let references: [String]
    /// Optional closure that validates a connection in exercise mode.
    /// Return true = rule satisfied, false = violation, nil = not applicable.
    let exerciseValidation: ((NodeConnection, AppState) -> Bool?)?

    init(
        id: String,
        domain: String,
        title: String,
        detail: String,
        references: [String] = [],
        exerciseValidation: ((NodeConnection, AppState) -> Bool?)? = nil
    ) {
        self.id                 = id
        self.domain             = domain
        self.title              = title
        self.detail             = detail
        self.references         = references
        self.exerciseValidation = exerciseValidation
    }
}

// MARK: - Exercise rule validation helper
extension SignalRules {
    /// Run all domain rules against every connection and return violation descriptions.
    static func violations(for connections: [NodeConnection], appState: AppState) -> [String] {
        var result: [String] = []
        for conn in connections {
            for rule in list {
                if let validate = rule.exerciseValidation,
                   let passed = validate(conn, appState),
                   !passed {
                    let fromInst = appState.instances.first { $0.id == conn.fromId }
                    let name = Components.all[fromInst?.type ?? ""]?.name ?? "device"
                    result.append("[\(rule.domain)] \(rule.title) — \(name) output \(conn.fromPortIndex + 1)")
                }
            }
        }
        return result
    }
}

// MARK: - Central registry
enum SignalRules {
    /// All rules keyed by domain string for O(1) lookup.
    static let all: [String: [SignalRule]] = {
        var d: [String: [SignalRule]] = [:]
        for rule in list {
            d[rule.domain, default: []].append(rule)
        }
        return d
    }()

    /// Master list — add new domain arrays here.
    static let list: [SignalRule] = aesRules + intercomRules + speakonRules + bindingPostRules
}
