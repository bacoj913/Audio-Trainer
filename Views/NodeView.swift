// Views/NodeView.swift — Individual component node card with all named I/O ports

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Port Anchor Preference Key
/// Reports each port dot's canvas-space center so CanvasView can draw connection curves.
struct PortAnchorPref: PreferenceKey {
    typealias Value = [String: CGPoint]
    static var defaultValue: [String: CGPoint] = [:]
    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Helpers
extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

/// Evenly distribute N ports along a card edge, with a margin from top/bottom.
func evenPortY(idx: Int, total: Int, height: CGFloat) -> CGFloat {
    guard total > 0 else { return height / 2 }
    if total == 1 { return height / 2 }
    let margin: CGFloat = 18
    return margin + CGFloat(idx) * (height - 2 * margin) / CGFloat(total - 1)
}

// MARK: - Constants
extension NodeView {
    static let width:      CGFloat = 168
    static let portRadius: CGFloat = 7
}

// MARK: - Node View
struct NodeView: View {
    @ObservedObject var instance: NodeInstance
    @EnvironmentObject var appState: AppState

    private var comp: Component {
        Components.all[instance.type] ?? .placeholder
    }

    var body: some View {
        if comp.isRack {
            RackNodeView(instance: instance, comp: comp)
        } else {
            StandardNodeView(instance: instance, comp: comp)
        }
    }
}

// MARK: - Standard Node
struct StandardNodeView: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @State private var dragStartPos: CGPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            VStack(alignment: .leading, spacing: 4) {
                ZStack{ // Header row
                HStack(spacing: 6) {
                    ComponentIcon(name: comp.iconName)
                        .frame(width: 18, height: 18)
                    Text(comp.name)
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    // Delete button
                    Button { appState.deleteNode(id: instance.id) } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        }
                    .buttonStyle(.plain)
                    .opacity(isHovered ? 1 : 0)
                    }
                .background{
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color.categoryColor(comp.category))
                        .frame(width: NodeView.width-9)
                    }
                }
                // Manufacturer
                if comp.manufacturer != "Generic" {
                    Text(comp.manufacturer)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }

                // Description
                Text(comp.desc)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Signal level badge
                if !comp.level.isEmpty {
                    Text(comp.level)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(Capsule())
                }

                // Coming Soon badge
                if comp.comingSoon {
                    Text("Coming Soon")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                }

            }
            .padding(.horizontal, 9)
            .padding(.top, 6)
            .padding(.bottom, 8)
        }
        .frame(width: NodeView.width)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(appState.connectingFromId == instance.id
                        ? Color.blue.opacity(0.8)
                        : Color.primary.opacity(0.08),
                        lineWidth: appState.connectingFromId == instance.id ? 2 : 1)
        )
        .shadow(color: .black.opacity(isHovered ? 0.14 : 0.08), radius: isHovered ? 10 : 5, x: 0, y: isHovered ? 4 : 2)
        // ── Per-port interactive dots on card edges ──
        .overlay {
            GeometryReader { geo in
                // Input dots — left edge
                ForEach(Array(comp.ports.inputs.enumerated()), id: \.offset) { idx, portName in
                    let sigType = comp.inputs.indices.contains(idx)
                        ? comp.inputs[idx]
                        : (comp.inputs.first ?? "line")
                    PortEdgeDot(instance: instance, portIndex: idx, side: "in",
                                total: comp.ports.inputs.count,
                                label: portName, signalType: sigType)
                        .position(x: 0, y: evenPortY(idx: idx, total: comp.ports.inputs.count, height: geo.size.height))
                }
                // Output dots — right edge
                ForEach(Array(comp.ports.outputs.enumerated()), id: \.offset) { idx, portName in
                    let sigType = comp.outputs.indices.contains(idx)
                        ? comp.outputs[idx]
                        : (comp.outputs.first ?? "line")
                    PortEdgeDot(instance: instance, portIndex: idx, side: "out",
                                total: comp.ports.outputs.count,
                                label: portName, signalType: sigType)
                        .position(x: geo.size.width, y: evenPortY(idx: idx, total: comp.ports.outputs.count, height: geo.size.height))
                }
            }
        }
        .onHover { isHovered = $0 }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard appState.connectingFromId == nil else { return }
                    if dragStartPos == nil { dragStartPos = instance.position }
                    guard let start = dragStartPos else { return }
                    instance.position = CGPoint(
                        x: max(0, start.x + value.translation.width),
                        y: max(0, start.y + value.translation.height)
                    )
                }
                .onEnded { _ in dragStartPos = nil }
        )
    }
}

