import SwiftUI
import UniformTypeIdentifiers

// Height per rack unit (1U = 44.45mm physical, represented here as 44pt)
private let unitHeight: CGFloat = 44

// MARK: - Helpers
/// Splits a side's ports into rows, determined by ru-1.
/// - Parameters:
///   - totalPorts: Total number of ports on that side.
///   - rackUnits: Rack height of the device.
/// - Returns: Rows containing original port indexes.
func rackGearRows(totalPorts: Int, rackUnits: Int, maxPortsPerRow: Int = 8) -> [[Int]] {
    guard totalPorts > 0 else { return [] }

    let targetRows = max(rackUnits - 1, 1)
    let portsPerRow = max(
        1,
        min(
            maxPortsPerRow,
            Int(ceil(Double(totalPorts) / Double(targetRows)))
        )
    )

    var rows: [[Int]] = []
    var current: [Int] = []

    for i in 0..<totalPorts {
        current.append(i)

        if current.count == portsPerRow {
            rows.append(current)
            current = []
        }
    }

    if !current.isEmpty {
        rows.append(current)
    }

    return rows
}

/// Returns the y-position for a visual row of ports.
/// Rows are based on how many actual rows of ports exist, not rack unit count.
func rackGearRowY(
    row: Int,
    totalRows: Int,
    height: CGFloat,
    headerHeight: CGFloat
) -> CGFloat {
    let rows = max(totalRows, 1)
    let topInset: CGFloat = 14
    let bottomInset: CGFloat = 14

    let usableHeight = max(height - headerHeight - topInset - bottomInset, 12)
    let rowBandHeight = usableHeight / CGFloat(rows)

    return headerHeight + topInset + (CGFloat(row) + 0.5) * rowBandHeight
}

/// Calculates resizable left and right column spans based on how many ports each side has.
/// Increased center gap so input/output columns breathe more.
func rackGearColumnSpans(
    width: CGFloat,
    inputCount: Int,
    outputCount: Int
) -> (left: ClosedRange<CGFloat>, right: ClosedRange<CGFloat>) {
    let outerInset: CGFloat = 24
    let centerGap: CGFloat = 110

    let usableWidth = max(width - (outerInset * 2) - centerGap, 120)

    let inputWeight = max(CGFloat(inputCount), 1)
    let outputWeight = max(CGFloat(outputCount), 1)
    let totalWeight = inputWeight + outputWeight

    let leftWidth = usableWidth * (inputWeight / totalWeight)
    let leftMin = outerInset
    let leftMax = leftMin + leftWidth

    let rightMin = leftMax + centerGap
    let rightMax = width - outerInset

    return (leftMin...leftMax, rightMin...rightMax)
}

func rackGearPortX(idx: Int, total: Int, span: ClosedRange<CGFloat>) -> CGFloat {
    let minX = span.lowerBound
    let maxX = span.upperBound
    let usableWidth = maxX - minX

    guard total > 0 else { return (minX + maxX) / 2 }
    if total == 1 { return minX + usableWidth / 2 }

    let step = usableWidth / CGFloat(total - 1)
    return minX + CGFloat(idx) * step
}

func rackFacePortFamilyName(signalType: String, fallbackLabel: String) -> String {
    let normalized = signalType
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    let fallbackNormalized = fallbackLabel
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    switch normalized {
    case "dante", "aes67", "milan", "avb", "network":
        return "Dante"
    case "aes", "aes3":
        return "AES"
    case "madi":
        if fallbackNormalized.contains("aux") {
            return "Aux"
        }
        return "MADI"
    case "mic":
        return "Mic"
    case "line", "analog":
        return "Line"
    case "speaker":
        return "Spk"
    case "clock", "word clock", "wc":
        return "Clock"
    default:
        if fallbackNormalized.contains("word clock") || fallbackNormalized.contains("clock") {
            return "Clock"
        }
        if fallbackNormalized.contains("aux") {
            return "Aux"
        }

        if !fallbackLabel.isEmpty {
            let firstWord = fallbackLabel
                .split(separator: " ")
                .first
                .map(String.init) ?? ""
            return firstWord.isEmpty ? "Port" : firstWord
        }
        return "Port"
    }
}

func rackFacePortTrailingNumber(from label: String) -> String? {
    let digits = label.reversed().prefix { $0.isNumber }.reversed()
    return digits.isEmpty ? nil : String(digits)
}

func rackFacePortOrdinalWithinFamily(
    ports: [VisualPort],
    upTo portIndex: Int
) -> Int {
    guard ports.indices.contains(portIndex) else { return portIndex + 1 }

    let targetPort = ports[portIndex]
    let targetFamily = rackFacePortFamilyName(
        signalType: targetPort.signalType,
        fallbackLabel: targetPort.label
    )

    var ordinal = 0

    for idx in 0...portIndex {
        let port = ports[idx]
        let family = rackFacePortFamilyName(
            signalType: port.signalType,
            fallbackLabel: port.label
        )

        if family == targetFamily {
            ordinal += 1
        }
    }

    return ordinal
}

