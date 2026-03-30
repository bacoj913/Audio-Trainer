// Models/Component.swift — Component data model

import SwiftUI

// MARK: - Port Info
struct PortInfo {
    var inputs: [String]   // named physical input ports, e.g. "XLR In 1"
    var outputs: [String]  // named physical output ports, e.g. "XLR Out 1"

    static let empty = PortInfo(inputs: [], outputs: [])
}
// MARK: - Port Group
struct PortGroup {
    let connector: String
    let count: Int
    let signalType: String

    let channelsPerPort: Int
    let transport: String?
    let isNetwork: Bool
    let bundleStyle: BundleStyle

    enum BundleStyle {
        case single
        case stereoPair
        case multichannel
        case network
    }

    init(
        connector: String,
        count: Int,
        signalType: String,
        channelsPerPort: Int? = nil,
        transport: String? = nil,
        isNetwork: Bool? = nil,
        bundleStyle: BundleStyle? = nil
    ) {
        let normalized = signalType
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        self.connector = connector
        self.count = count
        self.signalType = signalType

        switch normalized {
        case "aes", "aes3":
            self.channelsPerPort = channelsPerPort ?? 2
            self.transport = transport ?? "AES"
            self.isNetwork = isNetwork ?? false
            self.bundleStyle = bundleStyle ?? .stereoPair

        case "dante", "aes67", "milan", "avb", "networkaudio":
            self.channelsPerPort = channelsPerPort ?? 64
            self.transport = transport ?? {
                switch normalized {
                case "dante": return "Dante"
                case "aes67": return "AES67"
                case "milan": return "Milan"
                case "avb": return "AVB"
                default: return "Network"
                }
            }()
            self.isNetwork = isNetwork ?? true
            self.bundleStyle = bundleStyle ?? .network

        case "madi":
            self.channelsPerPort = channelsPerPort ?? 64
            self.transport = transport ?? "MADI"
            self.isNetwork = isNetwork ?? false
            self.bundleStyle = bundleStyle ?? .multichannel

        default:
            self.channelsPerPort = channelsPerPort ?? 1
            self.transport = transport
            self.isNetwork = isNetwork ?? false
            self.bundleStyle = bundleStyle ?? .single
        }
    }

    func labels(for side: String) -> [String] {
        guard count > 0 else { return [] }

        let direction = side == "in" ? "In" : "Out"
        let normalized = signalType
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized == "aes" || normalized == "aes3" {
            if count == 1 {
                return ["AES \(direction) 1/2"]
            }

            return (0..<count).map { idx in
                let first = idx * 2 + 1
                let second = first + 1
                return "AES \(direction) \(first)/\(second)"
            }
        }

        if isNetwork, let transport {
            if count == 1 {
                return ["\(transport) \(direction)"]
            }

            return (1...count).map { "\(transport) \(direction) \($0)" }
        }

        let baseLabel = "\(connector) \(direction)"

        if count == 1 {
            return [baseLabel]
        }

        return (1...count).map { "\(baseLabel) \($0)" }
    }

    var signalTypes: [String] {
        Array(repeating: signalType, count: count)
    }
}
extension PortInfo {
    init(inputGroups: [PortGroup], outputGroups: [PortGroup]) {
        self.init(
            inputs: inputGroups.flatMap { $0.labels(for: "in") },
            outputs: outputGroups.flatMap { $0.labels(for: "out") }
        )
    }
}

extension Component {
    init(
        id: String,
        name: String,
        iconName: String,
        category: String,
        manufacturer: String,
        model: String,
        inputGroups: [PortGroup],
        outputGroups: [PortGroup],
        desc: String,
        level: String,
        isRack: Bool = false,
        rackUnits: Int = 0,
        comingSoon: Bool = false,
        availablePresets: [String] = [],
        slotCount: Int = 0,
        isSlotCard: Bool = false
    ) {
        self.init(
            id: id,
            name: name,
            iconName: iconName,
            category: category,
            manufacturer: manufacturer,
            model: model,
            inputs: inputGroups.flatMap(\.signalTypes),
            outputs: outputGroups.flatMap(\.signalTypes),
            ports: PortInfo(inputGroups: inputGroups, outputGroups: outputGroups),
            desc: desc,
            level: level,
            isRack: isRack,
            rackUnits: rackUnits,
            comingSoon: comingSoon,
            availablePresets: availablePresets,
            slotCount: slotCount,
            isSlotCard: isSlotCard
        )
    }
}
// MARK: - Slot Card
/// A named expansion card inserted into a numbered slot on a parent device.
struct SlotCard: Identifiable, Codable {
    let id: UUID
    var slotNumber: Int   // 0-based slot index
    var cardType: String  // component ID of the inserted card

