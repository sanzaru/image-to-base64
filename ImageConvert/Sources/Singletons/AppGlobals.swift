//
//  AppGlobals.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 14.10.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class AppGlobals: NSObject {
    /// Constant holding the default notification display time
    static let notificationDisplayDuration: Double = 10.0
    
    /// Status label texts
    static let statusLabelTexts = [
        "default": "Drag your image",
        "ondrag": "Release the image",
        "error": "There was an error processing the image.",
        "processing": "Please wait...",
        "done": "Drag another image"
    ]
}
