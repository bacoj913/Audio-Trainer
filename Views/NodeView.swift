// Views/NodeView.swift — Individual component node card with all named I/O ports

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Port Anchor Preference Key
/// Reports each port dot's canvas-space center so CanvasView can draw connection curves.
struct PortAnchorPref: PreferenceKey {
    typealias Value = [String: CGPoint]
    static var defaultValue: [String: CGPoint] = [:]
    static func reduce(
        value: inout [String: CGPoint],
        nextValue: () -> [String: CGPoint]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Rack Display Port
struct RackDisplayPort: Identifiable {
    let id = UUID()
    let side: String
    let signalType: String
    let bundleStyle: PortGroup.BundleStyle
    let portIndexes: [Int]
    let isBidirectional: Bool
}

// MARK: - Helpers
extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

/// Evenly distribute N ports along a card edge, with a margin from top/bottom.
/// - Parameters:
///   - idx: Zero-based port index.
///   - total: Number of ports on that edge.
///   - height: Available edge height.
/// - Returns: Y position for a given port.
func evenPortY(idx: Int, total: Int, height: CGFloat) -> CGFloat {
    guard total > 0 else { return height / 2 }
    if total == 1 { return height / 2 }
    let margin: CGFloat = 18
    return margin + CGFloat(idx) * (height - 2 * margin) / CGFloat(total - 1)
}

/// Stacks body ports from top to bottom, with a margin from the top.
/// - Parameters:
///   - idx: Zero-based port index.
///   - total: Total ports in the stack. Currently unused.
///   - height: Full node height. Currently unused.
/// - Returns: Y position for a given port.
func bodyPortY(idx: Int, rowCount _: Int, comp: Component) -> CGFloat {
    let firstRowY =
        NodeView.standardTopReserved
        + standardNodeSlotOffset(for: comp)
        + NodeView.standardBodyTopInset

    return firstRowY + CGFloat(idx) * NodeView.standardPortSpacing
}

/// Calculates standard node height
/// - Parameter comp: Component whos ports determine height.
/// - Returns: Total node height.
func standardNodeHeight(for instance: NodeInstance, comp: Component) -> CGFloat {
    return NodeView.standardTopReserved
        + standardNodePortBodyHeight(for: instance, comp: comp)
        + standardNodeSlotSectionHeight(for: comp)
        + NodeView.standardBottomPadding
}
func standardNodeSlotOffset(for comp: Component) -> CGFloat {
    // Only add an offset when the device has BOTH slots AND base ports.
    // Slot-only devices (e.g. RIVAGE PM7 with no built-in I/O) need zero offset
    // so the slot section doesn't shift the port body upward.
    guard comp.slotCount > 0 else { return 0 }
    let hasBasePorts = !comp.ports.inputs.isEmpty || !comp.ports.outputs.isEmpty
    return hasBasePorts ? standardNodeSlotSectionHeight(for: comp) - 14 : 0
}
/// Estimated text width for layout sizing without exact text measurement.
/// - Parameters:
///   - text: Text to estimate.
///   - fontSize: Font size used for text.
/// - Returns: Approximate text width.
func estimatedTextWidth(_ text: String, fontSize: CGFloat) -> CGFloat {
    CGFloat(text.count) * fontSize * 0.58
}
func standardNodePortBodyHeight(for instance: NodeInstance, comp: Component) -> CGFloat {
    let effectivePorts = instance.effectivePorts ?? comp.ports
    let portCount = max(effectivePorts.inputs.count, effectivePorts.outputs.count)

    if portCount <= 1 {
        return NodeView.standardMinBodyHeight
    } else {
        let portsHeight = CGFloat(portCount - 1) * NodeView.standardPortSpacing
        return max(
            NodeView.standardMinBodyHeight,
            NodeView.standardBodyTopInset + portsHeight + NodeView.standardBodyBottomInset
        )
    }
}
func standardNodeSlotSectionHeight(for comp: Component) -> CGFloat {
    comp.slotCount > 0
        ? CGFloat(comp.slotCount) * 22 + 20
        : 0
}
/// Calculates standard node width to determine if node should widen to fit port labels.
/// - Parameter comp: Component whos port labels determine width.
/// - Returns: Node width.
func standardNodeWidth(for comp: Component) -> CGFloat {
    let baseWidth: CGFloat = 168
    let innerPadding: CGFloat = 18
    let labelGapFromPort: CGFloat = 24
    
    let longestInput = comp.ports.inputs.max(by: { $0.count < $1.count }) ?? ""
    let longestOutput =
    comp.ports.outputs.max(by: { $0.count < $1.count }) ?? ""
    
    let inputTextWidth = estimatedTextWidth(longestInput, fontSize: 8)
    let outputTextWidth = estimatedTextWidth(longestOutput, fontSize: 8)
    
    let totalLabelWidth =
    inputTextWidth + outputTextWidth + (labelGapFromPort * 2)
    + (innerPadding * 2)
    
    return max(baseWidth, totalLabelWidth)
}
func standardNodePortBodyHeight(for comp: Component) -> CGFloat {
    let portCount = max(comp.ports.inputs.count, comp.ports.outputs.count)

    if portCount <= 1 {
        return NodeView.standardMinBodyHeight
    } else {
        let portsHeight = CGFloat(portCount - 1) * NodeView.standardPortSpacing
        return max(
            NodeView.standardMinBodyHeight,
            NodeView.standardBodyTopInset + portsHeight + NodeView.standardBodyBottomInset
        )
    }
}

func standardNodeHeight(for comp: Component) -> CGFloat {
    return NodeView.standardTopReserved
        + standardNodePortBodyHeight(for: comp)
        + standardNodeSlotSectionHeight(for: comp)
        + NodeView.standardBottomPadding
}
func rackDisplayFamilyKey(signalType: String, bundleStyle: PortGroup.BundleStyle) -> String {
    let normalized = signalType
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    switch normalized {
    case "mic", "line", "analog", "instrument":
        return "analog"
    case "aes", "aes3":
        return "aes"
    case "madi":
        return "madi"
    case "dante", "aes67", "milan", "avb", "network":
        return "network"
    default:
        switch bundleStyle {
        case .network:
            return "network"
        case .stereoPair:
            return "aes"
        case .multichannel:
            return "multichannel"
        default:
            return normalized
        }
    }
}

func makeRackDisplayPorts(
    labels: [String],
    signalTypes: [String],
    side: String
) -> [RackDisplayPort] {
    let visualPorts = makeVisualPorts(labels: labels, signalTypes: signalTypes)

    var groupedIndexes: [String: [Int]] = [:]
    var groupedSignalType: [String: String] = [:]
    var groupedBundleStyle: [String: PortGroup.BundleStyle] = [:]
    var orderedKeys: [String] = []

    for (idx, port) in visualPorts.enumerated() {
        let key = rackDisplayFamilyKey(
            signalType: port.signalType,
            bundleStyle: port.bundleStyle
        )

        if groupedIndexes[key] == nil {
            groupedIndexes[key] = []
            groupedSignalType[key] = port.signalType
            groupedBundleStyle[key] = port.bundleStyle
            orderedKeys.append(key)
        }

        groupedIndexes[key, default: []].append(idx)
    }

    return orderedKeys.map { key in
        let sType = groupedSignalType[key] ?? key
        let normalized = sType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let bidir = ["dante", "aes67", "milan", "avb", "network", "networkaudio"].contains(normalized)
            || groupedBundleStyle[key] == .network
        return RackDisplayPort(
            side: side,
            signalType: sType,
            bundleStyle: groupedBundleStyle[key] ?? .single,
            portIndexes: groupedIndexes[key] ?? [],
            isBidirectional: bidir
        )
    }
}

func rackAvailablePortIndexes(
    instanceId: UUID,
    side: String,
    candidates: [Int],
    appState: AppState
) -> [Int] {
    let allConns = appState.activeTab.connections + appState.crossTabConnections

    return candidates.filter { idx in
        if side == "in" {
            return !allConns.contains {
                $0.toId == instanceId && $0.toPortIndex == idx
            }
        } else {
            return !allConns.contains {
                $0.fromId == instanceId && $0.fromPortIndex == idx
            }
        }
    }
}

func rackUsedPortIndexes(
    instanceId: UUID,
    side: String,
    candidates: [Int],
    appState: AppState
) -> [Int] {
    let allConns = appState.activeTab.connections + appState.crossTabConnections

    return candidates.filter { idx in
        if side == "in" {
            return allConns.contains {
                $0.toId == instanceId && $0.toPortIndex == idx
            }
        } else {
            return allConns.contains {
                $0.fromId == instanceId && $0.fromPortIndex == idx
            }
        }
    }
}

func shouldAlwaysShowRackGroups(for comp: Component) -> Bool {
    comp.id == "configurable_io_2u"
        || comp.category == "Patching"
        || comp.category == "Stage Boxes"
}

func rackNodeHeight(for comp: Component) -> CGFloat {
    NodeView.rackHeaderHeight
        + CGFloat(comp.rackUnits) * NodeView.rackUnitHeight
        + 3
}
// TODO: Add Ruleset for Intercom devices

// MARK: - Constants
extension NodeView {
    static let width: CGFloat = 168
    static let portDotSize: CGFloat = 10
    static let portHitWidth: CGFloat = 30
    static let portHitHeight: CGFloat = 18
    static let portXMarkSize: CGFloat = 5
    
    static let portLabelGap: CGFloat = 12
    
    static let standardTopReserved: CGFloat = 96
    static let standardBodyTopInset: CGFloat = 24
    static let standardBodyBottomInset: CGFloat = 12
    static let standardBottomPadding: CGFloat = 10
    static let standardMinBodyHeight: CGFloat = 24
    static let standardPortSpacing: CGFloat = 22
    
    static let rackWidth: CGFloat = 200
    static let rackHeaderHeight: CGFloat = 28
    static let rackUnitHeight: CGFloat = 20
    static let rackDividerHeight: CGFloat = 1
    
    static let standardSlotTopGap: CGFloat = 6
}

// MARK: - Multichannel Ports
struct VisualPort: Identifiable {
    let id = UUID()
    let label: String
    let signalType: String
    let bundleStyle: PortGroup.BundleStyle
}

func makeVisualPorts(labels: [String], signalTypes: [String]) -> [VisualPort] {
    labels.enumerated().map { idx, label in
        let signalType =
        signalTypes.indices.contains(idx)
        ? signalTypes[idx]
        : (signalTypes.first ?? "line")
        
        let normalized =
        signalType
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        let bundleStyle: PortGroup.BundleStyle
        switch normalized {
        case "aes", "aes3":
            bundleStyle = .stereoPair
        case "madi":
            bundleStyle = .multichannel
        case "dante", "aes67", "milan", "avb", "network":
            bundleStyle = .network
        case "bindingpost":
            bundleStyle = .bindingPost
        default:
            bundleStyle = .single
        }
        
        return VisualPort(
            label: label,
            signalType: signalType,
            bundleStyle: bundleStyle
        )
    }
}
// MARK: - Slot-Simplified Port Helpers

/// One entry per installed slot card, suitable for showing one dot per slot in standard canvas view.
struct SlotDisplayPort {
    let label: String
    let portIndex: Int
    let signalType: String
    let bundleStyle: PortGroup.BundleStyle
}

/// Returns one SlotDisplayPort per installed slot card for the given side.
/// Port indices refer to positions in the merged effectivePorts list.
func slotSimplifiedPorts(instance: NodeInstance, comp: Component, side: String) -> [SlotDisplayPort] {
    guard comp.slotCount > 0 else { return [] }
    let baseCount = side == "in" ? comp.ports.inputs.count : comp.ports.outputs.count
    var offset = baseCount
    var results: [SlotDisplayPort] = []
    for slotIdx in 0..<comp.slotCount {
        if let card = instance.slotCards[slotIdx],
           let cardComp = Components.all[card.cardType] {
            let cardPortCount = side == "in" ? cardComp.ports.inputs.count : cardComp.ports.outputs.count
            let signalType = side == "in"
                ? (cardComp.inputs.first ?? "line")
                : (cardComp.outputs.first ?? "line")
            let normalized = signalType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let bundle: PortGroup.BundleStyle
            switch normalized {
            case "dante", "aes67", "milan", "avb", "network": bundle = .network
            case "aes", "aes3":                               bundle = .stereoPair
            case "madi":                                       bundle = .multichannel
            case "bindingpost":                                bundle = .bindingPost
            default:                                           bundle = .single
            }
            results.append(SlotDisplayPort(
                label: "Slot \(slotIdx + 1)",
                portIndex: offset,
                signalType: signalType,
                bundleStyle: bundle
            ))
            offset += cardPortCount
        }
        // Empty slot contributes no ports to the offset (no card installed)
    }
    return results
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
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack {  // Equipment Header
                    HStack(spacing: 6) {
                        ComponentIcon(name: comp.iconName)
                            .frame(width: 18, height: 18)
                            .foregroundColor(
                                Color.categoryColor(comp.category)
                                    .wcagContrastingTextColor
                            )
                        
                        Text(comp.name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(
                                Color.categoryColor(comp.category)
                                    .wcagContrastingTextColor
                            )
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer(minLength: 0)
                        
                        Button {
                            appState.deleteNode(id: instance.id)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .opacity(isHovered ? 1 : 0)
                        .allowsHitTesting(isHovered)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background {  //Background color for Equipment Header
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.categoryColor(comp.category))
                    }
                    
                }
                // FIXME: Remove comp.manufacturer
                if comp.manufacturer != "Generic" {  // Equipment Manufacturer
                    Text(comp.manufacturer)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Text(comp.desc)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    if !comp.level.isEmpty {
                        Text(comp.level)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.08))
                            .clipShape(Capsule())
                    }

                    if comp.comingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    if comp.hasNetworkIP {
                        IPAddressBadge(instance: instance)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 4)

            // Slot cards section (only shown for devices with expansion slots)
            if comp.slotCount > 0 {
                SlotCardsSection(instance: instance, comp: comp)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)

                Divider()
                    .padding(.horizontal, 6)
                    .padding(.bottom, 6)
            }

            Spacer(minLength: standardNodePortBodyHeight(for: instance, comp: comp))
        }
        .frame(
            width: standardNodeWidth(for: comp),
            height: standardNodeHeight(for: instance, comp: comp)
        )
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(
                    appState.connectingFromId == instance.id
                    ? Color.blue.opacity(0.8)
                    : Color.primary.opacity(0.08),
                    lineWidth: appState.connectingFromId == instance.id ? 2 : 1
                )
        )
        .shadow(
            color: .black.opacity(isHovered ? 0.14 : 0.08),
            radius: isHovered ? 10 : 5,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        // MARK: - Per-port interactive dots on card edges
        // Must be BEFORE .offset() so dots move with the card during drag
        .overlay {
            GeometryReader { geo in
                // For slotted devices: show base ports + one dot per installed slot card
                // For regular devices: show all effective ports individually
                let effectivePorts = instance.effectivePorts ?? comp.ports
                let (inputPorts, inputPortIndexes): ([VisualPort], [Int])
                let (outputPorts, outputPortIndexes): ([VisualPort], [Int])

                if comp.slotCount > 0 {
                    // Base device ports
                    let baseInputPorts = makeVisualPorts(
                        labels: comp.ports.inputs,
                        signalTypes: comp.inputs
                    )
                    let baseOutputPorts = makeVisualPorts(
                        labels: comp.ports.outputs,
                        signalTypes: comp.outputs
                    )
                    // Slot-simplified ports (one per installed card)
                    let slotIns  = slotSimplifiedPorts(instance: instance, comp: comp, side: "in")
                    let slotOuts = slotSimplifiedPorts(instance: instance, comp: comp, side: "out")
                    let slotInPorts  = slotIns.map  { VisualPort(label: $0.label, signalType: $0.signalType, bundleStyle: $0.bundleStyle) }
                    let slotOutPorts = slotOuts.map { VisualPort(label: $0.label, signalType: $0.signalType, bundleStyle: $0.bundleStyle) }
                    inputPorts  = baseInputPorts  + slotInPorts
                    outputPorts = baseOutputPorts + slotOutPorts
                    inputPortIndexes  = Array(0..<baseInputPorts.count)  + slotIns.map(\.portIndex)
                    outputPortIndexes = Array(0..<baseOutputPorts.count) + slotOuts.map(\.portIndex)
                } else {
                    let ins  = makeVisualPorts(labels: effectivePorts.inputs,  signalTypes: instance.effectiveInputTypes  ?? comp.inputs)
                    let outs = makeVisualPorts(labels: effectivePorts.outputs, signalTypes: instance.effectiveOutputTypes ?? comp.outputs)
                    inputPorts  = ins
                    outputPorts = outs
                    inputPortIndexes  = Array(0..<ins.count)
                    outputPortIndexes = Array(0..<outs.count)
                }

                let rowCount = max(inputPorts.count, outputPorts.count)

                ForEach(Array(inputPorts.enumerated()), id: \.offset) { idx, port in
                    PortEdgeDot(
                        instance: instance,
                        portIndex: inputPortIndexes[idx],
                        side: "in",
                        total: inputPorts.count,
                        label: port.label,
                        signalType: port.signalType,
                        bundleStyle: port.bundleStyle
                    )
                    .position(
                        x: 0,
                        y: bodyPortY(idx: idx, rowCount: rowCount, comp: comp)
                    )
                }

                ForEach(Array(outputPorts.enumerated()), id: \.offset) { idx, port in
                    PortEdgeDot(
                        instance: instance,
                        portIndex: outputPortIndexes[idx],
                        side: "out",
                        total: outputPorts.count,
                        label: port.label,
                        signalType: port.signalType,
                        bundleStyle: port.bundleStyle
                    )
                    .position(
                        x: geo.size.width,
                        y: bodyPortY(idx: idx, rowCount: rowCount, comp: comp)
                    )
                }
            }
        }
        .offset(x: dragOffset.width, y: dragOffset.height)
        .gesture(
            DragGesture(minimumDistance: 4)
                .updating($dragOffset) { value, state, _ in
                    guard appState.connectingFromId == nil else { return }
                    state = value.translation
                }
                .onEnded { value in
                    guard appState.connectingFromId == nil else { return }
                    instance.position = CGPoint(
                        x: max(0, instance.position.x + value.translation.width),
                        y: max(0, instance.position.y + value.translation.height)
                    )
                }
        )
    }
}

