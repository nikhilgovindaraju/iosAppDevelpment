
import Foundation

class FavoritesManager: ObservableObject {
    @Published var favorites: [String] = []
    private let favoritesKey = "favoritesCities"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favorites = data
        }
    }
    
    func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }
    
    func addFavorite(_ city: String) {
        if !favorites.contains(city) {
            favorites.append(city)
            saveFavorites()
        }
    }
    
    func removeFavorite(_ city: String) {
        if let index = favorites.firstIndex(of: city) {
            favorites.remove(at: index)
            saveFavorites()
        }
    }
    
    func isFavorite(_ city: String) -> Bool {
        return favorites.contains(city)
    }
}
