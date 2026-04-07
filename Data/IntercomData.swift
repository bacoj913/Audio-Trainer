import Foundation

// MARK: - Intercom Data Models

struct IntercomBrand: Identifiable {
    let id = UUID()
    var name: String
    var beltpackModels: [String]
    var mainStationModels: [String]
    var remoteStationModels: [String]
    var wirelessModels: [String]
    var matrixModels: [String]
}

struct IntercomChannel: Identifiable {
    var id: Int
    var label: String
    var partyLine: Bool   // true = party line, false = point-to-point
    var assignment: String // e.g. "Stage Manager → FOH", "All Crew"
    var notes: String
}

struct IntercomDevice: Identifiable {
    let id = UUID()
    var cat: String
    var name: String
    var qty: Int
}

struct IntercomPosition: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var channels: [String]  // channel labels assigned to this position
    var notes: String
}

struct IntercomProductionAdvance: Identifiable {
    let id = UUID()
    var showName: String
    var positions: [IntercomPosition]
    var venue: RFVenue
    var changeLog: [String]
}

// MARK: - Intercom Brands

let intercomBrands: [IntercomBrand] = [
    IntercomBrand(
        name: "Clear-Com",
        beltpackModels: ["RS-701", "RS-702", "FreeSpeak Edge BP", "LQ Series"],
        mainStationModels: ["MS-702", "MS-704", "Eclipse HX-PiCO", "Eclipse HX-Median"],
        remoteStationModels: ["RS-501", "RS-504", "CC-300", "CC-110"],
        wirelessModels: ["FreeSpeak II", "FreeSpeak Edge", "DX210"],
        matrixModels: ["Eclipse HX", "Eclipse HX-Delta", "Eclipse HX-Omega"]
    ),
    IntercomBrand(
        name: "RTS",
        beltpackModels: ["TR-800", "TR-1800", "ADAM-M", "OMNEO M"],
        mainStationModels: ["KP-32 CL", "KP-4016", "ADAM-II", "ADAM-CS"],
        remoteStationModels: ["KP-12 CL", "KP-16 CL", "KP-32 CL"],
        wirelessModels: ["BTR-800", "BTR-1600", "Odin Wireless"],
        matrixModels: ["ADAM-II", "Odin", "OMNEO Compact"]
    ),
    IntercomBrand(
        name: "Riedel",
        beltpackModels: ["Artist 1000", "Artist 1200", "Bolero BP", "SmartPanel"],
        mainStationModels: ["Artist Node", "Artist 128", "MediorNet"],
        remoteStationModels: ["Artist Panel 12", "Artist Panel 4"],
        wirelessModels: ["Bolero", "Acrobat", "SmartBelt"],
        matrixModels: ["Artist 128", "Artist 64", "MediorNet MicroN"]
    ),
    IntercomBrand(
        name: "Bolero (Riedel)",
        beltpackModels: ["Bolero Beltpack", "Bolero Advance"],
        mainStationModels: ["Bolero Antenna Hub", "Bolero Base Station"],
        remoteStationModels: ["Bolero Wired Panel"],
        wirelessModels: ["Bolero DECT", "Bolero Advanced DECT"],
        matrixModels: ["Bolero Standalone", "Artist + Bolero"]
    ),
    IntercomBrand(
        name: "Tempest",
        beltpackModels: ["2400 Beltpack", "800CH Beltpack"],
        mainStationModels: ["2400 Base Station", "800CH Base"],
        remoteStationModels: ["Wired Panel"],
        wirelessModels: ["2400 MHz System", "900 MHz System"],
        matrixModels: ["Tempest Standalone"]
    ),
]

// MARK: - Position Pools

private let stagePositions: [(name: String, loc: String, channels: [String], notes: String)] = [
    ("Stage Manager",       "Stage Right",    ["All", "Deck", "Fly"],       "Calls all cues"),
    ("Deck SM",             "Stage Left",     ["All", "Deck"],              "Deck calls"),
    ("A1",                  "FOH",            ["All", "Audio"],             "Front of house audio"),
    ("A2",                  "Stage",          ["All", "Audio"],             "Stage audio"),
    ("L1 (LD)",             "FOH Lighting",   ["All", "Lighting"],          "Lighting designer"),
    ("L2 (Board Op)",       "FOH Lighting",   ["All", "Lighting"],          "Lighting board"),
    ("Fly Rail",            "Stage Right Fly",["All", "Fly"],               "Fly system"),
    ("Follow Spot 1",       "Booth",          ["Lighting", "Spots"],        ""),
    ("Follow Spot 2",       "Booth",          ["Lighting", "Spots"],        ""),
    ("Video Director",      "Video Village",  ["All", "Video"],             ""),
    ("Camera 1",            "Stage Left",     ["Video"],                    ""),
    ("Camera 2",            "Stage Right",    ["Video"],                    ""),
    ("Wardrobe",            "Backstage",      ["All", "Wardrobe"],          "Quick changes"),
    ("Hair/Makeup",         "Dressing Room",  ["All"],                      ""),
    ("Catering/Craft",      "Catering",       ["Production"],               ""),
    ("Security",            "House",          ["Production", "Security"],   ""),
    ("Lobby",               "Lobby",          ["Production"],               ""),
    ("Truck/Load-In",       "Loading Dock",   ["Production"],               ""),
    ("Production Manager",  "Production",     ["All", "Production"],        "PM position"),
    ("Director",            "FOH",            ["All"],                      "Show director"),
]

