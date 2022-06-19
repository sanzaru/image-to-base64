//
//  NotificationView.swift
//  ImageToBase64
//
//  Created by Martin Albrecht on 19.12.19.
//  Copyright © 2019 Martin Albrecht <martin.albrecht@seriousmonkey.de>. All rights reserved.
//
//  Licensed under Apache License v2.0
//

import Cocoa

@IBDesignable
class NotificationView: NSView {
    @IBOutlet var mainView: NSView!
    @IBOutlet var messageLabel: NSTextField!

    @IBInspectable var backgroundColor: NSColor = .systemBlue

    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func show(with message: String, duration: Double = 10.0) {
        messageLabel.stringValue = message

        timer?.invalidate()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            self.alphaValue = 0.9
        }, completionHandler: {
            self.timer = Timer.scheduledTimer(
                timeInterval: duration,
                target: self,
                selector: #selector(self.hide),
                userInfo: nil,
                repeats: false
            )
        })
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        self.hide()
    }

    @objc func hide() {
        timer?.invalidate()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            self.alphaValue = 0
        }, completionHandler: {})
    }

    // MARK: - Private methods
    private func setup() {
        self.alphaValue = 0

        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)

        addSubview(mainView)
    }
}
