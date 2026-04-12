// Models/SavedProject.swift — Codable data-transfer objects for canvas save/load

import Foundation
import CoreGraphics

// MARK: - Top-level project file

struct SavedProject: Codable {
    var version: Int = 1
    var tabs: [SavedTab]
    var crossTabConnections: [SavedConnection]
    var danteFlows: [SavedDanteFlow]? = nil
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
    var ipAddress: String?
    var portVlanTags: [Int: Int]?
    var selectedPreset: String?
    var slotCards: [Int: SavedSlotCard]?
    var danteDeviceName: String?
}

// MARK: - Expansion slot card

struct SavedSlotCard: Codable {
    var id: UUID
    var slotNumber: Int
    var cardType: String
}

// MARK: - Dante routing flow

struct SavedDanteFlow: Codable {
    var id: UUID
    var fromDeviceId: UUID
    var fromPortIndex: Int
    var toDeviceId: UUID
    var toPortIndex: Int
}

// MARK: - Configurable I/O override

struct SavedIOConfig: Codable {
    // New format: groups of (count, signalType) per direction
    var inputGroups: [SavedIOPortGroup]
    var outputGroups: [SavedIOPortGroup]

    init(ioConfig: IOConfig) {
        self.inputGroups  = ioConfig.inputGroups.map  { SavedIOPortGroup(count: $0.count, signalType: $0.signalType, labelPrefix: $0.labelPrefix) }
        self.outputGroups = ioConfig.outputGroups.map { SavedIOPortGroup(count: $0.count, signalType: $0.signalType, labelPrefix: $0.labelPrefix) }
    }

    func toIOConfig() -> IOConfig {
        IOConfig(
            inputGroups:  inputGroups.map  { IOPortGroup(count: $0.count, signalType: $0.signalType, labelPrefix: $0.labelPrefix) },
            outputGroups: outputGroups.map { IOPortGroup(count: $0.count, signalType: $0.signalType, labelPrefix: $0.labelPrefix) }
        )
    }
}

struct SavedIOPortGroup: Codable {
    var count: Int
    var signalType: String
    var labelPrefix: String = ""
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