func rackFaceCompactLabel(
    for port: VisualPort,
    portIndex: Int,
    ports: [VisualPort]
) -> String {
    let family = rackFacePortFamilyName(
        signalType: port.signalType,
        fallbackLabel: port.label
    )

    let number = rackFacePortTrailingNumber(from: port.label)
        ?? "\(rackFacePortOrdinalWithinFamily(ports: ports, upTo: portIndex))"

    return "\(family) \(number)"
}
func rackFaceDisplayLabel(
    for port: VisualPort,
    portIndex: Int,
    ports: [VisualPort],
    inRowCount rowCount: Int,
    totalSideCount: Int
) -> String {
    if rowCount <= 4 && totalSideCount <= 8 {
        return port.label
    }
    
    if rowCount <= 8 {
        return rackFaceCompactLabel(
            for: port,
            portIndex: portIndex,
            ports: ports
        )
    }
    
    return rackFaceCompactLabel(
        for: port,
        portIndex: portIndex,
        ports: ports
    )
}
// MARK: - Rack Slot Layout Helpers

enum RackSlotArrangement {
    case horizontal
    case vertical
}

func rackGearSlotArrangement(for comp: Component) -> RackSlotArrangement {
    switch comp.category {
    case "Stage Racks", "Stage Boxes":
        return .vertical
    default:
        return .horizontal
    }
}

func rackGearSlotCardsAreaHeight(for comp: Component) -> CGFloat {
    guard comp.slotCount > 0 else { return 0 }

    switch rackGearSlotArrangement(for: comp) {
    case .horizontal:
        return CGFloat(comp.slotCount) * 22 + CGFloat(max(comp.slotCount - 1, 0)) * 4
    case .vertical:
        return 30
    }
}

func rackGearSlotSectionHeight(for comp: Component) -> CGFloat {
    guard comp.slotCount > 0 else { return 0 }
    return 16 + rackGearSlotCardsAreaHeight(for: comp)
}

// MARK: - Rack Slot Port Index Helpers

func rackSlotCardInputIndexes(
    instance: NodeInstance,
    hostComp: Component,
    slotIndex: Int
) -> [Int] {
    guard
        let slotCard = instance.slotCards[slotIndex],
        let cardComp = Components.all[slotCard.cardType]
    else {
        return []
    }

    var start = hostComp.ports.inputs.count

    for idx in 0..<slotIndex {
        if let prior = instance.slotCards[idx],
           let priorComp = Components.all[prior.cardType] {
            start += priorComp.ports.inputs.count
        }
    }

    return Array(start..<(start + cardComp.ports.inputs.count))
}

func rackSlotCardOutputIndexes(
    instance: NodeInstance,
    hostComp: Component,
    slotIndex: Int
) -> [Int] {
    guard
        let slotCard = instance.slotCards[slotIndex],
        let cardComp = Components.all[slotCard.cardType]
    else {
        return []
    }

    var start = hostComp.ports.outputs.count

    for idx in 0..<slotIndex {
        if let prior = instance.slotCards[idx],
           let priorComp = Components.all[prior.cardType] {
            start += priorComp.ports.outputs.count
        }
    }

    return Array(start..<(start + cardComp.ports.outputs.count))
}
// MARK: - RackCanvasView
struct RackCanvasView: View {
    @EnvironmentObject var appState: AppState
    @State private var mousePos: CGPoint = .zero

    private var tab: CanvasTab { appState.activeTab }

    /// The rack enclosure component this tab represents
    private var rackComp: Component? {
        guard let rackId = tab.parentRackInstanceId else { return nil }
        for t in appState.tabs {
            if let inst = t.instances.first(where: { $0.id == rackId }) {
                return Components.all[inst.type]
            }
        }
        return nil
    }

    private var totalUnits: Int { max(rackComp?.rackUnits ?? 16, 4) }

    var body: some View {
        VStack(spacing: 0) {
            rackHeader

            ZStack {
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 0) {
                            ForEach(0..<totalUnits, id: \.self) { slot in
                                RackSlotRow(slot: slot, totalUnits: totalUnits, tab: tab)
                            }
                        }

                        ForEach(tab.instances) { instance in
                            if let comp = Components.all[instance.type] {
                                RackGearItem(
                                    instance: instance,
                                    comp: comp,
                                    rackCapacity: totalUnits
                                )
                                .offset(y: CGFloat(instance.rackSlot ?? 0) * unitHeight)
                            }
                        }

                        // Canvas lives inside the content ZStack so it shares the same
                        // coordinate space as port anchors — curves stay attached when scrolling.
                        Canvas { ctx, _ in
                            drawConnections(ctx: ctx)

                            if let fromId = appState.connectingFromId,
                               let src = appState.portCenter(
                                for: fromId,
                                portIndex: appState.connectingFromPortIndex,
                                side: "out"
                               ) {
                                drawPreview(ctx: ctx, from: src, to: mousePos)
                            }
                        }
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity, minHeight: CGFloat(totalUnits) * unitHeight + 24)

                        ForEach(appState.connections) { conn in
                            ConnectionHitArea(connection: conn)
                        }
                    }
                    .coordinateSpace(name: "canvas")
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .onContinuousHover { phase in
                        if case .active(let loc) = phase {
                            mousePos = loc
                        }
                    }
                }
                .onDrop(of: [UTType.plainText], isTargeted: nil) { providers, location in
                    providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                        guard let data = data as? Data,
                              let typeId = String(data: data, encoding: .utf8) else { return }
                        DispatchQueue.main.async {
                            let scrollY = max(0, location.y - 12)
                            let targetSlot = Int(scrollY / unitHeight)
                            let clamped = min(targetSlot, totalUnits - 1)
                            let inst = appState.addInstance(
                                type: typeId,
                                position: CGPoint(x: 0, y: CGFloat(clamped) * unitHeight)
                            )
                            inst.rackSlot = clamped
                        }
                    }
                    return true
                }
                .onPreferenceChange(PortAnchorPref.self) { positions in
                    DispatchQueue.main.async {
                        appState.activeTab.portPositions.merge(positions) { $1 }
                    }
                }
            }
            .onTapGesture {
                if appState.connectingFromId != nil {
                    appState.cancelConnecting()
                }
            }
        }
    }

    // MARK: - Header
    private var rackHeader: some View {
        HStack(spacing: 8) {
            Button {
                appState.switchTab(index: 0)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .medium))
                    Text("Main")
                        .font(.system(size: 12))
                }
                .foregroundColor(.blue)
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(.secondary)

            Image(systemName: "server.rack")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Text(tab.name)
                .font(.system(size: 12, weight: .semibold))
