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
    "Sources", "Processing", "Patching", "Consoles",
    "Amplifiers", "Wireless Mics", "Wireless IEMs", "Antennas",
    "Networking", "Stage Racks", "Stage Boxes", "Racks", "Speakers", "Power", "Intercom"
]

// MARK: - Signal type colors (for port dots and connection wires)
extension Color {
    static func signalTypeColor(_ type: String) -> Color {
        switch type {
        case "mic":        return Color(red: 0.20, green: 0.78, blue: 0.35) // green
        case "line":       return Color(red: 0.00, green: 0.48, blue: 1.00) // blue
        case "instrument": return Color(red: 1.00, green: 0.62, blue: 0.04) // orange
        case "speaker":    return Color(red: 1.00, green: 0.27, blue: 0.23) // red
        case "rf":         return Color(red: 0.00, green: 0.73, blue: 0.91) // cyan
        default:           return Color(red: 0.55, green: 0.55, blue: 0.58) // gray
        }
    }
}

// MARK: - Category accent colors (for node stripe)
extension Color {
    static func categoryColor(_ category: String) -> Color {
        switch category {
        case "Sources":      return Color(.systemCyan)
        case "Processing":   return Color(.systemPurple)
        case "Patching":     return Color(.systemYellow)
        case "Consoles":     return Color(.systemMint)
        case "Amplifiers":   return Color(.systemBlue)
        case "Wireless Mics": return Color(.systemCyan)
        case "Wireless IEMs": return Color(.systemIndigo)
        case "Antennas":     return Color(.systemGray)
        case "Networking":   return Color(.systemGreen)
        case "Stage Racks":  return Color(.systemYellow)
        case "Stage Boxes":  return Color(.systemBrown)
        case "Racks":        return Color(.systemGray)
        case "Speakers":     return Color(.systemPink)
        case "Power":        return Color(.systemOrange)
        case "Intercom":     return Color(.systemTeal) // dark blue
        default:             return Color.gray
        }
    }
}
// MARK: - Preview Helpers

private struct CategoryColorPreviewRow: View {
    let category: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.categoryColor(category))
                .frame(width: 36, height: 24)

            Text(category)
                .font(.system(size: 13, weight: .medium))

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}

private struct ComponentPreviewCard: View {
    let component: Component

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.categoryColor(component.category))
                    .frame(width: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(component.name)
                        .font(.headline)

                    Text("\(component.manufacturer) \(component.model)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text("Category: \(component.category)")
                .font(.caption)

            Text("Signal Inputs: \(component.inputs.joined(separator: ", "))")
                .font(.caption)

            Text("Signal Outputs: \(component.outputs.joined(separator: ", "))")
                .font(.caption)

            Text("Physical Inputs: \(component.ports.inputs.joined(separator: ", "))")
                .font(.caption)

            Text("Physical Outputs: \(component.ports.outputs.joined(separator: ", "))")
                .font(.caption)

            Text(component.desc.isEmpty ? "No description" : component.desc)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding()
    }
}

// MARK: - Previews

#Preview("Category Colors") {
    ScrollView {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(categoryOrder, id: \.self) { category in
                CategoryColorPreviewRow(category: category)
            }
        }
        .padding()
        .frame(width: 320)
    }
}

#Preview("Placeholder Component") {
    ComponentPreviewCard(component: .placeholder)
}

#Preview("Sample Rack Component") {
    ComponentPreviewCard(
        component: Component(
            id: "rack_fx_01",
            name: "FX Rack",
            iconName: "rack",
            category: "Racks",
            manufacturer: "Yamaha",
            model: "SPX2000",
            inputs: ["line"],
            outputs: ["line"],
            ports: PortInfo(
                inputs: ["XLR In L", "XLR In R"],
                outputs: ["XLR Out L", "XLR Out R"]
            ),
            desc: "Sample rack processor for previewing model data.",
            level: "Intermediate",
            isRack: true,
            rackUnits: 2,
            comingSoon: false
        )
    )
}

#Preview("Sample Source Component") {
    ComponentPreviewCard(
        component: Component(
            id: "src_mic_01",
            name: "Vocal Microphone",
            iconName: "mic",
            category: "Sources",
            manufacturer: "Shure",
            model: "SM58",
            inputs: [],
            outputs: ["mic"],
            ports: PortInfo(
                inputs: [],
                outputs: ["XLR Out"]
            ),
            desc: "Sample handheld source component for previewing the data model.",
            level: "Beginner"
        )
    )
}
