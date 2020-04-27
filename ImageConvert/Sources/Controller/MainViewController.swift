//
//  ViewController.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, DragViewDelegate, CodeViewDelegate {
    // MARK: - Properties
    private weak var image: NSImage?
    private var codeModel: CodeModel?
    
    private enum labelTypes: Int {
        case ondrag = 0, processing, error, none
    }
    
    @IBOutlet var codeView: CodeView!
    @IBOutlet var dragView: DragView!
    @IBOutlet var dragImage: NSImageView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var dragInfoView: NSStackView!
    @IBOutlet var processingView: ProcessingView!
    @IBOutlet var notificationView: NotificationView!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusLabel(to: .none)
        
        dragView.delegate = self
        codeView.delegate = self
        
        dragInfoView.isHidden = false
        processingView.isHidden = true
        codeView.isHidden = true
    }
    
    // MARK: - CodeViewDelegate
    func selectChanged() {
        if self.image != nil {
            updateBase64Content()
        }
    }
    
    func checkboxClicked() {
        if self.image != nil {
            if let fileType = self.getSelectedImageFileType() {
                self.setTextfieldWith(content: (self.codeModel?.getCode(
                    forDataUrl: self.codeView.checkboxState() == .on,
                    type: fileType))!
                )
            }
        }
    }
    
    func doneButtonClicked() {
        self.image = nil
        self.codeModel = nil
        
        resetDragView()
        codeModel?.clear()
        codeView.clearTextview()
        
        codeView.isHidden = true
        dragView.isHidden = false
        dragInfoView.isHidden = false
    }
    
    /**
     Called when copiedToClipboard event is fired inside code view
     */
    func copiedToClipboard() {
        notificationView?.show(with: "Copied to clipboard", duration: AppGlobals.notificationDisplayDuration)
    }

    // MARK: - DragViewDelegate
    
    /// Called when dragging ended
    /// - Parameter URL: URL of the dragged file
    func dragViewEnded(didDragFileWith URL: NSURL) {        
        if let image = NSImage(byReferencingFile: URL.path!) {
            self.image = image
            updateBase64Content()            
            dragImage.image = image
        } else {
            dragImage.image = NSImage(named: "ErrorIcon")
            codeView.updateViewControls(isError: true)
        }
    }
    
    func dragStarted() {
        dragImage.image = NSImage(named: "UploadIcon")
        setStatusLabel(to: .ondrag)
    }
    
    /// Called when dragged item exited the window
    func dragExit() {
        if self.image == nil {
            resetDragView()
        } else {
            dragImage.image = self.image
        }
    }
    
    /// Called when image convertion is in progress
    func dragProcessing() {
        setStatusLabel(to: .processing)
    }
    
    // MARK: - Private methods
    private func setStatusLabel(to: labelTypes) {
        switch to {
        case .error:
            statusLabel.stringValue = AppGlobals.statusLabelTexts["error"]!
            
        case .ondrag:
            statusLabel.stringValue = AppGlobals.statusLabelTexts["ondrag"]!
            
        case .processing:
            statusLabel.stringValue = AppGlobals.statusLabelTexts["processing"]!
                    
        default:
            statusLabel.stringValue = AppGlobals.statusLabelTexts["default"]!
        }
    }
    
    private func resetDragView() {
        dragImage.image = NSImage(named: "DropIcon")
        setStatusLabel(to: .none)
    }
    
    private func setTextfieldWith(content: String) {
        codeView.setTextview(with: content)
        codeView.updateViewControls(isError: false)
    }
    
    private func getSelectedImageFileType() -> NSBitmapImageRep.FileType? {
        if image != nil {
            if let selectedFileType = self.codeView.selectedFileType() {
                if selectedFileType == "image/jpg" {
                    return .jpeg
                }
                    
                return .png
            }
        }
        
        return nil
    }
    
    private func updateBase64Content() {
        self.codeView.isHidden = true
        self.dragView.isHidden = true
        self.dragInfoView.isHidden = false
        self.statusLabel.stringValue = AppGlobals.statusLabelTexts["processing"]!
        
        DispatchQueue.main.async {
            if let format = self.getSelectedImageFileType() {
                if let content = ImageConverter.getBase64String(
                    from: self.image!,
                    format: format,
                    forDataUrl: self.codeView.checkboxState() == .on
                ) {
                    self.codeModel = CodeModel(code: content)
                    self.setTextfieldWith(content: (self.codeModel?.getCode(
                        forDataUrl: self.codeView.checkboxState() == .on,
                        type: format))!
                    )
                    
                    self.dragInfoView.isHidden = true
                    self.codeView.isHidden = false
                    self.dragView.isHidden = true
                }
            }
        }
    }    
}
