// Views/InspectorView.swift — Right panel (switches between free mode and exercise mode)

import SwiftUI

struct InspectorView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            switch appState.mode {
            case .free:     FreePanelView()
            case .exercise: ExercisePanelView()
            case .rf:       EmptyView()
            }
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.96))
    }
}

// MARK: - Free Mode Panel
struct FreePanelView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // How to use
            InspectorSection(title: "HOW TO USE") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Build any signal chain you like.")
                        .font(.system(size: 11))
                    howToStep(n: 1, text: "Drag components from the sidebar")
                    howToStep(n: 2, text: "Click an **output ●** to start a cable")
                    howToStep(n: 3, text: "Click an **● input** to connect")
                    howToStep(n: 4, text: "Right-click a cable to remove it")
                    howToStep(n: 5, text: "Double-click palette items to add at default position")
                }
            }
            // Signal types legend
            InspectorSection(title: "SIGNAL TYPES") {
                VStack(spacing: 4) {
                    LevelRow(color: .signalTypeColor("mic"),        label: "Mic / Line",       tag: "analog")
                    LevelRow(color: .signalTypeColor("instrument"), label: "Instrument",        tag: "analog")
                    LevelRow(color: .signalTypeColor("speaker"),    label: "Speaker",           tag: "analog")
                    LevelRow(color: .signalTypeColor("aes"),        label: "AES",               tag: "digital")
                    LevelRow(color: .signalTypeColor("madi"),       label: "MADI",              tag: "digital")
                    LevelRow(color: .signalTypeColor("fiber"),      label: "Fiber / Optical",   tag: "digital")
                    LevelRow(color: .signalTypeColor("dante"),      label: "Dante / Milan",     tag: "network")
                    LevelRow(color: .signalTypeColor("rf"),         label: "RF",                tag: "wireless")
                    LevelRow(color: .signalTypeColor("antenna"),    label: "Antenna",           tag: "wireless")
                    LevelRow(color: .signalTypeColor("power"),      label: "Power",             tag: "power")
                }
            }

            // Signal Rules reference
            SignalRulesSection()

            // Quick Starts
            InspectorSection(title: "QUICK STARTS") {
                VStack(spacing: 6) {
                    QuickStartButton(icon: "mic", label: "Live PA Setup") {
                        appState.loadQuickStart("live-pa")
                    }
                    QuickStartButton(icon: "record.circle", label: "Recording Chain") {
                        appState.loadQuickStart("recording")
                    }
                    QuickStartButton(icon: "guitars", label: "Guitar Rig") {
                        appState.loadQuickStart("guitar")
                    }
                }
            }
        }
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func howToStep(n: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(n).")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 14, alignment: .trailing)
            Text(text)
                .font(.system(size: 11))
        }
    }
}

struct LevelRow: View {
    let color: Color
    let label: String
    let tag: String

    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11))
            Spacer()
            Text(tag)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.06))
                .clipShape(Capsule())
        }
    }
}

struct QuickStartButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 11, weight: .medium))
                Spacer()
                Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isHovered ? Color.blue.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Signal Rules Section
struct SignalRulesSection: View {
    @State private var selectedDomain: RuleDomain = .aes

    var body: some View {
        InspectorSection(title: "SIGNAL RULES") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("", selection: $selectedDomain) {
                    ForEach(RuleDomain.allCases) { domain in
                        Text(domain.displayName).tag(domain)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                VStack(spacing: 4) {
                    ForEach(SignalRules.all[selectedDomain.rawValue] ?? []) { rule in
                        SignalRuleRow(rule: rule, domainColor: selectedDomain.color)
                    }
                }
            }
        }
    }
}

struct SignalRuleRow: View {
    let rule: SignalRule
    let domainColor: Color
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 6) {
                Text(rule.detail)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                if !rule.references.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(rule.references, id: \.self) { ref in
                            Text("↳ \(ref)")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(domainColor.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.leading, 4)
            .padding(.bottom, 4)
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(domainColor)
                    .frame(width: 6, height: 6)
                Text(rule.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .disclosureGroupStyle(.automatic)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Shared Inspector Section
struct InspectorSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(Divider(), alignment: .bottom)
    }
}
