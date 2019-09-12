//
//  ImageConverter.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 12.09.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class ImageConverter: NSObject {
    static func getBase64String(from: NSImage, format: NSBitmapImageRep.FileType = .png, forDataUrl: Bool) -> String? {
        guard let base64Output = from.toBase64String(forDataUrl: forDataUrl, imageFormat: format) else {
            return nil
        }
        
        return base64Output
    }
}

// MARK: - Extension: NSImage
extension NSImage {
    func toBase64String(forDataUrl: Bool, imageFormat: NSBitmapImageRep.FileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: imageFormat, properties: [:]),
            let format = imageFormat == .jpeg ? "jpg" : "png"
            else {
                return nil
        }
        
        return !forDataUrl ? "\(data.base64EncodedString())" : "data:image/\(format);base64,\(data.base64EncodedString())"
    }
}
