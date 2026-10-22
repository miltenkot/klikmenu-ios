import KlikMenuCore

func emptyMenu(slug: String = "bistro") -> RestaurantMenu {
    RestaurantMenu(
        id: slug, name: slug, slug: slug, description: nil, address: nil,
        phone: nil, currency: "PLN", heroImageURL: nil, categories: []
    )
}
