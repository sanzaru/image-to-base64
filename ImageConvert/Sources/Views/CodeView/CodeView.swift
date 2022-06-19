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

    var selectedFileType: String? { selectFileType.titleOfSelectedItem }

    var checkboxState: NSControl.StateValue { checkboxDataUrl.state }

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
    }

    // MARK: - Action handler
    @objc func selectChanged() {
        self.delegate?.selectChanged()
    }

    @objc func checkboxClicked() {
        self.delegate?.checkboxClicked()
    }

    @IBAction func copyToClipboardClicked(_ sender: NSButton) {
        outputTextField.string.copyToClipboard()
        delegate?.copiedToClipboard!()
    }

    @IBAction func onDoneButtonClicked(_ sender: NSButton) {
        delegate?.doneButtonClicked()
    }

    @IBAction func onPreviewClick(_ sender: Any) {
        delegate?.onShowPreview()
    }

    // MARK: - Public methods
    func clearTextview() {
        self.outputTextField.textStorage?.mutableString.setString("")
    }

    func setTextview(with content: String) {
        clearTextview()
        outputTextField.string = content
        updateCharCountLabel()
    }

    func setImage(with image: NSImage) {
        previewImage.image = image
    }

    func updateViewControls(isError: Bool, isSvg: Bool = false) {
        outputTextField.isHidden = isError
        charCountLabel.isHidden = isError
        copyToClipboardButton.isEnabled = !isError
        checkboxDataUrl.isEnabled = !isError
        selectFileType.isEnabled = !isError

        if let menuitem = selectFileType.menu?.item(withTitle: "image/svg+xml") {
            menuitem.isHidden = !isSvg
        }
    }

    func showImageModal() {
        let view = NSView()
        addSubview(view)
    }

    func selectAllText() {
        outputTextField.window?.makeFirstResponder(outputTextField)
        outputTextField.selectAll(nil)
    }

    // MARK: - Private methods
    private func setup() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)

        selectFileType.target = self
        selectFileType.action = #selector(selectChanged)

        checkboxDataUrl.target = self
        checkboxDataUrl.action = #selector(checkboxClicked)

        outputTextField.isEditable = false
        outputTextField.isHidden = true

        addSubview(mainView)
    }

    private func updateCharCountLabel() {
        let content = outputTextField.string
        charCountLabel.stringValue = "\(content.count) \("label.bytes".localized) | \(content.count / 1024) kB"
    }
}