// FIXME: Rack Units internally are doubled from actual
            if let comp = rackComp {
                Text("· \(comp.rackUnits)U capacity")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("Drag gear from sidebar into rack slots")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .frame(height: 36)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Connection drawing
    private func drawConnections(ctx: GraphicsContext) {
        for conn in appState.connections {
            guard let src = appState.portCenter(for: conn.fromId, portIndex: conn.fromPortIndex, side: "out"),
                  let dst = appState.portCenter(for: conn.toId, portIndex: conn.toPortIndex, side: "in")
            else { continue }

            let wireColor = connectionColor(for: conn)

            var path = Path()
            path.move(to: src)
            let cx = (dst.x - src.x) * 0.6
            path.addCurve(
                to: dst,
                control1: CGPoint(x: src.x + cx, y: src.y),
                control2: CGPoint(x: dst.x - cx, y: dst.y)
            )
            ctx.stroke(
                path,
                with: .color(wireColor.opacity(0.75)),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            drawArrowhead(ctx: ctx, at: dst, from: src, color: wireColor.opacity(0.75))
        }
    }

    private func connectionColor(for conn: NodeConnection) -> Color {
        let fromInst = appState.instances.first { $0.id == conn.fromId }
        let fromComp = Components.all[fromInst?.type ?? ""]
        let outputs = fromInst?.effectiveOutputTypes ?? fromComp?.outputs ?? []
        let sigType = outputs.indices.contains(conn.fromPortIndex)
            ? outputs[conn.fromPortIndex]
            : outputs.first ?? "line"
        return Color.signalTypeColor(sigType)
    }

    private func activeOutputSignalType() -> Color {
        guard let fromId = appState.connectingFromId else {
            return Color.blue.opacity(0.45)
        }
        let fromInst = appState.instances.first { $0.id == fromId }
        let fromComp = Components.all[fromInst?.type ?? ""]
        let outputs = fromInst?.effectiveOutputTypes ?? fromComp?.outputs ?? []
        let sigType = outputs.indices.contains(appState.connectingFromPortIndex)
            ? outputs[appState.connectingFromPortIndex]
            : outputs.first ?? "line"
        return Color.signalTypeColor(sigType).opacity(0.45)
    }

    private func drawPreview(ctx: GraphicsContext, from: CGPoint, to: CGPoint) {
        var path = Path()
        path.move(to: from)
        let cx = (to.x - from.x) * 0.6
        path.addCurve(
            to: to,
            control1: CGPoint(x: from.x + cx, y: from.y),
            control2: CGPoint(x: to.x - cx, y: to.y)
        )
        ctx.stroke(
            path,
            with: .color(activeOutputSignalType()),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 3])
        )
    }

    private func drawArrowhead(ctx: GraphicsContext, at tip: CGPoint, from origin: CGPoint, color: Color) {
        let angle = atan2(tip.y - origin.y, tip.x - origin.x)
        let arrowLen: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        let p1 = CGPoint(
            x: tip.x - arrowLen * cos(angle - arrowAngle),
            y: tip.y - arrowLen * sin(angle - arrowAngle)
        )
        let p2 = CGPoint(
            x: tip.x - arrowLen * cos(angle + arrowAngle),
            y: tip.y - arrowLen * sin(angle + arrowAngle)
        )

        var arrow = Path()
        arrow.move(to: tip)
        arrow.addLine(to: p1)
        arrow.addLine(to: p2)
        arrow.closeSubpath()
        ctx.fill(arrow, with: .color(color))
    }
}

// MARK: - Rack Slot Row
struct RackSlotRow: View {
    let slot: Int
    let totalUnits: Int
    let tab: CanvasTab

    private var isOccupied: Bool {
        tab.instances.contains { $0.rackSlot == slot }
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(totalUnits - slot)U")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, 6)

            Rectangle()
                .fill(slot.isMultiple(of: 2) ? Color.primary.opacity(0.025) : Color.clear)
                .frame(maxWidth: .infinity)
                .frame(height: unitHeight)
                .overlay(
                    Rectangle()
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
                )

            Text("\(totalUnits - slot)U")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 28, alignment: .leading)
                .padding(.leading, 6)
        }
    }
}

