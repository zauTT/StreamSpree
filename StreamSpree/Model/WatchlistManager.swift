//
//  WatchlistManager.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 27.05.25.
//

import Foundation

class WatchlistManager {
    private let key = "watchlist_movies"
    
    func getWatchlist() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: key),
                let movies = try? JSONDecoder().decode([Movie].self, from: data) else {
            return []
        }
        return movies
    }
    
    func addToWatchlist(_ movie: Movie) {
        var current = getWatchlist()
        guard !current.contains(where: { $0.id == movie.id }) else { return }
        current.append(movie)
        save(current)
    }
    
    func removeFromWatchlist(_ movie: Movie) {
        var current = getWatchlist()
        current.removeAll { $0.id == movie.id }
        save(current)
    }
    
    private func save(_ movies: [Movie]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
}