// MARK: - Port Edge Dot
/// An interactive circle on the left (input) or right (output) edge of a node card.
/// Color is based on signal type. Reports canvas-space center via PortAnchorPref.
struct PortEdgeDot: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String
    let total: Int
    var label: String = ""
    var signalType: String = "line"
    var bundleStyle: PortGroup.BundleStyle = .single
    @EnvironmentObject var appState: AppState

    @State private var showingBindingPostPicker = false
    @State private var lastBananaOrientation: String? = nil
    
    private var color: Color { Color.signalTypeColor(signalType) }
    
    private var isSource: Bool {
        appState.connectingFromId == instance.id
        && appState.connectingFromPortIndex == portIndex
    }
    
    private var isConnecting: Bool { appState.connectingFromId != nil }
    
    private var isConnected: Bool {
        let allConns = appState.activeTab.connections + appState.crossTabConnections
        if side == "in" {
            return allConns.contains {
                $0.toId == instance.id && $0.toPortIndex == portIndex
            }
        } else {
            return allConns.contains {
                $0.fromId == instance.id && $0.fromPortIndex == portIndex
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(
                    width: NodeView.portHitWidth,
                    height: NodeView.portHitHeight
                )

            PortGlyph(
                color: color,
                bundleStyle: bundleStyle,
                showDisconnectMark: isConnected && side == "in" && !isConnecting
            )
            .shadow(
                color: color.opacity(0.5),
                radius: isSource ? 8 : (isConnecting && side == "in" ? 6 : 0)
            )
        }
        .overlay(alignment: side == "in" ? .leading : .trailing) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 8))
                    .foregroundColor(.primary.opacity(0.65))
                    .lineLimit(1)
                    .fixedSize()
                    .allowsHitTesting(false)
                    .offset(
                        x: side == "in"
                        ? (NodeView.portHitWidth / 2 + NodeView.portLabelGap)
                        : -(NodeView.portHitWidth / 2
                            + NodeView.portLabelGap)
                    )
            }
        }
        .contentShape(Rectangle())
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: PortAnchorPref.self,
                    value: [
                        "\(instance.id)-\(side)-\(portIndex)":
                            geo.frame(in: .named("canvas")).center
                    ]
                )
            }
        )
        .popover(isPresented: $showingBindingPostPicker,
                 arrowEdge: side == "in" ? .leading : .trailing) {
            BananaOrientationPicker(
                instance: instance,
                portIndex: portIndex,
                side: side,
                onSelect: { orientation in
                    showingBindingPostPicker = false
                    lastBananaOrientation = orientation
                    instance.bananaOrientations[portIndex] = orientation
                    if side == "out" {
                        appState.startConnecting(fromId: instance.id, fromPortIndex: portIndex)
                    } else if isConnecting {
                        appState.finishConnecting(toId: instance.id, toPortIndex: portIndex)
                    }
                }
            )
            .environmentObject(appState)
        }
        .onTapGesture {
            if bundleStyle == .bindingPost && appState.mode == .exercise {
                if side == "out" && !isConnecting {
                    // Defer to next run loop so the gesture is fully settled before
                    // SwiftUI tries to present the popover — standard macOS fix.
                    DispatchQueue.main.async { showingBindingPostPicker = true }
                } else if side == "out" && isSource {
                    appState.cancelConnecting()
                } else if side == "in" && isConnecting {
                    DispatchQueue.main.async { showingBindingPostPicker = true }
                } else if side == "in" && isConnected {
                    appState.disconnectInput(instanceId: instance.id, portIndex: portIndex)
                }
                return
            }
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
                    appState.disconnectInput(instanceId: instance.id, portIndex: portIndex)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 6)
                .onChanged { _ in
                    if side == "out" && !isConnecting {
                        appState.startConnecting(
                            fromId: instance.id,
                            fromPortIndex: portIndex
                        )
                    }
                }
                .onEnded { _ in
                    if appState.connectingFromId != nil {
                        appState.cancelConnecting()
                    }
                }
        )
        .help(
            side == "in"
            ? (isConnected
               ? "Click to disconnect" : "Input — click to connect")
            : "Output — click or drag to start connection"
        )
    }
}

