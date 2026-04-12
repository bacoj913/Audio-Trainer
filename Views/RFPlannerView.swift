import SwiftUI

struct RFPlannerView: View {
    @EnvironmentObject var rfState: RFState
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            PhaseModeBar()
                .environmentObject(rfState)
            Divider()
            HSplitView {
                VenueColumnView()
                    .frame(minWidth: 240)
                GearListColumnView()
                    .frame(minWidth: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Phase / Mode Bar
struct PhaseModeBar: View {
    @EnvironmentObject var rfState: RFState

    var body: some View {
        HStack(spacing: 12) {
            Picker("", selection: $rfState.phase) {
                ForEach(RFPhase.allCases) { phase in
                    Text(phase.rawValue).tag(phase)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)

            Divider().frame(height: 20)

            HStack(spacing: 6) {
                Text("Mode:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Picker("", selection: $rfState.mode) {
                    ForEach(CoordinatorMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            Spacer()

            Text(phaseDescription)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    var phaseDescription: String {
        switch rfState.phase {
        case .prep:
            return rfState.mode == .beginner
                ? "Beginner: gear list auto-populated from advance"
                : "Expert: extrapolate gear list from production advance"
        case .rehearsal:
            return "Rehearsal \(rfState.rehearsalIteration + 1): apply changes from TD"
        case .show:
            return "Show: validate final gear list against advance"
        }
    }
}

// MARK: - Venue Column
struct VenueColumnView: View {
    @EnvironmentObject var rfState: RFState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("VENUE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                Spacer()
                actionButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(spacing: 12) {
                    if let venue = rfState.venue {
                        VenueCardView(venue: venue)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    } else {
                        emptyState
                    }
                    if let advance = rfState.productionAdvance {
                        ProductionAdvanceCardView(advance: advance)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var actionButton: some View {
        switch rfState.phase {
        case .prep:
            Button {
                generateRF(rfState: rfState)
            } label: {
                Label("Generate", systemImage: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
        case .rehearsal:
            Button {
                guard let advance = rfState.productionAdvance else { return }
                let (newAdvance, _) = generateRehearsalChange(
                    advance: advance,
                    iteration: rfState.rehearsalIteration
                )
                rfState.gearListHistory.append(rfState.gear)
                rfState.productionAdvance = newAdvance
                rfState.rehearsalIteration += 1
                if rfState.mode == .beginner {
                    rfState.gear = gearFromAdvance(
                        newAdvance,
                        existing: rfState.gear,
                        nextId: &rfState.nextId
                    )
                }
            } label: {
                Label("Apply Change", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
            .disabled(rfState.productionAdvance == nil)
        case .show:
            Text("Show Mode")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .italic()
        }
    }

    var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.3))
            Text("Click **Generate** to begin")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Venue Card
struct VenueCardView: View {
    let venue: RFVenue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(venue.name)
                .font(.system(size: 16, weight: .bold))

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
        Text(env.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(pillColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(pillColor.opacity(0.15))
            .clipShape(Capsule())
    }

    var pillColor: Color {
        switch env {
        case .low:      return .green
        case .moderate: return .blue
        case .busy:     return .orange
        case .veryBusy: return .red
        }
    }
}

// MARK: - Production Advance Card
struct ProductionAdvanceCardView: View {
    let advance: RFProductionAdvance

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(advance.showName)
                    .font(.system(size: 13, weight: .semibold))
            }

            Text("PRODUCTION ADVANCE — \(advance.performers.count) PERFORMERS")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(spacing: 0) {
                // Table header
                HStack(spacing: 0) {
                    Text("Name / Role")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Location")
                        .frame(width: 88, alignment: .leading)
                    Text("WX")
                        .frame(width: 34, alignment: .center)
                    Text("IEM")
                        .frame(width: 34, alignment: .center)
                }
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.05))

                ForEach(advance.performers) { p in
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(p.name)
                                    .font(.system(size: 11, weight: .medium))
                                Text(p.role)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Text(p.location)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(width: 88, alignment: .leading)

                            Text(p.wirelessChannels > 0
                                 ? "\(p.wirelessChannels)\(p.wirelessType == "HH" ? "h" : "b")"
                                 : "—")
                                .font(.system(size: 11, design: .monospaced))
                                .frame(width: 34, alignment: .center)

                            Text(p.iemChannels > 0 ? "\(p.iemChannels)" : "—")
                                .font(.system(size: 11, design: .monospaced))
                                .frame(width: 34, alignment: .center)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        Divider()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )

            if let lastChange = advance.changeLog.last {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                    Text(lastChange)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Gear Validation Badge
struct RFGearValidationBadge: View {
    let results: [RFValidationResult]

    var allOk: Bool { results.allSatisfy { $0.isOk } }
    var gapCount: Int { results.filter { !$0.isOk }.count }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: allOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text(allOk ? "Advance Met" : "\(gapCount) Gap\(gapCount == 1 ? "" : "s")")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(allOk ? .green : .orange)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background((allOk ? Color.green : Color.orange).opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Gear List Column
struct GearListColumnView: View {
    @EnvironmentObject var rfState: RFState

    private var validationResults: [RFValidationResult] {
        guard let advance = rfState.productionAdvance else { return [] }
        return validateGearList(gear: rfState.gear, against: advance)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("RF GEAR LIST")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                if !validationResults.isEmpty {
                    RFGearValidationBadge(results: validationResults)
                }

                Spacer()

                if rfState.phase != .show {
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(Divider(), alignment: .bottom)

            if rfState.gear.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text(rfState.mode == .expert && rfState.productionAdvance != nil
                         ? "Review the production advance and build your gear list"
                         : "Generate a setup to populate the gear list")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedGear, id: \.0) { (cat, items) in
                            Section {
                                ForEach(items) { item in
                                    GearRowView(item: binding(for: item))
                                        .disabled(rfState.phase == .show)
                                }
                            } header: {
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

            TextField("Item name", text: $item.name)
                .font(.system(size: 11))
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)

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
    let venue = rfPick(rfVenues)
    rfState.venue = venue
    rfState.gear = []
    rfState.nextId = 1
    rfState.rehearsalIteration = 0
    rfState.gearListHistory = []

    // Always generate a production advance
    let advance = generateProductionAdvance(venue: venue)
    rfState.productionAdvance = advance

    // Expert mode: leave gear list empty for user to fill in
    guard rfState.mode == .beginner else { return }

    // Beginner mode: auto-populate gear list from the advance + venue
    let cap    = venue.capacity
    let region = venue.region
    var gear: [(cat: String, name: String, qty: Int)] = []

    let wxChannels: Int, iemChannels: Int
    switch cap {
    case ..<300:   wxChannels = rfRand(2,4);   iemChannels = rfRand(2,4)
    case ..<1000:  wxChannels = rfRand(4,8);   iemChannels = rfRand(4,8)
    case ..<5000:  wxChannels = rfRand(8,16);  iemChannels = rfRand(6,12)
    default:       wxChannels = rfRand(16,32); iemChannels = rfRand(12,24)
    }

    let maxWxSystems  = cap < 1000 ? 1 : cap < 5000 ? rfRand(1,2) : rfRand(1,3)
    let maxIemSystems = cap < 1000 ? 1 : rfRand(1,2)

    let shuffled = rfWirelessSystems.shuffled()
    let wxSystems  = Array(shuffled.prefix(maxWxSystems))
    let iemSystems = Array(shuffled.filter { $0.iemTx != nil }.prefix(maxIemSystems))

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

    for (si, sys) in iemSystems.enumerated() {
        let thisCh = si == iemSystems.count - 1
            ? iemChannels - (iemChannels / iemSystems.count) * si
            : iemChannels / iemSystems.count
        guard thisCh >= 1, let txList = sys.iemTx, let rxList = sys.iemRx else { continue }

        let bands  = sys.freqBands[region] ?? sys.freqBands["US"] ?? []
        let band   = bands.isEmpty ? nil : rfPick(bands)
        let txName = band != nil ? "\(rfPick(txList).name) – \(band!.band) (\(band!.range))" : rfPick(txList).name

        gear.append((cat: "IEM Transmitter", name: txName,              qty: thisCh))
        gear.append((cat: "IEM Receiver",    name: rfPick(rxList).name, qty: thisCh))
    }

    let antCount = cap >= 5000 ? rfRand(4,8) : cap >= 1000 ? 4 : 2
    gear.append((cat: "Antenna", name: rfPick(rfAntennas).name, qty: antCount))

    if wxChannels >= 4 {
        let distroUnits = max(1, Int(ceil(Double(wxChannels) / 8)))
        gear.append((cat: "Antenna Distribution", name: rfPick(rfDistros).name, qty: distroUnits))
    }

    let coordBrands = Set(wxSystems.map { $0.coord })
    for c in coordBrands {
        gear.append((cat: "Coordination Software", name: c, qty: 1))
    }
    if !coordBrands.contains("IAS Intermodulation Analysis System") {
        gear.append((cat: "Coordination Software", name: "IAS Intermodulation Analysis System", qty: 1))
    }

    for a in rfPickN(rfAccessories, rfRand(3,5)) {
        gear.append((cat: a.cat, name: a.name, qty: 1))
    }

    rfState.gear = gear.map {
        let id = rfState.nextId
        rfState.nextId += 1
        return RFGearItem(id: id, cat: $0.cat, name: $0.name, qty: $0.qty)
    }
}

/// Rebuild the beginner gear list to match a new advance, preserving manually-added items.
func gearFromAdvance(
    _ advance: RFProductionAdvance,
    existing: [RFGearItem],
    nextId: inout Int
) -> [RFGearItem] {
    let totalHH  = advance.performers.reduce(0) { $0 + ($1.wirelessType == "HH" ? $1.wirelessChannels : 0) }
    let totalBP  = advance.performers.reduce(0) { $0 + ($1.wirelessType != "HH" ? $1.wirelessChannels : 0) }
    let totalIEM = advance.performers.reduce(0) { $0 + $1.iemChannels }

    var updated = existing

    func setQty(cat: String, qty: Int) {
        if let idx = updated.firstIndex(where: { $0.cat == cat }) {
            updated[idx].qty = qty
        } else if qty > 0 {
            updated.append(RFGearItem(id: nextId, cat: cat, name: cat, qty: qty))
            nextId += 1
        }
    }

    setQty(cat: "Handheld Wireless", qty: totalHH)
    setQty(cat: "Bodypack / Lav",    qty: totalBP)
    if totalIEM > 0 {
        setQty(cat: "IEM Transmitter", qty: totalIEM)
        setQty(cat: "IEM Receiver",    qty: totalIEM)
    }

    return updated.filter { $0.qty > 0 }
}
