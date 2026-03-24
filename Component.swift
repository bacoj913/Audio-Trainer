// Models/Component.swift — Component data model

import SwiftUI

// MARK: - Port Info
struct PortInfo {
    var inputs: [String]   // named physical input ports, e.g. "XLR In 1"
    var outputs: [String]  // named physical output ports, e.g. "XLR Out 1"

    static let empty = PortInfo(inputs: [], outputs: [])
}

// MARK: - Component
struct Component {
    let id: String
    let name: String
    let iconName: String       // key into ComponentIcons
    let category: String
    let manufacturer: String
    let model: String
    let inputs: [String]       // signal types: "mic", "line", "rf", etc.
    let outputs: [String]
    let ports: PortInfo        // named physical I/O
    let desc: String
    let level: String
    var isRack: Bool = false
    var rackUnits: Int = 0
    var comingSoon: Bool = false

    // A placeholder for nil-safety
    static let placeholder = Component(
        id: "_", name: "Unknown", iconName: "mic",
        category: "", manufacturer: "", model: "",
        inputs: [], outputs: [], ports: .empty,
        desc: "", level: ""
    )
}

// MARK: - Category Order
let categoryOrder: [String] = [
    "Sources", "Processing", "Effects", "Routing", "Recording",
    "Output", "Wireless Mic", "Wireless IEM", "Antennas",
    "Networking", "Stage Boxes", "Racks", "Power", "2 Wire Comms", "4 Wire Comms",
    "Wireless Comms", "Comm Matrices"
]

// MARK: - Category accent colors (for node stripe)
extension Color {
    static func categoryColor(_ category: String) -> Color {
        switch category {
        case "Sources":      return Color(red: 0.20, green: 0.78, blue: 0.35) // green
        case "Processing":   return Color(red: 0.00, green: 0.48, blue: 1.00) // blue
        case "Effects":      return Color(red: 0.60, green: 0.36, blue: 1.00) // purple
        case "Routing":      return Color(red: 1.00, green: 0.62, blue: 0.04) // orange
        case "Recording":    return Color(red: 1.00, green: 0.27, blue: 0.23) // red
        case "Output":       return Color(red: 0.99, green: 0.23, blue: 0.49) // pink
        case "Wireless Mic": return Color(red: 0.00, green: 0.73, blue: 0.91) // cyan
        case "Wireless IEM": return Color(red: 0.37, green: 0.82, blue: 0.75) // teal
        case "Antennas":     return Color(red: 0.55, green: 0.55, blue: 0.58) // gray
        case "Networking":   return Color(red: 0.24, green: 0.67, blue: 0.50) // dark teal
        case "Stage Boxes":  return Color(red: 0.64, green: 0.44, blue: 0.28) // brown
        case "Racks":        return Color(red: 0.36, green: 0.36, blue: 0.38) // dark gray
        case "Power":        return Color(red: 1.00, green: 0.60, blue: 0.00) // amber
        case "2 Wire Comms": return Color(red: 0.00, green: 0.48, blue: 1.00) // dark blue
        case "4 Wire Comms": return Color(red: 0.11, green: 0.33, blue: 0.68)
        case "Wireless Comms": return Color(red: 0.00, green: 0.73, blue: 0.91)
        case "Comm Matrices": return Color(red: 0.00, green: 0.48, blue: 1.00) 
        default:             return Color.gray
        }
    }
}
