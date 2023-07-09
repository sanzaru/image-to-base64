//
//  ImageToBase64_UITestsLaunchTests.swift
//  ImageToBase64-UITests
//
//  Created by Martin Albrecht on 08.07.23.
//  Copyright © 2023 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import XCTest

final class ImageToBase64_UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
