//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import SwiftUI
import Sparkle

class StatusBar: NSObject, NSMenuDelegate {
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var prefsWindow: PreferencesWindow!
    private var spaceSwitcher: SpaceSwitcher!
    private var shortcutHelper: ShortcutHelper!
    private let defaults = UserDefaults.standard

    override init() {
        super.init()
        
        shortcutHelper = ShortcutHelper()
        spaceSwitcher = SpaceSwitcher()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenu = NSMenu()
        statusBarMenu.autoenablesItems = false
        statusBarMenu.delegate = self
        
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
        
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(updates)
        statusBarMenu.addItem(pref)
        statusBarMenu.addItem(quit)
        //statusBarItem.menu = statusBarMenu
        
        statusBarItem.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
        statusBarItem.button?.action = #selector(handleClick)
        statusBarItem.button?.target = self
    }
    
    @objc func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseDown {
            print("Right click: set menu")
            // Show the menu on right-click
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil  // Clear the menu after showing it
            
            //statusBarItem.button?.isHighlighted = true
            //statusBarMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
            //statusBarItem.button?.isHighlighted = false
        } else {
            print("Left click \(event.locationInWindow)")
            // Navigate
        }
    }
    
    // NSMenuDelegate method to detect when the menu is closed
    func menuDidClose(_ menu: NSMenu) {
        print("menuDidClose")
        // Manually deactivate the status bar item to reset its state
    }
    
    func updateStatusBar(withIcon icon: NSImage, withSpaces spaces: [Space]) {
        // update icon
        if let statusBarButton = statusBarItem.button {
            statusBarButton.image = icon
        }
        // update menu
        guard spaces.count > 0 else {
            return
        }
        var removeCandidateItem = statusBarMenu.items[2]
        while (!removeCandidateItem.isSeparatorItem) {
            statusBarMenu.removeItem(removeCandidateItem)
            removeCandidateItem = statusBarMenu.items[2]
        }
        for space in spaces.reversed() {
            let switchItem = makeSwitchToSpaceItem(space: space)
            statusBarMenu.insertItem(switchItem, at: 2)
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
        let spaceNumber = space.spaceNumber
        let spaceName = space.spaceName
        
        let mask = shortcutHelper.getModifiersAsFlags()
        var shortcutKey = ""
        if spaceNumber < 10 {
            shortcutKey = String(spaceNumber)
        } else if spaceNumber == 10 {
            shortcutKey = "0"
        }
        
        let icon = NSImage(imageLiteralResourceName: "SpaceManIcon")
        let menuIcon = IconCreator().createRectWithNumberIcon(
            icons: [icon],
            index: 0,
            space: space,
            fraction: 0.6)
        let item = NSMenuItem(
            title: spaceName,
            action: #selector(switchToSpace(_:)),
            keyEquivalent: shortcutKey)
        item.keyEquivalentModifierMask = mask
        item.target = self
        item.tag = spaceNumber
        item.image = menuIcon
        if space.isCurrentSpace {
            item.isEnabled = !space.isCurrentSpace
            //if OSVersion().exceeds(14, 0) {
            //if #available(macOS 14.0, *)  {
            //    item.badge = NSMenuItemBadge(string: "Current")
            //}
        }
        return item
    }

    @objc func switchToSpace(_ sender: NSMenuItem) {
        let spaceNumber = sender.tag
        guard (spaceNumber >= 1 && spaceNumber <= 10) else {
            return
        }
        spaceSwitcher.switchToSpace(spaceNumber: spaceNumber)
    }
}
