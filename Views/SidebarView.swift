// Views/SidebarView.swift — Component palette sidebar with search and drag support

import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var collapsedCategories: Set<String> = []

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
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if isCollapsed {
                                            collapsedCategories.remove(category)
                                        } else {
                                            collapsedCategories.insert(category)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 7, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                                        Text(category.uppercased())
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if isCollapsed {
                                            Text("\(items.count)")
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
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.96))
    }

    private func filteredItems(in category: String) -> [Component] {
        Components.list
            .filter { $0.category == category }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
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
