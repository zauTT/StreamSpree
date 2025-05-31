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
    
    var selectedGenre: String? = nil
    var minRating: Double? = nil
    
    var onUpdate: (() -> Void)?
    
    var onNoResults: (() -> Void)?
    
    /// Test initializer
    init(testMovies: [Movie]) {
        self.movies = testMovies
        self.currentMovie = testMovies.first
    }

    /// Default initializer
    init() {}

    /// support shuffle in tests
    func shuffleMovie() {
        guard !movies.isEmpty else { return }
        var newMovie: Movie?
        repeat {
            newMovie = movies.randomElement()
        } while newMovie?.id == currentMovie?.id && movies.count > 1
        currentMovie = newMovie
    }
    
    func applyFilters(to movies: [Movie], genre: String?, minRating: Double?) -> [Movie] {
        return movies.filter { movie in
            let genreMatches: Bool = {
                guard let selectedGenre = genre?.lowercased(),
                      let genreId = self.genreId(for: selectedGenre) else { return true }
                return movie.genreIDs.contains(genreId)
            }()
            
            let ratingMatches = minRating == nil || movie.voteAverage >= minRating!
            
            return genreMatches && ratingMatches
        }
    }
    
    func fetchRandomTrendingMovie(retryCount: Int = 1) {
        NetworkManager.shared.fetchTrendingmovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let allMovies):
                    self.movies = allMovies
                    let filtered = self.movies.filter { movie in
                        let genreMatches: Bool = {
                            guard let selectedGenre = self.selectedGenre?.lowercased(),
                                  let genreId = self.genreId(for: selectedGenre) else { return true }
                            return movie.genreIDs.contains(genreId)
                        }()
                        
                        let ratingMatches = self.minRating == nil || movie.voteAverage >= self.minRating!
                        
                        return genreMatches && ratingMatches
                    }
                    
                    guard let movie = filtered.randomElement() else {
                        print("No movies matched the filters.")
                        self.onNoResults?()
                        return
                    }
                    
                    self.currentMovie = movie
                    self.onUpdate?()
                    
                case .failure(let error):
                    print("Failed to fetch movies: \(error.localizedDescription)")
                    if retryCount > 0 {
                        self.fetchRandomTrendingMovie(retryCount: retryCount - 1)
                    }
                }
            }
        }
    }
    
    func filterMovies(genre: String?, minRating: Double?) {
        self.selectedGenre = genre == "Any" ? nil : genre
        self.minRating = minRating
        fetchRandomTrendingMovie()
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
