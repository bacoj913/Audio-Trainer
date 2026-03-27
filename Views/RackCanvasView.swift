// Views/RackCanvasView.swift — Rack unit grid inner canvas for placing gear inside a rack enclosure

import SwiftUI
import UniformTypeIdentifiers

// Height per rack unit (1U = 44.45mm physical, represented here as 44pt)
private let unitHeight: CGFloat = 44

struct RackCanvasView: View {
    @EnvironmentObject var appState: AppState
    @State private var mousePos: CGPoint = .zero

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

            // Wire ZStack: ScrollView + connection canvas overlay
            ZStack {
                // Rack unit grid with drop support
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        // Rack unit slot rows
                        VStack(spacing: 0) {
                            ForEach(0..<totalUnits, id: \.self) { slot in
                                RackSlotRow(slot: slot, totalUnits: totalUnits, tab: tab)
                            }
                        }

                        // Placed gear items (overlay on top of slot grid)
                        ForEach(tab.instances) { instance in
                            if let comp = Components.all[instance.type] {
                                RackGearItem(instance: instance, comp: comp)
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
                            // Determine target rack slot from Y position
                            let scrollY = max(0, location.y - 12) // subtract padding
                            let targetSlot = Int(scrollY / unitHeight)
                            let clamped = min(targetSlot, totalUnits - 1)
                            let inst = appState.addInstance(
                                type: typeId,
                                position: CGPoint(x: 0, y: CGFloat(clamped) * unitHeight))
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

                // Connection bezier wires (drawn over the scroll content, fixed to viewport)
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

                // Right-click hit areas for deleting connections
                ForEach(appState.connections) { conn in
                    ConnectionHitArea(connection: conn)
                }
            }
            .onContinuousHover { phase in
                if case .active(let loc) = phase { mousePos = loc }
            }
            .onTapGesture {
                if appState.connectingFromId != nil { appState.cancelConnecting() }
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

    // MARK: - Connection drawing

    private func drawConnections(ctx: GraphicsContext) {
        for conn in appState.connections {
            guard let src = appState.portCenter(for: conn.fromId, portIndex: conn.fromPortIndex, side: "out"),
                  let dst = appState.portCenter(for: conn.toId,   portIndex: conn.toPortIndex,   side: "in")
            else { continue }

            let wireColor = connectionColor(for: conn)

            var path = Path()
            path.move(to: src)
            let cx = (dst.x - src.x) * 0.6
            path.addCurve(to: dst,
                          control1: CGPoint(x: src.x + cx, y: src.y),
                          control2: CGPoint(x: dst.x - cx, y: dst.y))
            ctx.stroke(path,
                       with: .color(wireColor.opacity(0.75)),
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
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
        guard let fromId = appState.connectingFromId else { return Color.blue.opacity(0.45) }
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
        path.addCurve(to: to,
                      control1: CGPoint(x: from.x + cx, y: from.y),
                      control2: CGPoint(x: to.x - cx,   y: to.y))
        ctx.stroke(path,
                   with: .color(activeOutputSignalType()),
                   style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 3]))
    }

    private func drawArrowhead(ctx: GraphicsContext, at tip: CGPoint, from origin: CGPoint, color: Color) {
        let angle = atan2(tip.y - origin.y, tip.x - origin.x)
        let arrowLen: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        let p1 = CGPoint(x: tip.x - arrowLen * cos(angle - arrowAngle),
                         y: tip.y - arrowLen * sin(angle - arrowAngle))
        let p2 = CGPoint(x: tip.x - arrowLen * cos(angle + arrowAngle),
                         y: tip.y - arrowLen * sin(angle + arrowAngle))
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
            // U number label
            Text("\(totalUnits - slot)U")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, 6)

            // Slot area
            Rectangle()
                .fill(slot.isMultiple(of: 2)
                      ? Color.primary.opacity(0.025)
                      : Color.clear)
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

// MARK: - Rack Gear Item
/// A component placed inside the rack, displayed as a colored block spanning its rackUnits height
struct RackGearItem: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    @State private var showingConfig = false

    private var itemHeight: CGFloat {
        CGFloat(max(comp.rackUnits, 1)) * unitHeight
    }

    private var effectivePorts: PortInfo { instance.effectivePorts ?? comp.ports }
    private var effectiveInputTypes: [String] { instance.effectiveInputTypes ?? comp.inputs }
    private var effectiveOutputTypes: [String] { instance.effectiveOutputTypes ?? comp.outputs }

    var body: some View {
        HStack(spacing: 0) {
            // Left indent to align with slot area (28pt label + 6pt padding)
            Color.clear.frame(width: 34)

            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.categoryColor(comp.category).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.categoryColor(comp.category).opacity(0.5), lineWidth: 1.5)
                    )

                // Content
                HStack(spacing: 8) {
                    // Category stripe
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.categoryColor(comp.category))
                        .frame(width: 4)
                        .padding(.vertical, 6)

                    ComponentIcon(name: comp.iconName)
                        .frame(width: 16, height: 16)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(comp.name)
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                        Text(comp.manufacturer)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Rack unit size badge
                    if comp.rackUnits > 0 {
                        Text("\(comp.rackUnits)U")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    // Configure button (configurable I/O only)
                    if comp.id == "configurable_io_2u" {
                        Button {
                            showingConfig = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .opacity(isHovered ? 1 : 0)
                        .popover(isPresented: $showingConfig, arrowEdge: .trailing) {
                            IOConfigPopoverView(instance: instance)
                                .environmentObject(appState)
                        }
                    }

                    // Delete button
                    Button { appState.deleteNode(id: instance.id) } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .opacity(isHovered ? 1 : 0)
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: itemHeight - 4)
            // Port dots on edges
            .overlay {
                GeometryReader { geo in
                    ForEach(Array(effectivePorts.inputs.enumerated()), id: \.offset) { idx, portName in
                        let sigType = effectiveInputTypes.indices.contains(idx)
                            ? effectiveInputTypes[idx]
                            : (effectiveInputTypes.first ?? "line")
                        PortEdgeDot(instance: instance, portIndex: idx, side: "in",
                                    total: effectivePorts.inputs.count,
                                    label: portName, signalType: sigType)
                            .position(x: NodeView.portHitWidth / 2,
                                      y: evenPortY(idx: idx, total: effectivePorts.inputs.count, height: geo.size.height))
                    }
                    ForEach(Array(effectivePorts.outputs.enumerated()), id: \.offset) { idx, portName in
                        let sigType = effectiveOutputTypes.indices.contains(idx)
                            ? effectiveOutputTypes[idx]
                            : (effectiveOutputTypes.first ?? "line")
                        PortEdgeDot(instance: instance, portIndex: idx, side: "out",
                                    total: effectivePorts.outputs.count,
                                    label: portName, signalType: sigType)
                            .position(x: geo.size.width - NodeView.portHitWidth / 2,
                                      y: evenPortY(idx: idx, total: effectivePorts.outputs.count, height: geo.size.height))
                    }
                }
            }

            // Right indent
            Color.clear.frame(width: 34)
        }
        .frame(height: itemHeight)
        .onHover { isHovered = $0 }
        .shadow(color: .black.opacity(isHovered ? 0.12 : 0.04), radius: isHovered ? 6 : 2, x: 0, y: 2)
    }
}

// MARK: - I/O Configuration Popover
struct IOConfigPopoverView: View {
    @ObservedObject var instance: NodeInstance
    @EnvironmentObject var appState: AppState

    @State private var config: IOConfig = IOConfig()

    private let signalTypes: [(label: String, value: String)] = [
        ("Mic",      "mic"),
        ("Line",     "line"),
        ("AES",      "aes"),
        ("MADI",     "madi"),
        ("Dante",    "dante"),
        ("Fiber",    "fiber"),
        ("Optical",  "optical"),
        ("RF",       "rf"),
        ("Speaker",  "speaker"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configure I/O")
                .font(.system(size: 13, weight: .semibold))

            // Inputs
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

            // Outputs
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
