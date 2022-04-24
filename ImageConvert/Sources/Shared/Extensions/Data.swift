//
//  Data.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 24.04.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Foundation
import SVGKit

extension Data {
    /// Try to fetch SVG image dimensions from data
    var svgDimensions: (CGFloat, CGFloat)? {
        guard let svg = SVGKImage(data: self) else {
            return nil
        }
        
        return (svg.size.width, svg.size.height)
    }
    
    /// Convert SVG data to NSImage object
    /// - Parameter data: The SVG image data
    /// - Returns: NSImage object
    func svgToImage(w: CGFloat, h: CGFloat) -> NSImage?{
        guard let svg = SVGKImage(data: self) else {
            return nil
        }
        
        return svg.nsImage.resized(width: w, height: h)
    }
}
