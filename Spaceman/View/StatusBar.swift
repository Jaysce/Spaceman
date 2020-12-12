//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import SwiftUI
import Sparkle

class StatusBar {
    private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusBarMenu = NSMenu()
    private var prefsWindow = PreferencesWindow()
    
    init() {
        let about = NSMenuItem()
        let aboutView = AboutView()
        let view = NSHostingView(rootView: aboutView)
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 70)
        about.view = view
        
        let updates = NSMenuItem(
            title: "Check for updates...",
            action: #selector(checkForUpdates(_:)),
            keyEquivalent: "")
        updates.target = self
        
        let pref = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferencesWindow(_:)),
            keyEquivalent: "")
        pref.target = self
        
        let quit = NSMenuItem(
            title: "Quit Spaceman",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "")
        
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(updates)
        statusBarMenu.addItem(pref)
        statusBarMenu.addItem(quit)
        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar(withIcon icon: NSImage) {
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = icon
        }
    }
    
    @objc func showPreferencesWindow(_ sender: AnyObject) {
        prefsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    @objc func checkForUpdates(_ sender: AnyObject) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
}
