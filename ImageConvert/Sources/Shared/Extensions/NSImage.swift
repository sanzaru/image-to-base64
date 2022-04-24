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
    ///   - width: Width to resize to
    ///   - height: Height to resize to
    /// - Returns: The resized image on success or nil on failure
    func resized(width: CGFloat, height: CGFloat) -> NSImage? {
        let size = CGSize(width: width, height: height)
        let newImage = NSImage(size: size)
        let rectDest = NSMakeRect(0, 0, size.width, size.height)
        let rectSource = NSMakeRect(0, 0, self.size.width, self.size.height)
        
        newImage.lockFocus()
        self.draw(in: rectDest, from: rectSource, operation: NSCompositingOperation.sourceOver, fraction: 1)
        newImage.unlockFocus()
        
        newImage.size = size
        
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
