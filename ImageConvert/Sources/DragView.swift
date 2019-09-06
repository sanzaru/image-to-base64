//
//  DragView.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//

import Cocoa

protocol DragViewDelegate {
    func dragStarted()
    func dragProcessing()
    func dragViewEnded(didDragFileWith URL: NSURL)
}

class DragView: NSView {
    // MARK: - Properties
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    let allowedFileExtensions = ["jpg", "jpeg", "bmp", "png", "gif"]
    
    var fileExtensionOkay = false
    var delegate: DragViewDelegate?
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    
    // MARK: - Dragging
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkFileExtension(drag: sender) {
            fileExtensionOkay = true
            delegate?.dragStarted()
            return .copy
        } else {
            fileExtensionOkay = false
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileExtensionOkay {
            return .copy
        } else {
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        delegate?.dragProcessing()
        
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let imagePath = board[0] as? String {
            delegate?.dragViewEnded(didDragFileWith: NSURL(fileURLWithPath: imagePath))
            return true
        }
        
        return false
    }
    
    // MARK: - Private methods
    private func checkFileExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            
            if let fileExtension = url.pathExtension?.lowercased() {
                return allowedFileExtensions.contains(fileExtension)
            }
        }
        
        return false
    }
}
