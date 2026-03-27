// AppState.swift — Observable app-wide state

import SwiftUI
import Combine
import AppKit
import UniformTypeIdentifiers

// MARK: - App Mode
enum AppMode { case free, exercise, rf }

// MARK: - Configurable I/O
struct IOConfig: Equatable {
    var inputCount: Int = 8
    var inputSignalType: String = "line"
    var outputCount: Int = 8
    var outputSignalType: String = "line"
}

// MARK: - Node Instance
class NodeInstance: ObservableObject, Identifiable {
    let id: UUID
    let type: String
    @Published var position: CGPoint
    var rackSlot: Int? = nil   // U-slot index within a rack tab (nil if on main canvas)
    @Published var ioConfig: IOConfig? = nil   // non-nil for configurable I/O components
    @Published var ipAddress: String? = nil    // device IP address (for network-capable devices)
    @Published var portVlanTags: [Int: Int] = [:]  // port index → VLAN ID (0 = untagged) for network switches
    @Published var selectedPreset: String? = nil   // selected Lake module preset (for amps/processors)

    init(id: UUID = UUID(), type: String, position: CGPoint) {
        self.id = id
        self.type = type
        self.position = position
    }

    // MARK: - Effective port helpers (override component defaults when ioConfig is set)
    var effectivePorts: PortInfo? {
        guard let cfg = ioConfig else { return nil }
        let inLabels  = (1...max(1, cfg.inputCount)).map  { "\(cfg.inputSignalType.capitalized) In \($0)" }
        let outLabels = (1...max(1, cfg.outputCount)).map { "\(cfg.outputSignalType.capitalized) Out \($0)" }
        return PortInfo(inputs: inLabels, outputs: outLabels)
    }

    var effectiveInputTypes: [String]? {
        guard let cfg = ioConfig else { return nil }
        return Array(repeating: cfg.inputSignalType, count: cfg.inputCount)
    }

    var effectiveOutputTypes: [String]? {
        guard let cfg = ioConfig else { return nil }
        return Array(repeating: cfg.outputSignalType, count: cfg.outputCount)
    }
}

// MARK: - Canvas Tab
class CanvasTab: ObservableObject, Identifiable {
    let id: UUID
    var name: String
    var parentRackInstanceId: UUID?   // nil = main canvas

    @Published var instances: [NodeInstance] = []
    @Published var connections: [NodeConnection] = []
    @Published var portPositions: [String: CGPoint] = [:]

    init(id: UUID = UUID(), name: String, parentRackInstanceId: UUID? = nil) {
        self.id = id
        self.name = name
        self.parentRackInstanceId = parentRackInstanceId
    }
}

// MARK: - Connection
struct NodeConnection: Identifiable, Codable, Equatable {
    let id: UUID
    var fromId: UUID
    var fromPortIndex: Int
    var toId: UUID
    var toPortIndex: Int
    var routePoints: [CGPoint] = []

    init(
        id: UUID = UUID(),
        fromId: UUID,
        fromPortIndex: Int,
        toId: UUID,
        toPortIndex: Int,
        routePoints: [CGPoint] = []
    ) {
        self.id = id
        self.fromId = fromId
        self.fromPortIndex = fromPortIndex
        self.toId = toId
        self.toPortIndex = toPortIndex
        self.routePoints = routePoints
    }
}

// MARK: - RF State
class RFState: ObservableObject {
    @Published var venue: RFVenue? = nil
    @Published var gear: [RFGearItem] = []
    var nextId = 1
}

struct RFGearItem: Identifiable {
    let id: Int
    var cat: String
    var name: String
    var qty: Int
}

// MARK: - App State
class AppState: ObservableObject {
    /// Shared singleton — used by menu Commands which cannot access @EnvironmentObject.
    static weak var shared: AppState?

    @Published var mode: AppMode = .free
    @Published var connectingFromId: UUID? = nil
    @Published var connectingFromPortIndex: Int = 0
    @Published var mousePosition: CGPoint = .zero
    @Published var exerciseIndex: Int = 0
    @Published var hintIndex: Int = 0
    @Published var showExerciseBuilder: Bool = false
    @Published var isDarkMode: Bool = false
    @Published var exercises: [Exercise] = builtInExercises
    @Published var rfState: RFState = RFState()
    @Published var canvasScale: CGFloat = 1.0
    @Published var canvasOffset: CGSize = .zero
    @Published var crossTabConnections: [NodeConnection] = []

