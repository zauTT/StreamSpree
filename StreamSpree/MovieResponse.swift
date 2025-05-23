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

struct Movie: Decodable {
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
}
