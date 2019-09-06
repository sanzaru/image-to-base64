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
    private var base64code: String?
    
    @IBOutlet weak var dragImage: NSImageView!
    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var outputTextField: NSTextView!
    @IBOutlet weak var checkboxDataUrl: NSButton!
    @IBOutlet weak var selectFileType: NSPopUpButton!
    @IBOutlet weak var copyToClipboardButton: NSButton!
    @IBOutlet weak var charCountLabel: NSTextField!
    
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
    
    // MARK: - Action handler
    @objc func selectChanged() {
        if self.image != nil {
            updateBase64Content()
        }
    }
    
    @objc func checkboxClicked() {
        if self.image != nil {
            updateBase64Content()
        }
    }
    
    @IBAction func copyToClipboardClicked(_ sender: Any) {
        self.copyToClipBoard()
    }

    // MARK: - DragViewDelegate
    func dragViewEnded(didDragFileWith URL: NSURL) {
        clearTextfield()
        self.base64code = nil
        
        if let image = NSImage(byReferencingFile: URL.path!) {
            self.image = image
            updateBase64Content()
            
            dragImage.image = image
            statusLabel.stringValue = "The base64 code was copied to your clipboard.\nYou may drag another image, now."
            outputTextField.isHidden = false
            copyToClipboardButton.isEnabled = true
        } else {
            dragImage.image = NSImage(named: "ErrorIcon")
            statusLabel.stringValue = "There was an error processing the image."
            outputTextField.isHidden = true
            copyToClipboardButton.isEnabled = false
            charCountLabel.isHidden = true
        }
    }
    
    func dragStarted() {
        dragImage.image = NSImage(named: "UploadIcon")
        statusLabel.stringValue = "Release the image"
    }
    
    func dragProcessing() {
        clearTextfield()
        statusLabel.stringValue = "Processing..."
    }
    
    // MARK: - Private methods
    private func copyToClipBoard() {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        
        if let content = self.base64code {
            pasteBoard.setString(content, forType: .string)
        }
    }
    
    private func clearTextfield() {
        outputTextField.textStorage?.mutableString.setString("")
    }
    
    private func setTextfieldWith(content: String) {
        copyToClipBoard()
        outputTextField.textStorage?.mutableString.setString("")
        outputTextField.textStorage?.append(NSAttributedString(string: content, attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor] as [NSAttributedString.Key: Any]))
    }
    
    private func updateBase64Content() {
        if let content = getBase64StringFromImage() {
            setTextfieldWith(content: content)
            self.base64code = content
            self.updateCharCountLabel()
        }
    }
    
    private func updateCharCountLabel() {
        if self.base64code != nil {
            if let content = self.base64code {
                charCountLabel.stringValue = "\(content.count) bytes | \(content.count / 1024) kB"
            }
            charCountLabel.isHidden = false
        } else {
            charCountLabel.isHidden = true
        }
    }
    
    private func getBase64StringFromImage() -> String? {
        var format: NSBitmapImageRep.FileType = .png
        
        if selectFileType.titleOfSelectedItem == "image/jpg" {
            format = .jpeg
        }
        
        guard let base64Output = image?.toBase64String(forDataUrl: checkboxDataUrl.state == .on, imageFormat: format) else {
            return nil
        }
        
        return base64Output
    }
}

// MARK: - Extension: NSImage
extension NSImage {
    func toBase64String(forDataUrl: Bool, imageFormat: NSBitmapImageRep.FileType) -> String? {
        guard
            let bits = self.representations.first as? NSBitmapImageRep,
            let data = bits.representation(using: imageFormat, properties: [:]),
            let format = imageFormat == .jpeg ? "jpg" : "png"
            else {
                return nil
        }
        
        return !forDataUrl ? "\(data.base64EncodedString())" : "data:image/\(format);base64,\(data.base64EncodedString())"
    }
}
