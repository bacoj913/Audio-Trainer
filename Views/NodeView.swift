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
func bodyPortY(idx: Int, rowCount _: Int) -> CGFloat {
    let firstRowY = NodeView.standardTopReserved + NodeView.standardBodyTopInset
    return firstRowY + CGFloat(idx) * NodeView.standardPortSpacing
}
// TODO: Fix Distance to blue headphone level thing
/// Calculates standard node height
/// - Parameter comp: Component whos ports determine height.
/// - Returns: Total node height.
func standardNodeHeight(for comp: Component) -> CGFloat {
    let portCount = max(comp.ports.inputs.count, comp.ports.outputs.count)
    
    if portCount <= 1 {
        return NodeView.standardTopReserved
        + NodeView.standardMinBodyHeight
        + NodeView.standardBottomPadding
    }
    
    let portsHeight = CGFloat(portCount - 1) * NodeView.standardPortSpacing
    let bodyHeight = max(
        NodeView.standardMinBodyHeight,
        NodeView.standardBodyTopInset + portsHeight
        + NodeView.standardBodyBottomInset
    )
    
    return NodeView.standardTopReserved
    + bodyHeight
    + NodeView.standardBottomPadding
}
/// Estimated text width for layout sizing without exact text measurement.
/// - Parameters:
///   - text: Text to estimate.
///   - fontSize: Font size used for text.
/// - Returns: Approximate text width.
func estimatedTextWidth(_ text: String, fontSize: CGFloat) -> CGFloat {
    CGFloat(text.count) * fontSize * 0.58
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
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 8)
            
            Spacer(minLength: 0)
        }
        .frame(
            width: standardNodeWidth(for: comp),
            height: standardNodeHeight(for: comp)
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
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    guard appState.connectingFromId == nil else { return }
                    if dragStartPos == nil { dragStartPos = instance.position }
                    guard let start = dragStartPos else { return }
                    instance.position = CGPoint(
                        x: max(0, start.x + value.translation.width),
                        y: max(0, start.y + value.translation.height)
                    )
                }
                .onEnded { _ in
                    dragStartPos = nil
                }
        )
        // MARK: - Per-port interactive dots on card edges
        .overlay {
            GeometryReader { geo in
                let effectivePorts = instance.effectivePorts ?? comp.ports
                let inputPorts = makeVisualPorts(
                    labels: effectivePorts.inputs,
                    signalTypes: instance.effectiveInputTypes ?? comp.inputs
                )
                let outputPorts = makeVisualPorts(
                    labels: effectivePorts.outputs,
                    signalTypes: instance.effectiveOutputTypes ?? comp.outputs
                )
                
                let rowCount = max(inputPorts.count, outputPorts.count)
                
                ForEach(Array(inputPorts.enumerated()), id: \.offset) {
                    idx,
                    port in
                    PortEdgeDot(
                        instance: instance,
                        portIndex: idx,
                        side: "in",
                        total: inputPorts.count,
                        label: port.label,
                        signalType: port.signalType,
                        bundleStyle: port.bundleStyle
                    )
                    .position(
                        x: 0,
                        y: bodyPortY(idx: idx, rowCount: rowCount)
                    )
                }
                
                ForEach(Array(outputPorts.enumerated()), id: \.offset) {
                    idx,
                    port in
                    PortEdgeDot(
                        instance: instance,
                        portIndex: idx,
                        side: "out",
                        total: outputPorts.count,
                        label: port.label,
                        signalType: port.signalType,
                        bundleStyle: port.bundleStyle
                    )
                    .position(
                        x: geo.size.width,
                        y: bodyPortY(idx: idx, rowCount: rowCount)
                    )
                }
            }
        }
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
        .onTapGesture {
            if side == "out" {
                if !isConnecting {
                    appState.startConnecting(
                        fromId: instance.id,
                        fromPortIndex: portIndex
                    )
                } else if isSource {
                    appState.cancelConnecting()
                }
            } else {
                if isConnecting {
                    appState.finishConnecting(
                        toId: instance.id,
                        toPortIndex: portIndex
                    )
                } else if isConnected {
                    appState.disconnectInput(
                        instanceId: instance.id,
                        portIndex: portIndex
                    )
                }
            }
        }
        .help(
            side == "in"
            ? (isConnected
               ? "Click to disconnect" : "Input — click to connect")
            : "Output — click to start connection"
        )
    }
    
    private var glyphWithAnchor: some View {
        PortGlyph(
            color: color,
            bundleStyle: bundleStyle,
            showDisconnectMark: isConnected && side == "in" && !isConnecting
        )
        .shadow(
            color: color.opacity(0.5),
            radius: isSource ? 8 : (isConnecting && side == "in" ? 6 : 0)
        )
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: PortAnchorPref.self,
                    value: [
                        "\(instance.id)-\(side)-\(portIndex)":
                            CGPoint(
                                x: geo.size.width / 2,
                                y: geo.size.height / 2
                            )
                    ]
                )
            }
        )
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

// MARK: - Rack Node
// MARK: - Rack Node Header Height Preference
private struct RackHeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 31
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct RackNodeView: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @State private var dragStartPos: CGPoint?
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
            let topRow = min((inst.rackSlot ?? 0) / 2, comp.rackUnits - 1)
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
        .gesture(
            DragGesture(minimumDistance: 4)
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
        // Cross-rack port dots — rendered AFTER clipShape so they extend outside card edges
        .overlay {
            GeometryReader { geo in
                ForEach(items, id: \.inst.id) { item in
                    let itemTopY = headerHeight + CGFloat(item.topRow) * Self.unitH
                    let itemH = CGFloat(item.rowSpan) * Self.unitH
                    let effectivePorts = item.inst.effectivePorts ?? item.comp.ports
                    let inputPorts = makeVisualPorts(
                        labels: effectivePorts.inputs,
                        signalTypes: item.inst.effectiveInputTypes ?? item.comp.inputs
                    )
                    let outputPorts = makeVisualPorts(
                        labels: effectivePorts.outputs,
                        signalTypes: item.inst.effectiveOutputTypes ?? item.comp.outputs
                    )
                    // Limit displayed ports so they don't crowd in small slots
                    let maxPorts = max(1, Int(itemH / 14))
                    let visInputs = Array(inputPorts.prefix(maxPorts))
                    let visOutputs = Array(outputPorts.prefix(maxPorts))

                    ForEach(Array(visInputs.enumerated()), id: \.offset) { idx, port in
                        PortEdgeDot(
                            instance: item.inst,
                            portIndex: idx,
                            side: "in",
                            total: visInputs.count,
                            label: "",
                            signalType: port.signalType,
                            bundleStyle: port.bundleStyle
                        )
                        .position(
                            x: 0,
                            y: itemTopY + evenPortY(idx: idx, total: visInputs.count, height: itemH)
                        )
                    }

                    ForEach(Array(visOutputs.enumerated()), id: \.offset) { idx, port in
                        PortEdgeDot(
                            instance: item.inst,
                            portIndex: idx,
                            side: "out",
                            total: visOutputs.count,
                            label: "",
                            signalType: port.signalType,
                            bundleStyle: port.bundleStyle
                        )
                        .position(
                            x: geo.size.width,
                            y: itemTopY + evenPortY(idx: idx, total: visOutputs.count, height: itemH)
                        )
                    }
                }
            }
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
