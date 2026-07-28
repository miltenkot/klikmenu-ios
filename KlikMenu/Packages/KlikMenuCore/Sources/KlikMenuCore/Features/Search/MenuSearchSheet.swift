import SwiftUI

public struct MenuSearchSheet: View {
    public let menu: RestaurantMenu
    @Environment(\.dismiss) private var dismiss
    @State private var filters = MenuFilters()
    @State private var results: [FilteredMenuCategory] = []

    public init(menu: RestaurantMenu) {
        self.menu = menu
    }

    private var resultCount: Int {
        results.reduce(0) { $0 + $1.items.count }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: $filters.dietaryType) {
                        Text("Wszystkie", bundle: #bundle).tag(DietaryFilter.all)
                        Text("Wegetariańskie", bundle: #bundle).tag(DietaryFilter.vegetarian)
                        Text("Wegańskie", bundle: #bundle).tag(DietaryFilter.vegan)
                    } label: {
                        Text("Dieta", bundle: #bundle)
                    }
                    .accessibilityLabel(Text("Filtr dietetyczny", bundle: #bundle))

                    Picker(selection: $filters.categoryID) {
                        Text("Wszystkie", bundle: #bundle).tag(Optional<String>.none)
                        ForEach(menu.categories) { category in
                            Text(category.name).tag(Optional(category.id))
                        }
                    } label: {
                        Text("Kategoria", bundle: #bundle)
                    }

                    if let category = menu.categories.first(where: { $0.id == filters.categoryID }),
                        !category.subcategories.isEmpty
                    {
                        Picker(selection: $filters.subcategoryID) {
                            Text("Wszystkie", bundle: #bundle).tag(Optional<String>.none)
                            ForEach(category.subcategories) { subcategory in
                                Text(subcategory.name).tag(Optional(subcategory.id))
                            }
                        } label: {
                            Text("Subkategoria", bundle: #bundle)
                        }
                    }
                } header: {
                    Text("Filtry", bundle: #bundle)
                }

                if results.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label {
                                Text("Brak wyników", bundle: #bundle)
                            } icon: {
                                Image(systemName: "magnifyingglass")
                            }
                        } description: {
                            Text("Spróbuj zmienić frazę lub filtry.", bundle: #bundle)
                        }
                        .listRowBackground(Color.clear)
                    } header: {
                        Text("Wyniki: \(resultCount)", bundle: #bundle)
                    }
                } else {
                    ForEach(results) { group in
                        Section {
                            ForEach(group.items) { entry in
                                SearchResultRow(item: entry.item, currency: menu.currency)
                            }
                        } header: {
                            Text("\(group.category.name) · \(group.items.count)", bundle: #bundle)
                        }
                    }
                }
            }
            .navigationTitle(Text("Szukaj w menu", bundle: #bundle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(iOS)
            .searchable(
                text: $filters.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Szukaj po nazwie dania", bundle: #bundle)
            )
            #else
            .searchable(
                text: $filters.query,
                prompt: Text("Szukaj po nazwie dania", bundle: #bundle)
            )
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringResource("Gotowe", bundle: #bundle), action: dismiss.callAsFunction)
                        .frame(minHeight: 44)
                }
            }
            .onAppear(perform: refreshResults)
            .onChange(of: filters) { _, _ in
                refreshResults()
            }
            .onChange(of: filters.categoryID) { _, _ in
                filters.subcategoryID = nil
            }
            .accessibilityLabel(Text("Wyniki wyszukiwania: \(resultCount)", bundle: #bundle))
        }
        .presentationDetents([.large])
    }

    private func refreshResults() {
        results = filterMenuCategories(menu.categories, filters: filters)
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
                if let dietary = item.dietaryType.displayLabel {
                    Text(dietary)
                        .font(.caption)
                        .foregroundStyle(Color.klikAccent)
                }
            }
            Spacer()
            priceText
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var priceText: some View {
        if let value = Decimal(string: item.price, locale: Locale(identifier: "en_US_POSIX")) {
            Text(value, format: .currency(code: currency))
        } else {
            Text(verbatim: "\(item.price) \(currency)")
        }
    }
}
