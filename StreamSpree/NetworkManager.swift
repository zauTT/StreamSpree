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
