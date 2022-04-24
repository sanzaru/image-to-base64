//
//  DragView.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

protocol DragViewDelegate {
    func dragStarted()
    func dragExit()
    func dragProcessing()
    func dragViewEnded(didDragFileWith URL: NSURL)
}

class DragView: NSView {
    // MARK: - Properties
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    let allowedFileExtensions = ["jpg", "jpeg", "bmp", "png", "gif", "heic", "svg"]
    
    var fileExtensionOkay = false
    var delegate: DragViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // MARK: - Dragging overrides
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileExtensionAllowed(from: sender) {
            fileExtensionOkay = true
            delegate?.dragStarted()
            return .copy
        } else {
            fileExtensionOkay = false
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileExtensionOkay ? .copy : []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        delegate?.dragExit()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        delegate?.dragProcessing()
        
        if let url = fileUrl(from: sender) {
            delegate?.dragViewEnded(didDragFileWith: url)
            return true
        }
        
        return false
    }
    
    // MARK: - Private methods
    private func setup() {
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
        
        let mainView = NSView(frame: frame)
        mainView.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        addSubview(mainView)
    }
    
    private func fileUrl(from info: NSDraggingInfo) -> NSURL? {
        if let board = info.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let path = board[0] as? String {
            return NSURL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    private func fileExtensionAllowed(from info: NSDraggingInfo) -> Bool {
        guard let url = fileUrl(from: info), let fileExtension = url.pathExtension?.lowercased() else {
            return false
        }
        
        return allowedFileExtensions.contains(fileExtension)
    }
}
