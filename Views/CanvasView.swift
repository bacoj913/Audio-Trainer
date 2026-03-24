// Views/CanvasView.swift — Interactive canvas with zoom/pan, draggable nodes and bezier connections

import SwiftUI
import UniformTypeIdentifiers

struct CanvasView: View {
    @EnvironmentObject var appState: AppState
    @State private var mousePos: CGPoint = .zero
    @State private var isDragTarget = false
    @State private var scaleAtGestureStart: CGFloat = 1.0
    @State private var panStartOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {

                // ── Canvas background — handles pan drag ──
                Color(nsColor: .textBackgroundColor)
                    .gesture(
                        DragGesture(minimumDistance: 0)
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
                            }
                    )
                    .onTapGesture { appState.cancelConnecting() }

                // ── Scaled & panned canvas content ──
                ZStack(alignment: .topLeading) {

                    // Dot grid
                    canvasDotGrid

                    // Empty state hint
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
                    }

                    // Bezier connection curves
                    Canvas { ctx, _ in
                        drawConnections(ctx: ctx)
                        if let fromId = appState.connectingFromId,
                           let src = appState.portCenter(for: fromId,
                                                         portIndex: appState.connectingFromPortIndex,
                                                         side: "out") {
                            drawPreview(ctx: ctx, from: src, to: mousePos)
                        }
                    }
                    .allowsHitTesting(false)

                    // Connection delete hit areas
                    ForEach(appState.connections) { conn in
                        ConnectionHitArea(connection: conn)
                    }

                    // Component nodes
                    ForEach(appState.instances) { instance in
                        NodeView(instance: instance)
                            .position(
                                x: instance.position.x + nodeHalfWidth(for: instance),
                                y: instance.position.y + 30
                            )
                    }
                }
                .scaleEffect(appState.canvasScale, anchor: .topLeading)
                .offset(appState.canvasOffset)
                .coordinateSpace(name: "canvas")
            }
            .contentShape(Rectangle())
            // Track mouse for connection preview line (convert screen → canvas coords)
            .onContinuousHover { phase in
                if case .active(let loc) = phase {
                    mousePos = CGPoint(
                        x: (loc.x - appState.canvasOffset.width) / appState.canvasScale,
                        y: (loc.y - appState.canvasOffset.height) / appState.canvasScale
                    )
                }
            }
            // Pinch to zoom (trackpad)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        appState.canvasScale = max(0.25, min(4.0,
                            scaleAtGestureStart * value.magnification))
                    }
                    .onEnded { _ in
                        scaleAtGestureStart = appState.canvasScale
                    }
            )
            // Collect port anchor positions reported by PortEdgeDot views
            .onPreferenceChange(PortAnchorPref.self) { positions in
                DispatchQueue.main.async {
                    appState.activeTab.portPositions.merge(positions) { $1 }
                }
            }
            // Drop target for palette items
            .onDrop(of: [UTType.plainText], isTargeted: $isDragTarget) { providers, location in
                providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                    guard let data = data as? Data,
                          let typeId = String(data: data, encoding: .utf8) else { return }
                    DispatchQueue.main.async {
                        // Convert drop location from screen to canvas coordinates
                        let canvasX = (location.x - appState.canvasOffset.width) / appState.canvasScale
                        let canvasY = (location.y - appState.canvasOffset.height) / appState.canvasScale
                        let pos = CGPoint(
                            x: max(10, canvasX - NodeView.width / 2),
                            y: max(10, canvasY - 40)
                        )
                        appState.addInstance(type: typeId, position: pos)
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
            // Sync panStartOffset on appear in case scale/offset was pre-set
            panStartOffset = appState.canvasOffset
            scaleAtGestureStart = appState.canvasScale
        }
    }

    // MARK: - Helpers
    private func nodeHalfWidth(for instance: NodeInstance) -> CGFloat {
        let comp = Components.all[instance.type]
        return comp?.isRack == true ? 100 : NodeView.width / 2
    }

    // MARK: - Draw connections
    private func drawConnections(ctx: GraphicsContext) {
        for conn in appState.connections {
            guard let src = appState.portCenter(for: conn.fromId, portIndex: conn.fromPortIndex, side: "out"),
                  let dst = appState.portCenter(for: conn.toId,   portIndex: conn.toPortIndex,   side: "in")
            else { continue }

            // Determine wire color from the output port's signal type
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
        let outputs = fromComp?.outputs ?? []
        let sigType = outputs.indices.contains(conn.fromPortIndex)
            ? outputs[conn.fromPortIndex]
            : outputs.first ?? "line"
        return Color.signalTypeColor(sigType)
    }

    private func activeOutputSignalType() -> Color {
        guard let fromId = appState.connectingFromId else { return Color.blue.opacity(0.45) }
        let fromInst = appState.instances.first { $0.id == fromId }
        let fromComp = Components.all[fromInst?.type ?? ""]
        let outputs = fromComp?.outputs ?? []
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
        Color.clear
            .contentShape(
                ConnectionShape(
                    src: appState.portCenter(for: connection.fromId,
                                             portIndex: connection.fromPortIndex,
                                             side: "out"),
                    dst: appState.portCenter(for: connection.toId,
                                             portIndex: connection.toPortIndex,
                                             side: "in")
                )
            )
            .contextMenu {
                Button(role: .destructive) {
                    appState.removeConnection(connection.id)
                } label: {
                    Label("Remove Connection", systemImage: "trash")
                }
            }
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
