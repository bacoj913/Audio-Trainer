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
