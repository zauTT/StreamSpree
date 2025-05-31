//
//  StreamSpreeTests.swift
//  StreamSpreeTests
//
//  Created by Giorgi Zautashvili on 23.05.25.
//

import XCTest
@testable import StreamSpree

final class MovieViewModelTests: XCTestCase {

    func testShuffleChangesCurrentMovie() {
        let movies = [
            Movie(id: 1, title: "A", overview: "", posterPath: nil, voteAverage: 7.0, genreIDs: [28]),
            Movie(id: 2, title: "B", overview: "", posterPath: nil, voteAverage: 6.5, genreIDs: [35]),
            Movie(id: 3, title: "C", overview: "", posterPath: nil, voteAverage: 8.0, genreIDs: [18])
        ]

        let viewModel = MovieViewModel(testMovies: movies)
        let initial = viewModel.currentMovie?.id

        var didChange = false
        for _ in 0..<10 {
            viewModel.shuffleMovie()
            if viewModel.currentMovie?.id != initial {
                didChange = true
                break
            }
        }
        XCTAssertTrue(didChange, "Shuffle did not change the current movie after multiple attempts.")
    }
    
    func testApplyFiltersWithNoGenreOrRatingReturnsAllMovies() {
        let movies = [
            Movie(id: 1, title: "A", overview: "", posterPath: nil, voteAverage: 8.0, genreIDs: [28]),
            Movie(id: 2, title: "B", overview: "", posterPath: nil, voteAverage: 6.0, genreIDs: [35])
        ]
        
        let viewModel = MovieViewModel(testMovies: movies)
        
        let filtered = viewModel.applyFilters(to: movies, genre: nil, minRating: nil)
        
        XCTAssertEqual(filtered.count, 2)
    }
    
    func testApplyFiltersReturnsCorrectMovies() {
        let movies = [
            Movie(id: 1, title: "Action Movie", overview: "", posterPath: nil, voteAverage: 8.2, genreIDs: [28]),
            Movie(id: 2, title: "Comedy Movie", overview: "", posterPath: nil, voteAverage: 7.1, genreIDs: [35]),
            Movie(id: 3, title: "Low Rated Action", overview: "", posterPath: nil, voteAverage: 5.5, genreIDs: [28])
        ]
        
        let viewModel = MovieViewModel(testMovies: movies)
        
        let filtered = viewModel.applyFilters(to: movies, genre: "Action", minRating: 7.0)
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Action Movie")
    }
}
