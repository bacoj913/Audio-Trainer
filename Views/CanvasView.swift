// Views/CanvasView.swift — Interactive canvas with zoom/pan, draggable nodes and bezier connections

import SwiftUI
import UniformTypeIdentifiers

struct CanvasView: View {
    @EnvironmentObject var appState: AppState
    @State private var mousePos: CGPoint = .zero
    @State private var isDragTarget = false
    @State private var scaleAtGestureStart: CGFloat = 1.0
    @State private var panStartOffset: CGSize = .zero
    /// Incremented after zoom/pan to force port anchor preference re-reporting
    @State private var layoutVersion: Int = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {

                // Background only
                Color(nsColor: .textBackgroundColor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.cancelConnecting()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 4)
                            .onChanged { value in
                                if appState.connectingFromId != nil {
                                    appState.cancelConnecting()
                                    return
                                }

                                appState.canvasOffset = CGSize(
                                    width: panStartOffset.width + value.translation.width,
                                    height: panStartOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                panStartOffset = appState.canvasOffset
                                layoutVersion += 1
                            }
                    )
                // Scaled & panned canvas content
                ZStack(alignment: .topLeading) {

                    canvasDotGrid
                        .allowsHitTesting(false)

                    if appState.instances.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("Drag components from the sidebar to begin")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
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

                    ForEach(appState.crossTabConnections) { conn in
                        ConnectionHitArea(connection: conn)
                    }

                    ForEach(appState.instances) { instance in
                        PositionedNodeView(instance: instance)
                            .zIndex(1)
                    }
                }
                .scaleEffect(appState.canvasScale, anchor: .topLeading)
                .offset(appState.canvasOffset)
                .coordinateSpace(name: "canvas")
                .id(layoutVersion)
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                if case .active(let loc) = phase {
                    mousePos = CGPoint(
                        x: (loc.x - appState.canvasOffset.width) / appState.canvasScale,
                        y: (loc.y - appState.canvasOffset.height) / appState.canvasScale
                    )
                }
            }
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { value in
                        appState.canvasScale = max(
                            0.25,
                            min(4.0, scaleAtGestureStart * value.magnification)
                        )
                    }
                    .onEnded { _ in
                        scaleAtGestureStart = appState.canvasScale
                        layoutVersion += 1
                    }
            )
            .onPreferenceChange(PortAnchorPref.self) { positions in
                DispatchQueue.main.async {
                    appState.activeTab.portPositions.merge(positions) { $1 }
                }
            }
            .onDrop(of: [UTType.plainText], isTargeted: $isDragTarget) { providers, location in
                providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                    guard let data = data as? Data,
                          let payload = String(data: data, encoding: .utf8) else { return }

                    DispatchQueue.main.async {
                        let canvasX = (location.x - appState.canvasOffset.width) / appState.canvasScale
                        let canvasY = (location.y - appState.canvasOffset.height) / appState.canvasScale

                        if payload.hasPrefix("userrack:") {
                            // Drop of a user-saved rack template
                            let rackIdStr = String(payload.dropFirst("userrack:".count))
                            guard let rackId = UUID(uuidString: rackIdStr),
                                  let userRack = appState.userRacks.first(where: { $0.id == rackId })
                            else { return }
                            let pos = CGPoint(x: max(10, canvasX - NodeView.rackWidth / 2),
                                             y: max(10, canvasY - 30))
                            appState.placeUserRack(userRack, at: pos)
                        } else {
                            // Drop of a standard component
                            let comp = Components.all[payload]
                            let droppedHalfHeight: CGFloat = {
                                if let comp, comp.isRack { return 30 }
                                if let comp { return standardNodeHeight(for: comp) / 2 }
                                return 30
                            }()
                            let pos = CGPoint(x: max(10, canvasX - NodeView.width / 2),
                                             y: max(10, canvasY - droppedHalfHeight))
                            appState.addInstance(type: payload, position: pos)
                        }
                    }
                }
                return true
            }
            .overlay(
                isDragTarget
                    ? RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                    : nil
            )
        }
        .onAppear {
            panStartOffset = appState.canvasOffset
            scaleAtGestureStart = appState.canvasScale
        }
    }

    // MARK: - Draw connections
    private func drawConnections(ctx: GraphicsContext) {
        // Draw same-tab connections
        for conn in appState.connections {
            guard let src = appState.portCenter(for: conn.fromId, portIndex: conn.fromPortIndex, side: "out"),
                  let dst = appState.portCenter(for: conn.toId,   portIndex: conn.toPortIndex,   side: "in")
            else { continue }
            let wireColor = connectionColor(for: conn)
            drawWire(ctx: ctx, from: src, to: dst, color: wireColor)
        }
        // Draw cross-tab connections where both ports are visible on this canvas
        for conn in appState.crossTabConnections {
            guard let src = appState.portCenter(for: conn.fromId, portIndex: conn.fromPortIndex, side: "out"),
                  let dst = appState.portCenter(for: conn.toId,   portIndex: conn.toPortIndex,   side: "in")
            else { continue }
            let wireColor = crossTabConnectionColor(for: conn)
            drawWire(ctx: ctx, from: src, to: dst, color: wireColor)
        }
    }

    private func drawWire(ctx: GraphicsContext, from src: CGPoint, to dst: CGPoint, color: Color) {
        var path = Path()
        path.move(to: src)
        let cx = (dst.x - src.x) * 0.6
        path.addCurve(to: dst,
                      control1: CGPoint(x: src.x + cx, y: src.y),
                      control2: CGPoint(x: dst.x - cx, y: dst.y))
        ctx.stroke(path,
                   with: .color(color.opacity(0.75)),
                   style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        drawArrowhead(ctx: ctx, at: dst, from: src, color: color.opacity(0.75))
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

    private func crossTabConnectionColor(for conn: NodeConnection) -> Color {
        guard let (fromInst, _) = appState.findInstance(id: conn.fromId) else { return Color.signalTypeColor("line") }
        let fromComp = Components.all[fromInst.type]
        let outputs = fromInst.effectiveOutputTypes ?? fromComp?.outputs ?? []
        let sigType = outputs.indices.contains(conn.fromPortIndex)
            ? outputs[conn.fromPortIndex]
            : outputs.first ?? "line"
        return Color.signalTypeColor(sigType)
    }

    private func activeOutputSignalType() -> Color {
        guard let fromId = appState.connectingFromId else { return Color.blue.opacity(0.45) }
        // Search both active tab and all tabs (for cross-rack source ports)
        let fromInst = appState.instances.first { $0.id == fromId }
            ?? appState.findInstance(id: fromId)?.0
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

        let p1 = CGPoint(
            x: tip.x - arrowLen * cos(angle - arrowAngle),
            y: tip.y - arrowLen * sin(angle - arrowAngle))
        let p2 = CGPoint(
            x: tip.x - arrowLen * cos(angle + arrowAngle),
            y: tip.y - arrowLen * sin(angle + arrowAngle))

        var arrow = Path()
        arrow.move(to: tip)
        arrow.addLine(to: p1)
        arrow.addLine(to: p2)
        arrow.closeSubpath()

        ctx.fill(arrow, with: .color(color))
    }

    // MARK: - Dot grid background
    private var canvasDotGrid: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 22
            var dotPath = Path()
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    dotPath.addEllipse(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                    y += spacing
                }
                x += spacing
            }
            ctx.fill(dotPath, with: .color(Color.primary.opacity(0.06)))
        }
    }
}

