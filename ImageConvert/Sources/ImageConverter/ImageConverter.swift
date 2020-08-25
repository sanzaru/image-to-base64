//
//  ImageConverter.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 12.09.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa
import SVGKit


final class ImageConverter: NSObject {
    enum FileType {
        case jpeg, png, svg
    }
    
    /// Convert SVG data to NSImage object
    /// - Parameter data: The SVG image data
    /// - Returns: NSImage object
    static func svgToImage(data: Data, w: CGFloat, h: CGFloat) -> NSImage?{
        guard let svg = SVGKImage(data: data) else {
            return nil
        }
        
        return ImageConverter.resizeImage(source: svg.nsImage, width: w, height: h)
    }
    
    static func svgDimensions(from data: Data) -> (CGFloat, CGFloat)? {
        guard let svg = SVGKImage(data: data) else {
            return nil
        }
        
        return (svg.size.width, svg.size.height)
    }
    
    static func resizeImage(source: NSImage, width: CGFloat, height: CGFloat) -> NSImage? {
        let size = CGSize(width: width, height: height)
        let newImage = NSImage(size: size)
        let rectDest = NSMakeRect(0, 0, size.width, size.height)
        let rectSource = NSMakeRect(0, 0, source.size.width, source.size.height)
        
        newImage.lockFocus()
        source.draw(in: rectDest, from: rectSource, operation: NSCompositingOperation.sourceOver, fraction: 1)
        newImage.unlockFocus()
        
        newImage.size = size
        
        return NSImage(data: newImage.tiffRepresentation!)
    }
    
    static func imageFileType(from fileType: ImageConverter.FileType) -> NSBitmapImageRep.FileType? {
        switch fileType {
        case .jpeg:
            return NSBitmapImageRep.FileType.jpeg
            
        case .png:
            return NSBitmapImageRep.FileType.png
            
        case .svg:
            return nil
        }
    }
}


// MARK: - Extension: NSImage
extension NSImage {
    func toBase64String(from type: ImageConverter.FileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let format = ImageConverter.imageFileType(from: type),
            let data = bits.representation(using: format, properties: [:])
            else {
                return nil
        }
        
        return "\(data.base64EncodedString())"
    }
}