// MARK: - Port Edge Dot
/// An interactive circle on the left (input) or right (output) edge of a node card.
/// Color is based on signal type. Reports canvas-space center via PortAnchorPref.
struct PortEdgeDot: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String        // "in" or "out"
    let total: Int
    var label: String = ""
    var signalType: String = "line"
    @EnvironmentObject var appState: AppState

    private var color: Color { Color.signalTypeColor(signalType) }

    private var isSource: Bool {
        appState.connectingFromId == instance.id && appState.connectingFromPortIndex == portIndex
    }

    private var isConnecting: Bool { appState.connectingFromId != nil }

    private var isConnected: Bool {
        if side == "in" {
            return appState.activeTab.connections.contains {
                $0.toId == instance.id && $0.toPortIndex == portIndex
            }
        } else {
            return appState.activeTab.connections.contains {
                $0.fromId == instance.id && $0.fromPortIndex == portIndex
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            // For input ports: label on the right side (inside card), dot on the left edge
            // For output ports: dot on the right edge, label on the left side (inside card)
            if side == "in" {
                dotCircle
                if !label.isEmpty {
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundColor(.primary.opacity(0.65))
                        .lineLimit(1)
                        .fixedSize()
                }
            } else {
                if !label.isEmpty {
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundColor(.primary.opacity(0.65))
                        .lineLimit(1)
                        .fixedSize()
                }
                dotCircle
            }
        }
        .offset(x: side == "in" ? -7 : 7)
    }

    private var dotCircle: some View {
        Circle()
            .fill(isConnected && side == "in" && !isConnecting
                  ? Color.red.opacity(0.75)
                  : color)
            .frame(width: 14, height: 14)
            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            .overlay {
                // Show × on connected input ports to hint at disconnect
                if isConnected && side == "in" && !isConnecting {
                    Image(systemName: "xmark")
                        .font(.system(size: 6, weight: .black))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: color.opacity(0.5),
                    radius: isSource ? 8 : (isConnecting && side == "in" ? 6 : 0))
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: PortAnchorPref.self,
                        value: ["\(instance.id)-\(side)-\(portIndex)":
                                    geo.frame(in: .named("canvas")).center]
                    )
                }
            )
            .onTapGesture {
                if side == "out" {
                    if !isConnecting {
                        appState.startConnecting(fromId: instance.id, fromPortIndex: portIndex)
                    } else if isSource {
                        appState.cancelConnecting()
                    }
                } else {
                    if isConnecting {
                        appState.finishConnecting(toId: instance.id, toPortIndex: portIndex)
                    } else if isConnected {
                        // Fix 5: click connected input port to disconnect
                        appState.disconnectInput(instanceId: instance.id, portIndex: portIndex)
                    }
                }
            }
            .help(side == "in"
                  ? (isConnected ? "Click to disconnect" : "Input — click to connect")
                  : "Output — click to start connection")
    }
}

// MARK: - Port List Section (all named physical ports — informational display)
struct PortListSection: View {
    let inputs: [String]
    let outputs: [String]

    var body: some View {
        if inputs.isEmpty && outputs.isEmpty { EmptyView() }
        else {
            VStack(alignment: .leading, spacing: 2) {
                // Input ports
                if !inputs.isEmpty {
                    Text("INPUTS")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    ForEach(inputs, id: \.self) { port in
                        PortPill(name: port, isInput: true)
                    }
                }
                // Output ports
                if !outputs.isEmpty {
                    Text("OUTPUTS")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.top, inputs.isEmpty ? 4 : 2)
                    ForEach(outputs, id: \.self) { port in
                        PortPill(name: port, isInput: false)
                    }
                }
            }
        }
    }
}

