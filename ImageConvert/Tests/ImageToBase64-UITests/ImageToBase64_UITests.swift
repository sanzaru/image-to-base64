//
//  ImageToBase64_UITests.swift
//  ImageToBase64-UITests
//
//  Created by Martin Albrecht on 08.07.23.
//  Copyright © 2023 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import XCTest

final class ImageToBase64_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartView() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.images["DropIcon"].exists)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
