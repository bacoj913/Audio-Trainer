// Views/RackCanvasView.swift — Rack unit grid inner canvas for placing gear inside a rack enclosure

import SwiftUI
import UniformTypeIdentifiers

// Height per rack unit (1U = 44.45mm physical, represented here as 44pt)
private let unitHeight: CGFloat = 44
// MARK: - Helpers
/// Returns the x-position for a rack-face port in the left or right half of the gear.
/// - Parameters:
///   - idx: The port index on that side.
///   - total: The total number of ports on that side.
///   - width: The available gear width.
///   - side: The side of the gear, either "in" or "out".
/// - Returns: The horizontal center position for that port.
func rackGearPortX(idx: Int, total: Int, width: CGFloat, side: String) -> CGFloat {
    let outerInset: CGFloat = 22
    let centerGap: CGFloat = 28
    
    let halfWidth = width / 2
    let minX = side == "in" ? outerInset : halfWidth + centerGap / 2
    let maxX = side == "in" ? halfWidth - centerGap / 2 : width - outerInset
    let usableWidth = maxX - minX
    
    guard total > 0 else { return width / 2 }
    if total == 1 { return minX + usableWidth / 2 }
    
    let step = usableWidth / CGFloat(total - 1)
    return minX + CGFloat(idx) * step
}

/// Returns the y-position for the input row on the rack gear face.
/// - Parameter height: The height of the gear face.
/// - Returns: The vertical center position for the input row.
func rackGearInputRowY(height: CGFloat) -> CGFloat {
    height * 0.32
}

/// Returns the y-position for the output row on the rack gear face.
/// - Parameter height: The height of the gear face.
/// - Returns: The vertical center position for the output row.
func rackGearOutputRowY(height: CGFloat) -> CGFloat {
    height * 0.70
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

//MARK: - Rack Canvas Face Port
struct RackCanvasFacePort: View {
    @ObservedObject var instance: NodeInstance
    let portIndex: Int
    let side: String
    var signalType: String = "line"
    var bundleStyle: PortGroup.BundleStyle = .single
    
    @EnvironmentObject var appState: AppState
    
    private var color: Color { Color.signalTypeColor(signalType) }
    
    private var isSource: Bool {
        appState.connectingFromId == instance.id &&
        appState.connectingFromPortIndex == portIndex
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
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black.opacity(0.10))
                .frame(width: 28, height: 16)
            
            PortGlyph(
                color: color,
                bundleStyle: bundleStyle,
                showDisconnectMark: isConnected && side == "in" && !isConnecting
            )
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
/// A component placed inside the rack, displayed as a colored block spanning its rackUnits height
struct RackGearItem: View {
    @ObservedObject var instance: NodeInstance
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    
    private var itemHeight: CGFloat {
        CGFloat(max(comp.rackUnits, 1)) * unitHeight
    }
    
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
                    let inputY = rackGearInputRowY(height: geo.size.height)
                    let outputY = rackGearOutputRowY(height: geo.size.height)
                    
                    ForEach(Array(comp.ports.inputs.enumerated()), id: \.offset) { idx, _ in
                        let sigType = comp.inputs.indices.contains(idx) ? comp.inputs[idx] : (comp.inputs.first ?? "line")
                        
                        RackCanvasFacePort(
                            instance: instance,
                            portIndex: idx,
                            side: "in",
                            signalType: sigType
                        )
                        .position(
                            x: rackGearPortX(
                                idx: idx,
                                total: comp.ports.inputs.count,
                                width: geo.size.width,
                                side: "in"
                            ),
                            y: inputY
                        )
                    }
                    
                    ForEach(Array(comp.ports.outputs.enumerated()), id: \.offset) { idx, _ in
                        let sigType = comp.outputs.indices.contains(idx) ? comp.outputs[idx] : (comp.outputs.first ?? "line")
                        
                        RackCanvasFacePort(
                            instance: instance,
                            portIndex: idx,
                            side: "out",
                            signalType: sigType
                        )
                        .position(
                            x: rackGearPortX(
                                idx: idx,
                                total: comp.ports.outputs.count,
                                width: geo.size.width,
                                side: "out"
                            ),
                            y: outputY
                        )
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