struct PortPill: View {
    let name: String
    let isInput: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isInput ? Color(red: 0.37, green: 0.36, blue: 0.90) : Color.blue)
                .frame(width: 5, height: 5)
            Text(name)
                .font(.system(size: 9))
                .foregroundColor(.primary.opacity(0.75))
                .lineLimit(1)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
            (isInput ? Color(red: 0.37, green: 0.36, blue: 0.90) : Color.blue).opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

// MARK: - Rack Node
struct RackNodeView: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @State private var dragStartPos: CGPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.categoryColor(comp.category))
                .frame(height: 3)

            HStack {
                ComponentIcon(name: comp.iconName).frame(width: 16, height: 16)
                VStack(alignment: .leading, spacing: 1) {
                    Text(comp.name)
                        .font(.system(size: 11, weight: .semibold))
                    Text(comp.manufacturer)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Open inner rack canvas
                Button {
                    appState.openRackTab(for: instance.id)
                } label: {
                    HStack(spacing: 3) {
                        Text("Open")
                            .font(.system(size: 9, weight: .medium))
                        Image(systemName: "arrow.forward.circle")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0)
                .padding(.trailing, 2)

                Button { appState.deleteNode(id: instance.id) } label: {
                    Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)

            // Rack unit slots
            VStack(spacing: 0) {
                ForEach(0..<comp.rackUnits, id: \.self) { i in
                    HStack {
                        Text("\(comp.rackUnits - i)U")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 9)
                    .frame(height: 20)
                    .background(i.isMultiple(of: 2)
                                ? Color.primary.opacity(0.03)
                                : Color.clear)
                    if i < comp.rackUnits - 1 {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .frame(width: 200)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.primary.opacity(0.08), lineWidth: 1))
        // ── Per-port interactive dots on card edges ──
        .overlay {
            GeometryReader { geo in
                ForEach(Array(comp.ports.inputs.enumerated()), id: \.offset) { idx, portName in
                    let sigType = comp.inputs.indices.contains(idx)
                        ? comp.inputs[idx]
                        : (comp.inputs.first ?? "line")
                    PortEdgeDot(instance: instance, portIndex: idx, side: "in",
                                total: comp.ports.inputs.count,
                                label: portName, signalType: sigType)
                        .position(x: 0, y: evenPortY(idx: idx, total: comp.ports.inputs.count, height: geo.size.height))
                }
                ForEach(Array(comp.ports.outputs.enumerated()), id: \.offset) { idx, portName in
                    let sigType = comp.outputs.indices.contains(idx)
                        ? comp.outputs[idx]
                        : (comp.outputs.first ?? "line")
                    PortEdgeDot(instance: instance, portIndex: idx, side: "out",
                                total: comp.ports.outputs.count,
                                label: portName, signalType: sigType)
                        .position(x: geo.size.width, y: evenPortY(idx: idx, total: comp.ports.outputs.count, height: geo.size.height))
                }
            }
        }
        .onHover { isHovered = $0 }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragStartPos == nil { dragStartPos = instance.position }
                    guard let start = dragStartPos else { return }
                    instance.position = CGPoint(
                        x: max(0, start.x + value.translation.width),
                        y: max(0, start.y + value.translation.height)
                    )
                }
                .onEnded { _ in dragStartPos = nil }
        )
    }
}

// MARK: - SF Symbol icon wrapper
struct ComponentIcon: View {
    let name: String
    var body: some View {
        Image(systemName: sfSymbol(for: name))
            .resizable()
            .scaledToFit()
            .foregroundColor(.primary.opacity(0.7))
    }