    /// User-saved rack templates shown in the "My Equipment" sidebar category.
    @Published var userRacks: [UserRack] = []
    /// URL of the currently open project file (nil = unsaved).
    var currentProjectURL: URL? = nil

    // MARK: - Tab system
    @Published var tabs: [CanvasTab] = [CanvasTab(name: "Main")]
    @Published var activeTabIndex: Int = 0

    var activeTab: CanvasTab { tabs[activeTabIndex] }

    /// Forwards active tab's objectWillChange → AppState so views re-render on tab data changes.
    private var activeTabObserver: AnyCancellable?

    init() {
        AppState.shared = self
        observeActiveTab()
        loadCustomExercisesFromStorage()
        loadUserRacksFromStorage()
    }

    private func observeActiveTab() {
        guard activeTabIndex < tabs.count else { return }
        activeTabObserver = tabs[activeTabIndex].objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
    }

    // Computed proxies so existing call-sites continue to compile
    var instances: [NodeInstance] { activeTab.instances }
    var connections: [NodeConnection] { activeTab.connections }
    var portPositions: [String: CGPoint] {
        get { activeTab.portPositions }
        set { activeTab.portPositions = newValue }
    }

    private var nextNodeId = 1

    // MARK: - Canvas
    static let nodeWidth: CGFloat = 192
    static let nodeHeight: CGFloat = 130
    static let rackNodeWidth: CGFloat = 200

    /// Look up the canvas-space center of a specific port by index.
    /// Positions are reported by PortEdgeDot views via PortAnchorPref.
    func portCenter(for instanceId: UUID, portIndex: Int, side: String) -> CGPoint? {
        activeTab.portPositions["\(instanceId)-\(side)-\(portIndex)"]
    }

    // MARK: - Tab Management
    func openRackTab(for instanceId: UUID) {
        if let idx = tabs.firstIndex(where: { $0.parentRackInstanceId == instanceId }) {
            activeTabIndex = idx
            observeActiveTab()
            return
        }
        let inst = activeTab.instances.first { $0.id == instanceId }
        let comp = Components.all[inst?.type ?? ""]
        let tab = CanvasTab(name: comp?.name ?? "Rack", parentRackInstanceId: instanceId)
        tabs.append(tab)
        activeTabIndex = tabs.count - 1
        observeActiveTab()
    }