private let theaterPositions: [(name: String, loc: String, channels: [String], notes: String)] = [
    ("Stage Manager",       "Prompt Corner",  ["All", "SM", "Deck"],        "Calls show"),
    ("ASM 1",               "Stage Right",    ["All", "SM", "Deck"],        ""),
    ("ASM 2",               "Stage Left",     ["All", "SM", "Deck"],        ""),
    ("A1",                  "Mix Position",   ["All", "Audio"],             ""),
    ("A2",                  "Stage",          ["All", "Audio"],             ""),
    ("LD",                  "Mix Position",   ["All", "Lighting"],          ""),
    ("Board Op",            "Booth",          ["Lighting"],                 ""),
    ("Fly Operator",        "Fly Floor",      ["All", "Fly", "SM"],         ""),
    ("Automation",          "Wings",          ["All", "SM", "Automation"],  ""),
    ("Props",               "Backstage",      ["All", "SM"],                ""),
    ("Wardrobe Head",       "Wardrobe",       ["All", "SM", "Wardrobe"],    ""),
    ("Hair Supervisor",     "Dressing Room",  ["SM"],                       ""),
    ("Follow Spot 1",       "Booth",          ["Lighting"],                 ""),
    ("Follow Spot 2",       "Booth",          ["Lighting"],                 ""),
    ("Video",               "Tech Booth",     ["All", "Video"],             ""),
    ("Production Manager",  "Production",     ["All"],                      ""),
]

private let corporatePositions: [(name: String, loc: String, channels: [String], notes: String)] = [
    ("Show Caller",         "Stage",          ["All", "Show"],              "Calls all elements"),
    ("A1",                  "FOH",            ["All", "Audio"],             ""),
    ("A2",                  "Stage",          ["All", "Audio"],             ""),
    ("LD",                  "FOH",            ["All", "Lighting"],          ""),
    ("Video Director",      "Video Village",  ["All", "Video"],             ""),
    ("Teleprompter Op",     "Prompt",         ["All", "Prompt"],            ""),
    ("Camera 1",            "Aisle",          ["Video"],                    ""),
    ("Camera 2",            "Stage Left",     ["Video"],                    ""),
    ("Confidence Monitor",  "Stage",          ["All"],                      ""),
    ("Staging PM",          "Production",     ["All", "Production"],        ""),
    ("Client Liaison",      "Client Area",    ["Production"],               ""),
    ("Rigging",             "Overhead",       ["All", "Production"],        ""),
    ("IT/Networking",       "Tech Area",      ["Production"],               ""),
]

private let showNames = [
    "World Tour", "North American Tour", "Spring Run", "Summer Season",
    "Residency", "Broadway Transfer", "Regional Tour", "National Tour",
    "Festival Run", "One Night Only", "Grand Opening", "World Premiere"
]

// MARK: - Advance Generator

func generateIntercomAdvance(venue: RFVenue) -> IntercomProductionAdvance {
    let pool: [(name: String, loc: String, channels: [String], notes: String)]
    let count: Int

    switch venue.type {
    case "Theater":
        pool = theaterPositions
        count = min(pool.count, icRand(8, 14))
    case "Corporate":
        pool = corporatePositions
        count = min(pool.count, icRand(6, 11))
    default: // Concert
        pool = stagePositions
        count = min(pool.count, icRand(8, 16))
    }

    let selected = Array(pool.shuffled().prefix(count))
    let positions: [IntercomPosition] = selected.map { p in
        IntercomPosition(name: p.name, location: p.loc, channels: p.channels, notes: p.notes)
    }

    return IntercomProductionAdvance(
        showName: "\(venue.name) — \(icPick(showNames))",
        positions: positions,
        venue: venue,
        changeLog: []
    )
}

