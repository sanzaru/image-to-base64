//
//  CodeModel.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 18.12.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

class CodeModel {
    private var rawBase64Code: String

    init(code: String) {
        rawBase64Code = code.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func code(forDataUrl: Bool, type: ImageConverterFileType) -> String {
        return forDataUrl ? "data:\(prefix(of: type));base64,\(rawBase64Code)" : rawBase64Code
    }

    func clear() {
        rawBase64Code = ""
    }

    private func prefix(of type: ImageConverterFileType) -> String {
        switch type {
        case .jpeg:
            return "image/jpg"

        case .png:
            return "image/png"

        case .svg:
            return "image/svg+xml"
        }

    }
}
