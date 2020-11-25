//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import SwiftUI

class StatusBar {
    private let statusBarItem: NSStatusItem
    private let statusBarMenu: NSMenu
    private let iconBuilder = IconBuilder()
    private var window: NSWindow!
    
    init() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenu = NSMenu()
        addStatusBarMenuItems()
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
    }
    
    func updateStatusBar(spaces: [Space]) {
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = iconBuilder.getIcon(for: spaces)
        }
    }
    
    func addStatusBarMenuItems() {
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
    
    @objc func showPreferencesWindow(_ sender: AnyObject) {
        let contentView = ContentView()
        
        // Create the window and set the content view.
        
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}