// MARK: - Rack Canvas Face Port
struct RackCanvasFacePort: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String
    var label: String = ""
    var signalType: String = "line"
    var bundleStyle: PortGroup.BundleStyle = .single
    var compactFor1U: Bool = false
    var isNetworkSwitch: Bool = false
    var usesAlignedSlotLabelLayout: Bool = false
    
    @EnvironmentObject var appState: AppState
    @State private var showingVlanPicker = false

    private var vlanId: Int { instance.portVlanTags[portIndex] ?? 0 }
    private var vlanColor: Color { Color.vlanColor(vlanId) }

    private var color: Color {
        isNetworkSwitch && vlanId > 0 ? vlanColor : Color.signalTypeColor(signalType)
    }

    private var isSource: Bool {
        appState.connectingFromId == instance.id
            && appState.connectingFromPortIndex == portIndex
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

    private var portShellWidth: CGFloat {
        compactFor1U ? 24 : 28
    }

    private var portShellHeight: CGFloat {
        compactFor1U ? 14 : 16
    }

    private var labelWidth: CGFloat {
        if usesAlignedSlotLabelLayout {
            return compactFor1U ? 52 : 44
        }
        return compactFor1U ? 38 : 44
    }

    private var labelBandHeight: CGFloat {
        compactFor1U ? 10 : 12
    }

    private var totalHeight: CGFloat {
        if usesAlignedSlotLabelLayout {
            return labelBandHeight + portShellHeight
        }
        return label.isEmpty ? (compactFor1U ? 16 : 18) : (compactFor1U ? 27 : 30)
    }

    private var glyphScale: CGFloat {
        compactFor1U ? 0.82 : 1.0
    }
    var body: some View {
        Group {
            if usesAlignedSlotLabelLayout {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        if !label.isEmpty {
                            Text(label)
                                .font(.system(size: compactFor1U ? 6 : 7, weight: .medium))
                                .foregroundColor(.primary.opacity(0.78))
                                .lineLimit(1)
                                .minimumScaleFactor(0.45)
                                .allowsTightening(true)
                                .truncationMode(.tail)
                                .frame(width: labelWidth, height: labelBandHeight, alignment: .top)
                                .fixedSize(horizontal: false, vertical: true)
                                .allowsHitTesting(false)
                        } else {
                            Color.clear
                                .frame(width: labelWidth, height: labelBandHeight)
                        }
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black.opacity(0.10))
                            .frame(width: portShellWidth, height: portShellHeight)

                        PortGlyph(
                            color: color,
                            bundleStyle: bundleStyle,
                            showDisconnectMark: isConnected && side == "in" && !isConnecting
                        )
                        .scaleEffect(glyphScale)

                        if isNetworkSwitch && vlanId > 0 {
                            Text("\(vlanId)")
                                .font(.system(size: 5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: labelWidth, height: portShellHeight, alignment: .top)
                }
                .frame(width: labelWidth, height: totalHeight, alignment: .top)
            } else {
                VStack(spacing: compactFor1U ? 1 : 2) {
                    if !label.isEmpty {
                        Text(label)
                            .font(.system(size: compactFor1U ? 6 : 7, weight: .medium))
                            .foregroundColor(.primary.opacity(0.78))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .truncationMode(.tail)
                            .frame(width: labelWidth, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .allowsHitTesting(false)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black.opacity(0.10))
                            .frame(width: portShellWidth, height: portShellHeight)

                        PortGlyph(
                            color: color,
                            bundleStyle: bundleStyle,
                            showDisconnectMark: isConnected && side == "in" && !isConnecting
                        )
                        .scaleEffect(glyphScale)

                        if isNetworkSwitch && vlanId > 0 {
                            Text("\(vlanId)")
                                .font(.system(size: 5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .frame(width: labelWidth, height: totalHeight, alignment: .top)
            }
        }
        .contentShape(Rectangle())
        .shadow(
            color: color.opacity(0.45),
            radius: isSource ? 8 : (isConnecting && side == "in" ? 6 : 0)
        )
        .popover(isPresented: $showingVlanPicker, arrowEdge: .bottom) {
            VlanPickerPopover(instance: instance, portIndex: portIndex, label: label)
                .environmentObject(appState)
        }
        .contextMenu {
            if isNetworkSwitch {
                Button("Set VLAN Tag…") { showingVlanPicker = true }
            }
        }
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
                    appState.disconnectInput(instanceId: instance.id, portIndex: portIndex)
                }
            }
        }
    }
}

// MARK: - VLAN Picker Popover
struct VlanPickerPopover: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let label: String

    @State private var vlanInput: String = ""
    @Environment(\.dismiss) private var dismiss

    private var currentVlan: Int { instance.portVlanTags[portIndex] ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label.isEmpty ? "Port \(portIndex + 1)" : label)
                .font(.system(size: 13, weight: .semibold))

            HStack(spacing: 8) {
                // Color swatch
                Circle()
                    .fill(Color.vlanColor(currentVlan))
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))

                Text(currentVlan == 0 ? "Untagged" : "VLAN \(currentVlan)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 6) {
                TextField("VLAN ID", text: $vlanInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)
                    .onSubmit { applyVlan() }

                Text("(1–4094, 0=untagged)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Clear") {
                    instance.portVlanTags.removeValue(forKey: portIndex)
                    dismiss()
                }
                .foregroundColor(.red)
                Spacer()
                Button("Apply") { applyVlan() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding(12)
        .frame(width: 240)
        .onAppear {
            vlanInput = currentVlan > 0 ? "\(currentVlan)" : ""
        }
    }

    private func applyVlan() {
        if let id = Int(vlanInput.trimmingCharacters(in: .whitespaces)), id >= 0, id <= 4094 {
            if id == 0 {
                instance.portVlanTags.removeValue(forKey: portIndex)
            } else {
                instance.portVlanTags[portIndex] = id
            }
        }
        dismiss()
    }
}

private struct RackSlotCardFace: View {
    @ObservedObject var instance: NodeInstance
    let hostComp: Component
    let slotIndex: Int
    let arrangement: RackSlotArrangement

    private var slotCard: SlotCard? {
        instance.slotCards[slotIndex]
    }

    private var cardComp: Component? {
        guard let slotCard else { return nil }
        return Components.all[slotCard.cardType]
    }

    private var inputIndexes: [Int] {
        rackSlotCardInputIndexes(
            instance: instance,
            hostComp: hostComp,
            slotIndex: slotIndex
        )
    }

    private var outputIndexes: [Int] {
        rackSlotCardOutputIndexes(
            instance: instance,
            hostComp: hostComp,
            slotIndex: slotIndex
        )
    }

    private var inputPorts: [VisualPort] {
        guard let cardComp else { return [] }
        return makeVisualPorts(
            labels: cardComp.ports.inputs,
            signalTypes: cardComp.inputs
        )
    }

    private var outputPorts: [VisualPort] {
        guard let cardComp else { return [] }
        return makeVisualPorts(
            labels: cardComp.ports.outputs,
            signalTypes: cardComp.outputs
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.primary.opacity(0.04))
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)

                if let cardComp {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.categoryColor(cardComp.category))
                            .frame(width: 5, height: 5)

                        Text(cardComp.name)
                            .font(.system(size: arrangement == .vertical ? 7 : 8, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, arrangement == .vertical ? 3 : 0)
                } else {
                    Text("Empty")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                switch arrangement {
                case .horizontal:
                    // Inputs in one horizontal row on the left half,
                    // outputs in one horizontal row on the right half.
                    ForEach(Array(inputPorts.enumerated()), id: \.offset) { idx, port in
                        if inputIndexes.indices.contains(idx) {
                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: inputIndexes[idx],
                                side: "in",
                                label: "",
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: true,
                                isNetworkSwitch: false,
                                usesAlignedSlotLabelLayout: true,
                            )
                            .position(
                                x: evenlySpacedX(
                                    idx: idx,
                                    total: inputPorts.count,
                                    minX: 18,
                                    maxX: max(18, geo.size.width * 0.44)
                                ),
                                y: geo.size.height * 0.72
                            )
                        }
                    }

                    ForEach(Array(outputPorts.enumerated()), id: \.offset) { idx, port in
                        if outputIndexes.indices.contains(idx) {
                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: outputIndexes[idx],
                                side: "out",
                                label: "",
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: true,
                                isNetworkSwitch: false,
                                usesAlignedSlotLabelLayout: true,
                            )
                            .position(
                                x: evenlySpacedX(
                                    idx: idx,
                                    total: outputPorts.count,
                                    minX: min(geo.size.width - 18, geo.size.width * 0.56),
                                    maxX: geo.size.width - 18
                                ),
                                y: geo.size.height * 0.72
                            )
                        }
                    }

                case .vertical:
                    let verticalPorts: [(Int, String, VisualPort)] =
                        Array(inputPorts.enumerated()).compactMap { idx, port in
                            guard inputIndexes.indices.contains(idx) else { return nil }
                            return (inputIndexes[idx], "in", port)
                        }
                        + Array(outputPorts.enumerated()).compactMap { idx, port in
                            guard outputIndexes.indices.contains(idx) else { return nil }
                            return (outputIndexes[idx], "out", port)
                        }

                    ForEach(Array(verticalPorts.enumerated()), id: \.element.0) { stackIndex, entry in
                        let portIndex = entry.0
                        let side = entry.1
                        let port = entry.2

                        RackCanvasFacePort(
                            instance: instance,
                            portIndex: portIndex,
                            side: side,
                            label: port.label,
                            signalType: port.signalType,
                            bundleStyle: port.bundleStyle,
                            compactFor1U: true,
                            isNetworkSwitch: false,
                            usesAlignedSlotLabelLayout: true,
                        )
                        .position(
                            x: geo.size.width * 0.5,
                            y: evenlySpacedY(
                                idx: stackIndex,
                                total: verticalPorts.count,
                                minY: 16,
                                maxY: geo.size.height - 16
                            )
                        )
                    }
                }
            }
        }
    }

    private func evenlySpacedX(idx: Int, total: Int, minX: CGFloat, maxX: CGFloat) -> CGFloat {
        guard total > 0 else { return (minX + maxX) / 2 }
        if total == 1 { return (minX + maxX) / 2 }

        let usable = max(maxX - minX, 4)
        return minX + CGFloat(idx) * usable / CGFloat(total - 1)
    }

    private func evenlySpacedY(idx: Int, total: Int, minY: CGFloat, maxY: CGFloat) -> CGFloat {
        guard total > 0 else { return (minY + maxY) / 2 }
        if total == 1 { return (minY + maxY) / 2 }

        let usable = max(maxY - minY, 4)
        return minY + CGFloat(idx) * usable / CGFloat(total - 1)
    }
}
// MARK: - Rack Gear Slot Section

