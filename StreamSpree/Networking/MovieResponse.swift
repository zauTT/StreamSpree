//
//  MovieResponse.swift
//  StreamSpree
//
//  Created by Giorgi Zautashvili on 23.05.25.
//


import Foundation

struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Codable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let genreIDs: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case genreIDs = "genre_ids"
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Movie {
    var genreNames: [String] {
        let genreDictionary: [Int: String] = [
            28: "Action",
            12: "Adventure",
            16: "Animation",
            35: "Comedy",
        ]
        return genreIDs.compactMap { genreDictionary[$0] }
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
