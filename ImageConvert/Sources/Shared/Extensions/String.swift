//
//  String.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 24.04.22.
//  Copyright © 2022 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

extension String {
    func copyToClipboard() {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(self, forType: .string)
    }
}

extension String {
    var localized: String { NSLocalizedString(self, comment: "") }
}