private struct RackGearSlotSection: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component

    private var arrangement: RackSlotArrangement {
        rackGearSlotArrangement(for: comp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Expansion Slots")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }

            switch arrangement {
            case .horizontal:
                VStack(spacing: 4) {
                    ForEach(0..<comp.slotCount, id: \.self) { slotIdx in
                        HStack(spacing: 6) {
                            Text("S\(slotIdx + 1)")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 16, alignment: .leading)

                            RackSlotCardFace(
                                instance: instance,
                                hostComp: comp,
                                slotIndex: slotIdx,
                                arrangement: arrangement
                            )
                            .frame(maxHeight: .infinity)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)

            case .vertical:
                HStack(spacing: 6) {
                    ForEach(0..<comp.slotCount, id: \.self) { slotIdx in
                        VStack(spacing: 3) {
                            Text("S\(slotIdx + 1)")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)

                            RackSlotCardFace(
                                instance: instance,
                                hostComp: comp,
                                slotIndex: slotIdx,
                                arrangement: arrangement
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }
}
// MARK: - Rack Gear Item
struct RackGearItem: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    let rackCapacity: Int
    @EnvironmentObject var appState: AppState

    @State private var isHovered = false
    @State private var dragYOffset: CGFloat = 0
    @State private var showingConfig = false
    @GestureState private var isDragging = false

    private var itemHeight: CGFloat {
        CGFloat(max(comp.rackUnits, 1)) * unitHeight
    }

    private var isCompact1UNetwork: Bool {
        comp.rackUnits == 1 && comp.iconName == "network"
    }

    private var headerHeight: CGFloat {
        isCompact1UNetwork ? 20 : 28
    }

    private var currentRackSlot: Int {
        instance.rackSlot ?? 0
    }

    private var maxRackSlot: Int {
        max(rackCapacity - max(comp.rackUnits, 1), 0)
    }

    private var chassisPorts: PortInfo {
        comp.ports
    }

    private var chassisInputTypes: [String] {
        comp.inputs
    }

    private var chassisOutputTypes: [String] {
        comp.outputs
    }
    
    private var useCompactNetworkPorts: Bool {
        isCompact1UNetwork
    }
    
    private var slotSectionHeight: CGFloat {
        rackGearSlotSectionHeight(for: comp)
    }
    
    private var chassisFaceTopInset: CGFloat {
        headerHeight
        + (comp.slotCount > 0 ? slotSectionHeight + 8 : 0)
        + (isCompact1UNetwork ? 4 : 8)
    }

    private var chassisFaceRowCount: Int {
        if comp.slotCount > 0 {
            return 1
        }
        return max(comp.rackUnits - 1, 1)
    }
    
    private var slottedBuiltInPortsRowY: CGFloat {
        itemHeight - 24
    }

    private var slottedBuiltInPortsRowTop: CGFloat {
        slottedBuiltInPortsRowY - 18
    }
    
    private func clampedRackSlot(for translation: CGFloat) -> Int {
        let deltaSlots = Int(round(translation / unitHeight))
        return min(max(currentRackSlot + deltaSlots, 0), maxRackSlot)
    }

    var body: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: 34)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                Color.categoryColor(comp.category).opacity(0.45),
                                lineWidth: 1.25
                            )
                    )

                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.categoryColor(comp.category))
                            .frame(height: headerHeight)

                        HStack(spacing: 6) {
                            ComponentIcon(name: comp.iconName)
                                .frame(
                                    width: isCompact1UNetwork ? 13 : 16,
                                    height: isCompact1UNetwork ? 13 : 16
                                )
                                .foregroundColor(
                                    Color.categoryColor(comp.category).wcagContrastingTextColor
                                )

                            Text(comp.name)
                                .font(.system(size: isCompact1UNetwork ? 10 : 11, weight: .semibold))
                                .foregroundColor(
                                    Color.categoryColor(comp.category).wcagContrastingTextColor
                                )
                                .lineLimit(1)

                            Spacer()

                            if comp.rackUnits > 0 {
                                Text("\(comp.rackUnits)U")
                                    .font(.system(size: isCompact1UNetwork ? 8 : 9, weight: .medium, design: .monospaced))
                                    .foregroundColor(
                                        Color.categoryColor(comp.category)
                                            .wcagContrastingTextColor
                                            .opacity(0.85)
                                    )
                            }

                            if comp.id == "configurable_io_2u" {
                                Button {
                                    showingConfig = true
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 10))
                                        .foregroundColor(
                                            Color.categoryColor(comp.category)
                                                .wcagContrastingTextColor
                                                .opacity(0.9)
                                        )
                                }
                                .buttonStyle(.plain)
                                .opacity(isHovered ? 1 : 0.75)
                                .popover(isPresented: $showingConfig, arrowEdge: .trailing) {
                                    IOConfigPopoverView(instance: instance)
                                        .environmentObject(appState)
                                }
                            }

                            if !comp.availablePresets.isEmpty {
                                Menu {
                                    Button("None") { instance.selectedPreset = nil }
                                    Divider()
                                    ForEach(comp.availablePresets, id: \.self) { preset in
                                        Button(preset) { instance.selectedPreset = preset }
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Image(systemName: "list.bullet")
                                            .font(.system(size: 8))
                                        Text(instance.selectedPreset ?? "Module")
                                            .font(.system(size: isCompact1UNetwork ? 7 : 8, weight: .medium))
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(
                                        Color.categoryColor(comp.category)
                                            .wcagContrastingTextColor
                                            .opacity(0.9)
                                    )
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.12))
                                    )
                                }
                                .menuStyle(.borderlessButton)
                                .fixedSize()
                                .opacity(isHovered ? 1 : 0.75)
                            }

                            Button {
                                appState.deleteNode(id: instance.id)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(
                                        Color.categoryColor(comp.category)
                                            .wcagContrastingTextColor
                                            .opacity(0.9)
                                    )
                            }
                            .buttonStyle(.plain)
                            .opacity(isHovered ? 1 : 0.75)
                        }
                        .padding(.horizontal, isCompact1UNetwork ? 6 : 8)
                    }
                    if comp.slotCount > 0 {
                        RackGearSlotSection(instance: instance, comp: comp)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: max(slottedBuiltInPortsRowTop - headerHeight - 8, 24),
                                alignment: .top
                            )

                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    } else {
                        Spacer(minLength: 0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: itemHeight - (isCompact1UNetwork ? 10 : 4))
            .overlay {
                GeometryReader { geo in
                    let visualRows = chassisFaceRowCount

                    let inputPorts = makeVisualPorts(
                        labels: chassisPorts.inputs,
                        signalTypes: chassisInputTypes
                    )
                    let outputPorts = makeVisualPorts(
                        labels: chassisPorts.outputs,
                        signalTypes: chassisOutputTypes
                    )

                    let inputRows = rackGearRows(
                        totalPorts: inputPorts.count,
                        rackUnits: visualRows + 1,
                        maxPortsPerRow: 8
                    )
                    let outputRows = rackGearRows(
                        totalPorts: outputPorts.count,
                        rackUnits: visualRows + 1,
                        maxPortsPerRow: 8
                    )

                    let spans = rackGearColumnSpans(
                        width: geo.size.width,
                        inputCount: inputPorts.count,
                        outputCount: outputPorts.count
                    )

                    ForEach(0..<visualRows, id: \.self) { row in
                        let inputRow = inputRows.indices.contains(row) ? inputRows[row] : []
                        let outputRow = outputRows.indices.contains(row) ? outputRows[row] : []

                        let rowY = comp.slotCount > 0
                            ? slottedBuiltInPortsRowY
                            : min(
                                rackGearRowY(
                                    row: row,
                                    totalRows: visualRows,
                                    height: max(geo.size.height - chassisFaceTopInset, 20),
                                    headerHeight: 0
                                ) + chassisFaceTopInset,
                                geo.size.height - 8
                            )
                        
                        ForEach(Array(inputRow.enumerated()), id: \.element) { rowIndex, originalIndex in
                            let port = inputPorts[originalIndex]

                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: originalIndex,
                                side: "in",
                                label: rackFaceDisplayLabel(
                                    for: port,
                                    portIndex: originalIndex,
                                    ports: inputPorts,
                                    inRowCount: inputRow.count,
                                    totalSideCount: inputPorts.count
                                ),
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: useCompactNetworkPorts && port.bundleStyle == .network,
                                isNetworkSwitch: comp.category == "Networking"
                            )
                            .position(
                                x: rackGearPortX(
                                    idx: rowIndex,
                                    total: inputRow.count,
                                    span: spans.left
                                ),
                                y: rowY
                            )
                        }

                        ForEach(Array(outputRow.enumerated()), id: \.element) { rowIndex, originalIndex in
                            let port = outputPorts[originalIndex]

                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: originalIndex,
                                side: "out",
                                label: rackFaceDisplayLabel(
                                    for: port,
                                    portIndex: originalIndex,
                                    ports: inputPorts,
                                    inRowCount: inputRow.count,
                                    totalSideCount: inputPorts.count
                                ),
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: useCompactNetworkPorts && port.bundleStyle == .network,
                                isNetworkSwitch: comp.category == "Networking"
                            )
                            .position(
                                x: rackGearPortX(
                                    idx: rowIndex,
                                    total: outputRow.count,
                                    span: spans.right
                                ),
                                y: rowY
                            )
                        }
                    }
                }
            }

            Color.clear.frame(width: 34)
        }
        .frame(height: itemHeight)
        .offset(y: dragYOffset)
        .zIndex(isDragging ? 1000 : 1)
        .onHover { isHovered = $0 }
        // simultaneousGesture lets child tap gestures fire even while the parent
        // drag is evaluating, fixing port clicks on dense/network devices.
        .simultaneousGesture(
            DragGesture(minimumDistance: 6)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    if abs(value.translation.height) > 4 {
                        dragYOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    let newSlot = clampedRackSlot(for: value.translation.height)

                    withAnimation(.snappy(duration: 0.16)) {
                        instance.rackSlot = newSlot
                        dragYOffset = 0
                    }
                }
        )
        .shadow(
            color: .black.opacity(isDragging ? 0.16 : (isHovered ? 0.12 : 0.04)),
            radius: isDragging ? 8 : (isHovered ? 6 : 2),
            x: 0,
            y: 2
        )
    }
}

