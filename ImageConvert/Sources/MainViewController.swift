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
    
    @IBOutlet var dragImage: NSImageView!
    @IBOutlet var dragView: DragView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var outputTextField: NSTextView!
    @IBOutlet var checkboxDataUrl: NSButton!
    @IBOutlet var selectFileType: NSPopUpButton!
    @IBOutlet var copyToClipboardButton: NSButton!
    @IBOutlet var charCountLabel: NSTextField!
    
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
            updateViewControls(isError: false)
        } else {
            dragImage.image = NSImage(named: "ErrorIcon")
            updateViewControls(isError: true)
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
    private func updateViewControls(isError: Bool) {
        if isError {
            statusLabel.stringValue = "There was an error processing the image."
            outputTextField.isHidden = true
            charCountLabel.isHidden = true
            copyToClipboardButton.isEnabled = false
            checkboxDataUrl.isEnabled = false
            selectFileType.isEnabled = false
        } else {
            statusLabel.stringValue = "The base64 code was copied to your clipboard.\nYou may drag another image, now."
            outputTextField.isHidden = false
            copyToClipboardButton.isEnabled = true
            checkboxDataUrl.isEnabled = true
            selectFileType.isEnabled = true
        }
    }
    
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
        //copyToClipBoard()
        clearTextfield()
        
        outputTextField.textStorage?.append(NSAttributedString(string: content, attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor] as [NSAttributedString.Key: Any]))
    }
    
    private func updateBase64Content() {
        let originalTitle = self.title
        self.title = "Converting..."
        
        dump("UPDATE")
        
        DispatchQueue.main.async {
            var format: NSBitmapImageRep.FileType = .png
            if self.selectFileType.titleOfSelectedItem == "image/jpg" {
                format = .jpeg
            }
            
            if let content = ImageConverter.getBase64String(from: self.image!, format: format, forDataUrl: self.checkboxDataUrl.state == .on) {
                self.setTextfieldWith(content: content)
                self.base64code = content
                self.updateCharCountLabel()
                self.title = originalTitle
                dump("UPDATE DONE")
            }
        }
    }
    
    private func updateCharCountLabel() {
        if let content = self.base64code {
            charCountLabel.stringValue = "\(content.count) bytes | \(content.count / 1024) kB"
            charCountLabel.isHidden = false
        } else {
            charCountLabel.isHidden = true
        }
    }
}
