// Views/DanteControllerView.swift — Dante / network audio routing controller

import SwiftUI

// MARK: - Dante Controller

struct DanteControllerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddFlow = false
    @State private var selectedDeviceId: UUID? = nil

    // All Dante-capable instances across every tab
    private var devices: [(inst: NodeInstance, comp: Component)] {
        appState.allNetworkInstances
    }

    var body: some View {
        HSplitView {
            // ── Left: device list ─────────────────────────────
            deviceListPanel
                .frame(minWidth: 220, idealWidth: 240, maxWidth: 300)

            // ── Right: flow list / detail ─────────────────────
            flowPanel
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showingAddFlow) {
            AddDanteFlowSheet(devices: devices)
                .environmentObject(appState)
        }
    }

    // MARK: - Device List

    private var deviceListPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Devices")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(devices.count)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical, 10.5)
            .background(.ultraThinMaterial)
            .overlay(Divider(), alignment: .bottom)

            if devices.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "network.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No Dante / network devices\non canvas yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(devices, id: \.inst.id) { item in
                            DeviceRow(
                                inst: item.inst,
                                comp: item.comp,
                                isSelected: selectedDeviceId == item.inst.id,
                                flowCount: flowCount(for: item.inst.id)
                            )
                            .onTapGesture { selectedDeviceId = item.inst.id }
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(Divider(), alignment: .trailing)
    }

    // MARK: - Flow Panel

    private var flowPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Routing Flows")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    showingAddFlow = true
                } label: {
                    Label("Add Flow", systemImage: "plus")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(devices.count < 2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .overlay(Divider(), alignment: .bottom)

            // Filtered flows
            let visibleFlows = selectedDeviceId == nil
                ? appState.danteFlows
                : appState.danteFlows.filter { $0.fromDeviceId == selectedDeviceId || $0.toDeviceId == selectedDeviceId }

            if visibleFlows.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(appState.danteFlows.isEmpty
                         ? "No flows yet.\nTap \"+\" to route a transmitter to a receiver."
                         : "No flows for selected device.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(visibleFlows) { flow in
                            FlowRow(flow: flow, devices: devices)
                                .environmentObject(appState)
                            Divider().padding(.leading, 14)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func flowCount(for deviceId: UUID) -> Int {
        appState.danteFlows.filter { $0.fromDeviceId == deviceId || $0.toDeviceId == deviceId }.count
    }
}

// MARK: - Device Row

private struct DeviceRow: View {
    @ObservedObject var inst: NodeInstance
    let comp: Component
    let isSelected: Bool
    let flowCount: Int

    @State private var editingName = false
    @State private var nameInput: String = ""

    var body: some View {
        HStack(spacing: 10) {
            // Category color dot
            Circle()
                .fill(Color.categoryColor(comp.category))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                // Dante device name (editable)
                if editingName {
                    TextField("Device name", text: $nameInput, onCommit: {
                        inst.danteDeviceName = nameInput.isEmpty ? nil : nameInput
                        editingName = false
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, weight: .semibold))
                    .onExitCommand { editingName = false }
                } else {
                    Text(inst.danteDeviceName ?? comp.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                        .onTapGesture(count: 2) {
                            nameInput = inst.danteDeviceName ?? comp.name
                            editingName = true
                        }
                }

                HStack(spacing: 4) {
                    if let ip = inst.ipAddress, !ip.isEmpty {
                        Text(ip)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    Text(comp.name)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if flowCount > 0 {
                Text("\(flowCount)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - Flow Row

private struct FlowRow: View {
    let flow: DanteFlow
    let devices: [(inst: NodeInstance, comp: Component)]
    @EnvironmentObject var appState: AppState

    private func deviceName(for id: UUID) -> String {
        guard let item = devices.first(where: { $0.inst.id == id }) else { return "Unknown" }
        return item.inst.danteDeviceName ?? item.comp.name
    }

    private func portLabel(deviceId: UUID, portIndex: Int, side: String) -> String {
        guard let item = devices.first(where: { $0.inst.id == deviceId }) else { return "Port \(portIndex + 1)" }
        let ports = item.inst.effectivePorts ?? item.comp.ports
        let labels = side == "out" ? ports.outputs : ports.inputs
        guard portIndex < labels.count else { return "Port \(portIndex + 1)" }
        return labels[portIndex]
    }

    var body: some View {
        HStack(spacing: 8) {
            // Transmitter side
            VStack(alignment: .trailing, spacing: 2) {
                Text(deviceName(for: flow.fromDeviceId))
                    .font(.system(size: 11, weight: .semibold))
                Text(portLabel(deviceId: flow.fromDeviceId, portIndex: flow.fromPortIndex, side: "out"))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Image(systemName: "arrow.right")
                .font(.system(size: 10))
                .foregroundColor(Color.signalTypeColor("dante"))

            // Receiver side
            VStack(alignment: .leading, spacing: 2) {
                Text(deviceName(for: flow.toDeviceId))
                    .font(.system(size: 11, weight: .semibold))
                Text(portLabel(deviceId: flow.toDeviceId, portIndex: flow.toPortIndex, side: "in"))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Delete button
            Button {
                appState.removeDanteFlow(id: flow.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}

// MARK: - Add Flow Sheet

struct AddDanteFlowSheet: View {
    let devices: [(inst: NodeInstance, comp: Component)]
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var fromDeviceId: UUID?
    @State private var fromPortIndex: Int = 0
    @State private var toDeviceId: UUID?
    @State private var toPortIndex: Int = 0

    private var fromDevice: (inst: NodeInstance, comp: Component)? {
        devices.first { $0.inst.id == fromDeviceId }
    }
    private var toDevice: (inst: NodeInstance, comp: Component)? {
        devices.first { $0.inst.id == toDeviceId }
    }

    private func outputPorts(for item: (inst: NodeInstance, comp: Component)) -> [String] {
        let ports = item.inst.effectivePorts ?? item.comp.ports
        // Only show Dante/network outputs
        let types = item.inst.effectiveOutputTypes ?? item.comp.outputs
        return zip(ports.outputs, types)
            .filter { ["dante", "milan", "aes67", "avb", "network"].contains($0.1.lowercased()) }
            .map { $0.0 }
    }

    private func inputPorts(for item: (inst: NodeInstance, comp: Component)) -> [String] {
        let ports = item.inst.effectivePorts ?? item.comp.ports
        let types = item.inst.effectiveInputTypes ?? item.comp.inputs
        return zip(ports.inputs, types)
            .filter { ["dante", "milan", "aes67", "avb", "network"].contains($0.1.lowercased()) }
            .map { $0.0 }
    }

    private func outputPortIndex(label: String, for item: (inst: NodeInstance, comp: Component)) -> Int {
        let ports = item.inst.effectivePorts ?? item.comp.ports
        return ports.outputs.firstIndex(of: label) ?? 0
    }

    private func inputPortIndex(label: String, for item: (inst: NodeInstance, comp: Component)) -> Int {
        let ports = item.inst.effectivePorts ?? item.comp.ports
        return ports.inputs.firstIndex(of: label) ?? 0
    }

    private var canAdd: Bool {
        fromDeviceId != nil && toDeviceId != nil && fromDeviceId != toDeviceId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Dante Flow")
                .font(.system(size: 16, weight: .semibold))

            // Transmitter picker
            GroupBox("Transmitter (Source)") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Device", selection: $fromDeviceId) {
                        Text("Select device…").tag(UUID?.none)
                        ForEach(devices, id: \.inst.id) { item in
                            Text(item.inst.danteDeviceName ?? item.comp.name)
                                .tag(UUID?.some(item.inst.id))
                        }
                    }
                    if let item = fromDevice {
                        let outs = outputPorts(for: item)
                        if !outs.isEmpty {
                            Picker("Output", selection: $fromPortIndex) {
                                ForEach(Array(outs.enumerated()), id: \.offset) { idx, label in
                                    Text(label).tag(outputPortIndex(label: label, for: item))
                                }
                            }
                        } else {
                            Text("No network outputs on this device")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(4)
            }

            // Receiver picker
            GroupBox("Receiver (Destination)") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Device", selection: $toDeviceId) {
                        Text("Select device…").tag(UUID?.none)
                        ForEach(devices.filter { $0.inst.id != fromDeviceId }, id: \.inst.id) { item in
                            Text(item.inst.danteDeviceName ?? item.comp.name)
                                .tag(UUID?.some(item.inst.id))
                        }
                    }
                    if let item = toDevice {
                        let ins = inputPorts(for: item)
                        if !ins.isEmpty {
                            Picker("Input", selection: $toPortIndex) {
                                ForEach(Array(ins.enumerated()), id: \.offset) { idx, label in
                                    Text(label).tag(inputPortIndex(label: label, for: item))
                                }
                            }
                        } else {
                            Text("No network inputs on this device")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(4)
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button("Add Flow") {
                    if let from = fromDeviceId, let to = toDeviceId {
                        appState.addDanteFlow(fromDeviceId: from, fromPortIndex: fromPortIndex,
                                              toDeviceId: to, toPortIndex: toPortIndex)
                    }
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(!canAdd)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}

// MARK: - Previews

private extension AppState {
    static var dantePreviewState: AppState {
        let s = AppState()
        s.addInstance(type: "mixer", position: CGPoint(x: 100, y: 100))
        s.addInstance(type: "dante_switch", position: CGPoint(x: 300, y: 100))
        s.addInstance(type: "wireless_rx", position: CGPoint(x: 500, y: 100))
        s.addInstance(type: "power_amp", position: CGPoint(x: 700, y: 100))
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
            s.addDanteFlow(
                fromDeviceId: devices[0].inst.id, fromPortIndex: 1,
                toDeviceId: devices[2 % devices.count].inst.id, toPortIndex: 0
            )
        }
        return s
    }
}

#Preview("Dante Controller – Empty") {
    DanteControllerView()
        .environmentObject(AppState())
        .frame(width: 800, height: 500)
}

#Preview("Dante Controller – Devices") {
    DanteControllerView()
        .environmentObject(AppState.dantePreviewState)
        .frame(width: 900, height: 550)
}

#Preview("Dante Controller – With Flows") {
    DanteControllerView()
        .environmentObject(AppState.danteWithFlowsState)
        .frame(width: 900, height: 550)
}

#Preview("Add Dante Flow Sheet") {
    let state = AppState.dantePreviewState
    let devices = state.allNetworkInstances
    AddDanteFlowSheet(devices: devices)
        .environmentObject(state)
}