    init(id: UUID = UUID(), slotNumber: Int, cardType: String) {
        self.id = id
        self.slotNumber = slotNumber
        self.cardType = cardType
    }
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
    var availablePresets: [String] = []   // e.g. Lake module names for amps/processors
    var slotCount: Int = 0                // number of expansion card slots (0 = none)
    var isSlotCard: Bool = false          // true when this component IS an expansion card

    /// True for any device that participates in a network (dante, milan, aes67, avb, or plain "network" signal type).
    var hasNetworkIP: Bool {
        let networkTypes: Set<String> = ["dante", "milan", "aes67", "avb", "network"]
        return (inputs + outputs).contains { networkTypes.contains($0.lowercased()) }
    }

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
    "Networking", "Stage Racks", "Stage Boxes", "Racks", "Speakers", "Power", "Intercom",
    "Expansion Cards"
]

// MARK: - Signal type colors (for port dots and connection wires)
extension Color {
    static func signalTypeColor(_ type: String) -> Color {
        switch type
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        {
        case "mic":        return Color(.systemRed)
        case "line":       return Color(.systemRed)
        case "instrument": return Color(.systemPink)
        case "speaker":    return Color(.black)
        case "network":    return Color(.systemGreen)
        case "antenna":    return Color(.systemGray)
        case "madi":       return Color(.systemTeal)
        case "fiber":      return Color(.systemOrange)
        case "optical":    return Color(.systemOrange)
        case "aes":        return Color(.systemPurple)
        case "dante":      return Color(.systemGreen)
        case "milan":      return Color(.systemGreen)
        case "rf":         return Color(.systemBlue)
        case "power":      return Color(.systemYellow)
        case "clock":      return Color(.systemMint)
        default:           return Color(.systemGray)
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

// MARK: - VLAN Colors
extension Color {
    /// Distinct colors for VLAN IDs, cycling through a palette. VLAN 0 = untagged (gray).
    static func vlanColor(_ vlanId: Int) -> Color {
        guard vlanId > 0 else { return Color(.systemGray) }
        let palette: [Color] = [
            Color(.systemBlue), Color(.systemGreen), Color(.systemOrange),
            Color(.systemPurple), Color(.systemRed), Color(.systemTeal),
            Color(.systemYellow), Color(.systemIndigo), Color(.systemPink),
            Color(.systemBrown)
        ]
        return palette[(vlanId - 1) % palette.count]
    }
}

// MARK: - Auto Text Contrast
extension Color {
    func nsColor(for appearance: NSAppearance? = NSApp.effectiveAppearance) -> NSColor {
        let base = NSColor(self)

        guard let appearance else { return base }

        var resolved = base
        appearance.performAsCurrentDrawingAppearance {
            resolved = NSColor(self)
        }
        return resolved
    }

    var wcagContrastingTextColor: Color {
        let resolved = nsColor()

        guard let rgb = resolved.usingColorSpace(.deviceRGB) else {
            return .white
        }

        func linearize(_ c: CGFloat) -> CGFloat {
            if c <= 0.04045 {
                return c / 12.92
            } else {
                return pow((c + 0.055) / 1.055, 2.4)
            }
        }

        let r = linearize(rgb.redComponent)
        let g = linearize(rgb.greenComponent)
        let b = linearize(rgb.blueComponent)

        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        let whiteContrast = (1.0 + 0.05) / (luminance + 0.05)
        let blackContrast = (luminance + 0.05) / 0.05

        return whiteContrast > blackContrast ? .white : .black
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
