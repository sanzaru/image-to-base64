//
//  ImageConverterFileType.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 12.09.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//
import Cocoa

enum ImageConverterFileType {
    case jpeg, png, svg

    var fileType: NSBitmapImageRep.FileType? {
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
