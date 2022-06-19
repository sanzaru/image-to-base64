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

class MainViewController: NSViewController, DragViewDelegate, CodeViewDelegate {
    @IBOutlet var codeView: CodeView!
    @IBOutlet var dragView: DragView!
    @IBOutlet var dragImage: NSImageView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var dragInfoView: NSStackView!
    @IBOutlet var notificationView: NotificationView!

    private var imageConverter: ImageConverter?

    private lazy var previewController: ImagePreviewViewController = ImagePreviewViewController()

    private enum LabelTypes {
        case ondrag, processing, error, none
    }

    /// Fetch the selected file type from the drop down inside the code view and return it
    private var selectedImageFileType: ImageConverter.FileType? {
        switch codeView.selectedFileType {
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

    private var forDataURL: Bool { codeView.checkboxState == .on }

    private class Error: NSError {
        init(message: String, code: Int = 0) {
            super.init(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        required init?(coder: NSCoder) {
            fatalError("error.coderNotImplemented".localized)
        }
    }

    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()

        dragView.delegate = self
        codeView.delegate = self

        dragInfoView.isHidden = false
        codeView.isHidden = true

        setStatusLabel(to: .none)

        // Attach subviews
        attachSubviews()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onFileDropOnDock(_:)),
            name: AppGlobals.kNotification,
            object: nil
        )
    }

    // MARK: Private methods
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
    private func processImage(from url: NSURL) {
        /// Reset the status label
        setStatusLabel(to: .none)

        do {
            imageConverter = ImageConverter()
            try imageConverter?.loadImage(from: url)

            guard let image = imageConverter?.image else {
                throw Error(message: "error.imageCouldNotBeLoaded".localized)
            }

            dragImage.image = image
            updateBase64Content()
        } catch {
            setError(with: error.localizedDescription)
        }
    }

    /// Show an error message inside the notification view and reset the drag view
    private func setError(with message: String? = nil) {
        notificationView?.show(
            with: message ?? "error.general".localized,
            duration: AppGlobals.notificationDisplayDuration
        )
        resetDragViewStatus()
    }

    // swiftlint:disable identifier_name
    /// Set the status label according to given label type
    /// - Parameter to: The type of label to show
    private func setStatusLabel(to: LabelTypes = .none) {
        switch to {
        case .error:
            statusLabel.stringValue = "label.error".localized

        case .ondrag:
            statusLabel.stringValue = "label.ondrag".localized

        case .processing:
            statusLabel.stringValue = "label.processing".localized

        default:
            statusLabel.stringValue = "label.default".localized
        }
    }

    /// Reset the status of the drag view. Label and icon will be reset to their default
    private func resetDragViewStatus() {
        dragImage.image = NSImage(named: "DropIcon")
        setStatusLabel()
    }

    /// Set the text inside the codeview's textview
    private func setTextfield() {
        if let format = selectedImageFileType {
            if let content = imageConverter?.code(forDataUrl: forDataURL, type: format) {
                codeView.setTextview(with: content)
                if let image = imageConverter?.image {
                    codeView.setImage(with: image)
                }
                codeView.updateViewControls(isError: false, isSvg: imageConverter?.isSVG ?? false)
            }
        }
    }

    /// Update the base64 code and put it into the textview inside our code view
    private func updateBase64Content() {
        codeView.isHidden = true
        dragView.isHidden = true
        dragInfoView.isHidden = false
        statusLabel.stringValue = "label.processing".localized
        notificationView?.close()

        DispatchQueue.main.async {
            self.setTextfield()

            self.dragInfoView.isHidden = true
            self.codeView.isHidden = false
        }
    }
}

// MARK: - Menu item handler
extension MainViewController {
    @IBAction func copyToClipboard(_ sender: Any) {
        codeView.outputTextField.string.copyToClipboard()
        copiedToClipboard()
    }

    @IBAction func selectAllText(_ sender: Any) {
        codeView.selectAllText()
    }
}

// MARK: - CodeViewDelegate
extension MainViewController {
    /// Handler for changes in select box
    func selectChanged() {
        updateBase64Content()
    }

    /// Handler for changes on checkbox
    func checkboxClicked() {
        setTextfield()
    }

    /// Handler for click on done button
    func doneButtonClicked() {
        resetDragViewStatus()
        codeView.clearTextview()
        imageConverter = nil

        notificationView?.close()

        codeView.isHidden = true
        dragView.isHidden = false
        dragInfoView.isHidden = false
    }

    /// Handler for copiedToClipboard event
    func copiedToClipboard() {
        notificationView?.show(
            with: "label.copiedToClipboard".localized,
            duration: AppGlobals.notificationDisplayDuration
        )
    }

    func onShowPreview() {
        if let image = imageConverter?.image {
            previewController.image = image
            presentAsSheet(previewController)
        }
    }
}

// MARK: - DragViewDelegate
extension MainViewController {
    /// Called when dragging ended
    /// - Parameter URL: URL of the dragged file
    func dragViewEnded(didDragFileWith URL: NSURL) {
        processImage(from: URL)
    }

    /// Called when dragging is started
    func dragStarted() {
        dragImage.image = NSImage(named: "UploadIcon")
        setStatusLabel(to: .ondrag)
    }

    /// Called when dragged item exited the window
    func dragExit() {
        resetDragViewStatus()
    }

    /// Called when image convertion is in progress
    func dragProcessing() {
        setStatusLabel(to: .processing)
    }
}

// MARK: - AppDelegate handling
private extension MainViewController {
    @objc func onFileDropOnDock(_ sender: Notification) {
        if let filename = sender.object as? String {
            resetDragViewStatus()
            processImage(from: NSURL(fileURLWithPath: filename))
        }
    }
}
