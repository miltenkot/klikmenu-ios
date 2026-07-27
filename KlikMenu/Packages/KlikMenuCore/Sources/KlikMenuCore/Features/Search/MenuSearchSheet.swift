import SwiftUI

public struct MenuSearchSheet: View {
    public let menu: RestaurantMenu
    @Environment(\.dismiss) private var dismiss
    @State private var filters = MenuFilters()

    public init(menu: RestaurantMenu) {
        self.menu = menu
    }

    private var results: [FilteredMenuCategory] {
        filterMenuCategories(menu.categories, filters: filters)
    }

    private var resultCount: Int {
        results.reduce(0) { $0 + $1.items.count }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Filtry") {
                    Picker("Dieta", selection: $filters.dietaryType) {
                        Text("Wszystkie").tag(DietaryFilter.all)
                        Text("Wegetariańskie").tag(DietaryFilter.vegetarian)
                        Text("Wegańskie").tag(DietaryFilter.vegan)
                    }
                    .accessibilityLabel("Filtr dietetyczny")

                    Picker("Kategoria", selection: $filters.categoryID) {
                        Text("Wszystkie").tag(Optional<String>.none)
                        ForEach(menu.categories) { category in
                            Text(category.name).tag(Optional(category.id))
                        }
                    }

                    if let category = menu.categories.first(where: { $0.id == filters.categoryID }),
                        !category.subcategories.isEmpty
                    {
                        Picker("Subkategoria", selection: $filters.subcategoryID) {
                            Text("Wszystkie").tag(Optional<String>.none)
                            ForEach(category.subcategories) { subcategory in
                                Text(subcategory.name).tag(Optional(subcategory.id))
                            }
                        }
                    }
                }

                Section {
                    if results.isEmpty {
                        ContentUnavailableView(
                            "Brak wyników",
                            systemImage: "magnifyingglass",
                            description: Text("Spróbuj zmienić frazę lub filtry.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(results) { group in
                            Section(group.category.name) {
                                ForEach(group.items) { entry in
                                    SearchResultRow(item: entry.item, currency: menu.currency)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Wyniki: \(resultCount)")
                }
            }
            .navigationTitle("Szukaj w menu")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(
                text: $filters.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Szukaj po nazwie dania"
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { dismiss() }
                        .frame(minHeight: 44)
                }
            }
            .onChange(of: filters.categoryID) { _, _ in
                filters.subcategoryID = nil
            }
        }
        .presentationDetents([.large])
    }
}

private struct SearchResultRow: View {
    let item: MenuItem
    let currency: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                if let dietary = item.dietaryType.searchLabel {
                    Text(dietary)
                        .font(.caption)
                        .foregroundStyle(Color.klikAccent)
                }
            }
            Spacer()
            Text(PriceFormatter.string(price: item.price, currency: currency))
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

extension DietaryType {
    fileprivate var searchLabel: String? {
        switch self {
        case .none: nil
        case .vegetarian: "Wegetariańskie"
        case .vegan: "Wegańskie"
        }
    }
}