// MARK: - Connection Hit Area (right-click to delete)
struct ConnectionHitArea: View {
    let connection: NodeConnection
    @EnvironmentObject var appState: AppState

    var body: some View {
        let shape = ConnectionShape(
            src: appState.portCenter(
                for: connection.fromId,
                portIndex: connection.fromPortIndex,
                side: "out"
            ),
            dst: appState.portCenter(
                for: connection.toId,
                portIndex: connection.toPortIndex,
                side: "in"
            )
        )

        shape
            .stroke(Color.clear, lineWidth: 12)
            .contentShape(shape)
            .contextMenu {
                Button(role: .destructive) {
                    appState.removeConnection(connection.id)
                } label: {
                    Label("Remove Connection", systemImage: "trash")
                }
            }
            .allowsHitTesting(true)
        }
}
struct ConnectionShape: Shape {
    let src: CGPoint?
    let dst: CGPoint?

    func path(in rect: CGRect) -> Path {
        guard let src, let dst else { return Path() }

        var p = Path()
        p.move(to: src)
        let cx = (dst.x - src.x) * 0.6
        p.addCurve(to: dst,
                   control1: CGPoint(x: src.x + cx, y: src.y),
                   control2: CGPoint(x: dst.x - cx, y: dst.y))
        return p.strokedPath(StrokeStyle(lineWidth: 12))
    }
}

