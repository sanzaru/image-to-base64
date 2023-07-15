//
//  ImageToBase64_Tests.swift
//  ImageToBase64-Tests
//
//  Created by Martin Albrecht on 09.07.23.
//  Copyright © 2023 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import XCTest

final class ImageToBase64_Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppGlobals() throws {
        XCTAssert(!AppGlobals.kNotification.rawValue.isEmpty)
        XCTAssert(!AppGlobals.notificationDisplayDuration.isNaN)
        XCTAssert(AppGlobals.notificationDisplayDuration >= 0)
    }

    func testStringExtension() throws {
        let testString = "Hello Test"
        testString.copyToClipboard()

        XCTAssertEqual(testString, NSPasteboard.general.string(forType: .string))
    }

    func testImageconverterBase64() throws {
        let converter = ImageConverter()

        XCTAssertNotNil(TestMockupData.testImage, "Test image is nil")

        let imageData = TestMockupData.testImage.tiffRepresentation
        XCTAssertNotNil(imageData)

        converter.loadImage(from: imageData!, fileType: .jpeg)
        XCTAssertNotNil(converter.image, "Converter image is empty")

        // JPEG
        var code = converter.code(forDataUrl: false, type: .jpeg)
        XCTAssert(!code.isEmpty, "Base64 code is empty")
        XCTAssertEqual(code, TestMockupData.mockupTestJPEGBase64, "Code not matching mockup code")

        code = converter.code(forDataUrl: true, type: .jpeg)
        XCTAssert(!code.isEmpty, "Base64 code is empty")
        XCTAssertEqual(code, TestMockupData.MockupPrefixes.jpeg.rawValue + TestMockupData.mockupTestJPEGBase64, "Code not matching mockup code")

        // PNG
        code = converter.code(forDataUrl: false, type: .png)
        XCTAssert(!code.isEmpty, "Base64 code is empty")
        XCTAssertEqual(code, TestMockupData.mockupTestPNGBase64, "Code not matching mockup code")

        code = converter.code(forDataUrl: true, type: .png)
        XCTAssert(!code.isEmpty, "Base64 code is empty")
        XCTAssertEqual(code, TestMockupData.MockupPrefixes.png.rawValue + TestMockupData.mockupTestPNGBase64, "Code not matching mockup code")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//
//        }
//    }
}
