//
//  AppGlobals.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 14.10.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

class AppGlobals: NSObject {
    /// Constant holding the default notification display time
    static let notificationDisplayDuration: Double = 10.0
    
    /// Status label texts
    static let statusLabelTexts = [
        "default": "Drag your image",
        "ondrag": "Release the image",
        "error": "Error processing the image. Drop another one.",
        "processing": "Please wait...",
        "done": "Drag another image"
    ]
    
    
    static func copyToClipboard(content: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(content, forType: .string)
    }
}