    func closeTab(id: UUID) {
        guard tabs.count > 1, let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: idx)
        activeTabIndex = max(0, min(activeTabIndex, tabs.count - 1))
        observeActiveTab()
    }

    func switchTab(index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        activeTabIndex = index
        observeActiveTab()
    }

    // MARK: - Node Management
    @discardableResult
    func addInstance(type: String, position: CGPoint) -> NodeInstance {
        let inst = NodeInstance(type: type, position: position)
        activeTab.instances.append(inst)
        return inst
    }

    func deleteNode(id: UUID) {
        activeTab.connections.removeAll { $0.fromId == id || $0.toId == id }
        crossTabConnections.removeAll { $0.fromId == id || $0.toId == id }
        activeTab.portPositions = activeTab.portPositions.filter { !$0.key.hasPrefix(id.uuidString) }
        activeTab.instances.removeAll { $0.id == id }
        if connectingFromId == id { connectingFromId = nil }
        // Also close any rack tab for this instance (and remove its internal gear's cross-tab connections)
        if let rackTabIdx = tabs.firstIndex(where: { $0.parentRackInstanceId == id }) {
            let rackTab = tabs[rackTabIdx]
            let rackInstanceIds = Set(rackTab.instances.map { $0.id })
            crossTabConnections.removeAll { rackInstanceIds.contains($0.fromId) || rackInstanceIds.contains($0.toId) }
            tabs.remove(at: rackTabIdx)
            activeTabIndex = max(0, min(activeTabIndex, tabs.count - 1))
            observeActiveTab()
        }
    }

    func clearCanvas() {
        let instanceIds = Set(activeTab.instances.map { $0.id })
        crossTabConnections.removeAll { instanceIds.contains($0.fromId) || instanceIds.contains($0.toId) }
        activeTab.instances.removeAll()
        activeTab.connections.removeAll()
        activeTab.portPositions.removeAll()
        connectingFromId = nil
    }

    func autoLayout() {
        guard !activeTab.instances.isEmpty else { return }
        let cols = Int(ceil(sqrt(Double(activeTab.instances.count))))
        let cellW: CGFloat = 200
        let cellH: CGFloat = 160
        for (i, inst) in activeTab.instances.enumerated() {
            let col = i % cols
            let row = i / cols
            inst.position = CGPoint(x: 40 + CGFloat(col) * cellW, y: 40 + CGFloat(row) * cellH)
        }
    }

    // MARK: - Cross-tab helpers
    func findInstance(id: UUID) -> (NodeInstance, CanvasTab)? {
        for tab in tabs {
            if let inst = tab.instances.first(where: { $0.id == id }) {
                return (inst, tab)
            }
        }
        return nil
    }

    // MARK: - Connections
    func startConnecting(fromId: UUID, fromPortIndex: Int) {
        connectingFromId = fromId
        connectingFromPortIndex = fromPortIndex
    }

    func finishConnecting(toId: UUID, toPortIndex: Int) {
        guard let fromId = connectingFromId, fromId != toId else {
            connectingFromId = nil
            return
        }
        guard let (fromInst, fromTab) = findInstance(id: fromId),
              let (toInst, toTab) = findInstance(id: toId) else {
            connectingFromId = nil
            return
        }
        let fromComp = Components.all[fromInst.type]
        let toComp = Components.all[toInst.type]
        if fromComp?.comingSoon == true || toComp?.comingSoon == true {
            connectingFromId = nil
            return
        }
        if fromTab.id == toTab.id {
            // Same-tab connection
            let exists = fromTab.connections.contains {
                $0.fromId == fromId && $0.fromPortIndex == connectingFromPortIndex &&
                $0.toId == toId && $0.toPortIndex == toPortIndex
            }
            if !exists {
                fromTab.connections.append(NodeConnection(
                    fromId: fromId, fromPortIndex: connectingFromPortIndex,
                    toId: toId, toPortIndex: toPortIndex))
            }
        } else {
            // Cross-tab connection
            let exists = crossTabConnections.contains {
                $0.fromId == fromId && $0.fromPortIndex == connectingFromPortIndex &&
                $0.toId == toId && $0.toPortIndex == toPortIndex
            }
            if !exists {
                crossTabConnections.append(NodeConnection(
                    fromId: fromId, fromPortIndex: connectingFromPortIndex,
                    toId: toId, toPortIndex: toPortIndex))
            }
        }
        connectingFromId = nil
    }

    func cancelConnecting() { connectingFromId = nil }

    func removeConnection(_ id: UUID) {
        activeTab.connections.removeAll { $0.id == id }
        crossTabConnections.removeAll { $0.id == id }
    }

    func disconnectInput(instanceId: UUID, portIndex: Int) {
        activeTab.connections.removeAll {
            $0.toId == instanceId && $0.toPortIndex == portIndex
        }
        crossTabConnections.removeAll {
            $0.toId == instanceId && $0.toPortIndex == portIndex
        }
    }

    /// Remove connections that reference ports outside the new count bounds (called after I/O reconfigure).
    func clampConnections(for id: UUID, inputCount: Int, outputCount: Int) {
        activeTab.connections.removeAll {
            ($0.toId   == id && $0.toPortIndex   >= inputCount) ||
            ($0.fromId == id && $0.fromPortIndex >= outputCount)
        }
    }

    // MARK: - Exercises
    var currentExercise: Exercise { exercises[exerciseIndex] }

    func loadExercise(_ idx: Int) {
        exerciseIndex = idx
        hintIndex = 0
        clearCanvas()
    }

    func nextExercise() {
        if exerciseIndex < exercises.count - 1 { loadExercise(exerciseIndex + 1) }
    }

    func prevExercise() {
        if exerciseIndex > 0 { loadExercise(exerciseIndex - 1) }
    }

    func resetExercise() {
        hintIndex = 0
        clearCanvas()
    }

    var placedTypes: Set<String> {
        Set(instances.map { $0.type })
    }

    var connectedTypePairs: Set<String> {
        Set(connections.compactMap { conn -> String? in
            let fromType = instances.first(where: { $0.id == conn.fromId })?.type
            let toType   = instances.first(where: { $0.id == conn.toId })?.type
            guard let f = fromType, let t = toType else { return nil }
            return "\(f)→\(t)"
        })
    }

    func checkFlow() -> (success: Bool, message: String) {
        let ex = currentExercise
        let missing = ex.required.filter { !placedTypes.contains($0) }
        if !missing.isEmpty {
            let names = missing.compactMap { Components.all[$0]?.name }.joined(separator: ", ")
            return (false, "Missing components: \(names)")
        }
        let pairs = connectedTypePairs
        let flowMet = ex.validFlows.contains { flow in
            (0..<flow.count - 1).allSatisfy { i in pairs.contains("\(flow[i])→\(flow[i+1])") }
        }
        if flowMet {
            return (true, "✓ Perfect signal flow! All connections are correct.")
        }
        return (false, "Signal flow is incomplete or incorrect.\nCheck the required connections, or use a Hint.")
    }

    func nextHint() -> String? {
        let hints = currentExercise.hints
        guard !hints.isEmpty else { return nil }
        let hint = hints[hintIndex % hints.count]
        hintIndex += 1
        return hint
    }

    // MARK: - Quick Starts
    func loadQuickStart(_ key: String) {
        clearCanvas()
        guard let qs = quickStarts[key] else { return }
        let addedIds = qs.nodes.map { n in addInstance(type: n.type, position: n.position) }
        for (a, b) in qs.flows {
            let conn = NodeConnection(fromId: addedIds[a].id, fromPortIndex: 0,
                                     toId: addedIds[b].id, toPortIndex: 0)
            activeTab.connections.append(conn)
        }
    }

    // MARK: - Custom Exercises (UserDefaults persistence)
    func saveCustomExercise(_ ex: Exercise) {
        exercises.append(ex)
        persistCustomExercises()
        exerciseIndex = exercises.count - 1
        loadExercise(exerciseIndex)
    }

    func persistCustomExercises() {
        let custom = exercises.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: "customExercises")
        }
    }

    func loadCustomExercisesFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "customExercises"),
              let custom = try? JSONDecoder().decode([Exercise].self, from: data) else { return }
        for ex in custom where !exercises.contains(where: { $0.id == ex.id }) {
            exercises.append(ex)
        }
    }

    // MARK: - Canvas Zoom/Pan
    func resetCanvasView() {
        canvasScale = 1.0
        canvasOffset = .zero
    }

    // MARK: - Dark Mode
    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    // MARK: - Project Save/Load

    /// Convert the full canvas state into a Codable project snapshot.
    func makeProject() -> SavedProject {
        let savedTabs = tabs.map { tab -> SavedTab in
            SavedTab(
                id: tab.id,
                name: tab.name,
                parentRackInstanceId: tab.parentRackInstanceId,
                instances: tab.instances.map { inst in
                    SavedInstance(
                        id: inst.id,
                        type: inst.type,
                        positionX: Double(inst.position.x),
                        positionY: Double(inst.position.y),
                        rackSlot: inst.rackSlot,
                        ioConfig: inst.ioConfig.map {
                            SavedIOConfig(inputCount: $0.inputCount,
                                          inputSignalType: $0.inputSignalType,
                                          outputCount: $0.outputCount,
                                          outputSignalType: $0.outputSignalType)
                        },
                        ipAddress: inst.ipAddress,
                        portVlanTags: inst.portVlanTags.isEmpty ? nil : inst.portVlanTags,
                        selectedPreset: inst.selectedPreset
                    )
                },
                connections: tab.connections.map {
                    SavedConnection(id: $0.id, fromId: $0.fromId, fromPortIndex: $0.fromPortIndex,
                                   toId: $0.toId, toPortIndex: $0.toPortIndex)
                }
            )
        }
        let savedCross = crossTabConnections.map {
            SavedConnection(id: $0.id, fromId: $0.fromId, fromPortIndex: $0.fromPortIndex,
                           toId: $0.toId, toPortIndex: $0.toPortIndex)
        }
        return SavedProject(tabs: savedTabs, crossTabConnections: savedCross)
    }

    /// Replace the entire canvas state with a loaded project snapshot.
    func loadProject(_ project: SavedProject) {
        connectingFromId = nil
        var newTabs: [CanvasTab] = []
        for savedTab in project.tabs {
            let tab = CanvasTab(id: savedTab.id, name: savedTab.name,
                                parentRackInstanceId: savedTab.parentRackInstanceId)
            for si in savedTab.instances {
                let inst = NodeInstance(id: si.id, type: si.type,
                                        position: CGPoint(x: si.positionX, y: si.positionY))
                inst.rackSlot = si.rackSlot
                if let cfg = si.ioConfig {
                    inst.ioConfig = IOConfig(inputCount: cfg.inputCount,
                                             inputSignalType: cfg.inputSignalType,
                                             outputCount: cfg.outputCount,
                                             outputSignalType: cfg.outputSignalType)
                }
                inst.ipAddress = si.ipAddress
                if let tags = si.portVlanTags { inst.portVlanTags = tags }
                inst.selectedPreset = si.selectedPreset
                tab.instances.append(inst)
            }
            for sc in savedTab.connections {
                tab.connections.append(NodeConnection(id: sc.id, fromId: sc.fromId,
                                                      fromPortIndex: sc.fromPortIndex,
                                                      toId: sc.toId, toPortIndex: sc.toPortIndex))
            }
            newTabs.append(tab)
        }
        if newTabs.isEmpty { newTabs.append(CanvasTab(name: "Main")) }
        tabs = newTabs
        activeTabIndex = 0
        observeActiveTab()
        crossTabConnections = project.crossTabConnections.map {
            NodeConnection(id: $0.id, fromId: $0.fromId, fromPortIndex: $0.fromPortIndex,
                           toId: $0.toId, toPortIndex: $0.toPortIndex)
        }
        canvasScale = 1.0
        canvasOffset = .zero
    }

    func newProject() {
        currentProjectURL = nil
        connectingFromId = nil
        crossTabConnections = []
        tabs = [CanvasTab(name: "Main")]
        activeTabIndex = 0
        observeActiveTab()
        canvasScale = 1.0
        canvasOffset = .zero
    }

    func openProject() {
        let panel = NSOpenPanel()
        panel.title = "Open Project"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.begin { response in
            guard response == .OK, let url = panel.url,
                  let data = try? Data(contentsOf: url),
                  let project = try? JSONDecoder().decode(SavedProject.self, from: data) else { return }
            DispatchQueue.main.async {
                self.loadProject(project)
                self.currentProjectURL = url
            }
        }
    }

    func saveProject() {
        if let url = currentProjectURL {
            writeProject(to: url)
        } else {
            saveProjectAs()
        }
    }

    func saveProjectAs() {
        let panel = NSSavePanel()
        panel.title = "Save Project"
        panel.nameFieldStringValue = "signal-flow-project.json"
        panel.allowedContentTypes = [.json]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            DispatchQueue.main.async {
                self.currentProjectURL = url
                self.writeProject(to: url)
            }
        }
    }

    private func writeProject(to url: URL) {
        guard let data = try? JSONEncoder().encode(makeProject()) else { return }
        try? data.write(to: url)
    }

    // MARK: - User Racks ("My Equipment")

    /// Snapshot the current rack tab for `instanceId` and save it as a named user rack.
    func saveRackToMyEquipment(instanceId: UUID, name: String) {
        guard let rackTab = tabs.first(where: { $0.parentRackInstanceId == instanceId }),
              let inst = findInstance(id: instanceId)?.0 else { return }
        let rack = UserRack(
            name: name,
            rackType: inst.type,
            instances: rackTab.instances.map { ri in
                SavedInstance(id: UUID(), type: ri.type,
                              positionX: Double(ri.position.x), positionY: Double(ri.position.y),
                              rackSlot: ri.rackSlot, ioConfig: ri.ioConfig.map {
                                  SavedIOConfig(inputCount: $0.inputCount, inputSignalType: $0.inputSignalType,
                                                outputCount: $0.outputCount, outputSignalType: $0.outputSignalType)
                              })
            },
            connections: rackTab.connections.map {
                SavedConnection(id: UUID(), fromId: $0.fromId, fromPortIndex: $0.fromPortIndex,
                               toId: $0.toId, toPortIndex: $0.toPortIndex)
            }
        )
        userRacks.append(rack)
        persistUserRacks()
    }

    /// Place a user rack template on the current tab at the given position,
    /// creating and populating its inner rack tab automatically.
    @discardableResult
    func placeUserRack(_ userRack: UserRack, at position: CGPoint) -> NodeInstance {
        let rackInst = addInstance(type: userRack.rackType, position: position)
        // Create the rack tab
        guard let rackComp = Components.all[userRack.rackType] else { return rackInst }
        let rackTab = CanvasTab(name: rackComp.name, parentRackInstanceId: rackInst.id)
        // Build an ID-remapping table so connections reference the new instances
        var idMap: [UUID: UUID] = [:]
        for si in userRack.instances {
            let newId = UUID()
            idMap[si.id] = newId
            let inst = NodeInstance(id: newId, type: si.type,
                                    position: CGPoint(x: si.positionX, y: si.positionY))
            inst.rackSlot = si.rackSlot
            if let cfg = si.ioConfig {
                inst.ioConfig = IOConfig(inputCount: cfg.inputCount, inputSignalType: cfg.inputSignalType,
                                         outputCount: cfg.outputCount, outputSignalType: cfg.outputSignalType)
            }
            inst.ipAddress = si.ipAddress
            if let tags = si.portVlanTags { inst.portVlanTags = tags }
            inst.selectedPreset = si.selectedPreset
            rackTab.instances.append(inst)
        }
        for sc in userRack.connections {
            let newFrom = idMap[sc.fromId] ?? sc.fromId
            let newTo   = idMap[sc.toId]   ?? sc.toId
            rackTab.connections.append(NodeConnection(fromId: newFrom, fromPortIndex: sc.fromPortIndex,
                                                       toId: newTo, toPortIndex: sc.toPortIndex))
        }
        tabs.append(rackTab)
        return rackInst
    }

    func deleteUserRack(id: UUID) {
        userRacks.removeAll { $0.id == id }
        persistUserRacks()
    }

    func persistUserRacks() {
        if let data = try? JSONEncoder().encode(userRacks) {
            UserDefaults.standard.set(data, forKey: "userRacks")
        }
    }

    func loadUserRacksFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "userRacks"),
              let loaded = try? JSONDecoder().decode([UserRack].self, from: data) else { return }
        userRacks = loaded
    }
}