    func sfSymbol(for iconName: String) -> String {
        switch iconName {
        case "mic", "mic_cond":   return "mic"
        case "guitar":            return "guitars"
        case "keyboard":          return "pianokeys"
        case "di":                return "arrow.left.arrow.right.square"
        case "preamp":            return "amplifier"
        case "equalizer":         return "slider.vertical.3"
        case "compressor":        return "waveform.path.ecg"
        case "gate":              return "waveform.path"
        case "effects":           return "waveform"
        case "pedal":             return "circle.grid.2x1"
        case "console":           return "slider.horizontal.3"
        case "patchbay":          return "cable.connector.horizontal"
        case "interface":         return "cpu"
        case "power_amp":         return "triangle"
        case "speaker":           return "speaker.wave.3"
        case "monitor":           return "desktopcomputer"
        case "headphones":        return "headphones"
        case "headphone_amp":     return "headphones.circle"
        case "wireless_rx":       return "antenna.radiowaves.left.and.right"
        case "wireless_tx":       return "dot.radiowaves.right"
        case "handheld":          return "mic.fill"
        case "iem_tx":            return "dot.radiowaves.left.and.right"
        case "iem_rx":            return "earbuds"
        case "antenna":           return "antenna.radiowaves.left.and.right"
        case "distro":            return "arrow.triangle.branch"
        case "combiner":          return "arrow.triangle.merge"
        case "network":           return "network"
        case "stagebox":          return "square.grid.3x3"
        case "power":             return "bolt"
        case "rack":              return "server.rack"
        default:                  return "questionmark.square"
        }
    }
}
// MARK: - Previews

private extension AppState {
    static var nodePreviewState: AppState {
        AppState()
    }

    static var standardNodePreviewState: AppState {
        let state = AppState()
        if let type = Components.all.first(where: { !$0.value.isRack })?.key {
            state.addInstance(type: type, position: CGPoint(x: 120, y: 120))
        }
        return state
    }

    static var rackNodePreviewState: AppState {
        let state = AppState()
        if let type = Components.all.first(where: { $0.value.isRack })?.key {
            state.addInstance(type: type, position: CGPoint(x: 120, y: 120))
        }
        return state
    }
}

#Preview("NodeView - Standard") {
    Group {
        if let instance = AppState.standardNodePreviewState.instances.first {
            NodeView(instance: instance)
                .environmentObject(AppState.standardNodePreviewState)
                .padding()
                .frame(width: 260, height: 240)
                .coordinateSpace(name: "canvas")
        } else {
            Text("No standard component available for preview")
                .padding()
        }
    }
}

#Preview("NodeView - Rack") {
    Group {
        if let instance = AppState.rackNodePreviewState.instances.first {
            NodeView(instance: instance)
                .environmentObject(AppState.rackNodePreviewState)
                .padding()
                .frame(width: 300, height: 260)
                .coordinateSpace(name: "canvas")
        } else {
            Text("No rack component available for preview")
                .padding()
        }
    }
}

#Preview("StandardNodeView") {
    Group {
        let state = AppState.standardNodePreviewState
        if let instance = state.instances.first {
            let comp = Components.all[instance.type] ?? .placeholder
            StandardNodeView(instance: instance, comp: comp)
                .environmentObject(state)
                .padding()
                .frame(width: 260, height: 240)
                .coordinateSpace(name: "canvas")
        } else {
            Text("No standard component available for preview")
                .padding()
        }
    }
}

#Preview("RackNodeView") {
    Group {
        let state = AppState.rackNodePreviewState
        if let instance = state.instances.first {
            let comp = Components.all[instance.type] ?? .placeholder
            RackNodeView(instance: instance, comp: comp)
                .environmentObject(state)
                .padding()
                .frame(width: 300, height: 260)
                .coordinateSpace(name: "canvas")
        } else {
            Text("No rack component available for preview")
                .padding()
        }
    }
}

#Preview("Port List Section") {
    PortListSection(
        inputs: ["Mic In", "Line In L", "Line In R"],
        outputs: ["Main Out L", "Main Out R", "Phones"]
    )
    .padding()
    .frame(width: 220, height: 160)
}

#Preview("Port Pill - Input") {
    PortPill(name: "Mic Input", isInput: true)
        .padding()
        .frame(width: 160, height: 60)
}

#Preview("Port Pill - Output") {
    PortPill(name: "Main Output", isInput: false)
        .padding()
        .frame(width: 160, height: 60)
}

#Preview("Component Icon") {
    VStack(spacing: 16) {
        ComponentIcon(name: "mic").frame(width: 24, height: 24)
        ComponentIcon(name: "console").frame(width: 24, height: 24)
        ComponentIcon(name: "speaker").frame(width: 24, height: 24)
        ComponentIcon(name: "rack").frame(width: 24, height: 24)
    }
    .padding()
    .frame(width: 120, height: 180)
}
