// Models/RFData.swift — RF Planner data: venues, wireless systems, antennas, distros, accessories

import Foundation

// MARK: - RF Environment
enum RFEnvironment: String, CaseIterable {
    case low      = "Low"
    case moderate = "Moderate"
    case busy     = "Busy"
    case veryBusy = "Very Busy"
}

// MARK: - RF Venue
struct RFVenue {
    let name: String
    let type: String
    let capacity: Int
    let city: String
    let region: String   // "US", "EU", "AU", "CA"
    let rfEnv: RFEnvironment
    let notes: String
}

// MARK: - Wireless System
struct FreqBand {
    let band: String
    let range: String
}

struct RFTxItem {
    let name: String
    let cat: String
}

struct RFRxModel {
    let name: String
    let channels: Int
    let cat: String
}

struct RFWirelessSystem {
    let key: String
    let brand: String
    let system: String
    let freqBands: [String: [FreqBand]]
    let receivers: [RFRxModel]
    let handhelds: [RFTxItem]
    let bodypacks: [RFTxItem]
    let iemTx: [RFTxItem]?
    let iemRx: [RFTxItem]?
    let coord: String
}

struct RFListItem {
    let name: String
    let cat: String
}

// MARK: - Venues
let rfVenues: [RFVenue] = [
    RFVenue(name: "The Blue Note Lounge",        type: "Jazz Club",              capacity: 120,    city: "Chicago, IL",       region: "US", rfEnv: .moderate,  notes: "Low ceiling, brick walls, good RF behavior. Neighboring bars may cause minor interference on busy nights."),
    RFVenue(name: "Riverside Brewing Co.",        type: "Brewery / Bar",          capacity: 250,    city: "Portland, OR",      region: "US", rfEnv: .moderate,  notes: "Industrial HVAC introduces some RF noise floor. Open floor plan is otherwise friendly for wireless."),
    RFVenue(name: "Sunset Rooftop Bar",           type: "Rooftop Venue",          capacity: 180,    city: "Miami, FL",         region: "US", rfEnv: .low,       notes: "Open sky great for RF line-of-sight. Neighboring high-rises may create unexpected multipath."),
    RFVenue(name: "The Palace Theatre",           type: "Historic Theater",        capacity: 850,    city: "Columbus, OH",      region: "US", rfEnv: .low,       notes: "Plaster walls and ornate interior can cause multipath reflections. Generally clean RF environment."),
    RFVenue(name: "Orpheum Performing Arts Ctr",  type: "Performing Arts Center",  capacity: 2400,   city: "Memphis, TN",       region: "US", rfEnv: .moderate,  notes: "Large stage requires distributed antenna coverage. Multiple HVAC zones across building."),
    RFVenue(name: "Lakeside Community Church",    type: "House of Worship",        capacity: 1800,   city: "Nashville, TN",     region: "US", rfEnv: .low,       notes: "Campus already uses 700/800 MHz comms. Newer LED stage lighting may cause narrowband interference."),
    RFVenue(name: "Grand Hyatt Ballroom",         type: "Hotel Ballroom",          capacity: 600,    city: "New York, NY",      region: "US", rfEnv: .busy,      notes: "Dense hotel Wi-Fi infrastructure. Multiple simultaneous events on property likely. Coordinate with AV department."),
    RFVenue(name: "Convention Center Hall A",     type: "Convention Center",       capacity: 5000,   city: "Las Vegas, NV",     region: "US", rfEnv: .veryBusy,  notes: "Dozens of simultaneous productions. Exhibitor Wi-Fi extremely dense. Extensive coordination with show organizer essential."),
    RFVenue(name: "Red Rocks Amphitheatre",       type: "Outdoor Amphitheater",    capacity: 9500,   city: "Morrison, CO",      region: "US", rfEnv: .moderate,  notes: "Open air with rocky terrain and altitude. Broadcast trucks often on-site. Clear line-of-sight generally available."),
    RFVenue(name: "Coachella Main Stage",         type: "Outdoor Festival Stage",  capacity: 100000, city: "Indio, CA",         region: "US", rfEnv: .veryBusy,  notes: "Festival environment with dozens of simultaneous active systems. Coordination with adjacent stages and broadcast critical."),
    RFVenue(name: "Metro Arena",                  type: "Indoor Arena",            capacity: 18000,  city: "Atlanta, GA",       region: "US", rfEnv: .veryBusy,  notes: "Dense LED video wall broadband noise. Scoreboard systems active on event days. Tour advance coordination required."),
    RFVenue(name: "Madison Square Garden",        type: "Arena / Stadium",         capacity: 20789,  city: "New York, NY",      region: "US", rfEnv: .veryBusy,  notes: "Dense urban RF environment on all sides. Legacy building infrastructure. Must coordinate with house systems team."),
    RFVenue(name: "O2 Arena",                     type: "Indoor Arena",            capacity: 20000,  city: "London, UK",        region: "EU", rfEnv: .veryBusy,  notes: "Post-700 MHz clearance: avoid 694 MHz+. Dense urban environment. Coordination with BSkyB broadcast required for large events."),
    RFVenue(name: "Royal Albert Hall",            type: "Concert Hall",            capacity: 5272,   city: "London, UK",        region: "EU", rfEnv: .moderate,  notes: "Victorian hall with excellent acoustics. Strong Wi-Fi from visitor devices. Licensed spectrum 606–614 MHz best avoided."),
    RFVenue(name: "Olympiahalle München",         type: "Arena",                   capacity: 15500,  city: "Munich, Germany",   region: "EU", rfEnv: .busy,      notes: "BOS (Blaulicht) comms active on event days. 470–694 MHz licensed spectrum must be coordinated with Bundesnetzagentur."),
    RFVenue(name: "Sydney Opera House",           type: "Concert Hall",            capacity: 2679,   city: "Sydney, Australia", region: "AU", rfEnv: .moderate,  notes: "ACMA licensed spectrum 520–694 MHz. Iconic building creates interesting RF reflections. Coordinate with house RF engineer."),
    RFVenue(name: "Rogers Centre",                type: "Domed Stadium",           capacity: 53500,  city: "Toronto, Canada",   region: "CA", rfEnv: .veryBusy,  notes: "ISED Canada licensed spectrum mirrors US: 470–608 MHz. Steel dome creates significant RF multipath. Distributed antenna system recommended."),
]

