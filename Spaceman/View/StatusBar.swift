//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import Sparkle
import SwiftUI

class StatusBar: NSObject, NSMenuDelegate {
    @AppStorage("hideInactiveSpaces") private var hideInactiveSpaces = false
    @AppStorage("schema") private var keySet = KeySet.toprow
    
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var prefsWindow: PreferencesWindow!
    private var spaceSwitcher: SpaceSwitcher!
    private var shortcutHelper: ShortcutHelper!
    private var updaterController: SPUStandardUpdaterController!
    
    public var iconCreator: IconCreator!

    override init() {
        super.init()
        
        shortcutHelper = ShortcutHelper()
        spaceSwitcher = SpaceSwitcher()
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
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
            action: #selector(updaterController.checkForUpdates(_:)),
            keyEquivalent: "")
        updates.target = updaterController
        
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
        
        statusBarItem.button?.action = #selector(handleClick)
        statusBarItem.button?.target = self
        statusBarItem.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])
    }

    @objc func handleClick(_ sbButton: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if event.type == .rightMouseDown {
                // Show the menu on right-click
                if let sbMenu = self.statusBarMenu {
                    let buttonFrame = sbButton.window?.convertToScreen(sbButton.frame) ?? .zero
                    // This calculation should be right, but is does not look good
                    //let menuOrigin = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY + CGFloat(self.iconCreator.sizes.ICON_HEIGHT) - 2 * buttonFrame.height)
                    // This calculation is not right, but looks good
                    let menuOrigin = CGPoint(x: buttonFrame.minX, y: buttonFrame.minY - CGFloat(self.iconCreator.sizes.ICON_HEIGHT) / 2)
                    sbMenu.minimumWidth = buttonFrame.width
                    sbMenu.popUp(positioning: nil, at: menuOrigin, in: nil)
                    sbButton.isHighlighted = false
                }
            } else if (event.type == .leftMouseDown) {
                // Switch desktops on left click, unless one single space shown
                guard !self.hideInactiveSpaces else {
                    print("Not switching: just one space visible")
                    return
                }
                let locationInButton = sbButton.convert(event.locationInWindow, from: sbButton)
                self.spaceSwitcher.switchUsingLocation(
                    iconWidths: self.iconCreator.iconWidths,
                    horizontal: locationInButton.x,
                    onError: self.flashStatusBar)
            } else {
                print("Other event: \(event.type)")
            }
        }
    }

    func flashStatusBar() {
        if let button = statusBarItem.button {
            let blinkInterval: TimeInterval = 0.1
            button.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + blinkInterval) {
                button.isHighlighted = false
                DispatchQueue.main.asyncAfter(deadline: .now() + blinkInterval) {
                    button.isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + blinkInterval) {
                        button.isHighlighted = false
                    }
                }
            }
        }
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
        let spaceByDesktopID = Int(space.spaceByDesktopID) ?? 99
        
        let mask = shortcutHelper.getModifiersAsFlags()
        var shortcutKey = ""
        if space.spaceByDesktopID == "F1" {
            shortcutKey = "-"
        } else if space.spaceByDesktopID == "F2" {
            shortcutKey = (keySet == KeySet.numpad ? "+" : "=")
        } else if spaceByDesktopID < 10 {
            shortcutKey = space.spaceByDesktopID
        } else if spaceByDesktopID == 10 {
            shortcutKey = "0"
        }
        
        let icon = NSImage(imageLiteralResourceName: "SpaceIconNumNormalActive")
        let menuIcon = iconCreator.createRectWithNumberIcon(
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
        switch space.spaceByDesktopID {
        case "F1":
            item.tag = -1
        case "F2":
            item.tag = -2
        default:
            item.tag = spaceNumber
        }
        item.image = menuIcon
        if space.isCurrentSpace || shortcutKey == "" {
            item.isEnabled = false
            //if OSVersion().exceeds(14, 0) {
            //if #available(macOS 14.0, *)  {
            //    item.badge = NSMenuItemBadge(string: "Current")
            //}
            if space.isCurrentSpace {
                item.state = .on // tick mark
            }
        }
        return item
    }

    @objc func switchToSpace(_ sender: NSMenuItem) {
        let spaceNumber = sender.tag
        guard (spaceNumber >= -2 && spaceNumber != 0 && spaceNumber <= 10) else {
            return
        }
        spaceSwitcher.switchToSpace(spaceNumber: spaceNumber, onError: flashStatusBar)
    }
}