// MARK: - Banana Orientation Picker
/// Popover shown in exercise mode when the user taps a binding post port.
/// Asks which direction the banana jack ground tab faces.
struct BananaOrientationPicker: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String
    let onSelect: (String) -> Void

    @EnvironmentObject var appState: AppState

    private var comp: Component? { Components.all[instance.type] }

    private var expectedOrientation: String? {
        guard let preset = instance.selectedPreset,
              let comp else { return nil }
        return comp.presetBananaOrientations[preset]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Banana Jack Orientation")
                .font(.system(size: 13, weight: .semibold))

            if let preset = instance.selectedPreset {
                Text("Module: **\(preset)**")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Text("Which direction is the ground tab?")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                ForEach(["left", "right"], id: \.self) { orientation in
                    Button {
                        onSelect(orientation)
                    } label: {
                        HStack(spacing: 10) {
                            // Mini binding-post diagram
                            HStack(spacing: 0) {
                                if orientation == "left" {
                                    Text("GND")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 14)
                                        .background(Color.black)
                                    Text("+")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 14)
                                        .background(Color.red)
                                } else {
                                    Text("+")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 14)
                                        .background(Color.red)
                                    Text("GND")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 14)
                                        .background(Color.black)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .overlay(RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1))

                            Text("Ground tab \(orientation)")
                                .font(.system(size: 11))
                            Spacer()

                            if let expected = expectedOrientation {
                                Image(systemName: orientation == expected
                                      ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(orientation == expected ? .green : .red)
                                    .font(.system(size: 13))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(width: 240)
    }
}

// MARK: - Rack Grouped Port Dot
struct RackGroupedPortDot: View {
    @ObservedObject var instance: NodeInstance
    let displayPort: RackDisplayPort

    @EnvironmentObject var appState: AppState
    @State private var showingPicker = false

    private var color: Color {
        Color.signalTypeColor(displayPort.signalType)
    }

    private var availableIndexes: [Int] {
        rackAvailablePortIndexes(
            instanceId: instance.id,
            side: displayPort.side,
            candidates: displayPort.portIndexes,
            appState: appState
        )
    }

    private var usedIndexes: [Int] {
        rackUsedPortIndexes(
            instanceId: instance.id,
            side: displayPort.side,
            candidates: displayPort.portIndexes,
            appState: appState
        )
    }

    private var isConnecting: Bool {
        appState.connectingFromId != nil
    }

    private var canReceiveConnection: Bool {
        displayPort.side == "in" && isConnecting && !availableIndexes.isEmpty
    }

    private var canStartConnection: Bool {
        displayPort.side == "out" && !availableIndexes.isEmpty
    }

    private var occupancyText: String {
        "\(usedIndexes.count)/\(displayPort.portIndexes.count)"
    }

    private var badgeAlignment: Alignment {
        displayPort.side == "in" ? .bottomLeading : .bottomTrailing
    }

    private var badgeXOffset: CGFloat {
        displayPort.side == "in" ? -10 : 10
    }

    var body: some View {
        ZStack {
            Color.clear
                .frame(
                    width: NodeView.portHitWidth + 14,
                    height: NodeView.portHitHeight + 12
                )

            ZStack(alignment: badgeAlignment) {
                PortGlyph(
                    color: color,
                    bundleStyle: displayPort.bundleStyle,
                    showDisconnectMark: false
                )
                .shadow(
                    color: color.opacity(
                        canReceiveConnection || canStartConnection ? 0.45 : 0.18
                    ),
                    radius: canReceiveConnection || canStartConnection ? 6 : 0
                )

                Text(occupancyText)
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.78))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.96))
                    .clipShape(Capsule())
                    .offset(x: badgeXOffset, y: 10)
                    .allowsHitTesting(false)
            }
            .opacity(availableIndexes.isEmpty ? 0.35 : 1)
        }
        .contentShape(Rectangle())
        .background(
            GeometryReader { geo in
                let center = geo.frame(in: .named("canvas")).center
                // Report with the first available port index so portCenter() can look it up.
                let firstIdx = availableIndexes.first ?? displayPort.portIndexes.first ?? 0
                return Color.clear.preference(
                    key: PortAnchorPref.self,
                    value: ["\(instance.id)-\(displayPort.side)-\(firstIdx)": center]
                )
            }
        )
        .onTapGesture {
            handleTap()
        }
        .popover(
            isPresented: $showingPicker,
            arrowEdge: displayPort.side == "in" ? .leading : .trailing
        ) {
            RackGroupedPortPicker(
                instance: instance,
                displayPort: displayPort,
                availableIndexes: availableIndexes
            )
            .environmentObject(appState)
        }
    }

    private func handleTap() {
        guard !availableIndexes.isEmpty else { return }

        let treatAsOut = displayPort.side == "out" || (!isConnecting && displayPort.isBidirectional)
        let treatAsIn  = displayPort.side == "in"  || (isConnecting  && displayPort.isBidirectional)

        if treatAsOut && !isConnecting {
            if availableIndexes.count == 1 {
                appState.startConnecting(fromId: instance.id, fromPortIndex: availableIndexes[0])
            } else {
                showingPicker = true
            }
        } else if treatAsIn && isConnecting {
            if availableIndexes.count == 1 {
                appState.finishConnecting(toId: instance.id, toPortIndex: availableIndexes[0])
            } else {
                showingPicker = true
            }
        }
    }
}

