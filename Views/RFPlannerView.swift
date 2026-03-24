import SwiftUI

struct RFPlannerView: View {
    @EnvironmentObject var rfState: RFState
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            // Left column: venue information and generator button
            VenueColumnView()
                .frame(maxWidth: .infinity)

            Divider()

            // Right column: grouped RF gear list
            GearListColumnView()
                .frame(maxWidth: .infinity)
        }
        // Fill available space in the parent container
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // Match the standard macOS text background color
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Venue Column
struct VenueColumnView: View {
    @EnvironmentObject var rfState: RFState

    var body: some View {
        VStack(spacing: 0) {
            // Header row with title and generate button
            HStack {
                Text("VENUE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                Spacer()

                // Generates a random venue and matching RF gear list
                Button {
                    generateRF(rfState: rfState)
                } label: {
                    Label("Generate Random Gear List", systemImage: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(Divider(), alignment: .bottom)

            // Main content area for the venue card or empty state
            ScrollView {
                if let venue = rfState.venue {
                    // Show selected/generated venue details
                    VenueCardView(venue: venue)
                        .padding(16)
                } else {
                    // Empty state shown before generation
                    VStack(spacing: 8) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.3))

                        Text("Click **Generate Random Gear List** to begin")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
        }
    }
}

// MARK: - Venue Card
struct VenueCardView: View {
    let venue: RFVenue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Venue name
            Text(venue.name)
                .font(.system(size: 16, weight: .bold))

            // Venue type and city
            HStack(spacing: 8) {
                Text(venue.type)
                    .font(.system(size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.07))
                    .clipShape(Capsule())

                Text(venue.city)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            // Capacity and RF environment summary
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CAPACITY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text(venue.capacity.formatted())
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("RF ENVIRONMENT")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)

                    RFEnvPill(env: venue.rfEnv)
                }
            }

            // Descriptive notes about the venue
            Text(venue.notes)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

struct RFEnvPill: View {
    let env: RFEnvironment

    var body: some View {
        // Colored capsule indicating RF congestion level
        Text(env.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(pillColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(pillColor.opacity(0.15))
            .clipShape(Capsule())
    }

    var pillColor: Color {
        // Maps RF environment levels to UI colors
        switch env {
        case .low:      return .green
        case .moderate: return .blue
        case .busy:     return .orange
        case .veryBusy: return .red
        }
    }
}

// MARK: - Gear List Column
struct GearListColumnView: View {
    @EnvironmentObject var rfState: RFState

    var body: some View {
        VStack(spacing: 0) {
            // Header row with title and add-item button
            HStack {
                Text("RF GEAR LIST")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                Spacer()

                // Adds a manual placeholder item to the current gear list
                Button {
                    let item = RFGearItem(id: rfState.nextId, cat: "Accessory", name: "New item", qty: 1)
                    rfState.nextId += 1
                    rfState.gear.append(item)
                } label: {
                    Label("Add Item", systemImage: "plus")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(Divider(), alignment: .bottom)

            if rfState.gear.isEmpty {
                // Empty state shown before a list is generated or manually populated
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.3))

                    Text("Generate a setup to populate the gear list")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Scrollable grouped gear list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedGear, id: \.0) { (cat, items) in
                            Section {
                                ForEach(items) { item in
                                    GearRowView(item: binding(for: item))
                                }
                            } header: {
                                // Section header for each gear category
                                Text(cat.uppercased())
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .tracking(0.5)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var groupedGear: [(String, [RFGearItem])] {
        // Preserves original category order while grouping items by category
        var groups: [(String, [RFGearItem])] = []
        var seen = Set<String>()

        for item in rfState.gear {
            if !seen.contains(item.cat) {
                seen.insert(item.cat)
                groups.append((item.cat, []))
            }
            if let idx = groups.firstIndex(where: { $0.0 == item.cat }) {
                groups[idx].1.append(item)
            }
        }
        return groups
    }

    private func binding(for item: RFGearItem) -> Binding<RFGearItem> {
        // Returns a binding to the matching item inside rfState.gear
        Binding(
            get: { rfState.gear.first(where: { $0.id == item.id }) ?? item },
            set: { updated in
                if let idx = rfState.gear.firstIndex(where: { $0.id == updated.id }) {
                    rfState.gear[idx] = updated
                }
            }
        )
    }
}

// MARK: - Gear Row
struct GearRowView: View {
    @Binding var item: RFGearItem
    @EnvironmentObject var rfState: RFState
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            // Quantity field
            HStack(spacing: 0) {
                TextField("", value: $item.qty, formatter: NumberFormatter())
                    .font(.system(size: 12, design: .monospaced))
                    .frame(width: 36)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .padding(4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
            }

            // Editable gear item name
            TextField("Item name", text: $item.name)
                .font(.system(size: 11))
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)

            // Remove button shown on hover
            Button {
                rfState.gear.removeAll { $0.id == item.id }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(isHovered ? Color.primary.opacity(0.03) : Color.clear)
        .onHover { isHovered = $0 }
    }
}

// MARK: - RF Generator
func generateRF(rfState: RFState) {
    // Pick a random venue and reset the current generated state
    let venue = rfPick(rfVenues)
    rfState.venue = venue
    rfState.gear = []
    rfState.nextId = 1

    let cap    = venue.capacity
    let region = venue.region
    var gear: [(cat: String, name: String, qty: Int)] = []

    // Determine rough wireless microphone and IEM channel counts from venue size
    let wxChannels: Int, iemChannels: Int
    switch cap {
    case ..<300:   wxChannels = rfRand(2,4);   iemChannels = rfRand(2,4)
    case ..<1000:  wxChannels = rfRand(4,8);   iemChannels = rfRand(4,8)
    case ..<5000:  wxChannels = rfRand(8,16);  iemChannels = rfRand(6,12)
    default:       wxChannels = rfRand(16,32); iemChannels = rfRand(12,24)
    }

    // Decide how many wireless and IEM system families to combine
    let maxWxSystems  = cap < 1000 ? 1 : cap < 5000 ? rfRand(1,2) : rfRand(1,3)
    let maxIemSystems = cap < 1000 ? 1 : rfRand(1,2)

    let shuffled = rfWirelessSystems.shuffled()
    let wxSystems  = Array(shuffled.prefix(maxWxSystems))
    let iemSystems = Array(shuffled.filter { $0.iemTx != nil }.prefix(maxIemSystems))

    // Build wireless microphone receiver/transmitter package list
    for (si, sys) in wxSystems.enumerated() {
        let thisCh = si == wxSystems.count - 1
            ? wxChannels - (wxChannels / wxSystems.count) * si
            : wxChannels / wxSystems.count
        guard thisCh >= 1 else { continue }

        let rxModel  = rfPick(sys.receivers)
        let rxUnits  = Int(ceil(Double(thisCh) / Double(rxModel.channels)))
        let actualCh = rxUnits * rxModel.channels

        let bands = sys.freqBands[region] ?? sys.freqBands["US"] ?? []
        let band  = bands.isEmpty ? nil : rfPick(bands)
        let rxName = band != nil ? "\(rxModel.name) – \(band!.band) (\(band!.range))" : rxModel.name

        gear.append((cat: rxModel.cat, name: rxName, qty: rxUnits))

        let heldCount = Int(ceil(Double(actualCh) * 0.4))
        let bpCount   = actualCh - heldCount
        if heldCount > 0 { gear.append((cat: "Handheld Wireless", name: rfPick(sys.handhelds).name, qty: heldCount)) }
        if bpCount   > 0 { gear.append((cat: "Bodypack / Lav",    name: rfPick(sys.bodypacks).name, qty: bpCount)) }
    }

    // Build IEM transmitter/receiver package list
    for (si, sys) in iemSystems.enumerated() {
        let thisCh = si == iemSystems.count - 1
            ? iemChannels - (iemChannels / iemSystems.count) * si
            : iemChannels / iemSystems.count
        guard thisCh >= 1, let txList = sys.iemTx, let rxList = sys.iemRx else { continue }

        let bands  = sys.freqBands[region] ?? sys.freqBands["US"] ?? []
        let band   = bands.isEmpty ? nil : rfPick(bands)
        let txName = band != nil ? "\(rfPick(txList).name) – \(band!.band) (\(band!.range))" : rfPick(txList).name

        gear.append((cat: "IEM Transmitter", name: txName,              qty: thisCh))
        gear.append((cat: "IEM Receiver",   name: rfPick(rxList).name, qty: thisCh))
    }

    // Add antennas based on venue size
    let antCount = cap >= 5000 ? rfRand(4,8) : cap >= 1000 ? 4 : 2
    gear.append((cat: "Antenna", name: rfPick(rfAntennas).name, qty: antCount))

    // Add antenna distribution when channel count is high enough
    if wxChannels >= 4 {
        let distroUnits = max(1, Int(ceil(Double(wxChannels) / 8)))
        gear.append((cat: "Antenna Distribution", name: rfPick(rfDistros).name, qty: distroUnits))
    }

    // Add coordination software based on system brands in use
    let coordBrands = Set(wxSystems.map { $0.coord })
    for c in coordBrands {
        gear.append((cat: "Coordination Software", name: c, qty: 1))
    }
    if !coordBrands.contains("IAS Intermodulation Analysis System") {
        gear.append((cat: "Coordination Software", name: "IAS Intermodulation Analysis System", qty: 1))
    }

    // Add a few random accessories for realism/completeness
    for a in rfPickN(rfAccessories, rfRand(3,5)) {
        gear.append((cat: a.cat, name: a.name, qty: 1))
    }

    // Convert tuples into RFGearItem models with incrementing IDs
    rfState.gear = gear.map {
        let id = rfState.nextId
        rfState.nextId += 1
        return RFGearItem(id: id, cat: $0.cat, name: $0.name, qty: $0.qty)
    }
}
