//
//  PreferencesWindow.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 2/12/20.
//

import SwiftUI
import AppKit

class PreferencesWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configureWindow()
    }
    
    func configureWindow() {
        let prefsView = PreferencesView()
        
        self.isReleasedWhenClosed = false
        self.center()
        self.setFrameAutosaveName("Main Window")
        self.contentView = NSHostingView(rootView: prefsView)
        self.title = "Spaceman Preferences"
    }
}
