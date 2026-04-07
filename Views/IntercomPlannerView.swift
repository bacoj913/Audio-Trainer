import SwiftUI

struct IntercomPlannerView: View {
    @EnvironmentObject var intercomState: IntercomState
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            IntercomPhaseModeBar()
                .environmentObject(intercomState)
            Divider()
            HStack(spacing: 0) {
                IntercomVenueColumnView()
                    .frame(maxWidth: .infinity)
                Divider()
                IntercomGearColumnView()
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Phase / Mode Bar
struct IntercomPhaseModeBar: View {
    @EnvironmentObject var intercomState: IntercomState

    var body: some View {
        HStack(spacing: 12) {
            Picker("", selection: $intercomState.phase) {
                ForEach(IntercomPhase.allCases) { phase in
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
                Picker("", selection: $intercomState.mode) {
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
        switch intercomState.phase {
        case .prep:
            return intercomState.mode == .beginner
                ? "Beginner: channel list auto-built from advance"
                : "Expert: design channel plan from production advance"
        case .rehearsal:
            return "Rehearsal \(intercomState.rehearsalIteration + 1): apply position changes from TD"
        case .show:
            return "Show: final channel list locked"
        }
    }
}

// MARK: - Venue / Advance Column
struct IntercomVenueColumnView: View {
    @EnvironmentObject var intercomState: IntercomState

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
                    if let venue = intercomState.venue {
                        VenueCardView(venue: venue)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    } else {
                        intercomEmptyState
                    }
                    if let advance = intercomState.productionAdvance {
                        IntercomAdvanceCardView(advance: advance)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var actionButton: some View {
        switch intercomState.phase {
        case .prep:
            Button {
                generateIntercom(intercomState: intercomState)
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
                guard let advance = intercomState.productionAdvance else { return }
                let (newAdvance, _) = generateIntercomChange(
                    advance: advance,
                    iteration: intercomState.rehearsalIteration
                )
                intercomState.channelListHistory.append(intercomState.channelList)
                intercomState.productionAdvance = newAdvance
                intercomState.rehearsalIteration += 1
                if intercomState.mode == .beginner {
                    intercomState.channelList = buildChannelList(from: newAdvance)
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
            .disabled(intercomState.productionAdvance == nil)
        case .show:
            Text("Show Mode")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .italic()
        }
    }

    var intercomEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "headphones")
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

// MARK: - Intercom Advance Card
struct IntercomAdvanceCardView: View {
    let advance: IntercomProductionAdvance

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(advance.showName)
                    .font(.system(size: 13, weight: .semibold))
            }

            Text("INTERCOM ADVANCE — \(advance.positions.count) POSITIONS")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Position")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Location")
                        .frame(width: 100, alignment: .leading)
                    Text("Channels")
                        .frame(maxWidth: 120, alignment: .leading)
                }
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.05))

                ForEach(advance.positions) { pos in
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text(pos.name)
                                .font(.system(size: 11, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(pos.location)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .leading)
                            Text(pos.channels.joined(separator: ", "))
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: 120, alignment: .leading)
                                .lineLimit(1)
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

// MARK: - Intercom Gear Column
struct IntercomGearColumnView: View {
    @EnvironmentObject var intercomState: IntercomState

    private var validationResults: [IntercomValidationResult] {
        guard let advance = intercomState.productionAdvance else { return [] }
        return validateIntercomGear(gear: intercomState.channelList.map {
            // Map channels to device count representation for validation
            IntercomDevice(cat: "Channel", name: $0.label, qty: 1)
        }, against: advance)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("INTERCOM PLAN")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                if !validationResults.isEmpty {
                    IntercomValidationBadge(results: validationResults)
                }

                Spacer()

                if intercomState.phase != .show {
                    Button {
                        let ch = IntercomChannel(
                            id: intercomState.nextId,
                            label: "Channel \(intercomState.nextId)",
                            partyLine: true,
                            assignment: "",
                            notes: ""
                        )
                        intercomState.nextId += 1
                        intercomState.channelList.append(ch)
                    } label: {
                        Label("Add Channel", systemImage: "plus")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(Divider(), alignment: .bottom)

            if intercomState.channelList.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text(intercomState.mode == .expert && intercomState.productionAdvance != nil
                         ? "Review the advance and design your channel plan"
                         : "Generate a setup to populate the channel list")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Column headers
                        HStack(spacing: 8) {
                            Text("Ch")
                                .frame(width: 28, alignment: .center)
                            Text("Label")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Type")
                                .frame(width: 80, alignment: .leading)
                            Text("Assignment")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.04))

                        ForEach($intercomState.channelList) { $ch in
                            IntercomChannelRow(channel: $ch)
                                .disabled(intercomState.phase == .show)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

// MARK: - Intercom Validation Badge
struct IntercomValidationBadge: View {
    let results: [IntercomValidationResult]

    var allOk: Bool { results.allSatisfy { $0.isOk } }
    var gapCount: Int { results.filter { !$0.isOk }.count }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: allOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text(allOk ? "Plan OK" : "\(gapCount) Gap\(gapCount == 1 ? "" : "s")")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(allOk ? .green : .orange)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background((allOk ? Color.green : Color.orange).opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Channel Row
struct IntercomChannelRow: View {
    @Binding var channel: IntercomChannel
    @EnvironmentObject var intercomState: IntercomState
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Text("\(channel.id)")
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 28, alignment: .center)
                .foregroundColor(.secondary)

            TextField("Label", text: $channel.label)
                .font(.system(size: 11, weight: .medium))
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)

            Picker("", selection: $channel.partyLine) {
                Text("Party Line").tag(true)
                Text("Point-to-Point").tag(false)
            }
            .labelsHidden()
            .frame(width: 80)
            .font(.system(size: 10))

            TextField("Assignment", text: $channel.assignment)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)

            Button {
                intercomState.channelList.removeAll { $0.id == channel.id }
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

// MARK: - Generator
func generateIntercom(intercomState: IntercomState) {
    let venue = rfPick(rfVenues)
    intercomState.venue = venue
    intercomState.channelList = []
    intercomState.nextId = 1
    intercomState.rehearsalIteration = 0
    intercomState.channelListHistory = []

    let advance = generateIntercomAdvance(venue: venue)
    intercomState.productionAdvance = advance

    guard intercomState.mode == .beginner else { return }

    intercomState.channelList = buildChannelList(from: advance)
    intercomState.nextId = (intercomState.channelList.map { $0.id }.max() ?? 0) + 1
}