// MARK: - I/O Configuration Popover
struct IOConfigPopoverView: View {
    @ObservedObject var instance: NodeInstance
    @EnvironmentObject var appState: AppState

    @State private var config: IOConfig = IOConfig()

    private let signalTypes: [(label: String, value: String)] = [
        ("Mic", "mic"),
        ("Line", "line"),
        ("AES", "aes"),
        ("MADI", "madi"),
        ("Dante", "dante"),
        ("Fiber", "fiber"),
        ("Optical", "optical"),
        ("RF", "rf"),
        ("Speaker", "speaker")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configure I/O")
                .font(.system(size: 13, weight: .semibold))

            GroupBox("Inputs") {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper("Count: \(config.inputCount)", value: $config.inputCount, in: 1...32)
                        .font(.system(size: 12))
                    Picker("Type", selection: $config.inputSignalType) {
                        ForEach(signalTypes, id: \.value) { item in
                            Text(item.label).tag(item.value)
                        }
                    }
                    .font(.system(size: 12))
                }
                .padding(.vertical, 4)
            }

            GroupBox("Outputs") {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper("Count: \(config.outputCount)", value: $config.outputCount, in: 1...32)
                        .font(.system(size: 12))
                    Picker("Type", selection: $config.outputSignalType) {
                        ForEach(signalTypes, id: \.value) { item in
                            Text(item.label).tag(item.value)
                        }
                    }
                    .font(.system(size: 12))
                }
                .padding(.vertical, 4)
            }

            HStack {
                Spacer()
                Button("Apply") {
                    instance.ioConfig = config
                    appState.clampConnections(
                        for: instance.id,
                        inputCount: config.inputCount,
                        outputCount: config.outputCount
                    )
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(16)
        .frame(width: 240)
        .onAppear {
            config = instance.ioConfig ?? IOConfig()
        }
    }
}

