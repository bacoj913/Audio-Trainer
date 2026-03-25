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
            name: "Shure SM58", iconName: "mic",
            category: "Sources", manufacturer: "Shure", model: "SM58",
            inputs: [], outputs: ["mic"],
            ports: PortInfo(inputs: [], outputs: ["XLR Output"]),
            desc: "Cardioid dynamic vocal mic", level: "Mic Level"),

        Component(id: "microphone_condenser",
            name: "Neumann KMS 105", iconName: "mic_cond",
            category: "Sources", manufacturer: "Neumann", model: "KMS 105",
            inputs: [], outputs: ["mic"],
            ports: PortInfo(inputs: [], outputs: ["XLR Output"]),
            desc: "Supercardioid condenser vocal mic", level: "Mic Level (+48V)"),

        Component(id: "guitar",
            name: "Guitar (Passive)", iconName: "guitar",
            category: "Sources", manufacturer: "Generic", model: "Passive Guitar",
            inputs: [], outputs: ["instrument"],
            ports: PortInfo(inputs: [], outputs: ["1/4\" TS Output"]),
            desc: "Unbalanced instrument source", level: "Instrument Level"),

        Component(id: "keyboard",
            name: "Nord Stage 4", iconName: "keyboard",
            category: "Sources", manufacturer: "Nord", model: "Stage 4",
            inputs: [], outputs: ["line"],
            ports: PortInfo(inputs: [], outputs: [
                "L Output (XLR)", "R Output (XLR)",
                "L Output (1/4\")", "R Output (1/4\")"]),
            desc: "Stage keyboard, line-level stereo out", level: "Line Level"),

        // ── Processing ───────────────────────────────────────
        Component(id: "di_box",
            name: "Radial J48 DI", iconName: "di",
            category: "Sources", manufacturer: "Radial Engineering", model: "J48",
            inputs: ["instrument"], outputs: ["mic"],
            ports: PortInfo(
                inputs:  ["Instrument In (1/4\")", "Parallel Thru (1/4\")"],
                outputs: ["XLR Output"]),
            desc: "Active DI — converts instrument to balanced XLR",
            level: "Instrument → Mic"),

        Component(id: "preamp",
            name: "Sound Devices 702", iconName: "preamp",
            category: "Processing", manufacturer: "Sound Devices", model: "702",
            inputs: ["mic"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["XLR In Ch1", "XLR In Ch2"],
                outputs: ["XLR Out Ch1", "XLR Out Ch2", "AES Out"]),
            desc: "High-end field recorder/preamp", level: "Mic → Line",
            rackUnits: 1),

        Component(id: "equalizer",
            name: "Lake LM 44", iconName: "equalizer",
            category: "Processing", manufacturer: "Lab.gruppen / Lake", model: "LM 44",
            inputs: ["line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["AES In 1-4", "Analog In 1-4"],
                outputs: ["AES Out 1-4", "Analog Out 1-4"]),
            desc: "Loudspeaker processor & EQ", level: "Line Level",
            rackUnits: 1),

        Component(id: "compressor",
            name: "SSL G-Bus Compressor", iconName: "compressor",
            category: "Processing", manufacturer: "Solid State Logic", model: "G-Bus Comp",
            inputs: ["line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["XLR In L", "XLR In R"],
                outputs: ["XLR Out L", "XLR Out R"]),
            desc: "Bus compressor, controls dynamic range", level: "Line Level",
            rackUnits: 1),

        Component(id: "gate",
            name: "Drawmer DS201", iconName: "gate",
            category: "Processing", manufacturer: "Drawmer", model: "DS201",
            inputs: ["line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["XLR In Ch1", "XLR In Ch2"],
                outputs: ["XLR Out Ch1", "XLR Out Ch2"]),
            desc: "Dual-channel noise gate", level: "Line Level",
            rackUnits: 1),

        // ── Effects ──────────────────────────────────────────
        Component(id: "effects",
            name: "TC Electronic M6000", iconName: "effects",
            category: "Processing", manufacturer: "TC Electronic", model: "M6000",
            inputs: ["line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["AES In 1-8", "Analog In 1-6"],
                outputs: ["AES Out 1-8", "Analog Out 1-6"]),
            desc: "Reverb, delay, and multi-effects engine", level: "Line Level",
            rackUnits: 2),

        Component(id: "effects_pedal",
            name: "Strymon BigSky", iconName: "pedal",
            category: "Processing", manufacturer: "Strymon", model: "BigSky",
            inputs: ["instrument"], outputs: ["instrument"],
            ports: PortInfo(
                inputs:  ["L/Mono In (1/4\")", "R In (1/4\")"],
                outputs: ["L/Mono Out (1/4\")", "R Out (1/4\")"]),
            desc: "Reverb effects pedal", level: "Instrument Level"),

        // ── Routing / Consoles ───────────────────────────────
        Component(id: "mixer",
            name: "DiGiCo SD12", iconName: "console",
            category: "Consoles", manufacturer: "DiGiCo", model: "SD12",
            inputs: ["mic", "line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Local XLR 1-12", "Local XLR 13-24", "MADI In A", "MADI In B", "Dante In"],
                outputs: ["Local XLR Out 1-12", "MADI Out A", "MADI Out B", "Dante Out", "AES Out"]),
            desc: "Digital mixing console, 72-ch I/O", level: "Line Level"),

        Component(id: "mixer_yamaha",
            name: "Yamaha PM7", iconName: "console",
            category: "Consoles", manufacturer: "Yamaha", model: "PM7",
            inputs: ["mic", "line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Local XLR 1-8", "Dante 1-64", "MADI In"],
                outputs: ["Local XLR Out 1-8", "Dante Out 1-64", "MADI Out"]),
            desc: "Digital mixing console, Dante/MADI", level: "Line Level"),

        Component(id: "mixer_ssl",
            name: "SSL Live L550", iconName: "console",
            category: "Consoles", manufacturer: "Solid State Logic", model: "Live L550",
            inputs: ["mic", "line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Local XLR 1-16", "Dante In 1-64", "MADI In A/B"],
                outputs: ["Local XLR Out 1-16", "Dante Out 1-64", "MADI Out A/B"]),
            desc: "SSL digital live console", level: "Line Level"),

        Component(id: "patch_bay",
            name: "Neutrik NYS-SPP-L Patchbay", iconName: "patchbay",
            category: "Patching", manufacturer: "Neutrik", model: "NYS-SPP-L",
            inputs: ["line"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["TRS 1-48 (Rear)"],
                outputs: ["TRS 1-48 (Front)"]),
            desc: "48-point TRS patchbay", level: "Line Level",
            rackUnits: 1),

        // ── Recording ────────────────────────────────────────
        Component(id: "audio_interface",
            name: "Universal Audio Apollo x8p", iconName: "interface",
            category: "Processing", manufacturer: "Universal Audio", model: "Apollo x8p",
            inputs: ["mic", "line", "instrument"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["XLR/TRS Combo 1-8", "Optical In 1-8", "AES In 1-8"],
                outputs: ["TRS Out 1-8", "AES Out 1-8", "Optical Out 1-8", "Headphone 1", "Headphone 2"]),
            desc: "Thunderbolt audio interface, UAD DSP", level: "AD/DA Converter",
            rackUnits: 1),

        // ── Output ───────────────────────────────────────────
        Component(id: "power_amp",
            name: "Lab.gruppen PLM 20000Q", iconName: "power_amp",
            category: "Amplifiers", manufacturer: "Lab.gruppen", model: "PLM 20000Q",
            inputs: ["line"], outputs: ["speaker"],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4", "AES In", "Dante In"],
                outputs: ["Speakon Ch1", "Speakon Ch2", "Speakon Ch3", "Speakon Ch4"]),
            desc: "20,000W 4-ch amplifier, Dante/AES", level: "Speaker Level",
            rackUnits: 2),

        Component(id: "power_amp_powersoft",
            name: "Powersoft X8", iconName: "power_amp",
            category: "Amplifiers", manufacturer: "Powersoft", model: "X8",
            inputs: ["line"], outputs: ["speaker"],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4",
                          "XLR In 5", "XLR In 6", "XLR In 7", "XLR In 8", "AES67/Dante In"],
                outputs: ["Speakon 1", "Speakon 2", "Speakon 3", "Speakon 4",
                          "Speakon 5", "Speakon 6", "Speakon 7", "Speakon 8"]),
            desc: "8-ch touring amplifier, AES67 network", level: "Speaker Level",
            rackUnits: 2),

        Component(id: "speakers",
            name: "L-Acoustics K2", iconName: "speaker",
            category: "Speakers", manufacturer: "L-Acoustics", model: "K2",
            inputs: ["speaker"], outputs: [],
            ports: PortInfo(
                inputs:  ["Speakon NL4 (HF)", "Speakon NL4 (LF)"],
                outputs: []),
            desc: "Line array loudspeaker element", level: "Speaker Level"),

        Component(id: "speakers_db",
            name: "d&b audiotechnik Y10P", iconName: "speaker",
            category: "Speakers", manufacturer: "d&b audiotechnik", model: "Y10P",
            inputs: ["speaker"], outputs: [],
            ports: PortInfo(
                inputs:  ["Speakon Input A", "Speakon Input B (thru)"],
                outputs: []),
            desc: "Passive 2-way point source cabinet", level: "Speaker Level"),

        Component(id: "speakers_powered",
            name: "QSC K12.2", iconName: "speaker",
            category: "Speakers", manufacturer: "QSC", model: "K12.2",
            inputs: ["line"], outputs: [],
            ports: PortInfo(
                inputs:  ["XLR/TRS Combo In 1", "XLR/TRS Combo In 2", "XLR Mix Out"],
                outputs: []),
            desc: "Powered 12\" loudspeaker, 2000W", level: "Line Level (powered)"),

        Component(id: "monitors",
            name: "Genelec 8351B", iconName: "monitor",
            category: "Speakers", manufacturer: "Genelec", model: "8351B",
            inputs: ["line"], outputs: [],
            ports: PortInfo(
                inputs:  ["XLR Balanced In", "AES In"],
                outputs: []),
            desc: "SAM studio monitor, 3-way", level: "Line Level (powered)"),

        Component(id: "headphones",
            name: "Sennheiser HD 25", iconName: "headphones",
            category: "Speakers", manufacturer: "Sennheiser", model: "HD 25",
            inputs: ["line"], outputs: [],
            ports: PortInfo(
                inputs:  ["3.5mm TRS", "1/4\" TRS (adapter)"],
                outputs: []),
            desc: "On-ear DJ/monitoring headphone", level: "Headphone Level"),

        Component(id: "headphone_amp",
            name: "Hear Technologies Hearback PRO", iconName: "headphone_amp",
            category: "Wireless IEMs", manufacturer: "Hear Technologies", model: "Hearback PRO Hub",
            inputs: ["line"], outputs: [],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4",
                          "XLR In 5", "XLR In 6", "XLR In 7", "XLR In 8", "Ethernet (Dante)"],
                outputs: ["1/4\" HP 1", "1/4\" HP 2"]),
            desc: "8-ch personal monitor mixer hub", level: "Headphone Level",
            rackUnits: 1),

        // ── Wireless Microphones ─────────────────────────────
        Component(id: "wireless_rx",
            name: "Shure AD4Q Receiver", iconName: "wireless_rx",
            category: "Wireless Mics", manufacturer: "Shure", model: "Axient Digital AD4Q",
            inputs: ["rf"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Antenna A (BNC)", "Antenna B (BNC)", "Antenna C (BNC)", "Antenna D (BNC)"],
                outputs: ["XLR Out Ch1", "XLR Out Ch2", "XLR Out Ch3", "XLR Out Ch4", "Dante Out"]),
            desc: "4-channel wireless receiver, Dante", level: "RF → Line",
            rackUnits: 1),

        Component(id: "wireless_rx_senn",
            name: "Sennheiser EM 6000 Dante", iconName: "wireless_rx",
            category: "Wireless Mics", manufacturer: "Sennheiser", model: "EM 6000",
            inputs: ["rf"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Antenna A (BNC)", "Antenna B (BNC)"],
                outputs: ["XLR Out Ch1", "XLR Out Ch2", "AES Out", "Dante Out"]),
            desc: "2-ch wireless receiver, Dante", level: "RF → Line",
            rackUnits: 1),

        Component(id: "wireless_rx_wisycom",
            name: "Wisycom MCR54", iconName: "wireless_rx",
            category: "Wireless Mics", manufacturer: "Wisycom", model: "MCR54",
            inputs: ["rf"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["Antenna A (BNC)", "Antenna B (BNC)"],
                outputs: ["XLR Out Ch1", "XLR Out Ch2", "XLR Out Ch3", "XLR Out Ch4",
                          "AES Out", "Dante Out"]),
            desc: "4-ch quad-diversity receiver", level: "RF → Line",
            rackUnits: 1),

        Component(id: "wireless_beltpack_tx",
            name: "Shure AD1 Bodypack TX", iconName: "wireless_tx",
            category: "Wireless Mics", manufacturer: "Shure", model: "Axient Digital AD1",
            inputs: ["mic"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TA4F (Lemo) Mic/Line In"],
                outputs: []),
            desc: "Bodypack transmitter for lavs/headsets", level: "Mic → RF"),

        Component(id: "wireless_beltpack_senn",
            name: "Sennheiser SK 6000 Bodypack", iconName: "wireless_tx",
            category: "Wireless Mics", manufacturer: "Sennheiser", model: "SK 6000",
            inputs: ["mic"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Lemo 3-pin Mic In"],
                outputs: []),
            desc: "Ultra-compact bodypack transmitter", level: "Mic → RF"),

        Component(id: "wireless_handheld_tx",
            name: "Shure AD2 Handheld TX", iconName: "handheld",
            category: "Wireless Mics", manufacturer: "Shure", model: "Axient Digital AD2",
            inputs: [], outputs: ["rf"],
            ports: PortInfo(inputs: [], outputs: []),
            desc: "Handheld wireless transmitter/mic", level: "Mic → RF"),

        Component(id: "wireless_handheld_senn",
            name: "Sennheiser SKM 6000", iconName: "handheld",
            category: "Wireless Mics", manufacturer: "Sennheiser", model: "SKM 6000",
            inputs: [], outputs: ["rf"],
            ports: PortInfo(inputs: [], outputs: []),
            desc: "Handheld wireless transmitter, interchangeable capsule", level: "Mic → RF"),

        // ── Wireless IEM ─────────────────────────────────────
        Component(id: "iem_tx",
            name: "Shure P10T IEM TX", iconName: "iem_tx",
            category: "Wireless IEMs", manufacturer: "Shure", model: "PSM1000 P10T",
            inputs: ["line"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["XLR In L", "XLR In R", "Dante In"],
                outputs: ["Antenna Out A (BNC)", "Antenna Out B (BNC)"]),
            desc: "Stereo IEM transmitter, Dante option", level: "Line → RF",
            rackUnits: 1),

        Component(id: "iem_tx_senn",
            name: "Sennheiser SR IEM G4 TX", iconName: "iem_tx",
            category: "Wireless IEMs", manufacturer: "Sennheiser", model: "SR IEM G4",
            inputs: ["line"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["XLR/TRS Combo In L", "XLR/TRS Combo In R", "Ethernet (RJ45)"],
                outputs: ["Antenna Out (BNC)"]),
            desc: "Stereo IEM transmitter, 1680 frequencies", level: "Line → RF",
            rackUnits: 1),

        Component(id: "iem_rx",
            name: "Shure P10R IEM Bodypack", iconName: "iem_rx",
            category: "Wireless IEMs", manufacturer: "Shure", model: "PSM1000 P10R",
            inputs: ["rf"], outputs: [],
            ports: PortInfo(
                inputs:  [],
                outputs: ["3.5mm Stereo Headphone Out"]),
            desc: "Stereo IEM bodypack receiver", level: "RF → Headphone"),

        Component(id: "iem_rx_senn",
            name: "Sennheiser EK IEM G4", iconName: "iem_rx",
            category: "Wireless IEMs", manufacturer: "Sennheiser", model: "EK IEM G4",
            inputs: ["rf"], outputs: [],
            ports: PortInfo(
                inputs:  [],
                outputs: ["3.5mm Stereo Headphone Out"]),
            desc: "True diversity IEM bodypack receiver", level: "RF → Headphone"),

        // ── Antennas ─────────────────────────────────────────
        Component(id: "antenna_passive",
            name: "Shure UA870 Omni Antenna", iconName: "antenna",
            category: "Antennas", manufacturer: "Shure", model: "UA870US",
            inputs: [], outputs: ["rf"],
            ports: PortInfo(inputs: [], outputs: ["BNC Output"]),
            desc: "Passive omnidirectional UHF antenna", level: "RF Signal"),

        Component(id: "antenna_lpda",
            name: "Wisycom LFA Log-Periodic", iconName: "antenna",
            category: "Antennas", manufacturer: "Wisycom", model: "LFA",
            inputs: [], outputs: ["rf"],
            ports: PortInfo(inputs: [], outputs: ["BNC Output"]),
            desc: "Log-periodic directional UHF antenna", level: "RF Signal"),

        Component(id: "antenna_active",
            name: "Shure UA845SWB Antenna Distro", iconName: "distro",
            category: "Antennas", manufacturer: "Shure", model: "UA845SWB",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Antenna In A (BNC)", "Antenna In B (BNC)"],
                outputs: ["Distro Out 1A (BNC)", "Distro Out 1B (BNC)",
                          "Distro Out 2A (BNC)", "Distro Out 2B (BNC)",
                          "Distro Out 3A (BNC)", "Distro Out 3B (BNC)",
                          "Distro Out 4A (BNC)", "Distro Out 4B (BNC)"]),
            desc: "Active 4-way antenna splitter/distro", level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_rf_venue",
            name: "RF Venue DISTRO4", iconName: "distro",
            category: "Antennas", manufacturer: "RF Venue", model: "DISTRO4",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Antenna In A (BNC)", "Antenna In B (BNC)"],
                outputs: ["Out 1A (BNC)", "Out 1B (BNC)",
                          "Out 2A (BNC)", "Out 2B (BNC)",
                          "Out 3A (BNC)", "Out 3B (BNC)",
                          "Out 4A (BNC)", "Out 4B (BNC)"]),
            desc: "4-channel antenna distributor", level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_wisycom",
            name: "Wisycom BFA Antenna Distro", iconName: "distro",
            category: "Antennas", manufacturer: "Wisycom", model: "BFA",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Ant In A (BNC)", "Ant In B (BNC)"],
                outputs: ["Out 1A (BNC)", "Out 1B (BNC)",
                          "Out 2A (BNC)", "Out 2B (BNC)",
                          "Out 3A (BNC)", "Out 3B (BNC)",
                          "Out 4A (BNC)", "Out 4B (BNC)"]),
            desc: "Active 4-way antenna distributor with bias-T power", level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_distro_lectro",
            name: "Lectrosonics UMCWBD-L Distro", iconName: "distro",
            category: "Antennas", manufacturer: "Lectrosonics", model: "UMCWBD-L",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Ant In A (BNC)", "Ant In B (BNC)"],
                outputs: ["Out 1A (BNC)", "Out 1B (BNC)",
                          "Out 2A (BNC)", "Out 2B (BNC)",
                          "Out 3A (BNC)", "Out 3B (BNC)",
                          "Out 4A (BNC)", "Out 4B (BNC)"]),
            desc: "Wideband 4-slot antenna multicoupler", level: "RF Distribution",
            rackUnits: 1),

        Component(id: "antenna_combiner_shure",
            name: "Shure UA844+SWB Combiner", iconName: "combiner",
            category: "Antennas", manufacturer: "Shure", model: "UA844+SWB",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TX In 1 (BNC)", "TX In 2 (BNC)", "TX In 3 (BNC)", "TX In 4 (BNC)"],
                outputs: ["Combined Ant Out A (BNC)", "Combined Ant Out B (BNC)"]),
            desc: "4-in active IEM transmitter antenna combiner", level: "RF Combining",
            rackUnits: 1),

        Component(id: "antenna_combiner_senn",
            name: "Sennheiser AC 3200-II Combiner", iconName: "combiner",
            category: "Antennas", manufacturer: "Sennheiser", model: "AC 3200-II",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TX In 1 (BNC)", "TX In 2 (BNC)", "TX In 3 (BNC)", "TX In 4 (BNC)",
                          "TX In 5 (BNC)", "TX In 6 (BNC)", "TX In 7 (BNC)", "TX In 8 (BNC)"],
                outputs: ["Combined Out A (BNC)", "Combined Out B (BNC)"]),
            desc: "8-in IEM transmitter antenna combiner", level: "RF Combining",
            rackUnits: 2),

        Component(id: "antenna_combiner_pws",
            name: "PWS DC216 Dual Combiner", iconName: "combiner",
            category: "Antennas", manufacturer: "Professional Wireless Systems", model: "DC216",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TX In 1 (BNC)", "TX In 2 (BNC)"],
                outputs: ["Combined Out (BNC)"]),
            desc: "2-channel passive IEM TX combiner with bandpass filters", level: "RF Combining",
            rackUnits: 1),

        // ── Networking ───────────────────────────────────────
        Component(id: "network_switch_cisco_SG350-28P",
            name: "Cisco SG350-28P PoE Switch", iconName: "network",
            category: "Networking", manufacturer: "Cisco", model: "SG350-28P",
            inputs: ["dante"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["Ethernet 1 (RJ45/PoE)", "Ethernet 2 (RJ45/PoE)", "Ethernet 3 (RJ45/PoE)",
                          "Ethernet 4 (RJ45/PoE)", "Ethernet 5-28 (RJ45/PoE)", "SFP 1", "SFP 2"],
                outputs: ["Ethernet 1 (RJ45/PoE)", "Ethernet 2 (RJ45/PoE)", "Ethernet 3 (RJ45/PoE)",
                          "Ethernet 4 (RJ45/PoE)", "Ethernet 5-28 (RJ45/PoE)", "SFP 1", "SFP 2"]),
            desc: "28-port Gigabit PoE managed switch for Dante", level: "Dante / AES67",
            rackUnits: 1),

        Component(id: "network_switch_luminex_GigaCore_10",
            name: "Luminex GigaCore 10", iconName: "network",
            category: "Networking", manufacturer: "Luminex", model: "GigaCore 10",
            inputs: ["dante"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["Ethernet 1 (EtherCon)", "Ethernet 2 (EtherCon)", "Ethernet 3 (EtherCon)",
                          "Ethernet 4 (EtherCon)", "Ethernet 5 (EtherCon)", "Ethernet 6 (EtherCon)",
                          "Ethernet 7 (EtherCon)", "Ethernet 8 (EtherCon)", "SFP 1", "SFP 2"],
                outputs: ["Ethernet 1 (EtherCon)", "Ethernet 2 (EtherCon)", "Ethernet 3 (EtherCon)",
                          "Ethernet 4 (EtherCon)", "Ethernet 5 (EtherCon)", "Ethernet 6 (EtherCon)",
                          "Ethernet 7 (EtherCon)", "Ethernet 8 (EtherCon)", "SFP 1", "SFP 2"]),
            desc: "10-port managed switch, media/show optimized", level: "Dante / AES67"),
        
        Component(id: "network_switch_netgear_M4250_8_Port",
            name: "Netgear M4250 8 Port", iconName: "network",
            category: "Networking", manufacturer: "Netgear", model: "M4250",
            inputs: ["dante"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["Ethernet 1 (EtherCon)", "Ethernet 2 (EtherCon)", "Ethernet 3 (EtherCon)",
                          "Ethernet 4 (EtherCon)", "Ethernet 5 (EtherCon)", "Ethernet 6 (EtherCon)",
                          "Ethernet 7 (EtherCon)", "Ethernet 8 (EtherCon)", "SFP 1", "SFP 2"],
                outputs: ["Ethernet 1 (EtherCon)", "Ethernet 2 (EtherCon)", "Ethernet 3 (EtherCon)",
                          "Ethernet 4 (EtherCon)", "Ethernet 5 (EtherCon)", "Ethernet 6 (EtherCon)",
                          "Ethernet 7 (EtherCon)", "Ethernet 8 (EtherCon)", "SFP 1", "SFP 2"]),
            desc: "10-port managed switch, media/show optimized", level: "Dante / AES67"),
            desc: "10-port managed switch, media/show optimized", level: "Dante / AES67",
            rackUnits: 1),

        // ── Stage Boxes / Snakes ─────────────────────────────
        Component(id: "stagebox_12",
            name: "Yamaha Rio1608-D2 (12ch)", iconName: "stagebox",
            category: "Stage Racks", manufacturer: "Yamaha", model: "Rio1608-D2",
            inputs: ["mic"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4",
                          "XLR In 5", "XLR In 6", "XLR In 7", "XLR In 8",
                          "XLR In 9", "XLR In 10", "XLR In 11", "XLR In 12"],
                outputs: ["XLR Out 1", "XLR Out 2", "XLR Out 3", "XLR Out 4",
                          "XLR Out 5", "XLR Out 6", "XLR Out 7", "XLR Out 8",
                          "Dante Port A (EtherCon)", "Dante Port B (EtherCon)"]),
            desc: "12-in stage box, Dante network I/O", level: "Analog → Dante",
            rackUnits: 1),

        Component(id: "stagebox_16",
            name: "DiGiCo Orange Box (16ch)", iconName: "stagebox",
            category: "Stage Racks", manufacturer: "DiGiCo", model: "Orange Box",
            inputs: ["mic"], outputs: ["dante", "line"],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4",
                          "XLR In 5", "XLR In 6", "XLR In 7", "XLR In 8",
                          "XLR In 9", "XLR In 10", "XLR In 11", "XLR In 12",
                          "XLR In 13", "XLR In 14", "XLR In 15", "XLR In 16"],
                outputs: ["XLR Out 1", "XLR Out 2", "XLR Out 3", "XLR Out 4",
                          "XLR Out 5", "XLR Out 6", "XLR Out 7", "XLR Out 8",
                          "MADI Out A (BNC)", "MADI Out B (BNC)", "Dante Out (EtherCon)"]),
            desc: "16-in stage box, MADI + Dante", level: "Analog → MADI/Dante",
            rackUnits: 1),

        Component(id: "stagebox_24",
            name: "Yamaha Rio3224-D2 (24ch)", iconName: "stagebox",
            category: "Stage Racks", manufacturer: "Yamaha", model: "Rio3224-D2",
            inputs: ["mic"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["XLR In 1", "XLR In 2", "XLR In 3", "XLR In 4",
                          "XLR In 5", "XLR In 6", "XLR In 7", "XLR In 8",
                          "XLR In 9", "XLR In 10", "XLR In 11", "XLR In 12",
                          "XLR In 13", "XLR In 14", "XLR In 15", "XLR In 16",
                          "XLR In 17", "XLR In 18", "XLR In 19", "XLR In 20",
                          "XLR In 21", "XLR In 22", "XLR In 23", "XLR In 24"],
                outputs: ["XLR Out 1", "XLR Out 2", "XLR Out 3", "XLR Out 4",
                          "XLR Out 5", "XLR Out 6", "XLR Out 7", "XLR Out 8",
                          "Dante Port A (EtherCon)", "Dante Port B (EtherCon)"]),
            desc: "24-in/8-out stage box, Dante", level: "Analog → Dante",
            rackUnits: 2),

        Component(id: "stagebox_32",
            name: "DiGiCo SD-Rack (32ch)", iconName: "stagebox",
            category: "Stage Racks", manufacturer: "DiGiCo", model: "SD-Rack 32ch",
            inputs: ["mic"], outputs: ["line"],
            ports: PortInfo(
                inputs:  ["XLR In 1-8", "XLR In 9-16", "XLR In 17-24", "XLR In 25-32"],
                outputs: ["XLR Out 1-8", "XLR Out 9-16",
                          "MADI Out A (BNC)", "MADI Out B (BNC)", "Optics Out"]),
            desc: "32-in/16-out SD-Rack, MADI + optical", level: "Analog → MADI",
            rackUnits: 3),

        Component(id: "stagebox_40",
            name: "Yamaha Rio6432-D2 (40ch)", iconName: "stagebox",
            category: "Stage Racks", manufacturer: "Yamaha", model: "Rio6432-D2",
            inputs: ["mic"], outputs: ["dante"],
            ports: PortInfo(
                inputs:  ["XLR In 1-8", "XLR In 9-16", "XLR In 17-24",
                          "XLR In 25-32", "XLR In 33-40", "XLR In 41-48 (expansion)"],
                outputs: ["XLR Out 1-16",
                          "Dante Port A (EtherCon)", "Dante Port B (EtherCon)"]),
            desc: "40-in/32-out stage box, dual Dante", level: "Analog → Dante",
            rackUnits: 3),

        // ── Rack Enclosures ──────────────────────────────────
        Component(id: "rack_8u",
            name: "8U Rack Enclosure", iconName: "rack",
            category: "Racks", manufacturer: "Middle Atlantic", model: "WRK-8-26",
            inputs: [], outputs: [], ports: .empty,
            desc: "8U standard rack enclosure", level: "",
            isRack: true, rackUnits: 8),

        Component(id: "rack_12u",
            name: "12U Rack Enclosure", iconName: "rack",
            category: "Racks", manufacturer: "Middle Atlantic", model: "WRK-12-26",
            inputs: [], outputs: [], ports: .empty,
            desc: "12U standard rack enclosure", level: "",
            isRack: true, rackUnits: 12),

        Component(id: "rack_20u",
            name: "20U Road Rack", iconName: "rack",
            category: "Racks", manufacturer: "Gator Cases", model: "G-TOUR20U",
            inputs: [], outputs: [], ports: .empty,
            desc: "20U tour-grade rolling rack", level: "",
            isRack: true, rackUnits: 20),

        Component(id: "rack_amp",
            name: "Amp Rack (8U)", iconName: "rack",
            category: "Racks", manufacturer: "Penn Elcom", model: "R8100-8UK",
            inputs: [], outputs: [], ports: .empty,
            desc: "8U amp rack with ventilation panels", level: "",
            isRack: true, rackUnits: 8),

        // ── Power Systems ────────────────────────────────────
        Component(id: "power_dist",
            name: "Socapex Power Distro", iconName: "power",
            category: "Power", manufacturer: "PowerTech", model: "PD-100A",
            inputs: ["power"], outputs: ["power"],
            ports: PortInfo(
                inputs:  ["Cam-Lok Feed (3-phase)"],
                outputs: ["Edison 20A ×8", "L6-20 ×4", "Socapex ×2"]),
            desc: "(Coming soon) Power distribution unit", level: "Power — 120/240V",
            comingSoon: true),

        // ── RF Combiners & Distros ───────────────────────────
        Component(id: "pws_combiner_2ch",
            name: "PWS DC216 2ch Combiner", iconName: "combiner",
            category: "Antennas", manufacturer: "Professional Wireless Systems", model: "DC216",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TX In 1 (BNC)", "TX In 2 (BNC)"],
                outputs: ["Combined Out (BNC)"]),
            desc: "Passive 2-ch IEM TX combiner, bandpass filters", level: "RF Combining",
            rackUnits: 1),

        Component(id: "pws_combiner_8ch",
            name: "PWS UCP-8 8ch Combiner", iconName: "combiner",
            category: "Antennas", manufacturer: "Professional Wireless Systems", model: "UCP-8",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["TX In 1 (BNC)", "TX In 2 (BNC)", "TX In 3 (BNC)", "TX In 4 (BNC)",
                          "TX In 5 (BNC)", "TX In 6 (BNC)", "TX In 7 (BNC)", "TX In 8 (BNC)"],
                outputs: ["Combined Out A (BNC)", "Combined Out B (BNC)"]),
            desc: "8-ch active IEM TX combiner with bandpass filters", level: "RF Combining",
            rackUnits: 1),

        Component(id: "pws_distro",
            name: "PWS PS-RF-1 Antenna Distro", iconName: "distro",
            category: "Antennas", manufacturer: "Professional Wireless Systems", model: "PS-RF-1",
            inputs: ["rf"], outputs: ["rf"],
            ports: PortInfo(
                inputs:  ["Ant In A (BNC)", "Ant In B (BNC)"],
                outputs: ["Out 1A (BNC)", "Out 1B (BNC)",
                          "Out 2A (BNC)", "Out 2B (BNC)",
                          "Out 3A (BNC)", "Out 3B (BNC)",
                          "Out 4A (BNC)", "Out 4B (BNC)"]),
            desc: "Active 4-way antenna distributor with DC bias", level: "RF Distribution",
            rackUnits: 1),
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