// MARK: - Rack Grouped Part Picker
struct RackGroupedPortPicker: View {
    @ObservedObject var instance: NodeInstance
    let displayPort: RackDisplayPort
    let availableIndexes: [Int]

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var effectivePorts: PortInfo {
        instance.effectivePorts ?? (Components.all[instance.type]?.ports ?? PortInfo(inputs: [], outputs: []))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(displayPort.signalType.uppercased()) \(displayPort.side == "in" ? "Inputs" : "Outputs")")
                .font(.system(size: 12, weight: .semibold))

            ForEach(availableIndexes, id: \.self) { portIndex in
                Button {
                    select(portIndex)
                } label: {
                    HStack(spacing: 8) {
                        PortGlyph(
                            color: Color.signalTypeColor(displayPort.signalType),
                            bundleStyle: displayPort.bundleStyle,
                            showDisconnectMark: false
                        )

                        Text(labelForPort(portIndex))
                            .font(.system(size: 12))
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(minWidth: 180, alignment: .leading)
                }
                .buttonStyle(.plain)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
    }

    private func labelForPort(_ portIndex: Int) -> String {
        let labels = displayPort.side == "in" ? effectivePorts.inputs : effectivePorts.outputs

        if labels.indices.contains(portIndex), !labels[portIndex].isEmpty {
            return labels[portIndex]
        }

        let dir = displayPort.side == "in" ? "In" : "Out"
        return "\(displayPort.signalType.uppercased()) \(dir) \(portIndex + 1)"
    }

    private func select(_ portIndex: Int) {
        if displayPort.side == "out" {
            appState.startConnecting(
                fromId: instance.id,
                fromPortIndex: portIndex
            )
        } else {
            appState.finishConnecting(
                toId: instance.id,
                toPortIndex: portIndex
            )
        }

        dismiss()
    }
}

// MARK: - Multichannel Port Glyph
struct PortGlyph: View {
    let color: Color
    let bundleStyle: PortGroup.BundleStyle
    let showDisconnectMark: Bool
    
    var body: some View {
        switch bundleStyle {
        case .single:
            Circle()
                .fill(color)
                .frame(
                    width: NodeView.portDotSize,
                    height: NodeView.portDotSize
                )
                .overlay(Circle().stroke(Color.white, lineWidth: 1.25))
                .overlay {
                    if showDisconnectMark {
                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: NodeView.portXMarkSize,
                                    weight: .black
                                )
                            )
                            .foregroundColor(.white)
                    }
                }
            
        case .stereoPair:
            HStack(spacing: 2) {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
            .overlay {
                if showDisconnectMark {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: NodeView.portXMarkSize,
                                weight: .black
                            )
                        )
                        .foregroundColor(.white)
                }
            }
            
        case .multichannel:
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 15, height: 8)
                .overlay(
                    HStack(spacing: 2) {
                        Circle().fill(.white.opacity(0.85)).frame(
                            width: 2,
                            height: 2
                        )
                        Circle().fill(.white.opacity(0.85)).frame(
                            width: 2,
                            height: 2
                        )
                        Circle().fill(.white.opacity(0.85)).frame(
                            width: 2,
                            height: 2
                        )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white, lineWidth: 1)
                )
                .overlay {
                    if showDisconnectMark {
                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: NodeView.portXMarkSize,
                                    weight: .black
                                )
                            )
                            .foregroundColor(.white)
                    }
                }
            
        case .network:
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 15, height: 10)
                .overlay(
                    Image(systemName: "network")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white, lineWidth: 1)
                )
                .overlay {
                    if showDisconnectMark {
                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: NodeView.portXMarkSize,
                                    weight: .black
                                )
                            )
                            .foregroundColor(.white)
                    }
                }

        case .bindingPost:
            // Half-black (ground/negative), half-red (positive) banana jack post.
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 7, height: 10)
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 7, height: 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white, lineWidth: 1)
            )
            .overlay {
                if showDisconnectMark {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: NodeView.portXMarkSize,
                                weight: .black
                            )
                        )
                        .foregroundColor(.white)
                }
            }
        }
    }
}
// MARK: - IP Address Badge
/// Clickable green pill showing the device IP address, with a popover to edit it.
struct IPAddressBadge: View {
    @ObservedObject var instance: NodeInstance
    @State private var showingPopover = false
    @State private var editingIP: String = ""

