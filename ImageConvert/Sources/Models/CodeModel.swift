//
//  CodeModel.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 18.12.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

class CodeModel {
    private var rawCode: String
    
    init(code: String) {
        self.rawCode = code
    }
    
    func getCode(forDataUrl: Bool, type: NSBitmapImageRep.FileType) -> String {
        if forDataUrl {
            let prefix = self.getPrefix(type: type)
            return "data:\(prefix);base64,\(rawCode)"
        }
        
        return rawCode
    }
    
    func clear() {
        rawCode = ""
    }
    
    private func getPrefix(type: NSBitmapImageRep.FileType) -> String {
        if type == .jpeg {
            return "image/jpg"
        }
        
        return "image/png"
    }
}
