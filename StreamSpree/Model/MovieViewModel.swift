//
//  MovieViewModel.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 23.05.25.
//

import Foundation

class MovieViewModel {
    
    private var movies: [Movie] = []
    private(set) var currentMovie: Movie?
    
    var onUpdate: (() -> Void)?
    
    func fetchRandomTrendingMovie(retryCount: Int = 1) {
        NetworkManager.shared.fetchTrendingmovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.currentMovie = movies.randomElement()
                    self?.onUpdate?()
                case .failure(let error as NSError):
                    if error.code == NSURLErrorNetworkConnectionLost && retryCount > 0 {
                        print("Connection lost, retrying...")
                        self?.fetchRandomTrendingMovie(retryCount: retryCount - 1)
                    } else {
                        print("Failed to fetch movies: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func filterMovies(genre: String?, minRating: Double?) {
        NetworkManager.shared.fetchTrendingmovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let allMovies):
                    var filtered = allMovies
                    
                    if let genre = genre?.lowercased(), let genreId = self?.genreId(for: genre) {
                        filtered = filtered.filter { $0.genreIDs.contains(genreId) }
                    }
                    
                    if let rating = minRating {
                        filtered = filtered.filter { $0.voteAverage >= rating }
                    }
                    
                    if filtered.isEmpty {
                        print("No matching movies for genre: \(genre ?? "-") and rating: \(minRating ?? -1)")
                    }
                    
                    self?.setRandomMovie(from: filtered)
                case .failure(let error):
                    print("Failed to filter movies: \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    private func genreId(for genreName: String) -> Int? {
        let map = [
            "action": 28, "adventure": 12, "animation": 16, "comedy": 35, "crime": 80,
            "documentary": 99, "drama": 18, "family": 10751, "fantasy": 14, "history": 36,
            "horror": 27, "music": 10402, "mystery": 9648, "romance": 10749,
            "science fiction": 878, "tv movie": 10770, "thriller": 53, "war": 10752, "western": 37
        ]
        return map[genreName]
    }
    
    func search(byGenre genre: String) {
        NetworkManager.shared.fetchMovies(byGenre: genre) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    if movies.isEmpty {
                        print("No movies found for genre: \(genre)")
                    }
                    self?.setRandomMovie(from: movies)
                case .failure(let error):
                    print("Failed to fetch movies by genre: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setRandomMovie(from movies: [Movie]) {
        self.movies = movies
        self.currentMovie = movies.randomElement()
        self.onUpdate?()
    }
    
    var title: String {
        currentMovie?.title ?? "No title"
    }
    
    var overwiev: String {
        currentMovie?.overview ?? "No description available"
    }
    
    var ratings: String {
        guard let vote = currentMovie?.voteAverage else { return "N/A"}
        return "★ \(String(format: "%.1f", vote))"
    }
    
    var genre: String {
        guard let genreId = currentMovie?.genreIDs.first else { return "Unknnown Genre" }
        return genreName(for: genreId)
    }
    
    private func genreName(for id: Int) -> String {
        let map = [
            28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy", 80: "Crime",
            99: "Documentary", 18: "Drama", 10751: "Family", 14: "Fantasy", 36: "History",
            27: "Horror", 10402: "Music", 9648: "Mystery", 10749: "Romance",
            878: "Sci-Fi", 10770: "TV Movie", 53: "Thriller", 10752: "War", 37: "Western"
        ]
        return map[id] ?? "Unknnown Genre"
    }
    
    var posterURL: URL? {
        guard let path = currentMovie?.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
