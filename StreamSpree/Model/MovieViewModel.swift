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
    
    func fetchRandomTrendingMovie() {
        NetworkManager.shared.fetchTrendingmovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.currentMovie = movies.randomElement()
                    self?.onUpdate?()
                case .failure(let error):
                    print("Failed to fetch movies: \(error.localizedDescription)")
                }
            }
        }
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
    
    var posterURL: URL? {
        guard let path = currentMovie?.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
