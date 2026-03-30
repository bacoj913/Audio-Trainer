// Models/ComponentData.swift — Full component library (all 55 components with complete I/O)

import Foundation

// MARK: - Component Library
enum Components {
    static let all: [String: Component] = {
        var d = [String: Component]()
        for c in list { d[c.id] = c }
        return d
    }()

    static let list: [Component] = [

        // ── Sources ──────────────────────────────────────────
        Component(id: "microphone",
            name: "Shure SM58",
                iconName: "mic",
            category: "Sources",
                manufacturer: "Shure",
                model: "SM58",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "XLR", count: 1, signalType: "mic")
            ],
            desc: "Cardioid dynamic vocal mic",
            level: "Mic Level"),

        Component(id: "microphone_condenser",
            name: "Neumann KMS 105",
                iconName: "mic_cond",
            category: "Sources",
                manufacturer: "Neumann",
                model: "KMS 105",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "XLR", count: 1, signalType: "mic")
            ],
            desc: "Supercardioid condenser vocal mic",
            level: "Mic Level (+48V)"),

        Component(id: "guitar",
            name: "Guitar (Passive)",
                iconName: "guitar",
            category: "Sources",
                manufacturer: "Generic",
                model: "Passive Guitar",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "1/4\" TS", count: 1, signalType: "instrument")
            ],
            desc: "Unbalanced instrument source",
            level: "Instrument Level"),

        Component(id: "keyboard",
            name: "Nord Stage 4",
                iconName: "keyboard",
            category: "Sources",
                manufacturer: "Nord",
                model: "Stage 4",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line"),
                PortGroup(connector: "1/4\"", count: 2, signalType: "line")
            ],
            desc: "Stage keyboard, line-level stereo out",
            level: "Line Level"),

        Component(id: "di_box",
            name: "Radial J48 DI",
                iconName: "di",
            category: "Sources",
                manufacturer: "Radial Engineering",
                model: "J48",
            inputGroups: [
                PortGroup(connector: "Instrument 1/4\"", count: 1, signalType: "instrument"),
                PortGroup(connector: "Parallel Thru 1/4\"", count: 1, signalType: "instrument")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 1, signalType: "mic")
            ],
            desc: "Active DI — converts instrument to balanced XLR",
            level: "Instrument → Mic"),

        // ── Processing ───────────────────────────────────────

        Component(id: "preamp",
            name: "Sound Devices 702",
                iconName: "preamp",
            category: "Processing",
                manufacturer: "Sound Devices",
                model: "702",
            inputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line"),
                PortGroup(connector: "AES", count: 1, signalType: "aes")
            ],
            desc: "High-end field recorder/preamp",
            level: "Mic → Line",
            rackUnits: 1),

        Component(id: "equalizer",
            name: "Lake LM 44",
                iconName: "equalizer",
            category: "Processing",
                manufacturer: "Lab.gruppen / Lake",
                model: "LM 44",
            inputGroups: [
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "Analog", count: 4, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "Analog", count: 4, signalType: "line")
            ],
            desc: "Loudspeaker processor & EQ",
            level: "Line Level",
            rackUnits: 1,
            availablePresets: [
                "PA Top Module", "PA Sub Module", "Fill Module", "Delay Module",
                "Front Fill Module", "Side Fill Module", "Monitor Module", "Drum Fill Module"
            ]),

        Component(id: "compressor",
            name: "SSL G-Bus Compressor",
                iconName: "compressor",
            category: "Processing",
                manufacturer: "Solid State Logic",
                model: "G-Bus Comp",
            inputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line")
            ],
            desc: "Bus compressor, controls dynamic range",
            level: "Line Level",
            rackUnits: 1),

        Component(id: "gate",
            name: "Drawmer DS201",
                iconName: "gate",
            category: "Processing",
                manufacturer: "Drawmer",
                model: "DS201",
            inputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line")
            ],
            desc: "Dual-channel noise gate",
            level: "Line Level",
            rackUnits: 1),
        
        // ── Effects ──────────────────────────────────────────
        Component(id: "effects",
            name: "TC Electronic M6000",
                iconName: "effects",
            category: "Processing",
                manufacturer: "TC Electronic",
                model: "M6000",
            inputGroups: [
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "Analog", count: 6, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "Analog", count: 6, signalType: "line")
            ],
            desc: "Reverb, delay, and multi-effects engine",
            level: "Line Level",
            rackUnits: 2),

        Component(id: "effects_pedal",
            name: "Strymon BigSky",
                iconName: "pedal",
            category: "Processing",
                manufacturer: "Strymon",
                model: "BigSky",
            inputGroups: [
                PortGroup(connector: "1/4\"", count: 2, signalType: "instrument")
            ],
            outputGroups: [
                PortGroup(connector: "1/4\"", count: 2, signalType: "instrument")
            ],
            desc: "Reverb effects pedal",
            level: "Instrument Level"),


        // ── Routing / Consoles ───────────────────────────────

        Component(id: "mixer",
            name: "DiGiCo SD12",
                iconName: "console",
            category: "Consoles",
                manufacturer: "DiGiCo",
                model: "SD12",
            inputGroups: [
                PortGroup(connector: "Local Mic/Line XLR", count: 8, signalType: "mic"),
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi")
            ],
            outputGroups: [
                PortGroup(connector: "Local Line XLR", count: 8, signalType: "line"),
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi"),
                PortGroup(connector: "Word Clock", count: 1, signalType: "clock")
            ],
            desc: "Digital mixing console with 2 DMI expansion slots",
            level: "Line Level",
            slotCount: 2),

        Component(id: "mixer_yamaha",
            name: "Yamaha RIVAGE PM7",
                iconName: "console",
            category: "Consoles",
                manufacturer: "Yamaha",
                model: "PM7",
            inputGroups: [],
            outputGroups: [],
            desc: "RIVAGE PM engine/surface system — I/O via HY and Mini-YGDAI expansion",
            level: "Line Level",
            slotCount: 6),

        Component(id: "mixer_ssl",
            name: "SSL Live L550 Plus",
                iconName: "console",
            category: "Consoles",
                manufacturer: "Solid State Logic",
                model: "L550 Plus",
            inputGroups: [
                PortGroup(connector: "Local Mic/Line", count: 32, signalType: "mic"),
                PortGroup(connector: "AES", count: 8, signalType: "aes"),
                PortGroup(connector: "MADI Coax", count: 12, signalType: "madi"),
                PortGroup(connector: "MADI Optical", count: 4, signalType: "madi")
            ],
            outputGroups: [
                PortGroup(connector: "Local Line", count: 32, signalType: "line"),
                PortGroup(connector: "Headphone/Monitor", count: 4, signalType: "line"),
                PortGroup(connector: "AES", count: 8, signalType: "aes"),
                PortGroup(connector: "MADI Coax", count: 12, signalType: "madi"),
                PortGroup(connector: "MADI Optical", count: 4, signalType: "madi")
            ],
            desc: "SSL live console with local analog, AES, and MADI I/O",
            level: "Line Level"),

        Component(id: "patch_bay",
            name: "Neutrik NYS-SPP-L Patchbay",
                iconName: "patchbay",
            category: "Patching",
                manufacturer: "Neutrik",
                model: "NYS-SPP-L",
            inputGroups: [
                PortGroup(connector: "TRS Rear", count: 48, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "TRS Front", count: 48, signalType: "line")
            ],
            desc: "48-point TRS patchbay",
            level: "Line Level",
            rackUnits: 1),

        Component(id: "configurable_io_2u",
            name: "Configurable I/O",
                iconName: "interface",
            category: "Patching",
                manufacturer: "Generic",
                model: "2U Configurable I/O",
            inputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line")
            ],
            desc: "2U configurable I/O — tap gear icon to change port count and signal type",
            level: "Line Level",
            rackUnits: 2),

        // ── Recording ────────────────────────────────────────

        Component(id: "audio_interface",
            name: "Universal Audio Apollo x8p",
                iconName: "interface",
            category: "Processing",
                manufacturer: "Universal Audio",
                model: "Apollo x8p",
            inputGroups: [
                PortGroup(connector: "XLR/TRS Combo", count: 8, signalType: "mic"),
                PortGroup(connector: "Optical", count: 8, signalType: "optical"),
                PortGroup(connector: "Hi-Z", count: 2, signalType: "instrument")
            ],
            outputGroups: [
                PortGroup(connector: "Line Out", count: 8, signalType: "line"),
                PortGroup(connector: "Monitor Out", count: 2, signalType: "line"),
                PortGroup(connector: "Headphone", count: 2, signalType: "line"),
                PortGroup(connector: "Optical", count: 8, signalType: "optical")
            ],
            desc: "Thunderbolt audio interface with 8 Unison mic pres and optical digital I/O",
            level: "AD/DA Converter",
            rackUnits: 1),

        // ── Output ───────────────────────────────────────────
        Component(id: "power_amp",
            name: "Lab.gruppen PLM 20000Q",
                iconName: "power_amp",
            category: "Amplifiers",
                manufacturer: "Lab.gruppen",
                model: "PLM 20000Q",
            inputGroups: [
                PortGroup(connector: "XLR", count: 4, signalType: "line"),
                PortGroup(connector: "AES", count: 1, signalType: "aes")
            ],
            outputGroups: [
                PortGroup(connector: "Dante", count: 2, signalType: "dante"),
                PortGroup(connector: "Speakon", count: 4, signalType: "speaker")
            ],
            desc: "20,000W 4-ch amplifier, Dante/AES",
            level: "Speaker Level",
            rackUnits: 2,
            availablePresets: [
                "PA Top Module", "PA Sub Module", "Fill Module", "Delay Module",
                "Front Fill Module", "Side Fill Module", "Monitor Module", "Drum Fill Module"
            ]),

        Component(id: "power_amp_powersoft",
            name: "Powersoft X8",
                iconName: "power_amp",
            category: "Amplifiers",
                manufacturer: "Powersoft",
                model: "X8",
            inputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line"),
                PortGroup(connector: "AES67/Dante", count: 1, signalType: "dante")
            ],
            outputGroups: [
                PortGroup(connector: "Speakon", count: 8, signalType: "speaker")
            ],
            desc: "8-ch touring amplifier, AES67 network",
            level: "Speaker Level",
            rackUnits: 2,
            availablePresets: [
                "PA Top Module", "PA Sub Module", "Fill Module", "Delay Module",
                "Front Fill Module", "Side Fill Module", "Monitor Module", "Drum Fill Module"
            ]),

        Component(id: "power_amp_labgruppen_plm20k44_bp",
            name: "Lab.gruppen PLM 20K44 BP",
                iconName: "power_amp",
            category: "Amplifiers",
                manufacturer: "Lab.gruppen",
                model: "PLM 20K44 BP",
            inputGroups: [
                PortGroup(connector: "Analog XLR", count: 4, signalType: "line"),
                PortGroup(connector: "AES", count: 2, signalType: "aes"),
                PortGroup(connector: "etherCON", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Binding Post", count: 4, signalType: "speaker")
            ],
            desc: "20,000W 4-channel powered loudspeaker management amplifier with analog, AES3, and Dante inputs",
            level: "Speaker Level",
            rackUnits: 2,
            availablePresets: [
                "PA Top Module", "PA Sub Module", "Fill Module", "Delay Module",
                "Front Fill Module", "Side Fill Module", "Monitor Module", "Drum Fill Module"
            ]),

        // ── Speaker ──────────────────────────────────────────
        Component(id: "speakers",
            name: "L-Acoustics K2",
                iconName: "speaker",
            category: "Speakers",
                manufacturer: "L-Acoustics",
                model: "K2",
            inputGroups: [
                PortGroup(connector: "Speakon NL4", count: 2, signalType: "speaker")
            ],
            outputGroups: [],
            desc: "Line array loudspeaker element",
            level: "Speaker Level"),

        Component(id: "speakers_db",
            name: "d&b audiotechnik Y10P",
                iconName: "speaker",
            category: "Speakers",
                manufacturer: "d&b audiotechnik",
                model: "Y10P",
            inputGroups: [
                PortGroup(connector: "Speakon", count: 2, signalType: "speaker")
            ],
            outputGroups: [],
            desc: "Passive 2-way point source cabinet",
            level: "Speaker Level"),

        Component(id: "speakers_powered",
            name: "QSC K12.2",
                iconName: "speaker",
            category: "Speakers",
                manufacturer: "QSC",
                model: "K12.2",
            inputGroups: [
                PortGroup(connector: "XLR/TRS Combo", count: 2, signalType: "line"),
                PortGroup(connector: "XLR Mix", count: 1, signalType: "line")
            ],
            outputGroups: [],
            desc: "Powered 12\" loudspeaker, 2000W",
            level: "Line Level (powered)"),

        Component(id: "monitors",
            name: "Genelec 8351B",
                iconName: "monitor",
            category: "Speakers",
                manufacturer: "Genelec",
                model: "8351B",
            inputGroups: [
                PortGroup(connector: "XLR Balanced", count: 1, signalType: "line"),
                PortGroup(connector: "AES", count: 1, signalType: "aes")
            ],
            outputGroups: [],
            desc: "SAM studio monitor, 3-way",
            level: "Line Level (powered)"),

        Component(id: "headphones",
            name: "Sennheiser HD 25",
                iconName: "headphones",
            category: "Speakers",
                manufacturer: "Sennheiser",
                model: "HD 25",
            inputGroups: [
                PortGroup(connector: "3.5mm TRS", count: 1, signalType: "line"),
                PortGroup(connector: "1/4\" TRS", count: 1, signalType: "line")
            ],
            outputGroups: [],
            desc: "On-ear DJ/monitoring headphone",
            level: "Headphone Level"),

        Component(id: "headphone_amp",
            name: "Hear Technologies Hearback PRO",
                iconName: "headphone_amp",
            category: "Wireless IEMs",
                manufacturer: "Hear Technologies",
                model: "Hearback PRO Hub",
            inputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line"),
                PortGroup(connector: "Ethernet Dante", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "1/4\" HP", count: 2, signalType: "line")
            ],
            desc: "8-ch personal monitor mixer hub",
            level: "Headphone Level",
            rackUnits: 1),
        // ── Wireless RX ─────────────────────────────────────
        Component(id: "wireless_rx",
            name: "Shure AD4Q Receiver",
                iconName: "wireless_rx",
            category: "Wireless Mics",
                manufacturer: "Shure",
                model: "Axient Digital AD4Q",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 4, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 4, signalType: "line"),
                PortGroup(connector: "Dante", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "4-channel wireless receiver, Dante",
            level: "RF → Line",
            rackUnits: 1),

        Component(id: "wireless_rx_senn",
            name: "Sennheiser EM 6000 Dante",
                iconName: "wireless_rx",
            category: "Wireless Mics",
                manufacturer: "Sennheiser",
                model: "EM 6000",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line"),
                PortGroup(connector: "AES", count: 1, signalType: "aes"),
                PortGroup(connector: "Dante", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "2-ch wireless receiver, Dante",
            level: "RF → Line",
            rackUnits: 1),

        Component(id: "wireless_rx_wisycom",
            name: "Wisycom MCR54",
                iconName: "wireless_rx",
            category: "Wireless Mics",
                manufacturer: "Wisycom",
                model: "MCR54",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 4, signalType: "line"),
                PortGroup(connector: "AES", count: 1, signalType: "aes"),
                PortGroup(connector: "Dante", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "4-ch quad-diversity receiver",
            level: "RF → Line",
            rackUnits: 1),

        // ── Wireless TX ─────────────────────────────────────
        Component(id: "wireless_beltpack_tx",
            name: "Shure AD1 Bodypack TX",
                iconName: "wireless_tx",
            category: "Wireless Mics",
                manufacturer: "Shure",
                model: "Axient Digital AD1",
            inputGroups: [
                PortGroup(connector: "TA4F (Lemo) Mic/Line", count: 1, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            desc: "Bodypack transmitter for lavs/headsets",
            level: "Mic → RF"),

        Component(id: "wireless_beltpack_senn",
            name: "Sennheiser SK 6000 Bodypack",
                iconName: "wireless_tx",
            category: "Wireless Mics",
                manufacturer: "Sennheiser",
                model: "SK 6000",
            inputGroups: [
                PortGroup(connector: "Lemo 3-pin Mic", count: 1, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            desc: "Ultra-compact bodypack transmitter",
            level: "Mic → RF"),

        Component(id: "wireless_handheld_tx",
            name: "Shure AD2 Handheld TX",
                iconName: "handheld",
            category: "Wireless Mics",
                manufacturer: "Shure",
                model: "Axient Digital AD2",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            desc: "Handheld wireless transmitter/mic",
            level: "Mic → RF"),

        Component(id: "wireless_handheld_senn",
            name: "Sennheiser SKM 6000",
                iconName: "handheld",
            category: "Wireless Mics",
                manufacturer: "Sennheiser",
                model: "SKM 6000",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            desc: "Handheld wireless transmitter, interchangeable capsule",
            level: "Mic → RF"),

        Component(id: "iem_tx",
            name: "Shure P10T IEM TX",
                iconName: "iem_tx",
            category: "Wireless IEMs",
                manufacturer: "Shure",
                model: "PSM1000 P10T",
            inputGroups: [
                PortGroup(connector: "XLR", count: 2, signalType: "line"),
                PortGroup(connector: "Dante", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            desc: "Stereo IEM transmitter, Dante option",
            level: "Line → RF",
            rackUnits: 1),

        Component(id: "iem_tx_senn",
            name: "Sennheiser SR IEM G4 TX",
                iconName: "iem_tx",
            category: "Wireless IEMs",
                manufacturer: "Sennheiser",
                model: "SR IEM G4",
            inputGroups: [
                PortGroup(connector: "XLR/TRS Combo", count: 2, signalType: "line"),
                PortGroup(connector: "Ethernet RJ45", count: 1, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Antenna BNC", count: 1, signalType: "rf")
            ],
            desc: "Stereo IEM transmitter, 1680 frequencies",
            level: "Line → RF",
            rackUnits: 1),

        Component(id: "iem_rx",
            name: "Shure P10R IEM Bodypack",
                iconName: "iem_rx",
            category: "Wireless IEMs",
                manufacturer: "Shure",
                model: "PSM1000 P10R",
            inputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "3.5mm Stereo Headphone", count: 1, signalType: "line")
            ],
            desc: "Stereo IEM bodypack receiver",
            level: "RF → Headphone"),

        Component(id: "iem_rx_senn",
            name: "Sennheiser EK IEM G4",
                iconName: "iem_rx",
            category: "Wireless IEMs",
                manufacturer: "Sennheiser",
                model: "EK IEM G4",
            inputGroups: [
                PortGroup(connector: "RF", count: 1, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "3.5mm Stereo Headphone", count: 1, signalType: "line")
            ],
            desc: "True diversity IEM bodypack receiver",
            level: "RF → Headphone"),
        // ── Antennas ─────────────────────────────────────────
        Component(id: "antenna_passive",
            name: "Shure UA870 Omni Antenna",
                iconName: "antenna",
            category: "Antennas",
                manufacturer: "Shure",
                model: "UA870US",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "BNC", count: 1, signalType: "rf")
            ],
            desc: "Passive omnidirectional UHF antenna",
            level: "RF Signal"),

        Component(id: "antenna_lpda",
            name: "Wisycom LFA Log-Periodic",
                iconName: "antenna",
            category: "Antennas",
                manufacturer: "Wisycom",
                model: "LFA",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "BNC", count: 1, signalType: "rf")
            ],
            desc: "Log-periodic directional UHF antenna",
            level: "RF Signal"),

        Component(id: "antenna_active",
            name: "Shure UA845SWB Antenna Distro",
                iconName: "distro",
            category: "Antennas",
                manufacturer: "Shure",
                model: "UA845SWB",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Distro BNC", count: 8, signalType: "rf")
            ],
            desc: "Active 4-way antenna splitter/distro",
            level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_rf_venue",
            name: "RF Venue DISTRO4",
                iconName: "distro",
            category: "Antennas",
                manufacturer: "RF Venue",
                model: "DISTRO4",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "BNC", count: 8, signalType: "rf")
            ],
            desc: "4-channel antenna distributor",
            level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_wisycom",
            name: "Wisycom BFA Antenna Distro",
                iconName: "distro",
            category: "Antennas",
                manufacturer: "Wisycom",
                model: "BFA",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "BNC", count: 8, signalType: "rf")
            ],
            desc: "Active 4-way antenna distributor with bias-T power",
            level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_lectro",
            name: "Lectrosonics UMCWBD-L Distro",
                iconName: "distro",
            category: "Antennas",
                manufacturer: "Lectrosonics",
                model: "UMCWBD-L",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "BNC", count: 8, signalType: "rf")
            ],
            desc: "Wideband 4-slot antenna multicoupler",
            level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_combiner_shure",
            name: "Shure UA844+SWB Combiner",
                iconName: "combiner",
            category: "Antennas",
                manufacturer: "Shure",
                model: "UA844+SWB",
            inputGroups: [
                PortGroup(connector: "TX BNC", count: 4, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Combined Ant BNC", count: 2, signalType: "rf")
            ],
            desc: "4-in active IEM transmitter antenna combiner",
            level: "RF Combining",
            rackUnits: 1),

        Component(id: "antenna_combiner_senn",
            name: "Sennheiser AC 3200-II Combiner",
                iconName: "combiner",
            category: "Antennas",
                manufacturer: "Sennheiser",
                model: "AC 3200-II",
            inputGroups: [
                PortGroup(connector: "TX BNC", count: 8, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Combined BNC", count: 2, signalType: "rf")
            ],
            desc: "8-in IEM transmitter antenna combiner",
            level: "RF Combining",
            rackUnits: 1),

        Component(id: "antenna_combiner_pws",
            name: "PWS DC216 Dual Combiner",
                iconName: "combiner",
            category: "Antennas",
                manufacturer: "Professional Wireless Systems",
                model: "DC216",
            inputGroups: [
                PortGroup(connector: "TX BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Combined BNC", count: 1, signalType: "rf")
            ],
            desc: "2-channel passive IEM TX combiner with bandpass filters",
            level: "RF Combining",
            rackUnits: 1),
        // ── Networking ───────────────────────────────────────
        Component(id: "network_switch_cisco_SG350-28P",
            name: "Cisco SG350-28P PoE Switch",
                iconName: "network",
            category: "Networking",
                manufacturer: "Cisco",
                model: "SG350-28P",
            inputGroups: [
                PortGroup(connector: "RJ45/PoE", count: 28, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            outputGroups: [
                PortGroup(connector: "RJ45/PoE", count: 28, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            desc: "28-port Gigabit PoE managed switch for Dante",
            level: "Dante / AES67",
            rackUnits: 1),

        Component(id: "network_switch_luminex_GigaCore_10",
            name: "Luminex GigaCore 10",
                iconName: "network",
            category: "Networking",
                manufacturer: "Luminex",
                model: "GigaCore 10",
            inputGroups: [
                PortGroup(connector: "EtherCon", count: 8, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            outputGroups: [
                PortGroup(connector: "EtherCon", count: 8, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            desc: "10-port managed switch, media/show optimized",
            level: "Dante / AES67",
            rackUnits: 1),

        Component(id: "network_switch_netgear_M4250_8_Port",
            name: "Netgear M4250 8 Port",
                iconName: "network",
            category: "Networking",
                manufacturer: "Netgear",
                model: "M4250",
            inputGroups: [
                PortGroup(connector: "EtherCon", count: 8, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            outputGroups: [
                PortGroup(connector: "EtherCon", count: 8, signalType: "dante"),
                PortGroup(connector: "SFP", count: 2, signalType: "fiber")
            ],
            desc: "10-port managed switch, media/show optimized",
            level: "Dante / AES67",
            rackUnits: 1),

        // ── Stage Boxes / Snakes ─────────────────────────────

        Component(id: "stagebox_12",
            name: "Yamaha Rio1608-D2",
                iconName: "stagebox",
            category: "Stage Racks",
                manufacturer: "Yamaha",
                model: "Rio1608-D2",
            inputGroups: [
                PortGroup(connector: "XLR", count: 16, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line"),
                PortGroup(connector: "Dante EtherCon", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "16-in / 8-out Dante I/O rack",
            level: "Analog → Dante",
            rackUnits: 3),

        Component(id: "stagebox_16",
            name: "DiGiCo Orange Box",
                iconName: "stagebox",
            category: "Stage Racks",
                manufacturer: "DiGiCo",
                model: "Orange Box",
            inputGroups: [
                PortGroup(connector: "Word Clock", count: 1, signalType: "clock")
            ],
            outputGroups: [
                PortGroup(connector: "Word Clock", count: 1, signalType: "clock")
            ],
            desc: "2U format converter with 2 DMI slots; audio I/O depends on installed cards",
            level: "Digital Format Conversion",
            rackUnits: 2,
            slotCount: 2),

        Component(id: "stagebox_24",
            name: "Yamaha Rio3224-D2",
                iconName: "stagebox",
            category: "Stage Racks",
                manufacturer: "Yamaha",
                model: "Rio3224-D2",
            inputGroups: [
                PortGroup(connector: "XLR", count: 32, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 16, signalType: "line"),
                PortGroup(connector: "AES", count: 4, signalType: "aes"),
                PortGroup(connector: "Dante EtherCon", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "32-in / 16-out Dante I/O rack with 8 AES/EBU output channels",
            level: "Analog → Dante",
            rackUnits: 5),

        Component(id: "stagebox_32",
            name: "DiGiCo SD-Rack (32ch)",
                iconName: "stagebox",
            category: "Stage Racks",
                manufacturer: "DiGiCo",
                model: "SD-Rack 32ch",
            inputGroups: [
                PortGroup(connector: "HMA", count: 1, signalType: "optical"),
                PortGroup(connector: "MADI BNC", count: 1, signalType: "madi"),
                PortGroup(connector: "MADI AUX", count: 1, signalType: "madi"),
                PortGroup(connector: "Word Clock", count: 1, signalType:"clock")
            ],
            outputGroups: [
                PortGroup(connector: "HMA", count: 1, signalType: "optical"),
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi"),
                PortGroup(connector: "MADI AUX", count: 2, signalType: "madi"),
                PortGroup(connector: "Word Clock", count: 1, signalType: "clock")
            ],
            desc: "SD-Rack, MADI + optical",
            level: "Analog → Digital",
            rackUnits: 5,
            slotCount: 14),

        Component(id: "stagebox_40",
            name: "Yamaha Rio6432-D2 (40ch)",
                iconName: "stagebox",
            category: "Stage Racks",
                manufacturer: "Yamaha",
                model: "Rio6432-D2",
            inputGroups: [
                PortGroup(connector: "XLR", count: 48, signalType: "mic")
            ],
            outputGroups: [
                PortGroup(connector: "XLR", count: 16, signalType: "line"),
                PortGroup(connector: "Dante EtherCon", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "40-in/32-out stage box, dual Dante",
            level: "Analog → Dante",
            rackUnits: 3),

        // ── Rack Enclosures ──────────────────────────────────
        Component(id: "rack_8u",
            name: "8U Rack Enclosure",
                iconName: "rack",
            category: "Racks",
                manufacturer: "Middle Atlantic",
                model: "WRK-8-26",
            inputGroups: [],
            outputGroups: [],
            desc: "8U standard rack enclosure",
            level: "",
            isRack: true,
            rackUnits: 8),

        Component(id: "rack_12u",
            name: "12U Rack Enclosure",
                iconName: "rack",
            category: "Racks",
                manufacturer: "Middle Atlantic",
                model: "WRK-12-26",
            inputGroups: [],
            outputGroups: [],
            desc: "12U standard rack enclosure",
            level: "",
            isRack: true,
            rackUnits: 12),

        Component(id: "rack_20u",
            name: "20U Road Rack",
                iconName: "rack",
            category: "Racks",
                manufacturer: "Gator Cases",
                model: "G-TOUR20U",
            inputGroups: [],
            outputGroups: [],
            desc: "20U tour-grade rolling rack",
            level: "",
            isRack: true,
            rackUnits: 20),

        Component(id: "rack_amp",
            name: "Amp Rack (8U)",
                iconName: "rack",
            category: "Racks",
                manufacturer: "Penn Elcom",
                model: "R8100-8UK",
            inputGroups: [],
            outputGroups: [],
            desc: "8U amp rack with ventilation panels",
            level: "",
            isRack: true,
            rackUnits: 8),

        // ── Power Systems ────────────────────────────────────
        Component(id: "power_dist",
            name: "Socapex Power Distro",
                iconName: "power",
            category: "Power",
                manufacturer: "PowerTech",
                model: "PD-100A",
            inputGroups: [
                PortGroup(connector: "Cam-Lok 3-phase", count: 1, signalType: "power")
            ],
            outputGroups: [
                PortGroup(connector: "Edison 20A", count: 8, signalType: "power"),
                PortGroup(connector: "L6-20", count: 4, signalType: "power"),
                PortGroup(connector: "Socapex", count: 2, signalType: "power")
            ],
            desc: "(Coming soon) Power distribution unit",
            level: "Power — 120/240V",
            comingSoon: true),
        // ── RF Combiners & Distros ───────────────────────────
        Component(id: "pws_combiner_2ch",
            name: "PWS DC216 2ch Combiner",
                iconName: "combiner",
            category: "Antennas",
                manufacturer: "Professional Wireless Systems",
                model: "DC216",
            inputGroups: [
                PortGroup(connector: "TX BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Combined BNC", count: 1, signalType: "rf")
            ],
            desc: "Passive 2-ch IEM TX combiner, bandpass filters",
            level: "RF Combining",
            rackUnits: 1),

        Component(id: "pws_combiner_8ch",
            name: "PWS UCP-8 8ch Combiner",
                iconName: "combiner",
            category: "Antennas",
                manufacturer: "Professional Wireless Systems",
                model: "UCP-8",
            inputGroups: [
                PortGroup(connector: "TX BNC", count: 8, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "Combined BNC", count: 2, signalType: "rf")
            ],
            desc: "8-ch active IEM TX combiner with bandpass filters",
            level: "RF Combining",
            rackUnits: 1),

        Component(id: "pws_distro",
            name: "PWS PS-RF-1 Antenna Distro",
                iconName: "distro",
            category: "Antennas",
                manufacturer: "Professional Wireless Systems",
                model: "PS-RF-1",
            inputGroups: [
                PortGroup(connector: "Antenna BNC", count: 2, signalType: "rf")
            ],
            outputGroups: [
                PortGroup(connector: "BNC", count: 8, signalType: "rf")
            ],
            desc: "Active 4-way antenna distributor with DC bias",
            level: "RF Distribution",
            rackUnits: 1),
        // ── Intercom ─────────────────────────────────────────
        // TODO: Add Intercom Devices

        // ── Expansion Cards ───────────────────────────────────
        Component(id: "card_digico_dmi_dante64_96",
            name: "DiGiCo DMI-DANTE64@96",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "DMI-DANTE64@96",
            inputGroups: [
                PortGroup(connector: "Dante EtherCon", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Dante EtherCon", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "64x64 Dante DMI card for DiGiCo consoles and Orange Box",
            level: "Network Audio",
            isSlotCard: true),

        Component(id: "card_digico_dmi_madi_b",
            name: "DiGiCo DMI-MADI-B",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "DMI-MADI-B",
            inputGroups: [
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi")
            ],
            outputGroups: [
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi")
            ],
            desc: "64x64 MADI DMI card over dual BNC",
            level: "Digital",
            isSlotCard: true),

        Component(id: "card_digico_dmi_aes",
            name: "DiGiCo DMI-AES",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "DMI-AES",
            inputGroups: [
                PortGroup(connector: "AES DB25", count: 2, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            outputGroups: [
                PortGroup(connector: "AES DB25", count: 2, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            desc: "16x16 AES DMI card with SRC on all inputs",
            level: "Digital",
            isSlotCard: true),

        Component(id: "card_digico_sd_micline_8in",
            name: "DiGiCo SD 8ch Mic/Line Input Module",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "SD Mic/Line In",
            inputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "mic")
            ],
            outputGroups: [],
            desc: "8-channel SD-Rack mic/line input module",
            level: "Mic Level",
            isSlotCard: true),

        Component(id: "card_digico_sd_line_out_8",
            name: "DiGiCo SD Line Out Module",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "MOD-SDR-DAC",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "XLR", count: 8, signalType: "line")
            ],
            desc: "8-channel SD-Rack analog output module",
            level: "Line Level",
            isSlotCard: true),

        Component(id: "card_digico_sd_aes_out",
            name: "DiGiCo AES/EBU Output Card",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "AES/EBU Output Card",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "AES", count: 4, signalType: "aes")
            ],
            desc: "8-channel AES/EBU output card for SD-Rack family",
            level: "Digital",
            isSlotCard: true),

        Component(id: "card_digico_aviom_d16c",
            name: "DiGiCo Aviom D-16c Module",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "DiGiCo",
                model: "Aviom D-16c",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "EtherCon", count: 1, signalType: "networkaudio", channelsPerPort: 16, transport: "Aviom", isNetwork: true, bundleStyle: .network)
            ],
            desc: "16-channel Aviom output module for SD-Rack family",
            level: "Personal Monitor Network",
            isSlotCard: true),

        Component(id: "card_yamaha_hy256_tl",
            name: "Yamaha HY256-TL",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "HY256-TL",
            inputGroups: [
                PortGroup(connector: "TWINLANe Optical", count: 2, signalType: "optical")
            ],
            outputGroups: [
                PortGroup(connector: "TWINLANe Optical", count: 2, signalType: "optical")
            ],
            desc: "256x256 TWINLANe HY card for RIVAGE PM",
            level: "Network Audio",
            isSlotCard: true),

        Component(id: "card_yamaha_hy144_d",
            name: "Yamaha HY144-D",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "HY144-D",
            inputGroups: [
                PortGroup(connector: "Dante RJ45", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Dante RJ45", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "144x144 Dante HY card for RIVAGE PM",
            level: "Network Audio",
            isSlotCard: true),

        Component(id: "card_yamaha_hy144_d_src",
            name: "Yamaha HY144-D-SRC",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "HY144-D-SRC",
            inputGroups: [
                PortGroup(connector: "Dante RJ45", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            outputGroups: [
                PortGroup(connector: "Dante RJ45", count: 2, signalType: "dante", transport: "Dante", isNetwork: true, bundleStyle: .network)
            ],
            desc: "144x144 Dante HY card with SRC for RIVAGE PM",
            level: "Network Audio",
            isSlotCard: true),

        Component(id: "card_yamaha_hy128_md",
            name: "Yamaha HY128-MD",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "HY128-MD",
            inputGroups: [
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi")
            ],
            outputGroups: [
                PortGroup(connector: "MADI BNC", count: 2, signalType: "madi")
            ],
            desc: "128x128 MADI HY card with SRC support",
            level: "Digital",
            isSlotCard: true),

        Component(id: "card_yamaha_my8_ae96s",
            name: "Yamaha MY8-AE96S",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "MY8-AE96S",
            inputGroups: [
                PortGroup(connector: "AES DB25", count: 1, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            outputGroups: [
                PortGroup(connector: "AES DB25", count: 1, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            desc: "8x8 AES/EBU mini-YGDAI card with input SRC",
            level: "Digital",
            isSlotCard: true),

        Component(id: "card_yamaha_ry16_ml_silk",
            name: "Yamaha RY16-ML-SILK",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "RY16-ML-SILK",
            inputGroups: [
                PortGroup(connector: "XLR", count: 16, signalType: "mic")
            ],
            outputGroups: [],
            desc: "16-channel mic/line input RY card with SILK processing",
            level: "Mic Level",
            isSlotCard: true),

        Component(id: "card_yamaha_ry16_da",
            name: "Yamaha RY16-DA",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "RY16-DA",
            inputGroups: [],
            outputGroups: [
                PortGroup(connector: "XLR", count: 16, signalType: "line")
            ],
            desc: "16-channel analog output RY card",
            level: "Line Level",
            isSlotCard: true),

        Component(id: "card_yamaha_ry16_ae",
            name: "Yamaha RY16-AE",
                iconName: "interface",
            category: "Expansion Cards",
                manufacturer: "Yamaha",
                model: "RY16-AE",
            inputGroups: [
                PortGroup(connector: "AES DB25", count: 2, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            outputGroups: [
                PortGroup(connector: "AES DB25", count: 2, signalType: "aes", channelsPerPort: 8, bundleStyle: .multichannel)
            ],
            desc: "16x16 AES/EBU RY card",
            level: "Digital",
            isSlotCard: true),
    ]
}

#if DEBUG
import SwiftUI

// MARK: - Preview Helpers

private struct ComponentLibrarySummaryView: View {
    private var categoryCounts: [(String, Int)] {
        Dictionary(grouping: Components.list, by: { $0.category })
            .map { ($0.key, $0.value.count) }
            .sorted { lhs, rhs in
                if let l = categoryOrder.firstIndex(of: lhs.0),
                   let r = categoryOrder.firstIndex(of: rhs.0) {
                    return l < r
                }
                return lhs.0 < rhs.0
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Component Library Summary")
                .font(.headline)

            Text("Total Components: \(Components.list.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(categoryCounts, id: \.0) { category, count in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.categoryColor(category))
                        .frame(width: 18, height: 18)

                    Text(category)
                        .font(.system(size: 13, weight: .medium))

                    Spacer()

                    Text("\(count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 320, alignment: .leading)
    }
}

private struct ComponentLibraryCard: View {
    let component: Component

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.categoryColor(component.category))
                    .frame(width: 10, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(component.name)
                        .font(.headline)

                    Text("\(component.manufacturer) • \(component.model)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Text(component.category)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.categoryColor(component.category).opacity(0.15))
                    .clipShape(Capsule())

                if component.isRack {
                    Text("\(component.rackUnits)U Rack")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Capsule())
                }

                if component.comingSoon {
                    Text("Coming Soon")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.16))
                        .clipShape(Capsule())
                }
            }

            Group {
                Text("Signal Inputs: \(component.inputs.isEmpty ? "None" : component.inputs.joined(separator: ", "))")
                Text("Signal Outputs: \(component.outputs.isEmpty ? "None" : component.outputs.joined(separator: ", "))")
                Text("Physical Inputs: \(component.ports.inputs.isEmpty ? "None" : component.ports.inputs.joined(separator: ", "))")
                Text("Physical Outputs: \(component.ports.outputs.isEmpty ? "None" : component.ports.outputs.joined(separator: ", "))")
                Text("Level: \(component.level.isEmpty ? "None" : component.level)")
            }
            .font(.caption)

            Text(component.desc)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 420, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
        )
        .padding()
    }
}

private struct ComponentLibraryListPreview: View {
    let title: String
    let components: [Component]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(Array(components.enumerated()), id: \.offset) { _, component in
                    ComponentLibraryCard(component: component)
                }
            }
            .padding(.vertical)
        }
        .frame(width: 470, height: 700)
    }
}

// MARK: - Sample Selections

private extension Array where Element == Component {
    static var previewGeneral: [Component] {
        Array(Components.list.prefix(3))
    }

    static var previewRacks: [Component] {
        Components.list.filter { $0.isRack }
    }

    static var previewComingSoon: [Component] {
        Components.list.filter { $0.comingSoon }
    }

    static var previewWireless: [Component] {
        Components.list.filter {
            $0.category == "Wireless Mics" || $0.category == "Wireless IEMs"
        }
    }
}

// MARK: - Previews

#Preview("Library Summary") {
    ComponentLibrarySummaryView()
}

#Preview("General Components") {
    ComponentLibraryListPreview(
        title: "Sample Components",
        components: .previewGeneral
    )
}

#Preview("Rack Components") {
    ComponentLibraryListPreview(
        title: "Rack Components",
        components: .previewRacks
    )
}

#Preview("Wireless Components") {
    ComponentLibraryListPreview(
        title: "Wireless Components",
        components: .previewWireless
    )
}

#Preview("Coming Soon") {
    Group {
        if Array<Component>.previewComingSoon.isEmpty {
            Text("No coming-soon components in library")
                .padding()
        } else {
            ComponentLibraryListPreview(
                title: "Coming Soon Components",
                components: .previewComingSoon
            )
        }
    }
}
#endif
