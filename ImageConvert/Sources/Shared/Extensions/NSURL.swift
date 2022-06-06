//
//  NSURL.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 05.06.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Foundation

extension NSURL {
    /// Check if given path is a SVG file
    /// - Parameter path: The path to check
    /// - Returns: True if svg extension is found, false if not
    var isSvg: Bool { pathExtension == "svg" } // FIXME: Find better way to identify SVG images
}
