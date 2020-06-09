//
//  CodeModel.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 18.12.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class CodeModel {
    private var rawBase64Code: String
    
    init(code: String) {
        self.rawBase64Code = code
    }
    
    func getCode(forDataUrl: Bool, type: ImageConverter.FileType) -> String {
        if forDataUrl {
            let prefix = self.getPrefix(type: type)
            return "data:\(prefix);base64,\(rawBase64Code)"
        }
        
        return rawBase64Code
    }
    
    func clear() {
        rawBase64Code = ""
    }
    
    private func getPrefix(type: ImageConverter.FileType) -> String {
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
