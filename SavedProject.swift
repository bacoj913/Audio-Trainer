// Models/SavedProject.swift — Codable data-transfer objects for canvas save/load

import Foundation
import CoreGraphics

// MARK: - Top-level project file

struct SavedProject: Codable {
    var version: Int = 1
    var tabs: [SavedTab]
    var crossTabConnections: [SavedConnection]
}

// MARK: - Tab (main canvas or rack interior)

struct SavedTab: Codable {
    var id: UUID
    var name: String
    var parentRackInstanceId: UUID?
    var instances: [SavedInstance]
    var connections: [SavedConnection]
}

// MARK: - Instance (placed component)

struct SavedInstance: Codable {
    var id: UUID
    var type: String
    var positionX: Double
    var positionY: Double
    var rackSlot: Int?
    var ioConfig: SavedIOConfig?
}

// MARK: - Configurable I/O override

struct SavedIOConfig: Codable {
    var inputCount: Int
    var inputSignalType: String
    var outputCount: Int
    var outputSignalType: String
}

// MARK: - Connection

struct SavedConnection: Codable {
    var id: UUID
    var fromId: UUID
    var fromPortIndex: Int
    var toId: UUID
    var toPortIndex: Int
}

// MARK: - User Rack (saved rack template stored in My Equipment)

struct UserRack: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    /// The rack enclosure component type (e.g. "rack_8u", "rack_amp")
    var rackType: String
    var instances: [SavedInstance]
    var connections: [SavedConnection]
}
