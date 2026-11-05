// Views/DanteControllerView.swift — Dante / network audio routing matrix

import SwiftUI

// MARK: - Channel Descriptors

private struct DanteTXChannel: Identifiable {
    let id: String      // "\(instId)-out-\(portIdx)"
    let device: NodeInstance
    let comp: Component
    let portIndex: Int
    let label: String
}

private struct DanteRXChannel: Identifiable {
    let id: String      // "\(instId)-in-\(portIdx)"
    let device: NodeInstance
    let comp: Component
    let portIndex: Int
    let label: String
}

// MARK: - Dante Controller (Matrix)

struct DanteControllerView: View {
    @EnvironmentObject var appState: AppState

    // All Dante-capable instances across every tab
    private var allDevices: [(inst: NodeInstance, comp: Component)] {
        appState.allNetworkInstances
    }

    private static let networkTypes: Set<String> = ["dante","milan","aes67","avb","network","networkaudio"]

    /// Collects all network PortGroups for a device including slot cards.
    private func networkPortGroups(inst: NodeInstance, comp: Component, side: String) -> [PortGroup] {
        var groups: [PortGroup] = []
        let baseGroups = side == "out" ? comp.outputPortGroups : comp.inputPortGroups
        for g in baseGroups where Self.networkTypes.contains(g.signalType.lowercased()) {
            groups.append(g)
        }
        for card in inst.slotCards.values.sorted(by: { $0.slotNumber < $1.slotNumber }) {
            guard let cardComp = Components.all[card.cardType] else { continue }
            let cardGroups = side == "out" ? cardComp.outputPortGroups : cardComp.inputPortGroups
            for g in cardGroups where Self.networkTypes.contains(g.signalType.lowercased()) {
                groups.append(g)
            }
        }
        return groups
    }

    private var txChannels: [DanteTXChannel] {
        allDevices.flatMap { item -> [DanteTXChannel] in
            var result: [DanteTXChannel] = []
            var chIdx = 0
            for group in networkPortGroups(inst: item.inst, comp: item.comp, side: "out") {
                let transport = group.transport ?? group.connector
                let total = group.count * group.channelsPerPort
                for ch in 0..<total {
                    result.append(DanteTXChannel(
                        id: "\(item.inst.id)-out-\(chIdx)",
                        device: item.inst,
                        comp: item.comp,
                        portIndex: chIdx,
                        label: "\(transport) \(ch + 1)"
                    ))
                    chIdx += 1
                }
            }
            return result
        }
    }

    private var rxChannels: [DanteRXChannel] {
        allDevices.flatMap { item -> [DanteRXChannel] in
            var result: [DanteRXChannel] = []
            var chIdx = 0
            for group in networkPortGroups(inst: item.inst, comp: item.comp, side: "in") {
                let transport = group.transport ?? group.connector
                let total = group.count * group.channelsPerPort
                for ch in 0..<total {
                    result.append(DanteRXChannel(
                        id: "\(item.inst.id)-in-\(chIdx)",
                        device: item.inst,
                        comp: item.comp,
                        portIndex: chIdx,
                        label: "\(transport) \(ch + 1)"
                    ))
                    chIdx += 1
                }
            }
            return result
        }
    }

