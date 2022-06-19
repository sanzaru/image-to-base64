//
//  NSImage.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 24.04.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
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
}
