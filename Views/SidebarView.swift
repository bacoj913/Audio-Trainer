// Views/SidebarView.swift — Component palette sidebar with search and drag support

import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var collapsedCategories: Set<String> = []
    private let myEquipmentKey = "My Equipment"

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                TextField("Search components…", text: $searchText)
                    .font(.system(size: 12))
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            // Component list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {

                    // MARK: My Equipment (user-saved racks)
                    let myRacks = filteredUserRacks()
                    if !myRacks.isEmpty || searchText.isEmpty {
                        let isCollapsed = collapsedCategories.contains(myEquipmentKey)
                        Section {
                            if !isCollapsed {
                                if myRacks.isEmpty {
                                    Text("Save a configured rack here")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                } else {
                                    ForEach(myRacks) { rack in
                                        UserRackPaletteItemView(rack: rack)
                                    }
                                }
                            }
                        } header: {
                            categoryHeader(myEquipmentKey, count: myRacks.count,
                                           isCollapsed: isCollapsed, accent: true)
                        }
                    }

                    // MARK: Built-in categories
                    ForEach(categoryOrder, id: \.self) { category in
                        let items = filteredItems(in: category)
                        if !items.isEmpty {
                            let isCollapsed = collapsedCategories.contains(category)
                            Section {
                                if !isCollapsed {
                                    ForEach(items, id: \.id) { comp in
                                        PaletteItemView(comp: comp)
                                    }
                                }
                            } header: {
                                categoryHeader(category, count: items.count,
                                               isCollapsed: isCollapsed, accent: false)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.96))
    }

    @ViewBuilder
    private func categoryHeader(_ name: String, count: Int, isCollapsed: Bool, accent: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isCollapsed { collapsedCategories.remove(name) }
                else { collapsedCategories.insert(name) }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundColor(accent ? .blue.opacity(0.7) : .secondary)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                if accent {
                    Image(systemName: "star.fill")
                        .font(.system(size: 7))
                        .foregroundColor(.blue.opacity(0.7))
                }
                Text(name.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(accent ? .blue.opacity(0.8) : .secondary)
                Spacer()
                if isCollapsed {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func filteredItems(in category: String) -> [Component] {
        Components.list
            .filter { $0.category == category }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private func filteredUserRacks() -> [UserRack] {
        appState.userRacks.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Palette Item (draggable)
struct PaletteItemView: View {
    let comp: Component
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            // Category stripe dot
            Circle()
                .fill(Color.categoryColor(comp.category))
                .frame(width: 7, height: 7)

            ComponentIcon(name: comp.iconName)
                .frame(width: 14, height: 14)
                .foregroundColor(.primary.opacity(0.6))

            Text(comp.name)
                .font(.system(size: 11))
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isHovered ? Color.blue.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        // Double-click adds at a default position
        .onTapGesture(count: 2) {
            let offset = CGFloat(appState.instances.count % 8) * 20
            appState.addInstance(type: comp.id, position: CGPoint(x: 60 + offset, y: 80 + offset))
        }
        // Drag to canvas
        .onDrag {
            NSItemProvider(object: comp.id as NSString)
        }
        .help("\(comp.name) — \(comp.desc)")
    }
}

// MARK: - User Rack Palette Item (draggable, with right-click delete)
struct UserRackPaletteItemView: View {
    let rack: UserRack
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.7))
                .frame(width: 7, height: 7)

            Image(systemName: "server.rack")
                .frame(width: 14, height: 14)
                .foregroundColor(.primary.opacity(0.6))

            Text(rack.name)
                .font(.system(size: 11))
                .lineLimit(1)

            Spacer()

            if let comp = Components.all[rack.rackType] {
                Text("\(comp.rackUnits)U")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isHovered ? Color.blue.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture(count: 2) {
            let offset = CGFloat(appState.instances.count % 8) * 20
            appState.placeUserRack(rack, at: CGPoint(x: 60 + offset, y: 80 + offset))
        }
        .onDrag {
            NSItemProvider(object: "userrack:\(rack.id.uuidString)" as NSString)
        }
        .contextMenu {
            Button(role: .destructive) {
                appState.deleteUserRack(id: rack.id)
            } label: {
                Label("Delete from My Equipment", systemImage: "trash")
            }
        }
        .help(rack.name)
    }
}