    var body: some View {
        Button {
            editingIP = instance.ipAddress ?? ""
            showingPopover = true
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "network")
                    .font(.system(size: 7, weight: .medium))
                Text(instance.ipAddress ?? "Set IP")
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.green)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                Text("IP Address")
                    .font(.system(size: 12, weight: .semibold))

                TextField("e.g. 192.168.1.100", text: $editingIP)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)

                HStack {
                    Button("Clear") {
                        instance.ipAddress = nil
                        showingPopover = false
                    }
                    .foregroundColor(.red)
                    Spacer()
                    Button("Cancel") { showingPopover = false }
                    Button("Apply") {
                        instance.ipAddress = editingIP.trimmingCharacters(in: .whitespaces).isEmpty
                            ? nil : editingIP.trimmingCharacters(in: .whitespaces)
                        showingPopover = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(12)
            .frame(width: 220)
        }
    }
}

// MARK: - Port List Section
struct PortListSection: View {
    let inputs: [String]
    let outputs: [String]
    
    var body: some View {
        if inputs.isEmpty && outputs.isEmpty {
            EmptyView()
        } else {
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
// MARK: - Signal Type Descriptor Pill
struct PortPill: View {
    let name: String
    let isInput: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(
                    isInput
                    ? Color(red: 0.37, green: 0.36, blue: 0.90) : Color.blue
                )
                .frame(width: 5, height: 5)
            Text(name)
                .font(.system(size: 9))
                .foregroundColor(.primary.opacity(0.75))
                .lineLimit(1)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
            (isInput ? Color(red: 0.37, green: 0.36, blue: 0.90) : Color.blue)
                .opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

// MARK: - Slot Cards Section

struct SlotCardsSection: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var pickingSlot: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text("Expansion Slots")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.vertical, 4)
            .overlay(Divider(), alignment: .top)

            // One row per slot
            ForEach(0..<comp.slotCount, id: \.self) { slotIdx in
                SlotRow(
                    instance: instance,
                    hostComp: comp,
                    slotIndex: slotIdx,
                    card: instance.slotCards[slotIdx],
                    onAdd: { pickingSlot = slotIdx },
                    onRemove: {
                        let removedCard = instance.slotCards[slotIdx]
                        instance.slotCards.removeValue(forKey: slotIdx)

                        if let cardType = removedCard?.cardType,
                           let cardComp = Components.all[cardType] {
                            let effectivePorts = instance.effectivePorts ?? comp.ports

                            let removedInputCount = cardComp.ports.inputs.count
                            let removedOutputCount = cardComp.ports.outputs.count

                            appState.clampConnections(
                                for: instance.id,
                                inputCount: max(comp.ports.inputs.count, effectivePorts.inputs.count - removedInputCount),
                                outputCount: max(comp.ports.outputs.count, effectivePorts.outputs.count - removedOutputCount)
                            )
                        }
                    }
                )
            }
        }
        .sheet(isPresented: Binding(get: { pickingSlot != nil }, set: { if !$0 { pickingSlot = nil } })) {
            SlotCardPickerSheet(slotIndex: pickingSlot ?? 0, hostComp: comp) { cardType in
                if let slot = pickingSlot {
                    instance.slotCards[slot] = SlotCard(slotNumber: slot, cardType: cardType)
                }
                pickingSlot = nil
            }
        }
    }
}