// MARK: - Wireless Systems
let rfWirelessSystems: [RFWirelessSystem] = [
    RFWirelessSystem(
        key: "shure-axient", brand: "Shure", system: "Axient Digital",
        freqBands: [
            "US": [FreqBand(band: "G57", range: "470–638 MHz"), FreqBand(band: "H60", range: "542–616 MHz"), FreqBand(band: "V60", range: "596–688 MHz")],
            "EU": [FreqBand(band: "R16", range: "655–679 MHz"), FreqBand(band: "S50", range: "823–865 MHz")],
            "AU": [FreqBand(band: "P10", range: "614–694 MHz")],
            "CA": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Shure AD4Q Axient Digital (4ch)", channels: 4, cat: "Receiver"),
            RFRxModel(name: "Shure AD4D Axient Digital (2ch)", channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Shure AD2 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Shure AD1 Bodypack Transmitter", cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Shure P10T PSM1000 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Shure P10R PSM1000 IEM Receiver",    cat: "IEM Receiver")],
        coord: "Shure Wireless Workbench 6"
    ),
    RFWirelessSystem(
        key: "shure-ulxd", brand: "Shure", system: "ULX-D",
        freqBands: [
            "US": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz"), FreqBand(band: "J50A", range: "572–636 MHz")],
            "EU": [FreqBand(band: "V50", range: "174–216 MHz"), FreqBand(band: "X52", range: "902–928 MHz")],
            "AU": [FreqBand(band: "L50", range: "632–696 MHz")],
            "CA": [FreqBand(band: "G50", range: "470–534 MHz"), FreqBand(band: "H50", range: "534–598 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Shure ULXD4Q Quad Receiver (4ch)", channels: 4, cat: "Receiver"),
            RFRxModel(name: "Shure ULXD4D Dual Receiver (2ch)",  channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Shure ULXD2 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Shure ULXD1 Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Shure P9T PSM900 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Shure P9R PSM900 IEM Receiver",    cat: "IEM Receiver")],
        coord: "Shure Wireless Workbench 6"
    ),
    RFWirelessSystem(
        key: "sennheiser-ew6000", brand: "Sennheiser", system: "EW 6000",
        freqBands: [
            "US": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "EU": [FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "G", range: "566–608 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "AU": [FreqBand(band: "D", range: "780–822 MHz")],
            "CA": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz")],
        ],
        receivers: [RFRxModel(name: "Sennheiser EM 6000 Dante (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Sennheiser SKM 6000 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Sennheiser SK 6000 Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Sennheiser SR IEM G4 Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Sennheiser EK IEM G4 Receiver",    cat: "IEM Receiver")],
        coord: "Sennheiser Wireless Systems Manager (WSM)"
    ),
    RFWirelessSystem(
        key: "sennheiser-g4", brand: "Sennheiser", system: "Evolution Wireless G4",
        freqBands: [
            "US": [FreqBand(band: "A1", range: "470–516 MHz"), FreqBand(band: "A", range: "516–558 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "EU": [FreqBand(band: "G", range: "566–608 MHz"), FreqBand(band: "B", range: "626–668 MHz")],
            "AU": [FreqBand(band: "D", range: "780–822 MHz")],
            "CA": [FreqBand(band: "A1", range: "470–516 MHz")],
        ],
        receivers: [RFRxModel(name: "Sennheiser EM 300-500 G4 (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Sennheiser SKM 300 G4 Handheld", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Sennheiser SK 300 G4 Bodypack",   cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Sennheiser SR IEM G4 Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Sennheiser EK IEM G4 Receiver",    cat: "IEM Receiver")],
        coord: "Sennheiser Wireless Systems Manager (WSM)"
    ),
    RFWirelessSystem(
        key: "wisycom", brand: "Wisycom", system: "MCR54 / MTP41S",
        freqBands: [
            "US": [FreqBand(band: "A5T", range: "470–558 MHz"), FreqBand(band: "B5T", range: "554–640 MHz"), FreqBand(band: "C5T", range: "636–722 MHz")],
            "EU": [FreqBand(band: "A5T", range: "470–558 MHz"), FreqBand(band: "B5T", range: "554–640 MHz")],
            "AU": [FreqBand(band: "B5T", range: "554–640 MHz")],
            "CA": [FreqBand(band: "A5T", range: "470–558 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Wisycom MCR54 Quad Receiver (4ch)",  channels: 4, cat: "Receiver"),
            RFRxModel(name: "Wisycom MCR42S Dual Receiver (2ch)", channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Wisycom MTH400 Handheld Transmitter", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Wisycom MTP41S Bodypack Transmitter",  cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Wisycom MTK952 IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Wisycom MPR52 IEM Receiver",     cat: "IEM Receiver")],
        coord: "IAS Intermodulation Analysis System"
    ),
    RFWirelessSystem(
        key: "audio-technica", brand: "Audio-Technica", system: "5000 Series",
        freqBands: [
            "US": [FreqBand(band: "TV56", range: "542–572 MHz"), FreqBand(band: "TV62", range: "578–608 MHz")],
            "EU": [FreqBand(band: "EG1", range: "470–530 MHz"), FreqBand(band: "EG2", range: "530–590 MHz")],
            "AU": [FreqBand(band: "AU",  range: "520–554 MHz")],
            "CA": [FreqBand(band: "TV56", range: "542–572 MHz")],
        ],
        receivers: [RFRxModel(name: "Audio-Technica ATW-R5220 (2ch)", channels: 2, cat: "Receiver")],
        handhelds: [RFTxItem(name: "Audio-Technica ATW-T5202 Handheld", cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Audio-Technica ATW-T5201 Bodypack",  cat: "Bodypack / Lav")],
        iemTx: nil,
        iemRx: nil,
        coord: "Audio-Technica ATND1061DAN Network Manager"
    ),
    RFWirelessSystem(
        key: "lectrosonics", brand: "Lectrosonics", system: "Venue2 / D Squared",
        freqBands: [
            "US": [FreqBand(band: "Block 470", range: "470–537 MHz"), FreqBand(band: "Block 19", range: "486–512 MHz"), FreqBand(band: "Block 21", range: "518–544 MHz"), FreqBand(band: "Block 22", range: "530–556 MHz")],
            "EU": [FreqBand(band: "EU1", range: "563–614 MHz"), FreqBand(band: "EU2", range: "614–663 MHz")],
            "AU": [FreqBand(band: "AUS", range: "520–614 MHz")],
            "CA": [FreqBand(band: "Block 470", range: "470–537 MHz")],
        ],
        receivers: [
            RFRxModel(name: "Lectrosonics Venue2 (6ch frame)", channels: 6, cat: "Receiver"),
            RFRxModel(name: "Lectrosonics DCR822 (2ch)",        channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Lectrosonics DHu Digital Handheld",   cat: "Handheld Wireless")],
        bodypacks: [RFTxItem(name: "Lectrosonics SMWB Bodypack Transmitter", cat: "Bodypack / Lav")],
        iemTx: [RFTxItem(name: "Lectrosonics M2T IEM Transmitter", cat: "IEM Transmitter")],
        iemRx: [RFTxItem(name: "Lectrosonics M2R IEM Receiver",    cat: "IEM Receiver")],
        coord: "IAS Intermodulation Analysis System"
    ),
    RFWirelessSystem(
        key: "sound-devices", brand: "Sound Devices", system: "A20 Series",
        freqBands: [
            "US": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "EU": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "AU": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
            "CA": [FreqBand(band: "Full Spectrum", range: "169–1525 MHz (band-agile)")],
        ],
        receivers: [
            RFRxModel(name: "Sound Devices A20-Nexus (8ch)", channels: 8, cat: "Receiver"),
            RFRxModel(name: "Sound Devices A20-RX (2ch)",    channels: 2, cat: "Receiver"),
        ],
        handhelds: [RFTxItem(name: "Sound Devices A20-TX Bodypack (no handheld)", cat: "Bodypack / Lav")],
        bodypacks: [RFTxItem(name: "Sound Devices A20-Mini Bodypack", cat: "Bodypack / Lav")],
        iemTx: nil,
        iemRx: nil,
        coord: "Sound Devices A20-Nexus Network App"
    ),
]

// MARK: - Antennas
let rfAntennas: [RFListItem] = [
    RFListItem(name: "RF Venue DIVERSITY FIN Antenna",        cat: "Antenna"),
    RFListItem(name: "Shure UA874US Active Cardioid Antenna", cat: "Antenna"),
    RFListItem(name: "Shure UA870US Active Omni Antenna",     cat: "Antenna"),
    RFListItem(name: "Wisycom LFA Log-Periodic Antenna",      cat: "Antenna"),
    RFListItem(name: "Lectrosonics ALP690 Log-Periodic",      cat: "Antenna"),
    RFListItem(name: "RF Venue CP Beam Circ. Polarized",      cat: "Antenna"),
    RFListItem(name: "PWS UHF Helical Antenna",               cat: "Antenna"),
]

// MARK: - Distros
let rfDistros: [RFListItem] = [
    RFListItem(name: "Shure UA845SWB 4-Way Active Distro",          cat: "Antenna Distribution"),
    RFListItem(name: "RF Venue DISTRO4 4-ch Distro",                cat: "Antenna Distribution"),
    RFListItem(name: "Lectrosonics UMCWBD-L Antenna Multicoupler",  cat: "Antenna Distribution"),
    RFListItem(name: "Professional Wireless Systems PS-RF-1 Distro", cat: "Antenna Distribution"),
    RFListItem(name: "Wisycom BFA Active Antenna Distributor",       cat: "Antenna Distribution"),
]

// MARK: - Accessories
let rfAccessories: [RFListItem] = [
    RFListItem(name: "Shure SBC850 Networked Multi-Bay Charger",      cat: "Accessory"),
    RFListItem(name: "Pelican 1630 RF Gear Transport Case",            cat: "Accessory"),
    RFListItem(name: "RG8X Low-Loss Coax Cable (100 ft)",             cat: "Accessory"),
    RFListItem(name: "BNC Male-to-Male Barrel Adapters (×10)",        cat: "Accessory"),
    RFListItem(name: "Neutrik BNC Chassis Connectors (×4)",           cat: "Accessory"),
    RFListItem(name: "Catapult CAT5 RF-over-Cat5 System (2ch)",       cat: "Accessory"),
    RFListItem(name: "Professional Wireless Systems PWS-ADII Combo",  cat: "Antenna Distribution"),
]

// MARK: - Generator helpers
func rfPick<T>(_ arr: [T]) -> T { arr[Int.random(in: 0..<arr.count)] }
func rfPickN<T>(_ arr: [T], _ n: Int) -> [T] {
    var copy = arr; var out = [T]()
    for _ in 0..<min(n, copy.count) {
        let i = Int.random(in: 0..<copy.count)
        out.append(copy.remove(at: i))
    }
    return out
}
func rfRand(_ lo: Int, _ hi: Int) -> Int { Int.random(in: lo...hi) }
