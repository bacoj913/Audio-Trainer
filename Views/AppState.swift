// AppState.swift — Observable app-wide state

import SwiftUI
import Combine

// MARK: - App Mode
enum AppMode { case free, exercise, rf }

// MARK: - Node Instance
class NodeInstance: ObservableObject, Identifiable {
    let id = UUID()
    let type: String
    @Published var position: CGPoint

    init(type: String, position: CGPoint) {
        self.type = type
        self.position = position
    }
}

// MARK: - Connection
struct NodeConnection: Identifiable, Equatable {
    let id = UUID()
    let fromId: UUID
    let fromPortIndex: Int   // index into comp.ports.outputs
    let toId: UUID
    let toPortIndex: Int     // index into comp.ports.inputs
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
    @Published var mode: AppMode = .free
    @Published var instances: [NodeInstance] = []
    @Published var connections: [NodeConnection] = []
    @Published var connectingFromId: UUID? = nil
    @Published var connectingFromPortIndex: Int = 0
    @Published var portPositions: [String: CGPoint] = [:]
    @Published var mousePosition: CGPoint = .zero
    @Published var exerciseIndex: Int = 0
    @Published var hintIndex: Int = 0
    @Published var showExerciseBuilder: Bool = false
    @Published var isDarkMode: Bool = false
    @Published var exercises: [Exercise] = builtInExercises
    @Published var rfState: RFState = RFState()

    private var nextNodeId = 1

    // MARK: - Canvas
    static let nodeWidth: CGFloat = 168
    static let nodeHeight: CGFloat = 130
    static let rackNodeWidth: CGFloat = 200

    /// Look up the canvas-space center of a specific port by index.
    /// Positions are reported by PortEdgeDot views via PortAnchorPref.
    func portCenter(for instanceId: UUID, portIndex: Int, side: String) -> CGPoint? {
        portPositions["\(instanceId)-\(side)-\(portIndex)"]
    }

    // MARK: - Node Management
    @discardableResult
    func addInstance(type: String, position: CGPoint) -> NodeInstance {
        let inst = NodeInstance(type: type, position: position)
        instances.append(inst)
        return inst
    }

    func deleteNode(id: UUID) {
        connections.removeAll { $0.fromId == id || $0.toId == id }
        portPositions = portPositions.filter { !$0.key.hasPrefix(id.uuidString) }
        instances.removeAll { $0.id == id }
        if connectingFromId == id { connectingFromId = nil }
    }

    func clearCanvas() {
        instances.removeAll()
        connections.removeAll()
        portPositions.removeAll()
        connectingFromId = nil
    }

    func autoLayout() {
        guard !instances.isEmpty else { return }
        let cols = Int(ceil(sqrt(Double(instances.count))))
        let cellW: CGFloat = 200
        let cellH: CGFloat = 160
        for (i, inst) in instances.enumerated() {
            let col = i % cols
            let row = i / cols
            inst.position = CGPoint(x: 40 + CGFloat(col) * cellW, y: 40 + CGFloat(row) * cellH)
        }
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
        let fromComp = Components.all[instances.first(where: { $0.id == fromId })?.type ?? ""]
        let toComp = Components.all[instances.first(where: { $0.id == toId })?.type ?? ""]
        if fromComp?.comingSoon == true || toComp?.comingSoon == true {
            connectingFromId = nil
            return
        }
        let exists = connections.contains {
            $0.fromId == fromId && $0.fromPortIndex == connectingFromPortIndex &&
            $0.toId == toId && $0.toPortIndex == toPortIndex
        }
        if !exists {
            connections.append(NodeConnection(
                fromId: fromId, fromPortIndex: connectingFromPortIndex,
                toId: toId, toPortIndex: toPortIndex))
        }
        connectingFromId = nil
    }

    func cancelConnecting() { connectingFromId = nil }

    func removeConnection(_ id: UUID) {
        connections.removeAll { $0.id == id }
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
            connections.append(conn)
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

    // MARK: - Dark Mode
    func toggleDarkMode() {
        isDarkMode.toggle()
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
