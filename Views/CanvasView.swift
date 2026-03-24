// Views/CanvasView.swift — Interactive canvas with draggable nodes and bezier connections

import SwiftUI
import UniformTypeIdentifiers

struct CanvasView: View {
    @EnvironmentObject var appState: AppState
    @State private var mousePos: CGPoint = .zero
    @State private var isDragTarget = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // ── Canvas background ──
                Color(nsColor: .textBackgroundColor)
                    .overlay(canvasDotGrid)

                // ── Empty state hint ──
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

                // ── Bezier connection curves ──
                Canvas { ctx, _ in
                    drawConnections(ctx: ctx)
                    if let fromId = appState.connectingFromId,
                       let src = appState.portCenter(for: fromId, portIndex: appState.connectingFromPortIndex, side: "out") {
                        drawPreview(ctx: ctx, from: src, to: mousePos)
                    }
                }
                .allowsHitTesting(false)

                // ── Connection delete hit areas ──
                ForEach(appState.connections) { conn in
                    ConnectionHitArea(connection: conn)
                }

                // ── Component nodes ──
                ForEach(appState.instances) { instance in
                    NodeView(instance: instance)
                        .position(
                            x: instance.position.x + nodeHalfWidth(for: instance),
                            y: instance.position.y + 30
                        )
                }
            }
            .coordinateSpace(name: "canvas")
            .contentShape(Rectangle())
            // Cancel connecting on canvas tap
            .onTapGesture { appState.cancelConnecting() }
            // Track mouse for preview line
            .onContinuousHover { phase in
                if case .active(let loc) = phase { mousePos = loc }
            }
            // Collect port anchor positions reported by PortEdgeDot views
            .onPreferenceChange(PortAnchorPref.self) { positions in
                DispatchQueue.main.async {
                    appState.portPositions.merge(positions) { $1 }
                }
            }
            // Drop target for palette items
            .onDrop(of: [UTType.plainText], isTargeted: $isDragTarget) { providers, location in
                providers.first?.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                    guard let data = data as? Data,
                          let typeId = String(data: data, encoding: .utf8) else { return }
                    DispatchQueue.main.async {
                        let pos = CGPoint(
                            x: max(10, location.x - NodeView.width / 2),
                            y: max(10, location.y - 40)
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

            var path = Path()
            path.move(to: src)
            let cx = (dst.x - src.x) * 0.6
            path.addCurve(to: dst,
                          control1: CGPoint(x: src.x + cx, y: src.y),
                          control2: CGPoint(x: dst.x - cx, y: dst.y))

            ctx.stroke(path,
                       with: .color(Color.blue.opacity(0.7)),
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Arrowhead at destination
            drawArrowhead(ctx: ctx, at: dst, from: src)
        }
    }

    private func drawPreview(ctx: GraphicsContext, from: CGPoint, to: CGPoint) {
        var path = Path()
        path.move(to: from)
        let cx = (to.x - from.x) * 0.6
        path.addCurve(to: to,
                      control1: CGPoint(x: from.x + cx, y: from.y),
                      control2: CGPoint(x: to.x - cx,   y: to.y))
        ctx.stroke(path,
                   with: .color(Color.blue.opacity(0.45)),
                   style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 3]))
    }

    private func drawArrowhead(ctx: GraphicsContext, at tip: CGPoint, from origin: CGPoint) {
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

        ctx.fill(arrow, with: .color(Color.blue.opacity(0.7)))
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
