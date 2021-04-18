//
//  ClipboardHelper.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 13.04.21.
//  Copyright © 2021 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
import Cocoa

struct ClipboardHelper {
    static func copy(from content: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(content, forType: .string)
    }
}
