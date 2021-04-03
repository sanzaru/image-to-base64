//
//  CodeView.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 14.12.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

@objc protocol CodeViewDelegate {
    func selectChanged()
    func checkboxClicked()
    @objc optional func copiedToClipboard()
    func doneButtonClicked()
    func onShowPreview()
}


@IBDesignable
class CodeView: NSView {
    // MARK: - Properties
    var delegate: CodeViewDelegate?
    
    private var base64code: String? {
        didSet {
            clearTextview()
            outputTextField.textStorage?.append(NSAttributedString(string: self.base64code!, attributes: [NSAttributedString.Key.foregroundColor: NSColor.textColor] as [NSAttributedString.Key: Any]))
            updateCharCountLabel()
        }
    }    
    
    @IBOutlet var mainView: NSView!
    @IBOutlet var charCountLabel: NSTextField!
    @IBOutlet var outputTextField: NSTextView!
    @IBOutlet var selectFileType: NSPopUpButton!
    @IBOutlet var checkboxDataUrl: NSButton!
    @IBOutlet var copyToClipboardButton: NSButton!
    @IBOutlet var previewImage: NSButton!


    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
                
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
    }
    
    // MARK: - Action handler
    @objc func selectChanged() {
        self.delegate?.selectChanged()
    }
    
    @objc func checkboxClicked() {
        self.delegate?.checkboxClicked()        
    }
    
    @IBAction func copyToClipboardClicked(_ sender: NSButton) {
        if let content = self.base64code {
            AppGlobals.copyToClipboard(content: content)
        }
        
        if self.delegate?.copiedToClipboard != nil {
            self.delegate?.copiedToClipboard!()
        }
    }
    
    @IBAction func onDoneButtonClicked(_ sender: NSButton) {
        self.delegate?.doneButtonClicked()
    }

    @IBAction func onPreviewClick(_ sender: Any) {
        self.delegate?.onShowPreview()
    }

    // MARK: - Public methods
    func getContent() -> String {
        return self.base64code ?? ""
    }
    
    func clearTextview() {
        self.outputTextField.textStorage?.mutableString.setString("")
    }
    
    func setTextview(with: String) {
        base64code = with
    }

    func setImage(with image: NSImage) {
        previewImage.image = image
    }
    
    func selectedFileType() -> String? {
        return self.selectFileType.titleOfSelectedItem
    }
    
    func checkboxState() -> NSControl.StateValue {
        return self.checkboxDataUrl.state
    }
    
    func updateViewControls(isError: Bool, isSvg: Bool = false) {
        if isError {
            outputTextField.isHidden = true
            charCountLabel.isHidden = true
            copyToClipboardButton.isEnabled = false
            checkboxDataUrl.isEnabled = false
            selectFileType.isEnabled = false
        } else {
            outputTextField.isHidden = false
            copyToClipboardButton.isEnabled = true
            checkboxDataUrl.isEnabled = true
            selectFileType.isEnabled = true
        }
        
        if let menuitem = selectFileType.menu?.item(withTitle: "image/svg+xml") {
            menuitem.isHidden = !isSvg            
        }
    }

    func showImageModal() {
        let view = NSView()

        addSubview(view)
    }
 
    // MARK: - Private methods
    private func setup() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)

        addSubview(mainView)
        
        selectFileType.target = self
        selectFileType.action = #selector(selectChanged)
        
        checkboxDataUrl.target = self
        checkboxDataUrl.action = #selector(checkboxClicked)
        
        outputTextField.isEditable = false
        outputTextField.isHidden = true
    }
    
    private func updateCharCountLabel() {
        if let content = self.base64code {
            charCountLabel.stringValue = "\(content.count) bytes | \(content.count / 1024) kB"
        }
    }
}