// MARK: - Previews

private extension AppState {
    /// AppState with a rack tab open and a few components placed inside.
    static var rackCanvasPreviewState: AppState {
        let s = AppState()
        // Place a rack enclosure on the main canvas
        let rackInst = s.addInstance(type: "rack_8u", position: CGPoint(x: 200, y: 200))
        // Open its interior tab so it becomes the active tab
        s.openRackTab(for: rackInst.id)
        // Populate the rack with some gear
        let amp = NodeInstance(type: "power_amp", position: CGPoint(x: 0, y: 0))
        amp.rackSlot = 0
        let eq  = NodeInstance(type: "equalizer",  position: CGPoint(x: 0, y: 44))
        eq.rackSlot = 1
        let comp = NodeInstance(type: "compressor", position: CGPoint(x: 0, y: 88))
        comp.rackSlot = 2
        s.activeTab.instances.append(contentsOf: [amp, eq, comp])
        return s
    }

    static var rackCanvasNetworkState: AppState {
        let s = AppState()
        let rackInst = s.addInstance(type: "rack_8u", position: CGPoint(x: 200, y: 200))
        s.openRackTab(for: rackInst.id)
        let sw = NodeInstance(type: "dante_switch", position: CGPoint(x: 0, y: 0))
        sw.rackSlot = 0
        let amp = NodeInstance(type: "power_amp", position: CGPoint(x: 0, y: 44))
        amp.rackSlot = 1
        s.activeTab.instances.append(contentsOf: [sw, amp])
        return s
    }
    static var rackCanvasSlottedDeviceState: AppState {
        let s = AppState()

        // Create a rack enclosure and open its rack tab
        let rackInst = s.addInstance(type: "rack_8u", position: CGPoint(x: 200, y: 200))
        s.openRackTab(for: rackInst.id)

        // Find a rackmount device that has expansion slots
        guard
            let hostComp = Components.all.values.first(where: { !$0.isRack && $0.rackUnits > 0 && $0.slotCount > 0}),
            let slotCardComp = Components.list.first(where: { $0.isSlotCard })
        else {
            return s
        }

        // Add the slotted device into the rack tab
        let hostInst = NodeInstance(type: hostComp.id, position: CGPoint(x: 0, y: 0))
        hostInst.rackSlot = 0
        hostInst.slotCards[0] = SlotCard(slotNumber: 0, cardType: slotCardComp.id)

        s.activeTab.instances.append(hostInst)
        return s
    }
}