// MARK: - Positioned Node View
/// Wraps NodeView and observes the NodeInstance directly so that position changes
/// during drag cause this view — and its .position() modifier — to re-render.
/// CanvasView only observes AppState, not individual NodeInstances, so without this
/// wrapper the .position() modifier would never update when instance.position changes.
// MARK: - Positioned Node View
/// Wraps NodeView and observes the NodeInstance directly so that position changes
/// during drag cause this view — and its .position() modifier — to re-render.
/// CanvasView only observes AppState, not individual NodeInstances, so without this
/// wrapper the .position() modifier would never update when instance.position changes.
private struct PositionedNodeView: View {
    @ObservedObject var instance: NodeInstance

    private var comp: Component {
        Components.all[instance.type] ?? .placeholder
    }

    var body: some View {
        NodeView(instance: instance)
            .position(
                x: instance.position.x + halfWidth,
                y: instance.position.y + halfHeight
            )
    }

    private var halfWidth: CGFloat {
        if comp.isRack {
            return NodeView.rackWidth / 2
        } else {
            return standardNodeWidth(for: comp) / 2
        }
    }

    private var halfHeight: CGFloat {
        if comp.isRack {
            return rackNodeHeight(for: comp) / 2
        } else {
            return standardNodeHeight(for: instance, comp: comp) / 2
        }
    }
}
// MARK: - Previews

private extension AppState {
    static var canvasEmptyState: AppState { AppState() }

    static var canvasPopulatedState: AppState {
        let s = AppState()
        let mic  = s.addInstance(type: "microphone",  position: CGPoint(x: 80,  y: 120))
        let pre  = s.addInstance(type: "preamp",       position: CGPoint(x: 300, y: 80))
        let mix  = s.addInstance(type: "mixer",        position: CGPoint(x: 530, y: 100))
        let amp  = s.addInstance(type: "power_amp",    position: CGPoint(x: 760, y: 100))
        let spk  = s.addInstance(type: "speakers",     position: CGPoint(x: 980, y: 100))
        s.activeTab.connections.append(NodeConnection(fromId: mic.id,  fromPortIndex: 0,
                                                      toId: pre.id,  toPortIndex: 0))
        s.activeTab.connections.append(NodeConnection(fromId: pre.id,  fromPortIndex: 0,
                                                      toId: mix.id,  toPortIndex: 0))
        s.activeTab.connections.append(NodeConnection(fromId: mix.id,  fromPortIndex: 0,
                                                      toId: amp.id,  toPortIndex: 0))
        s.activeTab.connections.append(NodeConnection(fromId: amp.id,  fromPortIndex: 0,
                                                      toId: spk.id,  toPortIndex: 0))
        return s
    }
}

#Preview("Canvas – Empty") {
    CanvasView()
        .environmentObject(AppState.canvasEmptyState)
        .frame(width: 1100, height: 700)
        .coordinateSpace(name: "canvas")
}

#Preview("Canvas – Signal Chain") {
    CanvasView()
        .environmentObject(AppState.canvasPopulatedState)
        .frame(width: 1200, height: 700)
        .coordinateSpace(name: "canvas")
}