// MARK: - Slot Row
private struct SlotRow: View {
    @ObservedObject var instance: NodeInstance
    let hostComp: Component
    let slotIndex: Int
    let card: SlotCard?
    let onAdd: () -> Void
    let onRemove: () -> Void

    private var cardComp: Component? {
        guard let c = card else { return nil }
        return Components.all[c.cardType]
    }

    var body: some View {
        HStack(spacing: 6) {
            Text("S\(slotIndex + 1)")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 18, alignment: .leading)

            Group {
                if let cc = cardComp {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.categoryColor(cc.category))
                            .frame(width: 6, height: 6)

                        Text(cc.name)
                            .font(.system(size: 9))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Button { onRemove() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                } else {
                    HStack(spacing: 6) {
                        Text("Empty")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary.opacity(0.6))

                        Spacer(minLength: 0)

                        Button { onAdd() } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 9))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 22, maxHeight: 22)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .frame(height: 22)
    }
}

struct SlotCardPickerSheet: View {
    let slotIndex: Int
    let hostComp: Component
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private var cards: [Component] {
        let all = Components.list.filter { $0.isSlotCard }
        if hostComp.compatibleCardIds.isEmpty { return all }
        return all.filter { hostComp.compatibleCardIds.contains($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose card for Slot \(slotIndex + 1)")
                .font(.system(size: 15, weight: .semibold))

            if cards.isEmpty {
                Text("No compatible cards found for this device.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(cards, id: \.id) { card in
                            Button {
                                onSelect(card.id)
                                dismiss()
                            } label: {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.categoryColor(card.category))
                                        .frame(width: 6, height: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(card.name)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text(card.desc)
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 400)
            }

            Button("Cancel") { dismiss() }
                .keyboardShortcut(.escape)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 340)
    }
}

// MARK: - Rack Node Header Height Preference
private struct RackHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 31
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
// MARK: - Rack Node View
struct RackNodeView: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @GestureState private var dragOffset: CGSize = .zero
    /// Measured height of the top bar + header HStack, used to position cross-rack port dots.
    @State private var headerHeight: CGFloat = 31
    @State private var showingSaveSheet = false
    @State private var saveRackName = ""
    
    private static let topBarH: CGFloat = 3
    private static let unitH: CGFloat = 20   // NodeView.rackUnitHeight
    
    // MARK: - Rack tab / slot items
    
    private var rackTab: CanvasTab? {
        appState.tabs.first { $0.parentRackInstanceId == instance.id }
    }
    
    private struct SlotItem {
        let topRow: Int
        let rowSpan: Int
        let inst: NodeInstance
        let comp: Component
    }
    
    private var slotItems: [SlotItem] {
        guard let tab = rackTab else { return [] }
        return tab.instances.compactMap { inst -> SlotItem? in
            guard let c = Components.all[inst.type] else { return nil }
            let topRow = min(inst.rackSlot ?? 0, comp.rackUnits - 1)
            return SlotItem(topRow: topRow, rowSpan: max(1, c.rackUnits), inst: inst, comp: c)
        }.sorted { $0.topRow < $1.topRow }
    }
    
    private var occupiedByItem: [Int: SlotItem] {
        var dict: [Int: SlotItem] = [:]
        for item in slotItems { dict[item.topRow] = item }
        return dict
    }
    
    private var continuationRows: Set<Int> {
        var rows = Set<Int>()
        for item in slotItems {
            for r in (item.topRow + 1)..<(item.topRow + item.rowSpan) {
                rows.insert(r)
            }
        }
        return rows
    }
    
    // MARK: - Body
    
    var body: some View {
        let items = slotItems
        let occupied = occupiedByItem
        let continued = continuationRows
        
        VStack(alignment: .leading, spacing: 0) {
            // Top color bar
            Rectangle()
                .fill(Color.categoryColor(comp.category))
                .frame(height: Self.topBarH)
            
            // Header — measure combined height for port positioning
            HStack {
                ComponentIcon(name: comp.iconName)
                    .frame(width: 16, height: 16)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(comp.name)
                        .font(.system(size: 11, weight: .semibold))
                    Text(comp.manufacturer)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
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
                
                Button {
                    saveRackName = comp.name
                    showingSaveSheet = true
                } label: {
                    Image(systemName: "star")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0)
                .padding(.trailing, 2)
                .help("Save to My Equipment")
                
                Button {
                    appState.deleteNode(id: instance.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(GeometryReader { geo in
                Color.clear.preference(
                    key: RackHeaderHeightKey.self,
                    value: Self.topBarH + geo.size.height
                )
            })
            
            // Rack body: slot rows
            VStack(spacing: 0) {
                ForEach(0..<comp.rackUnits, id: \.self) { i in
                    if continued.contains(i) {
                        // Continuation of a multi-U item — no row rendered
                        Color.clear.frame(height: 0)
                    } else if let item = occupied[i] {
                        rackItemRow(item: item)
                    } else {
                        emptySlotRow(i: i)
                    }
                }
            }
        }
        .frame(width: NodeView.rackWidth)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        // Cross-rack port dots — must be BEFORE .offset() so dots move with the card during drag
        .overlay {
            GeometryReader { geo in
                ForEach(items, id: \.inst.id) { item in
                    let itemTopY = headerHeight + CGFloat(item.topRow) * Self.unitH
                    let itemH = CGFloat(item.rowSpan) * Self.unitH
                    let effectivePorts = item.inst.effectivePorts ?? item.comp.ports
                    
                    let inputDisplayPorts = makeRackDisplayPorts(
                        labels: effectivePorts.inputs,
                        signalTypes: item.inst.effectiveInputTypes ?? item.comp.inputs,
                        side: "in"
                    )
                    
                    let outputDisplayPorts = makeRackDisplayPorts(
                        labels: effectivePorts.outputs,
                        signalTypes: item.inst.effectiveOutputTypes ?? item.comp.outputs,
                        side: "out"
                    )
                    
                    let alwaysShowGroups = shouldAlwaysShowRackGroups(for: item.comp)
                    
                    let visibleInputs = inputDisplayPorts.filter {
                        alwaysShowGroups || !rackAvailablePortIndexes(
                            instanceId: item.inst.id,
                            side: "in",
                            candidates: $0.portIndexes,
                            appState: appState
                        ).isEmpty
                    }
                    
                    let visibleOutputs = outputDisplayPorts.filter {
                        alwaysShowGroups || !rackAvailablePortIndexes(
                            instanceId: item.inst.id,
                            side: "out",
                            candidates: $0.portIndexes,
                            appState: appState
                        ).isEmpty
                    }
                    
                    if let inputPort = visibleInputs.first {
                        RackGroupedPortDot(
                            instance: item.inst,
                            displayPort: inputPort
                        )
                        .position(x: 0, y: itemTopY + itemH / 2)
                    }

                    if let outputPort = visibleOutputs.first {
                        RackGroupedPortDot(
                            instance: item.inst,
                            displayPort: outputPort
                        )
                        .position(x: geo.size.width, y: itemTopY + itemH / 2)
                    }
                }
            }
        }
        .offset(x: dragOffset.width, y: dragOffset.height)
        .gesture(
            DragGesture(minimumDistance: 4)
                .updating($dragOffset) { value, state, _ in
                    guard appState.connectingFromId == nil else { return }
                    state = value.translation
                }
                .onEnded { value in
                    guard appState.connectingFromId == nil else { return }
                    instance.position = CGPoint(
                        x: max(0, instance.position.x + value.translation.width),
                        y: max(0, instance.position.y + value.translation.height)
                    )
                }
        )
        .onPreferenceChange(RackHeaderHeightKey.self) { h in
            headerHeight = h
        }
        .sheet(isPresented: $showingSaveSheet) {
            SaveRackSheet(
                rackName: $saveRackName,
                onSave: { name in
                    appState.saveRackToMyEquipment(instanceId: instance.id, name: name)
                    showingSaveSheet = false
                },
                onCancel: { showingSaveSheet = false }
            )
        }
    }

    // MARK: - Slot row helpers
    
    @ViewBuilder
    private func rackItemRow(item: SlotItem) -> some View {
        let itemH = CGFloat(item.rowSpan) * Self.unitH
        let catColor = Color.categoryColor(item.comp.category)
        HStack(spacing: 0) {
            Rectangle()
                .fill(catColor)
                .frame(width: 4)
            HStack {
                Text(item.comp.name)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(item.comp.rackUnits)U")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
        }
        .frame(height: itemH)
        .background(catColor.opacity(0.08))
    }
    
    @ViewBuilder
    private func emptySlotRow(i: Int) -> some View {
        HStack {
            Text("\(comp.rackUnits - i)U")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 9)
        .frame(height: Self.unitH)
        .background(i.isMultiple(of: 2) ? Color.primary.opacity(0.03) : Color.clear)
    }
}
// MARK: - Save Rack Sheet
struct SaveRackSheet: View {
    @Binding var rackName: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Save to My Equipment")
                .font(.system(size: 14, weight: .semibold))

            TextField("Rack name", text: $rackName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 260)

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("Save") { onSave(rackName) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(rackName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}

// MARK: - SF Symbol icon wrapper
struct ComponentIcon: View {
    let name: String
    
    var body: some View {
        Image(systemName: sfSymbol(for: name))
            .resizable()
            .scaledToFit()
    }
    
    func sfSymbol(for iconName: String) -> String {
        switch iconName {
        case "mic", "mic_cond": return "mic"
        case "guitar": return "guitars"
        case "keyboard": return "pianokeys"
        case "di": return "arrow.left.arrow.right.square"
        case "preamp": return "amplifier"
        case "equalizer": return "slider.vertical.3"
        case "compressor": return "waveform.path.ecg"
        case "gate": return "waveform.path"
        case "effects": return "waveform"
        case "pedal": return "circle.grid.2x1"
        case "console": return "slider.horizontal.3"
        case "patchbay": return "cable.connector.horizontal"
        case "interface": return "cpu"
        case "power_amp": return "triangle"
        case "speaker": return "speaker.wave.3"
        case "monitor": return "desktopcomputer"
        case "headphones": return "headphones"
        case "headphone_amp": return "headphones.circle"
        case "wireless_rx": return "antenna.radiowaves.left.and.right"
        case "wireless_tx": return "dot.radiowaves.right"
        case "handheld": return "mic.fill"
        case "iem_tx": return "dot.radiowaves.left.and.right"
        case "iem_rx": return "earbuds"
        case "antenna": return "antenna.radiowaves.left.and.right"
        case "distro": return "arrow.triangle.branch"
        case "combiner": return "arrow.triangle.merge"
        case "network": return "network"
        case "stagebox": return "square.grid.3x3"
        case "power": return "bolt"
        case "rack": return "server.rack"
        default: return "questionmark.square"
        }
    }
}
// MARK: - Previews

extension AppState {
    fileprivate static var nodePreviewState: AppState {
        AppState()
    }
    
    fileprivate static var standardNodePreviewState: AppState {
        let state = AppState()
        if let type = Components.all.first(where: { !$0.value.isRack })?.key {
            state.addInstance(type: type, position: CGPoint(x: 120, y: 120))
        }
        return state
    }
    
    fileprivate static var rackNodePreviewState: AppState {
        let state = AppState()
        if let type = Components.all.first(where: { $0.value.isRack })?.key {
            state.addInstance(type: type, position: CGPoint(x: 120, y: 120))
        }
        return state
    }
    fileprivate static var slottedStandardNodePreviewState: AppState {
        let state = AppState()

        guard
            let hostComp = Components.all.values.first(where: { !$0.isRack && $0.slotCount > 0 }),
            let slotCardComp = Components.list.first(where: { $0.isSlotCard })
        else {
            return state
        }

        state.addInstance(type: hostComp.id, position: CGPoint(x: 120, y: 120))

        if let instance = state.instances.first {
            instance.slotCards[0] = SlotCard(slotNumber: 0, cardType: slotCardComp.id)
        }

        return state
    }
}
#Preview("StandardNodeView - Slotted") {
    Group {
        let state = AppState.slottedStandardNodePreviewState
        if let instance = state.instances.first {
            let comp = Components.all[instance.type] ?? .placeholder
            StandardNodeView(instance: instance, comp: comp)
                .environmentObject(state)
                .padding()
                .fixedSize()
                .coordinateSpace(name: "canvas")
        } else {
            Text("No slotted standard component available for preview")
                .padding()
        }
    }
}
#Preview("NodeView - Standard") {
    Group {
        if let instance = AppState.standardNodePreviewState.instances.first {
            NodeView(instance: instance)
                .environmentObject(AppState.standardNodePreviewState)
                .padding()
                .fixedSize()
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
                .fixedSize()
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
                .fixedSize()
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
                .fixedSize()
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
