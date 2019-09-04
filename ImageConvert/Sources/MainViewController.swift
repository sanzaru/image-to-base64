//
//  ViewController.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, DragViewDelegate {
    // MARK: - Properties
    private var image: NSImage?
    
    @IBOutlet weak var dragImage: NSImageView!
    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var outputTextField: NSTextView!
    @IBOutlet weak var checkboxDataUrl: NSButton!
    @IBOutlet weak var selectFileType: NSPopUpButton!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()

        dragView.delegate = self
        outputTextField.isEditable = false
        outputTextField.isHidden = true
        
        selectFileType.action = #selector(selectChanged)
        
        checkboxDataUrl.target = self
        checkboxDataUrl.action = #selector(checkboxClicked)
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    @objc func selectChanged() {
        if self.image != nil {
            if let content = getBase64() {
                setTextfieldContent(content: content)
            }
        }
    }
    
    @objc func checkboxClicked() {
        if self.image != nil {
            if let content = getBase64() {
                setTextfieldContent(content: content)
            }
        }
        
        selectFileType.isEnabled = checkboxDataUrl.state == .on
    }

    // MARK: - DragViewDelegate
    func dragViewEnded(didDragFileWith URL: NSURL) {
        if let image = NSImage(byReferencingFile: URL.path!) {
            self.image = image
            setTextfieldContent(content: getBase64() ?? "")
            
            dragImage.image = image
            statusLabel.stringValue = "The base64 code is copied to your clipboard.\nYou may drag another image, now."
        } else {
            dragImage.image = NSImage(named: "ErrorIcon")
            clearTextfieldContent()
            statusLabel.stringValue = "There was an error processing the image."
        }
    }
    
    func dragStarted() {
        dragImage.image = NSImage(named: "UploadIcon")
        statusLabel.stringValue = "Release the image"
    }
    
    func dragProcessing() {
        clearTextfieldContent()
        statusLabel.stringValue = "Processing..."
    }
    
    // MARK: - Private methods
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    private func clearTextfieldContent() {
        outputTextField.textStorage?.mutableString.setString("")
    }
    
    private func setTextfieldContent(content: String) {
        copyToClipBoard(textToCopy: content)
        outputTextField.textStorage?.mutableString.setString(content)
        outputTextField.isHidden = false
    }
    
    private func getBase64() -> String? {
        var format: NSBitmapImageRep.FileType = .png
        if selectFileType.titleOfSelectedItem == "image/jpg" {
            format = .jpeg
        }
        
        guard let base64Output = image?.base64String(forDataUrl: checkboxDataUrl.state == .on, imageFormat: format) else {
            return nil
        }
        
        return base64Output
    }
}

// MARK: - Extension: NSImage
extension NSImage {
    func base64String(forDataUrl: Bool, imageFormat: NSBitmapImageRep.FileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: imageFormat, properties: [:])
            else {
                return nil
        }
        
        var format = "png"
        switch imageFormat {
        case .jpeg:
            format = "jpg"
            break
            
        default:
            format = "png"
            break
        }
        
        return !forDataUrl ? "\(data.base64EncodedString())" : "data:image/\(format);base64,\(data.base64EncodedString())"
    }
}
