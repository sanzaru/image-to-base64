//
//  AppGlobals.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 14.10.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class AppGlobals: NSObject {
    
    // MARK: - Status label texts
    static let statusLabelTexts = [
        "default": "Drag your image here",
        "ondrag": "Release the image",
        "error": "There was an error processing the image.",
        "processing": "Processing",
        "done": "You may drag another image, now."
    ]
}
