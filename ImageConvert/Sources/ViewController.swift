//
//  ViewController.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, DragViewDelegate {
    @IBOutlet weak var dragImage: NSImageView!
    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var outputTextField: NSTextView!
    @IBOutlet weak var checkboxDataUrl: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dragView.delegate = self
        outputTextField.isEditable = false
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }

    func dragView(didDragFileWith URL: NSURL) {
        let image = NSImage(byReferencingFile: URL.path!)
        let base64Output = image?.base64String(forDataUrl: checkboxDataUrl.state == .on) ?? ""
        
        copyToClipBoard(textToCopy: base64Output)
        outputTextField.textStorage?.mutableString.setString(base64Output)
        
        dragImage.image = NSImage(named: "ArrowIcon")
        
        statusLabel.stringValue = "The base64 code is copied to your clipboard."
    }
    
    func dragStarted() {
        dragImage.image = NSImage(named: "UploadIcon")
        statusLabel.stringValue = "Drop your image, now"
    }
}

extension NSImage {
    func base64String(forDataUrl: Bool) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: .jpeg, properties: [:])
            else {
                return nil
        }
        
        return !forDataUrl ? "\(data.base64EncodedString())" : "data:image/jpeg;base64,\(data.base64EncodedString())"
    }
}
