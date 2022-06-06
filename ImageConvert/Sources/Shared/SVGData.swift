//
//  SVGData.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 05.06.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa
import SVGKit

struct SVGData {
    var size: CGSize { return svg.size }
    var base64EncodedString: String { data.base64EncodedString() }
    var nsImage: NSImage? { svg.nsImage }

    enum SVGError: Error {
        case invalidSVGData
    }

    private let svg: SVGKImage
    private let data: Data

    init(with url: NSURL) throws {
        data = try Data(contentsOf: url as URL)
        guard let image = SVGKImage(data: data) else {
            throw(SVGError.invalidSVGData)
        }
        svg = image
    }

    /// Convert SVG data to NSImage object
    /// - Parameter size: The size of the SVG
    /// - Returns: NSImage object
    func nsImage(size: CGSize) -> NSImage? {
        nsImage?.resized(to: size)
    }
}
