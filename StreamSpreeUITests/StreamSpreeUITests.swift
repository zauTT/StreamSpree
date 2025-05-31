//
//  StreamSpreeUITests.swift
//  StreamSpreeUITests
//
//  Created by Giorgi Zautashvili on 23.05.25.
//

import XCTest

final class StreamSpreeUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testShuffleButtonChangesMovie() {
        let titleLabel = app.staticTexts.matching(identifier: "movieTitleLabel").firstMatch
        let originalTitle = titleLabel.label
        
        let shuffleButton = app.buttons["Shuffle 🎲"]
        XCTAssertTrue(shuffleButton.exists)
        shuffleButton.tap()
        
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label != %@", originalTitle), object: titleLabel)
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAddToWatchlistButton() {
        let watchlistButton = app.buttons["Add to Watchlist ❤️"]
        XCTAssertTrue(watchlistButton.exists)
        watchlistButton.tap()
    }
    
    func testGoToWatchlist() {
        let watchlistNavButton = app.navigationBars.buttons["Watchlist >"]
        XCTAssertTrue(watchlistNavButton.exists)
        watchlistNavButton.tap()
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 2.0))
    }
    
    func testNoMoviesMatchFilterWithRating() {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        let filterButton = app.buttons["FilterButton"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2), "Filter button does not exist.")
        filterButton.tap()

        let picker = app.pickers["genrePicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 2), "Genre picker not found.")

        let romancePickerWheel = picker.pickerWheels.element(boundBy: 0)
        XCTAssertTrue(romancePickerWheel.exists, "Genre picker wheel not found.")
        romancePickerWheel.adjust(toPickerWheelValue: "Romance")

        let ratingSlider = app.sliders["ratingSlider"]
        XCTAssertTrue(ratingSlider.exists, "Rating slider not found.")

        ratingSlider.adjust(toNormalizedSliderPosition: 1.0)

        let applyButton = app.buttons["applyFilterButton"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 2), "Apply button not found.")
        applyButton.tap()

        let toast = app.staticTexts["toastLabel"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5), "Toast did not appear.")
        XCTAssertEqual(toast.label, "No movies matched your filters.")
    }
    
    func testPreventDuplicateWatchlistEntry() {
        let app = XCUIApplication()
        app.launch()

        let movieTitleLabel = app.staticTexts["movieTitleLabel"]
        XCTAssertTrue(movieTitleLabel.waitForExistence(timeout: 2), "Movie title label not found.")
        let movieTitle = movieTitleLabel.label

        let addButton = app.buttons["addToWatchlistButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add to watchlist button not found.")
        addButton.tap()
        addButton.tap()

        let watchlistButton = app.buttons["watchlistTabButton"]
        XCTAssertTrue(watchlistButton.waitForExistence(timeout: 2), "Watchlist button not found.")
        watchlistButton.tap()

        let matchingMovies = app.staticTexts.matching(identifier: "watchlistMovieTitleLabel_\(movieTitle)")
        XCTAssertEqual(matchingMovies.count, 1, "Duplicate movie found in watchlist.")
    }
    
    func testDeleteMovieFromWatchlist() {
        let app = XCUIApplication()
        app.launch()

        let movieTitle = app.staticTexts["movieTitleLabel"].label
        app.buttons["addToWatchlistButton"].tap()
        app.buttons["watchlistTabButton"].tap()

        let movieCell = app.staticTexts["watchlistMovieTitleLabel_\(movieTitle)"]
        XCTAssertTrue(movieCell.exists, "Movie not in Watchlist.")

        movieCell.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertFalse(movieCell.exists, "Movie was not deleted from Watchlist.")
    }
    
    func testShuffleChangesMovie() {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()
        sleep(1)

        let titleLabel = app.staticTexts["movieTitleLabel"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 2), "Movie title label does not exist.")
        let initialTitle = titleLabel.label

        let shuffleButton = app.buttons["shuffleButton"]
        XCTAssertTrue(shuffleButton.exists, "Shuffle button not found.")

        var didChange = false
        for _ in 0..<5 {
            shuffleButton.tap()
            sleep(1)

            if titleLabel.label != initialTitle {
                didChange = true
                break
            }
        }

        XCTAssertTrue(didChange, "Movie title did not change after multiple shuffles.")
    }
    
}