#Preview("Rack Canvas – Populated") {
    RackCanvasView()
        .environmentObject(AppState.rackCanvasPreviewState)
        .frame(width: 860, height: 700)
}

#Preview("Rack Canvas – Network Gear") {
    RackCanvasView()
        .environmentObject(AppState.rackCanvasNetworkState)
        .frame(width: 860, height: 700)
}

#Preview("Rack Canvas – Slotted Device") {
    RackCanvasView()
        .environmentObject(AppState.rackCanvasSlottedDeviceState)
        .frame(width: 860, height: 700)
}

#Preview("Rack Gear Item – Unslotted") {
    let instance = NodeInstance(type: "power_amp", position: .zero)
    instance.rackSlot = 0

    let comp = Components.all["power_amp"]!

    return ZStack(alignment: .topLeading) {
        RackSlotRow(slot: 0, totalUnits: 8, tab: CanvasTab(name: "Preview"))
        RackGearItem(
            instance: instance,
            comp: comp,
            rackCapacity: 8
        )
    }
    .environmentObject(AppState())
    .frame(width: 820, height: 220)
    .padding()
}

#Preview("Rack Gear Item – Slotted") {
    let instance = NodeInstance(type: "stagebox_32", position: .zero)
    instance.rackSlot = 0

    if let slotCardComp = Components.list.first(where: { $0.isSlotCard }) {
        instance.slotCards[0] = SlotCard(slotNumber: 0, cardType: slotCardComp.id)
        instance.slotCards[1] = SlotCard(slotNumber: 1, cardType: slotCardComp.id)
    }

    let comp = Components.all["stagebox_32"]!

    return ZStack(alignment: .topLeading) {
        RackSlotRow(slot: 0, totalUnits: 8, tab: CanvasTab(name: "Preview"))
        RackGearItem(
            instance: instance,
            comp: comp,
            rackCapacity: 8
        )
    }
    .environmentObject(AppState())
    .frame(width: 820, height: 320)
    .padding()
}

#Preview("Rack Canvas – Empty") {
    let s = AppState()
    let rack = s.addInstance(type: "rack_8u", position: .zero)
    s.openRackTab(for: rack.id)
    return RackCanvasView()
        .environmentObject(s)
        .frame(width: 860, height: 700)
}

#Preview("VLAN Picker Popover") {
    let inst = NodeInstance(type: "dante_switch", position: .zero)
    VlanPickerPopover(instance: inst, portIndex: 0, label: "Dante Port 1")
        .environmentObject(AppState())
        .frame(width: 240)
}

