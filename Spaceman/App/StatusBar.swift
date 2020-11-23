//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Cocoa
import Foundation

class StatusBar {
    private let statusBar: NSStatusBar
    private let statusBarItem: NSStatusItem
    private let statusBarMenu: NSMenu
    private let iconBuilder = IconBuilder()
    
    init() {
        // Create status bar
        statusBar = NSStatusBar.system
        
        // Create status bar item
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create status bar menu
        statusBarMenu = NSMenu()
        statusBarMenu.addItem(NSMenuItem(title: "About Spaceman", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(NSMenuItem(title: "Preferences...", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusBarMenu.addItem(NSMenuItem(title: "Quit Spaceman", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar(spaces: [Space]) {
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = iconBuilder.getIcon(spaces: spaces)
        }
    }
}
