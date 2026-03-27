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

    switch normalized {
    case "dante", "aes67", "milan", "avb", "network":
        return "Dante"
    case "aes", "aes3":
        return "AES"
    case "madi":
        return "MADI"
    case "mic":
        return "Mic"
    case "line", "analog":
        return "Line"
    case "speaker":
        return "Spk"
    default:
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

func rackFacePortTrailingNumber(from label: String, fallback index: Int) -> String {
    let digits = label.reversed().prefix { $0.isNumber }.reversed()
    if !digits.isEmpty {
        return String(digits)
    }
    return "\(index + 1)"
}

func rackFaceCompactLabel(
    for port: VisualPort,
    portIndex: Int
) -> String {
    let family = rackFacePortFamilyName(
        signalType: port.signalType,
        fallbackLabel: port.label
    )
    let number = rackFacePortTrailingNumber(
        from: port.label,
        fallback: portIndex
    )
    return "\(family) \(number)"
}

func rackFaceDisplayLabel(
    for port: VisualPort,
    portIndex: Int,
    inRowCount rowCount: Int,
    totalSideCount: Int
) -> String {
    if rowCount <= 4 && totalSideCount <= 8 {
        return port.label
    }

    if rowCount <= 8 {
        return rackFaceCompactLabel(
            for: port,
            portIndex: portIndex
        )
    }

    // Extremely dense rows: still keep names, but only compact ones
    return rackFaceCompactLabel(
        for: port,
        portIndex: portIndex
    )
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

    private var totalUnits: Int { max(rackComp?.rackUnits ?? 16, 4) * 2 }

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
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
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
                .coordinateSpace(name: "canvas")
                .onPreferenceChange(PortAnchorPref.self) { positions in
                    DispatchQueue.main.async {
                        appState.activeTab.portPositions.merge(positions) { $1 }
                    }
                }

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

                ForEach(appState.connections) { conn in
                    ConnectionHitArea(connection: conn)
                }
            }
            .onContinuousHover { phase in
                if case .active(let loc) = phase {
                    mousePos = loc
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
                Text("· \(comp.rackUnits * 2)U capacity")
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

    @EnvironmentObject var appState: AppState

    private var color: Color { Color.signalTypeColor(signalType) }

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
        compactFor1U ? 38 : 44
    }

    private var totalHeight: CGFloat {
        label.isEmpty ? (compactFor1U ? 16 : 18) : (compactFor1U ? 27 : 30)
    }

    private var glyphScale: CGFloat {
        compactFor1U ? 0.82 : 1.0
    }

    var body: some View {
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
            }
        }
        .frame(width: labelWidth, height: totalHeight, alignment: .top)
        .contentShape(Rectangle())
        .shadow(
            color: color.opacity(0.45),
            radius: isSource ? 8 : (isConnecting && side == "in" ? 6 : 0)
        )
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: PortAnchorPref.self,
                    value: [
                        "\(instance.id)-\(side)-\(portIndex)": geo.frame(in: .named("canvas")).center
                    ]
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
                    appState.disconnectInput(instanceId: instance.id, portIndex: portIndex)
                }
            }
        }
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

    private var effectivePorts: PortInfo {
        instance.effectivePorts ?? comp.ports
    }

    private var effectiveInputTypes: [String] {
        instance.effectiveInputTypes ?? comp.inputs
    }

    private var effectiveOutputTypes: [String] {
        instance.effectiveOutputTypes ?? comp.outputs
    }
    
    private var useCompactNetworkPorts: Bool {
        isCompact1UNetwork
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

                    Spacer(minLength: 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: itemHeight - (isCompact1UNetwork ? 10 : 4))
            .overlay {
                GeometryReader { geo in
                    let visualRows = max(comp.rackUnits - 1, 1)

                    let inputPorts = makeVisualPorts(
                        labels: effectivePorts.inputs,
                        signalTypes: effectiveInputTypes
                    )
                    let outputPorts = makeVisualPorts(
                        labels: effectivePorts.outputs,
                        signalTypes: effectiveOutputTypes
                    )

                    let inputRows = rackGearRows(
                        totalPorts: inputPorts.count,
                        rackUnits: max(comp.rackUnits, 1),
                        maxPortsPerRow: 8
                    )
                    let outputRows = rackGearRows(
                        totalPorts: outputPorts.count,
                        rackUnits: max(comp.rackUnits, 1),
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

                        let rowY = rackGearRowY(
                            row: row,
                            totalRows: visualRows,
                            height: geo.size.height,
                            headerHeight: headerHeight + (isCompact1UNetwork ? 4 : 8)
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
                                    inRowCount: inputRow.count,
                                    totalSideCount: inputPorts.count
                                ),
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: useCompactNetworkPorts && port.bundleStyle == .network
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
                                    inRowCount: outputRow.count,
                                    totalSideCount: outputPorts.count
                                ),
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle,
                                compactFor1U: useCompactNetworkPorts && port.bundleStyle == .network
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
        .gesture(
            DragGesture(minimumDistance: 2)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    dragYOffset = value.translation.height
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
