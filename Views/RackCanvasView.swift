// Views/RackCanvasView.swift — Rack unit grid inner canvas for placing gear inside a rack enclosure

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
func rackGearRows(totalPorts: Int, rackUnits: Int, maxPortsPerRow: Int = 8)
    -> [[Int]]
{
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
func rackGearPortX(idx: Int, total: Int, span: ClosedRange<CGFloat>) -> CGFloat
{
    let minX = span.lowerBound
    let maxX = span.upperBound
    let usableWidth = maxX - minX

    guard total > 0 else { return (minX + maxX) / 2 }
    if total == 1 { return minX + usableWidth / 2 }

    let step = usableWidth / CGFloat(total - 1)
    return minX + CGFloat(idx) * step
}
//MARK: - RackCanvasView
struct RackCanvasView: View {
    @EnvironmentObject var appState: AppState

    private var tab: CanvasTab { appState.activeTab }

    /// The rack enclosure component this tab represents
    private var rackComp: Component? {
        guard let rackId = tab.parentRackInstanceId else { return nil }
        // Search all tabs for the rack instance
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
            // Breadcrumb / header
            rackHeader

            // Rack unit grid with drop support
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Rack unit slot rows
                    VStack(spacing: 0) {
                        ForEach(0..<totalUnits, id: \.self) { slot in
                            RackSlotRow(
                                slot: slot,
                                totalUnits: totalUnits,
                                tab: tab
                            )
                        }
                    }

                    // Placed gear items (overlay on top of slot grid)
                    ForEach(tab.instances) { instance in
                        if let comp = Components.all[instance.type] {
                            RackGearItem(
                                instance: instance,
                                comp: comp,
                                rackCapacity: totalUnits
                            )
                            .offset(
                                y: CGFloat(instance.rackSlot ?? 0) * unitHeight
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
            }
            .onDrop(of: [UTType.plainText], isTargeted: nil) {
                providers,
                location in
                providers.first?.loadItem(
                    forTypeIdentifier: UTType.plainText.identifier
                ) { data, _ in
                    guard let data = data as? Data,
                        let typeId = String(data: data, encoding: .utf8)
                    else { return }
                    DispatchQueue.main.async {
                        // Determine target rack slot from Y position
                        let scrollY = max(0, location.y - 12)  // subtract padding
                        let targetSlot = Int(scrollY / unitHeight)
                        let clamped = min(targetSlot, totalUnits - 1)
                        let inst = appState.addInstance(
                            type: typeId,
                            position: CGPoint(
                                x: 0,
                                y: CGFloat(clamped) * unitHeight
                            )
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
        }
    }

    // MARK: - Header
    private var rackHeader: some View {
        HStack(spacing: 8) {
            // Back to main
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
            // U number label
            Text("\(totalUnits - slot)U")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, 6)

            // Slot area
            Rectangle()
                .fill(
                    slot.isMultiple(of: 2)
                        ? Color.primary.opacity(0.025)
                        : Color.clear
                )
                .frame(maxWidth: .infinity)
                .frame(height: unitHeight)
                .overlay(
                    Rectangle()
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
                )

            // Right U number
            Text("\(totalUnits - slot)U")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 28, alignment: .leading)
                .padding(.leading, 6)
        }
    }
}

//MARK: - Rack Canvas Face Port
struct RackCanvasFacePort: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String
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
        VStack(spacing: 3) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(.primary.opacity(0.72))
                    .lineLimit(1)
                    .fixedSize()
                    .allowsHitTesting(false)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.10))
                    .frame(width: 28, height: 16)

                PortGlyph(
                    color: color,
                    bundleStyle: bundleStyle,
                    showDisconnectMark: isConnected && side == "in"
                        && !isConnecting
                )
            }
        }
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
    }
}

// MARK: - Rack Gear Item
/// A component placed inside the rack, displayed as a colored block spanning its rackUnits height
struct RackGearItem: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    let rackCapacity: Int
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @State private var dragYOffset: CGFloat = 0
    @GestureState private var isDragging = false

    private var itemHeight: CGFloat {
        CGFloat(max(comp.rackUnits, 1)) * unitHeight
    }

    private var headerHeight: CGFloat {
        28
    }
    private var currentRackSlot: Int {
        instance.rackSlot ?? 0
    }

    private var maxRackSlot: Int {
        max(rackCapacity - max(comp.rackUnits, 1), 0)
    }

    private func clampedRackSlot(for translation: CGFloat) -> Int {
        let deltaSlots = Int(round(translation / unitHeight))
        return min(max(currentRackSlot + deltaSlots, 0), maxRackSlot)
    }
    var body: some View {
        HStack(spacing: 0) {
            // Left indent to align with slot area (28pt label + 6pt padding)
            Color.clear.frame(width: 34)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                Color.categoryColor(comp.category).opacity(
                                    0.45
                                ),
                                lineWidth: 1.25
                            )
                    )

                VStack(alignment: .leading, spacing: 0) {
                    // Header styled similarly to normal node header
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.categoryColor(comp.category))
                            .frame(height: headerHeight)

                        HStack(spacing: 6) {
                            ComponentIcon(name: comp.iconName)
                                .frame(width: 16, height: 16)
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
                                .lineLimit(1)

                            Spacer()

                            if comp.rackUnits > 0 {
                                Text("\(comp.rackUnits)U")
                                    .font(
                                        .system(
                                            size: 9,
                                            weight: .medium,
                                            design: .monospaced
                                        )
                                    )
                                    .foregroundColor(
                                        Color.categoryColor(comp.category)
                                            .wcagContrastingTextColor
                                            .opacity(0.85)
                                    )
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
                        .padding(.horizontal, 8)
                    }

                    // Face/body
                    Spacer(minLength: 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: itemHeight - 4)
            .overlay {
                GeometryReader { geo in
                    let headerHeight: CGFloat = 30
                    let visualRows = max(comp.rackUnits - 1, 1)

                    let inputPorts = makeVisualPorts(
                        labels: comp.ports.inputs,
                        signalTypes: comp.inputs
                    )
                    let outputPorts = makeVisualPorts(
                        labels: comp.ports.outputs,
                        signalTypes: comp.outputs
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
                        let inputRow =
                            inputRows.indices.contains(row)
                            ? inputRows[row] : []
                        let outputRow =
                            outputRows.indices.contains(row)
                            ? outputRows[row] : []

                        let rowY = rackGearRowY(
                            row: row,
                            totalRows: visualRows,
                            height: geo.size.height,
                            headerHeight: headerHeight
                        )

                        ForEach(Array(inputRow.enumerated()), id: \.element) {
                            rowIndex,
                            originalIndex in
                            let port = inputPorts[originalIndex]

                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: originalIndex,
                                side: "in",
                                label: port.label,
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle
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

                        ForEach(Array(outputRow.enumerated()), id: \.element) {
                            rowIndex,
                            originalIndex in
                            let port = outputPorts[originalIndex]

                            RackCanvasFacePort(
                                instance: instance,
                                portIndex: originalIndex,
                                side: "out",
                                label: port.label,
                                signalType: port.signalType,
                                bundleStyle: port.bundleStyle
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
            // Right indent
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
