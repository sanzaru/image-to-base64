//
//  ImagePreviewViewController.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 02.04.21.
//  Copyright © 2021 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

class ImagePreviewViewController: NSViewController {
    var image: NSImage = NSImage()

    @IBOutlet var closeButton: NSButton!
    @IBOutlet var imagePreview: NSImageView!

    override func viewWillAppear() {
        imagePreview.image = image
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        dismiss(sender)
    }

}