// MARK: - Rehearsal Change Generator

func generateIntercomChange(
    advance: IntercomProductionAdvance,
    iteration: Int
) -> (advance: IntercomProductionAdvance, description: String) {
    var updated = advance
    let changes = ["Position added", "Channel reassignment", "Additional beltpack needed",
                   "Position removed from call", "New wireless position requested",
                   "Matrix channel label change"]
    let desc = "\(icPick(changes)) (Rehearsal \(iteration + 1))"
    updated.changeLog.append(desc)

    // Occasionally add a new position
    if Int.random(in: 0...2) == 0 {
        let allPools = stagePositions + theaterPositions + corporatePositions
        let existing = Set(advance.positions.map { $0.name })
        let candidates = allPools.filter { !existing.contains($0.name) }
        if let new = candidates.randomElement() {
            updated.positions.append(
                IntercomPosition(name: new.name, location: new.loc, channels: new.channels, notes: new.notes)
            )
        }
    }
    return (updated, desc)
}

// MARK: - Channel List Builder

func buildChannelList(from advance: IntercomProductionAdvance) -> [IntercomChannel] {
    // Collect unique channel labels from all positions
    var seen = Set<String>()
    var channels: [IntercomChannel] = []
    var nextId = 1

    for position in advance.positions {
        for ch in position.channels {
            if !seen.contains(ch) {
                seen.insert(ch)
                channels.append(IntercomChannel(
                    id: nextId,
                    label: ch,
                    partyLine: true,
                    assignment: ch == "All" ? "All Crew" : "\(ch) Team",
                    notes: ""
                ))
                nextId += 1
            }
        }
    }
    return channels
}

// MARK: - Intercom Gear Generator

func generateIntercomGear(advance: IntercomProductionAdvance) -> [IntercomDevice] {
    let brand = icPick(intercomBrands)
    let posCount = advance.positions.count
    let wirelessCount = max(2, posCount / 3)
    let wiredCount = posCount - wirelessCount

    var gear: [IntercomDevice] = []

    // Matrix / main station
    gear.append(IntercomDevice(cat: "Matrix / Main Station", name: icPick(brand.matrixModels), qty: 1))

    // Wired beltpacks
    if wiredCount > 0 {
        gear.append(IntercomDevice(cat: "Wired Beltpack", name: icPick(brand.beltpackModels), qty: wiredCount))
    }

    // Wireless beltpacks + base stations
    if wirelessCount > 0 {
        gear.append(IntercomDevice(cat: "Wireless Beltpack", name: icPick(brand.wirelessModels), qty: wirelessCount))
        let antCount = max(1, Int(ceil(Double(wirelessCount) / 4)))
        gear.append(IntercomDevice(cat: "Antenna / Base Station", name: icPick(brand.mainStationModels), qty: antCount))
    }

    // Remote / key stations
    let keyStations = max(1, posCount / 5)
    gear.append(IntercomDevice(cat: "Key Station", name: icPick(brand.remoteStationModels), qty: keyStations))

    // Cable / accessories
    gear.append(IntercomDevice(cat: "Headset (Single Ear)", name: "Single-muff headset", qty: wiredCount))
    if wirelessCount > 0 {
        gear.append(IntercomDevice(cat: "Headset (Wireless)", name: "Lightweight headset", qty: wirelessCount))
    }

    return gear
}

// MARK: - Validation

struct IntercomValidationResult: Identifiable {
    let id = UUID()
    var category: String
    var required: Int
    var onHand: Int
    var isOk: Bool { onHand >= required }
}

func validateIntercomGear(
    gear: [IntercomDevice],
    against advance: IntercomProductionAdvance
) -> [IntercomValidationResult] {
    let posCount = advance.positions.count
    let wirelessNeeded = max(2, posCount / 3)
    let wiredNeeded = posCount - wirelessNeeded

    func qty(_ cat: String) -> Int {
        gear.filter { $0.cat == cat }.reduce(0) { $0 + $1.qty }
    }

    return [
        IntercomValidationResult(
            category: "Wired Beltpack",
            required: wiredNeeded,
            onHand: qty("Wired Beltpack")
        ),
        IntercomValidationResult(
            category: "Wireless Beltpack",
            required: wirelessNeeded,
            onHand: qty("Wireless Beltpack")
        ),
    ]
}

// MARK: - Helpers

private func icPick<T>(_ arr: [T]) -> T { arr[Int.random(in: 0..<arr.count)] }
private func icRand(_ lo: Int, _ hi: Int) -> Int { Int.random(in: lo...hi) }
