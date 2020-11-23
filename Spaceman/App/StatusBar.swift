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
    
    init() {
        // Create status bar
        statusBar = NSStatusBar()
        
        // Create status bar item
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "SpaceManIconBorder")
        }
        
        // Create status bar menu
        statusBarMenu = NSMenu()
        statusBarMenu.addItem(NSMenuItem(title: "About SpaceMan", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(NSMenuItem(title: "Preferences...", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusBarMenu.addItem(NSMenuItem(title: "Quit SpaceMan", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar() {
        print("Updating...")
    }
}
