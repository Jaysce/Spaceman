//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import SwiftUI

class StatusBar {
    private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusBarMenu = NSMenu()
    private var prefsWindow = PreferencesWindow()
    var updateCounter = 1
    
    init() {
        let about = NSMenuItem(title: "About Spaceman", action: nil, keyEquivalent: "")
        let pref = NSMenuItem(title: "Preferences...", action: #selector(showPreferencesWindow(_:)), keyEquivalent: "")
        pref.target = self
        let quit = NSMenuItem(title: "Quit Spaceman", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(pref)
        statusBarMenu.addItem(quit)
        
        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar(withIcon icon: NSImage) {
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = icon
        }
        
        print("Updating... \(updateCounter)")
        updateCounter += 1
    }
    
    @objc func showPreferencesWindow(_ sender: AnyObject) {
        prefsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
