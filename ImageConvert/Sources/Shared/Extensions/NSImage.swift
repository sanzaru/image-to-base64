//
//  NSImage.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 24.04.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

extension NSImage {
    /// Resize image to given dimensions
    /// - Parameters:
    ///   - to: CGSize with the desired size
    /// - Returns: The resized image on success or nil on failure
    func resized(to newSize: CGSize) -> NSImage? {
        let newImage = NSImage(size: size)
        let rectSource = NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let rectDest = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        newImage.lockFocus()
        self.draw(in: rectDest, from: rectSource, operation: NSCompositingOperation.sourceOver, fraction: 1)
        newImage.unlockFocus()

        newImage.size = newSize

        return NSImage(data: newImage.tiffRepresentation!)
    }

    /// Return base64 string for the image and given type
    /// - Parameter type: The image type to conver to
    /// - Returns: Base64 encoded image data on success or nil on failure
    func base64String(from type: ImageConverterFileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let format = type.fileType,
            let data = bits.representation(using: format, properties: [:])
            else {
                return nil
        }

        return "\(data.base64EncodedString())"
    }
}