    var body: some View {
        if allDevices.isEmpty {
            emptyState
        } else {
            DanteMatrixView(txChannels: txChannels, rxChannels: rxChannels)
                .environmentObject(appState)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No Dante / network devices on canvas")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text("Add devices with Dante, Milan, AES67, or AVB ports to the canvas.")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Matrix View

private struct DanteMatrixView: View {
    let txChannels: [DanteTXChannel]
    let rxChannels: [DanteRXChannel]
    @EnvironmentObject var appState: AppState

    // Cell dimensions
    private let cellW: CGFloat = 22
    private let cellH: CGFloat = 22
    private let txLabelWidth: CGFloat = 160
    private let headerHeight: CGFloat = 80
    private let rowHeight: CGFloat = 22

    private var totalGridWidth: CGFloat  { txLabelWidth + CGFloat(rxChannels.count) * cellW }
    private var totalGridHeight: CGFloat { headerHeight + CGFloat(txChannels.count) * rowHeight }

    // Compact route check
    private func isRouted(_ tx: DanteTXChannel, _ rx: DanteRXChannel) -> Bool {
        appState.danteFlows.contains {
            $0.fromDeviceId == tx.device.id && $0.fromPortIndex == tx.portIndex &&
            $0.toDeviceId == rx.device.id && $0.toPortIndex == rx.portIndex
        }
    }

    private func toggleRoute(_ tx: DanteTXChannel, _ rx: DanteRXChannel) {
        if let flow = appState.danteFlows.first(where: {
            $0.fromDeviceId == tx.device.id && $0.fromPortIndex == tx.portIndex &&
            $0.toDeviceId == rx.device.id && $0.toPortIndex == rx.portIndex
        }) {
            appState.removeDanteFlow(id: flow.id)
        } else {
            appState.addDanteFlow(
                fromDeviceId: tx.device.id, fromPortIndex: tx.portIndex,
                toDeviceId: rx.device.id, toPortIndex: rx.portIndex
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top legend bar
            matrixLegend

            // Matrix: TX label column on the left + scrollable grid
            HStack(spacing: 0) {
                // Fixed left column: TX labels
                VStack(spacing: 0) {
                    // Blank corner cell (aligns with header height)
                    cornerCell

                    // TX rows
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            txLabelColumn
                        }
                    }
                }
                .frame(width: txLabelWidth)
                .background(Color(nsColor: .controlBackgroundColor))
                .overlay(Divider(), alignment: .trailing)

                // Scrollable body: RX header + grid cells
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 0) {
                        // RX column headers
                        rxHeaderRow

                        // Grid body: one row per TX channel
                        ForEach(Array(txChannels.enumerated()), id: \.element.id) { txIdx, tx in
                            HStack(spacing: 0) {
                                ForEach(Array(rxChannels.enumerated()), id: \.element.id) { rxIdx, rx in
                                    MatrixCell(
                                        isRouted: isRouted(tx, rx),
                                        sameDevice: tx.device.id == rx.device.id
                                    )
                                    .frame(width: cellW, height: rowHeight)
                                    .onTapGesture {
                                        guard tx.device.id != rx.device.id else { return }
                                        toggleRoute(tx, rx)
                                    }
                                    .overlay(alignment: .trailing) {
                                        // Column separator at device boundary
                                        if rxIdx < rxChannels.count - 1,
                                           rxChannels[rxIdx].device.id != rxChannels[rxIdx + 1].device.id {
                                            Divider().opacity(0.4)
                                        }
                                    }
                                }
                            }
                            .background(txIdx % 2 == 0
                                ? Color.clear
                                : Color.primary.opacity(0.03))
                            .overlay(alignment: .bottom) {
                                // Row separator at device boundary
                                if txIdx < txChannels.count - 1,
                                   txChannels[txIdx].device.id != txChannels[txIdx + 1].device.id {
                                    Divider().opacity(0.4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - Legend

    private var matrixLegend: some View {
        HStack(spacing: 16) {
            Text("Dante Routing Matrix")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 6) {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                Text("Routed").font(.system(size: 11)).foregroundColor(.secondary)
            }
            HStack(spacing: 6) {
                Circle()
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                    .frame(width: 10, height: 10)
                Text("Not routed").font(.system(size: 11)).foregroundColor(.secondary)
            }
            HStack(spacing: 6) {
                Rectangle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 10, height: 10)
                Text("Same device").font(.system(size: 11)).foregroundColor(.secondary)
            }

            Text("\(txChannels.count) TX  ·  \(rxChannels.count) RX  ·  \(appState.danteFlows.count) flows")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Corner

    private var cornerCell: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("TX  ↓  /  RX  →")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.top, 4)
            Spacer()
        }
        .frame(width: txLabelWidth, height: headerHeight)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - TX Label Column

    private var txLabelColumn: some View {
        ForEach(Array(txChannels.enumerated()), id: \.element.id) { idx, tx in
            VStack(spacing: 0) {
                // Device name header row — shown only for the first channel of each device
                if idx == 0 || txChannels[idx - 1].device.id != tx.device.id {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.categoryColor(tx.comp.category))
                            .frame(width: 5, height: 5)
                        Text(tx.device.danteDeviceName ?? tx.comp.name)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 3)
                    .frame(height: 14)
                    .overlay(Divider().opacity(0.15), alignment: .bottom)
                }

                // Channel label row
                HStack {
                    Text(tx.label)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.leading, 12)
                    Spacer()
                }
                .frame(height: rowHeight)
                .overlay(Divider().opacity(0.2), alignment: .bottom)
            }
        }
    }

    // MARK: - RX Header Row

    private var rxHeaderRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(rxChannels.enumerated()), id: \.element.id) { idx, rx in
                VStack(spacing: 0) {
                    // Device name (only first channel of a device)
                    if idx == 0 || rxChannels[idx - 1].device.id != rx.device.id {
                        Text(rx.device.danteDeviceName ?? rx.comp.name)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .rotationEffect(.degrees(-45))
                            .frame(width: cellW, height: headerHeight - 20)
                            .clipped()
                    } else {
                        Spacer()
                            .frame(width: cellW, height: headerHeight - 20)
                    }

                    // Channel label (rotated)
                    Text(rx.label)
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .rotationEffect(.degrees(-45))
                        .frame(width: cellW, height: 20)
                        .clipped()
                }
                .frame(width: cellW, height: headerHeight)
                .overlay(alignment: .trailing) {
                    if idx < rxChannels.count - 1,
                       rxChannels[idx].device.id != rxChannels[idx + 1].device.id {
                        Divider().opacity(0.4)
                    }
                }
            }
        }
        .frame(height: headerHeight)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        .overlay(Divider(), alignment: .bottom)
    }
}

// MARK: - Matrix Cell

private struct MatrixCell: View {
    let isRouted: Bool
    let sameDevice: Bool

    var body: some View {
        ZStack {
            if sameDevice {
                Color.primary.opacity(0.06)
            }

            if !sameDevice {
                if isRouted {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                } else {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

private extension AppState {
    static var dantePreviewState: AppState {
        let s = AppState()
        s.addInstance(type: "mixer_ah_dlive_cdm32", position: CGPoint(x: 100, y: 100))
        s.addInstance(type: "network_switch_cisco_SG350-28P", position: CGPoint(x: 300, y: 100))
        s.addInstance(type: "configurable_io_2u", position: CGPoint(x: 500, y: 100))
        return s
    }

    static var danteWithFlowsState: AppState {
        let s = dantePreviewState
        let devices = s.allNetworkInstances
        if devices.count >= 2 {
            s.addDanteFlow(
                fromDeviceId: devices[0].inst.id, fromPortIndex: 0,
                toDeviceId: devices[1].inst.id, toPortIndex: 0
            )
        }
        return s
    }
}

#Preview("Dante Matrix – Empty") {
    DanteControllerView()
        .environmentObject(AppState())
        .frame(width: 900, height: 500)
}

#Preview("Dante Matrix – With Devices") {
    DanteControllerView()
        .environmentObject(AppState.dantePreviewState)
        .frame(width: 900, height: 600)
}

#Preview("Dante Matrix – With Flows") {
    DanteControllerView()
        .environmentObject(AppState.danteWithFlowsState)
        .frame(width: 900, height: 600)
}
