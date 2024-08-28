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
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var prefsWindow: PreferencesWindow!
    private var spaceSwitcher: SpaceSwitcher!
    private var config: Config!
    
    private var didRun: Bool = false // FIXME

    init() {
        config = Config()
        spaceSwitcher = SpaceSwitcher()
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenu = NSMenu()
        statusBarMenu.autoenablesItems = false
        makeStatusBar(spaces: [])
    }

    func makeStatusBar(spaces: [Space]) {
        prefsWindow = PreferencesWindow()
        let hostedPrefsView = NSHostingView(rootView: PreferencesView(parentWindow: prefsWindow))
        prefsWindow.contentView = hostedPrefsView
        
        let about = NSMenuItem()
        let aboutView = AboutView()
        let view = NSHostingView(rootView: aboutView)
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 70)
        about.view = view
        
        let updates = NSMenuItem(
            title: "Check for updates...",
            action: #selector(SUUpdater.checkForUpdates(_:)),
            keyEquivalent: "")
        updates.target = SUUpdater.shared()
        
        let pref = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferencesWindow(_:)),
            keyEquivalent: "")
        pref.target = self
        
        let quit = NSMenuItem(
            title: "Quit Spaceman",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "")
        
        statusBarMenu.removeAllItems()
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(NSMenuItem.separator())
        for space in spaces {
            statusBarMenu.addItem(makeSwitchToSpaceItem(space: space))
        }
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(updates)
        statusBarMenu.addItem(pref)
        statusBarMenu.addItem(quit)

        statusBarItem.menu = statusBarMenu
    }
    
    func updateStatusBar(withIcon icon: NSImage, withSpaces spaces: [Space]) {
        // update icon
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = icon
        }
        // update menu
        if spaces.count > 0 && !didRun {
            makeStatusBar(spaces: spaces)
            didRun = true
        }
    }

    @objc func showPreferencesWindow(_ sender: AnyObject) {
        if prefsWindow == nil {
            prefsWindow = PreferencesWindow()
            let hostedPrefsView = NSHostingView(rootView: PreferencesView(parentWindow: prefsWindow))
            prefsWindow.contentView = hostedPrefsView
        }
        
        prefsWindow.center()
        prefsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func makeSwitchToSpaceItem(space: Space) -> NSMenuItem {
        let title = space.spaceName
        let mask = config.getModifiersAsFlags()
        let item = NSMenuItem(
            title: title,
            action: #selector(switchToSpace(_:)),
            keyEquivalent: String(space.spaceNumber))
        item.keyEquivalentModifierMask = mask
        item.target = self
        item.tag = space.spaceNumber
        item.isEnabled = !space.isCurrentSpace
        return item
    }
    
    @objc func switchToSpace(_ sender: NSMenuItem) {
        let spaceNumber = sender.tag
        if (spaceNumber < 1 || spaceNumber > 10) {
            return
        }
        spaceSwitcher.switchToSpace(spaceNumber: spaceNumber)
    }
}
