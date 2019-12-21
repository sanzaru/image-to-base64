//
//  ImageConverter.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 12.09.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class ImageConverter: NSObject {
    static func getBase64String(from: NSImage, format: NSBitmapImageRep.FileType = .jpeg, forDataUrl: Bool) -> String? {
        guard let base64Output = from.toBase64String(imageFormat: format) else {
            return nil
        }
        
        return base64Output
    }
}

// MARK: - Extension: NSImage
extension NSImage {
    func toBase64String(imageFormat: NSBitmapImageRep.FileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: imageFormat, properties: [:])
            else {
                return nil
        }
        
        return "\(data.base64EncodedString())"
    }
}
