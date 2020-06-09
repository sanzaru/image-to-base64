//
//  DimensionFormViewController.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 28.05.20.
//  Copyright © 2020 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//

import Cocoa

protocol DimensionFormViewDelegate {
    func dimensionFormViewSave(w: CGFloat, h: CGFloat)
    func dimensionFormViewCancel()
}

class DimensionFormViewController: NSViewController {
    // MARK: - Outlets
    @IBOutlet var textfieldWidth: NSTextField!
    @IBOutlet var textfieldHeight: NSTextField!
    @IBOutlet var labelError: NSTextField!
    @IBOutlet var buttonSave: NSButton!
    
    // MARK: - Public variables
    var delegate: DimensionFormViewDelegate?
    var dimensions: (Int, Int) = (0, 0)
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        textfieldWidth.stringValue = String(dimensions.0)
        textfieldHeight.stringValue = String(dimensions.1)
        buttonSave.isHighlighted = true
        labelError.isHidden = true
    }
    
    /// Action triggered when cancel button is clicked
    /// - Parameter sender: The button element
    @IBAction func onCancel(_ sender: NSButton) {
        delegate?.dimensionFormViewCancel()
        dismiss(sender)
    }
    
    /// Action triggered when save button is clicked
    /// - Parameter sender: The button element
    @IBAction func onSave(_ sender: NSButton) {
        labelError.isHidden = true
        
        guard let w = Int(textfieldWidth.stringValue) else {
            showError(message: "Invalid value for width: Must be numeric.")
            return
        }
        
        guard let h = Int(textfieldHeight.stringValue) else {
            showError(message: "Invalid value for height: Must be numeric.")
            return
        }
        
        if textfieldHeight.stringValue.isEmpty || textfieldWidth.stringValue.isEmpty {
            showError(message: "Error: Please provide values for width and height.")
        } else {
            if w <= 0 || h <= 0 {
                showError(message: "Error: Values must be greater than 0.")
            } else {
                delegate?.dimensionFormViewSave(w: CGFloat(w), h: CGFloat(h))
                dismiss(sender)
            }
        }
    }
    
    
    // MARK: - Private methods
    
    /// Show the error label with given message
    /// - Parameter message: The message to show
    private func showError(message: String) {
        labelError.stringValue = message
        labelError.isHidden = false
    }
}
