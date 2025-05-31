//
//  StreamSpreeUITestsLaunchTests.swift
//  StreamSpreeUITests
//
//  Created by Giorgi Zautashvili on 23.05.25.
//
import XCTest

final class StreamSpreeUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchDisplaysInitialMovie() {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        let titleLabel = app.staticTexts["movieTitleLabel"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 3), "Movie title label should be visible on launch.")

        let shuffleButton = app.buttons["shuffleButton"]
        XCTAssertTrue(shuffleButton.exists, "Shuffle button should be visible on launch.")

        let watchlistButton = app.buttons["watchlistTabButton"]
        XCTAssertTrue(watchlistButton.exists, "Watchlist button should be visible on launch.")
    }
}
