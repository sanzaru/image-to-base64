//
//  ViewController.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, DragViewDelegate, CodeViewDelegate, DimensionFormViewDelegate {
    // MARK: - Properties
    private weak var image: NSImage?
    private var svgData: Data?
    private var codeModel: CodeModel?
    
    private lazy var dimensionsFormView: DimensionFormViewController = DimensionFormViewController()
    
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
    
    // MARK: - Menu item handler
    @IBAction func copyToClipboard(_ sender: Any) {
        AppGlobals.copyToClipboard(content: self.codeView.getContent())
        copiedToClipboard()
    }
    
    // MARK: - CodeViewDelegate
    
    /// Handler for changes in select box
    func selectChanged() {
        if self.image != nil {
            updateBase64Content()
        }
    }
    
    /// Handler for changes on checkbox
    func checkboxClicked() {
        if self.image != nil {
            if let fileType = self.getSelectedImageFileType() {
                self.setTextfield(with: (self.codeModel?.getCode(
                    forDataUrl: self.codeView.checkboxState() == .on,
                    type: fileType))!, isSvg: self.svgData != nil
                )
            }
        }
    }
    
    /// Handler for click on done button
    func doneButtonClicked() {
        self.image = nil
        self.svgData = nil
        self.codeModel = nil
        
        resetDragViewStatus()
        codeModel?.clear()
        codeView.clearTextview()
        
        if notificationView != nil {
            notificationView!.close()
        }
        
        codeView.isHidden = true
        dragView.isHidden = false
        dragInfoView.isHidden = false
    }
    
    /// Handler for copiedToClipboard event
    func copiedToClipboard() {
        if notificationView != nil {
            notificationView!.show(with: "Copied to clipboard", duration: AppGlobals.notificationDisplayDuration)
        }
    }
    
    // MARK: - DragViewDelegate
    
    /// Called when dragging ended
    /// - Parameter URL: URL of the dragged file
    func dragViewEnded(didDragFileWith URL: NSURL) {
        self.processImage(from: URL)
    }
    
    /// Called when dragging is started
    func dragStarted() {
        if notificationView != nil {
            notificationView!.close()
        }
        
        dragImage.image = NSImage(named: "UploadIcon")
        setStatusLabel(to: .ondrag)
    }
    
    /// Called when dragged item exited the window
    func dragExit() {
        if self.image == nil {
            resetDragViewStatus()
        } else {
            dragImage.image = self.image
        }
    }
    
    /// Called when image convertion is in progress
    func dragProcessing() {
        setStatusLabel(to: .processing)
    }
    
    // MARK: - DimensionFormViewDelegate
    
    /// Show the width and height definition dialog to set the values for the processed image
    /// - Parameters:
    ///   - w: The witdth of the given image
    ///   - h: The height of the given image
    func dimensionFormViewSave(w: CGFloat, h: CGFloat) {
        if let img = ImageConverter.svgToImage(data: svgData!, w: w, h: h) {
            image = img
            dragImage.image = image
            updateBase64Content()
        } else {
            setError()
        }
    }
    
    /// Cancel the dimensions dialog and reset drag view
    func dimensionFormViewCancel() {
        resetDragViewStatus()
    }
    
    
    // MARK: - Private methods
    
    /// Process the image at the given URL path
    /// - Parameter URL: The path of the image
    private func processImage(from URL: NSURL) {
        /// Reset the status label
        setStatusLabel(to: .none)
        
        /// Check for SVG image
        /// NOTE: This check has to be done first, as NSImage would recognize the given image as valid, but without any dimenstion information.
        ///      It would basically be a 0x0 NSImage with no @Content
        if self.pathIsSvg(path: URL) {
            // Fetch SVG data
            svgData = try? Data(contentsOf: URL as URL)
            
            if svgData != nil,
                let size = ImageConverter.svgDimensions(from: svgData!) {
                dimensionsFormView.delegate = self
                dimensionsFormView.dimensions = (Int(size.0), Int(size.1))
                presentAsSheet(dimensionsFormView)
            } else {
                setError()
            }
        } else {
            if let image = NSImage(byReferencingFile: URL.path!) {
                svgData = nil
                self.image = image
                updateBase64Content()
                dragImage.image = image
            } else {
                setError()
            }
        }
    }
    
    /// Check if given path is a SVG file
    /// FIXME: Find better way to identify SVG images
    ///
    /// - Parameter path: The path to check
    /// - Returns: True if svg extension is found, false if not
    private func pathIsSvg(path: NSURL) -> Bool {
        return path.pathExtension == "svg"
    }
    
    /// Show an error message inside the notification view and reset the drag view
    private func setError() {
        if notificationView != nil {
            notificationView!.show(with: "There was an error processing the image. Try another.", duration: AppGlobals.notificationDisplayDuration)
        }
        
        resetDragViewStatus()
    }
    
    /// Set the status label according to given label type
    /// - Parameter to: The type of label to show
    private func setStatusLabel(to: labelTypes = .none) {
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
    
    
    /// Reset the status of the drag view. Label and icon will be reset to their default
    private func resetDragViewStatus() {
        dragImage.image = NSImage(named: "DropIcon")
        setStatusLabel()
    }
    
    /// Set the text inside the codeview's textview
    /// - Parameters:
    ///   - content: The content string to put in the textview
    ///   - isSvg: True if the image is svg, false if not. This basically determines the menu options for output format.
    private func setTextfield(with content: String, isSvg: Bool = false) {
        codeView.setTextview(with: content)
        codeView.updateViewControls(isError: false, isSvg: isSvg)
    }
    
    /// Fetch the selected file type from the drop down inside the code view and return it
    /// - Returns: The selected file type or nil. There should always be a value, so nil is an indication for an error
    private func getSelectedImageFileType() -> ImageConverter.FileType? {
        if let selectedFileType = self.codeView.selectedFileType() {
            switch selectedFileType {
            case "image/jpg":
                return .jpeg
            case "image/png":
                return .png
            case "image/svg+xml":
                return .svg
            default:
                return nil
            }
        }
        
        return nil
    }
    
    /// Update the base64 code and put it into the textview inside our code view
    private func updateBase64Content() {
        self.codeView.isHidden = true
        self.dragView.isHidden = true
        self.dragInfoView.isHidden = false
        self.statusLabel.stringValue = AppGlobals.statusLabelTexts["processing"]!
        
        func setContent(content: String, format: ImageConverter.FileType) {
            self.codeModel = CodeModel(code: content)
            self.setTextfield(with: (self.codeModel?.getCode(
                forDataUrl: self.codeView.checkboxState() == .on,
                type: format))!, isSvg: self.svgData != nil
            )
        }
        
        DispatchQueue.main.async {
            self.dragView.isHidden.toggle()
            
            if let format = self.getSelectedImageFileType() {
                if self.image != nil {
                    if format == .svg && self.svgData != nil {
                        self.codeModel = CodeModel(code: self.svgData!.base64EncodedString())
                        setContent(content: self.svgData!.base64EncodedString(), format: format)
                    } else if let content = self.image!.toBase64String(imageFormat: format) {
                        setContent(content: content, format: format)
                    }
                    
                    self.dragInfoView.isHidden.toggle()
                    self.codeView.isHidden.toggle()
                } else {
                    if self.notificationView != nil {
                        self.notificationView!.show(with: "Error: Invalid image file", duration: AppGlobals.notificationDisplayDuration / 4)
                    }
                    
                    self.resetDragViewStatus()
                }
            }
        }
    }    
}
