//
//  ViewController.swift
//  ImageConvert
//
//  Created by Martin on 03.09.19.
//  Copyright © 2019 seriousmonkey. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

class MainViewController: NSViewController, DragViewDelegate, CodeViewDelegate, DimensionFormViewDelegate {
    @IBOutlet var codeView: CodeView!
    @IBOutlet var dragView: DragView!
    @IBOutlet var dragImage: NSImageView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var dragInfoView: NSStackView!
    @IBOutlet var notificationView: NotificationView!
    
    // MARK: - Properties
    private weak var image: NSImage?
    private var svgData: Data?
    private var codeModel: CodeModel?
    
    private lazy var dimensionsFormView: DimensionFormViewController = DimensionFormViewController()
    private lazy var previewController: ImagePreviewViewController = ImagePreviewViewController()

    private enum labelTypes: Int {
        case ondrag = 0, processing, error, none
    }
    
    /// Fetch the selected file type from the drop down inside the code view and return it
    private var selectedImageFileType: ImageConverter.FileType? {
        guard let selectedFileType = codeView.selectedFileType() else {
            return nil
        }
        
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
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragView.delegate = self
        codeView.delegate = self
        
        dragInfoView.isHidden = false
        codeView.isHidden = true
        
        setStatusLabel(to: .none)
        
        // Attach subviews
        attachSubviews()

        NotificationCenter.default.addObserver(self, selector: #selector(onFileDropOnDock(_:)), name: AppGlobals.kNotification, object: nil)
    }
    
    // MARK: - Menu item handler
    @IBAction func copyToClipboard(_ sender: Any) {
        ClipboardHelper.copy(from: codeView.getContent())
        copiedToClipboard()
    }
    
    // MARK: - CodeViewDelegate
    
    /// Handler for changes in select box
    func selectChanged() {
        if image != nil {
            updateBase64Content()
        }
    }
    
    /// Handler for changes on checkbox
    func checkboxClicked() {
        if image != nil {
            if let fileType = selectedImageFileType {
                setTextfield(with: (codeModel?.code(
                    forDataUrl: codeView.checkboxState() == .on,
                    type: fileType))!, isSvg: svgData != nil
                )
            }
        }
    }
    
    /// Handler for click on done button
    func doneButtonClicked() {
        image = nil
        svgData = nil
        codeModel = nil
        
        resetDragViewStatus()
        codeModel?.clear()
        codeView.clearTextview()
        
        notificationView?.close()
        
        codeView.isHidden = true
        dragView.isHidden = false
        dragInfoView.isHidden = false
    }
    
    /// Handler for copiedToClipboard event
    func copiedToClipboard() {
        notificationView?.show(with: "Copied to clipboard", duration: AppGlobals.notificationDisplayDuration)
    }

    func onShowPreview() {
        if let image = image {
            previewController.image = image
            presentAsSheet(previewController)
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
        dragImage.image = NSImage(named: "UploadIcon")
        setStatusLabel(to: .ondrag)
    }
    
    /// Called when dragged item exited the window
    func dragExit() {
        if image == nil {
            resetDragViewStatus()
        } else {
            dragImage.image = image
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
        guard let img = ImageConverter.svgToImage(data: svgData!, w: w, h: h) else {
            return setError(with: "Error setting SVG dimensions")
        }
            
        image = img
        dragImage.image = image
        updateBase64Content()
    }
    
    /// Cancel the dimensions dialog and reset drag view
    func dimensionFormViewCancel() {
        resetDragViewStatus()
    }
    
    
    // MARK: - Private methods
    
    private func attachSubviews() {
        // Drag view
        dragView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dragView)
        
        dragView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        dragView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // Code view
        view.addSubview(codeView)
                
        // Notification view
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        notificationView.layer?.zPosition = 99
        view.addSubview(notificationView)
                
        notificationView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
        notificationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        notificationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    /// Process the image at the given URL path
    /// - Parameter URL: The path of the image
    private func processImage(from URL: NSURL) {
        /// Reset the status label
        setStatusLabel(to: .none)
        
        /// Check for SVG image
        /// NOTE: This check has to be done first, as NSImage would recognize the given image as valid, but without any dimenstion information.
        ///      It would basically be a 0x0 NSImage with no content
        do {
            let imageData = try Data(contentsOf: URL as URL)
            
            if pathIsSvg(path: URL) {
                if let size = ImageConverter.svgDimensions(from: imageData) {
                    svgData = imageData
                    dimensionsFormView.delegate = self
                    dimensionsFormView.dimensions = (Int(size.0), Int(size.1))
                    presentAsSheet(dimensionsFormView)
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error fetching SVG dimensions."])
                }
            } else {
                if let imageContent = NSImage(data: imageData) {
                    image = imageContent
                    updateBase64Content()
                    dragImage.image = imageContent
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error loading image"])
                }
            }
        } catch let error {
            setError(with: error.localizedDescription)
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
    private func setError(with message: String? = nil) {
        notificationView?.show(
            with: message ?? "There was an error processing the image. Try another.",
            duration: AppGlobals.notificationDisplayDuration
        )
        resetDragViewStatus()
    }
    
    /// Set the status label according to given label type
    /// - Parameter to: The type of label to show
    private func setStatusLabel(to: labelTypes = .none) {
        switch to {
        case .error:
            statusLabel.stringValue = NSLocalizedString("error", comment: "")
            
        case .ondrag:
            statusLabel.stringValue = NSLocalizedString("ondrag", comment: "")
            
        case .processing:
            statusLabel.stringValue = NSLocalizedString("processing", comment: "")
            
        default:
            statusLabel.stringValue = NSLocalizedString("default", comment: "")
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
        if let image = self.image {
            codeView.setImage(with: image)
        }
        codeView.updateViewControls(isError: false, isSvg: isSvg)
    }
    
    /// Update the base64 code and put it into the textview inside our code view
    private func updateBase64Content() {
        codeView.isHidden = true
        dragView.isHidden = true
        dragInfoView.isHidden = false
        statusLabel.stringValue = NSLocalizedString("processing", comment: "")
        
        func setContent(content: String, format: ImageConverter.FileType) {
            codeModel = CodeModel(code: content)
            setTextfield(with: (codeModel?.code(
                forDataUrl: codeView.checkboxState() == .on,
                type: format))!, isSvg: svgData != nil
            )
        }
        
        DispatchQueue.main.async {
            self.dragView.isHidden.toggle()
            
            if let format = self.selectedImageFileType {
                if let image = self.image {
                    if format == .svg && self.svgData != nil {
                        self.codeModel = CodeModel(code: self.svgData!.base64EncodedString())
                        setContent(content: self.svgData!.base64EncodedString(), format: format)
                    } else if let content = image.toBase64String(from: format) {
                        setContent(content: content, format: format)
                    }
                    
                    self.dragInfoView.isHidden.toggle()
                    self.codeView.isHidden.toggle()
                } else {
                    self.notificationView?.show(
                        with: "Error: Invalid image file",
                        duration: AppGlobals.notificationDisplayDuration / 4
                    )
                    
                    self.resetDragViewStatus()
                }
            }
        }
    }

    // MARK: - AppDelegate handling
    @objc private func onFileDropOnDock(_ sender: Notification) {
        if let filename = sender.object as? String {
            resetDragViewStatus()
            processImage(from: NSURL(fileURLWithPath: filename))
        }
    }
}
