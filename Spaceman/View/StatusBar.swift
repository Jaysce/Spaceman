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
    private var shortcutHelper: ShortcutHelper!
    private let defaults = UserDefaults.standard

    init() {
        shortcutHelper = ShortcutHelper()
        spaceSwitcher = SpaceSwitcher()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenu = NSMenu()
        statusBarMenu.autoenablesItems = false
        
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
        statusBarItem.menu = statusBarMenu
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

    func narrowNumber(num: Int) -> String {
        guard (num >= 1 && num <= 20) else {
            return "\(num)."
        }
        return ["","⒈","⒉","⒊","⒋","⒌","⒍","⒎","⒏","⒐","⒑","⒒","⒓","⒔","⒕","⒖","⒗","⒘","⒙","⒚","⒛"][num]
    }

    func makeSwitchToSpaceItem(space: Space) -> NSMenuItem {
        let spaceNumber = space.spaceNumber
        //let spaceNumberStr = narrowNumber(num: spaceNumber) // Not sure if UTF-8 font is available everywhere
        let spaceName = space.spaceName
        let showSpaceNumberInMenu = defaults.bool(forKey: "showSpaceNumberInMenu")
        
        let title = showSpaceNumberInMenu ? "\(spaceNumber) : \(spaceName)" : spaceName
        let mask = shortcutHelper.getModifiersAsFlags()
        var shortcutKey = ""
        if spaceNumber < 10 {
            shortcutKey = String(spaceNumber)
        } else if spaceNumber == 10 {
            shortcutKey = "0"
        }
        
        let item = NSMenuItem(
            title: title,
            action: #selector(switchToSpace(_:)),
            keyEquivalent: shortcutKey)
        item.keyEquivalentModifierMask = mask
        item.target = self
        item.tag = spaceNumber
        if space.isCurrentSpace {
            item.isEnabled = !space.isCurrentSpace
            //item.badge = NSMenuItemBadge(string: "Current") // MacOS >= 14
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
