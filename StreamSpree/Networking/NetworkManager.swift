//
//  NetworkManager.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 23.05.25.
//


import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "88a76539c103d283f84088bdc0534132"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private init() {}
    
    func fetchTrendingmovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/trending/movie/week?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}

extension NetworkManager {
    private var genreMap: [String: Int] {
        return [
            "action": 28,
            "adventure": 12,
            "animation": 16,
            "comedy": 35,
            "crime": 80,
            "documentary": 99,
            "drama": 18,
            "family": 10751,
            "fantasy": 14,
            "history": 36,
            "horror": 27,
            "music": 10402,
            "mystery": 9648,
            "romance": 10749,
            "science fiction": 878,
            "tv movie": 10770,
            "thriller": 53,
            "war": 10752,
            "western": 37
        ]
    }
    
    func fetchMovies(byGenre genreName: String, completion: @escaping (Result<[Movie], Error>) -> Void){
        guard let genreId = genreMap[genreName.lowercased()] else {
            completion(.failure(NetworkError.invalidGenre))
            return
        }
        
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&with_genres=\(genreId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension NetworkError {
    static let invalidGenre = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid genre"])
}