// MARK: - Quick Starts Data
struct QuickStartNode {
    let type: String
    let position: CGPoint
}
struct QuickStart {
    let nodes: [QuickStartNode]
    let flows: [(Int, Int)]
}

let quickStarts: [String: QuickStart] = [
    "live-pa": QuickStart(nodes: [
        QuickStartNode(type: "microphone",  position: CGPoint(x: 60,  y: 120)),
        QuickStartNode(type: "mixer",       position: CGPoint(x: 230, y: 100)),
        QuickStartNode(type: "power_amp",   position: CGPoint(x: 400, y: 100)),
        QuickStartNode(type: "speakers",    position: CGPoint(x: 570, y: 100)),
    ], flows: [(0,1),(1,2),(2,3)]),

    "recording": QuickStart(nodes: [
        QuickStartNode(type: "microphone",      position: CGPoint(x: 60,  y: 120)),
        QuickStartNode(type: "preamp",          position: CGPoint(x: 230, y: 80)),
        QuickStartNode(type: "compressor",      position: CGPoint(x: 230, y: 200)),
        QuickStartNode(type: "audio_interface", position: CGPoint(x: 420, y: 120)),
        QuickStartNode(type: "monitors",        position: CGPoint(x: 600, y: 120)),
    ], flows: [(0,1),(1,2),(2,3),(3,4)]),

    "guitar": QuickStart(nodes: [
        QuickStartNode(type: "guitar",        position: CGPoint(x: 40,  y: 150)),
        QuickStartNode(type: "effects_pedal", position: CGPoint(x: 200, y: 150)),
        QuickStartNode(type: "di_box",        position: CGPoint(x: 360, y: 150)),
        QuickStartNode(type: "mixer",         position: CGPoint(x: 520, y: 120)),
        QuickStartNode(type: "power_amp",     position: CGPoint(x: 520, y: 230)),
        QuickStartNode(type: "speakers",      position: CGPoint(x: 680, y: 230)),
    ], flows: [(0,1),(1,2),(2,3),(3,4),(4,5)]),
]
