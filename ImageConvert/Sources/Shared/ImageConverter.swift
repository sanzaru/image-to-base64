//
//  ImageConverter.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 18.06.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Foundation
import SVGKit

class ImageConverter {
    var isSVG: Bool { fileType == .svg }

    private(set) var image: NSImage?

    private var fileType: FileType = .jpeg
    private var data: Data?

    enum FileType {
        case jpeg, png, svg

        var bitmapImageRep: NSBitmapImageRep.FileType? {
            switch self {
            case .jpeg:
                return NSBitmapImageRep.FileType.jpeg

            case .png:
                return NSBitmapImageRep.FileType.png

            case .svg:
                return nil
            }
        }
    }

    func loadImage(from url: NSURL) throws {
        if url.isSvg {
            data = try Data(contentsOf: url as URL)
            image = SVGKImage(data: data)?.nsImage
            fileType = .svg
        } else {
            data = try Data(contentsOf: url as URL)

            if let data = data {
                image = NSImage(data: data)
            }

            fileType = url.pathExtension == "png" ? .png : .jpeg
        }
    }

    func code(forDataUrl: Bool, type: ImageConverter.FileType) -> String {
        let code = base64String(for: type) ?? ""
        return forDataUrl ? "data:\(prefix(of: type));base64,\(code)" : code
    }

    /// Return base64 string for the image and given type
    /// - Parameter type: The image type to conver to
    /// - Returns: Base64 encoded image data on success or nil on failure
    private func base64String(for type: ImageConverter.FileType) -> String? {
        if type == .svg, fileType == .svg {
            return data?.base64EncodedString()
        }

        guard
            let image = image,
            let bits = image.representations.first as? NSBitmapImageRep,
            let format = type.bitmapImageRep,
            let data = bits.representation(using: format, properties: [:])
            else {
                return nil
        }

        return "\(data.base64EncodedString())"
    }

    private func prefix(of type: ImageConverter.FileType) -> String {
        switch type {
        case .jpeg:
            return "image/jpg"

        case .png:
            return "image/png"

        case .svg:
            return "image/svg+xml"
        }

    }
}
