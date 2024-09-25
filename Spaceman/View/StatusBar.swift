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
    
    public var iconCreator: IconCreator!

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
        
        statusBarItem.button?.action = #selector(handleClick)
        statusBarItem.button?.target = self
        statusBarItem.button?.sendAction(on: [.rightMouseDown, .leftMouseDown])

        /*
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMenuClose(_:)),
            name: NSMenu.didEndTrackingNotification,
            object: statusBarMenu)
        */
    }

    @objc func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        DispatchQueue.main.async {
            if event.type == .rightMouseDown {
                // Show the menu on right-click
                if let sbButton = self.statusBarItem.button, let sbMenu = self.statusBarMenu {
                    let buttonFrame = sbButton.window?.convertToScreen(sbButton.frame) ?? .zero
                    let menuOrigin = CGPoint(x: buttonFrame.minX, y: buttonFrame.minY - CGFloat(IconCreator.HEIGHT) / 2)
                    sbMenu.minimumWidth = buttonFrame.width
                    sbMenu.popUp(positioning: nil, at: menuOrigin, in: nil)
                    sbButton.isHighlighted = false
                }
            } else {
                // Switch desktops on left click
                let locationInButton = sender.convert(event.locationInWindow, from: self.statusBarItem.button)
                
                self.spaceSwitcher.switchUsingLocation(
                    widths: self.iconCreator.widths,
                    horizontal: locationInButton.x,
                    onError: self.flashStatusBar)
            }
        }
    }

    /*
    @objc private func handleMenuClose(_ notification: Notification) {
        // Reset the button state when the menu closes
        if let button = statusBarItem.button {
            button.isHighlighted = false
        }
        
        // Reactivate the button to ensure responsiveness
        // This line ensures the button becomes responsive to new clicks immediately
        //NSApp.nextEvent(matching: [.leftMouseDown, .rightMouseDown], until: Date.distantPast, inMode: .eventTracking, dequeue: true)
     
        // Reactivate the button to ensure responsiveness
        // Add a slight delay to ensure the event system has fully processed the menu close
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Force reset of the event queue
            NSApp.nextEvent(matching: [.leftMouseDown, .rightMouseDown], until: Date.distantPast, inMode: .eventTracking, dequeue: true)

            // Optional: Trigger a manual click reset to ensure the button state is fully cleared
            //self.statusBarItem.button?.performClick(nil)
        }
    }
    */

    func flashStatusBar() {
        if let button = statusBarItem.button {
            let duration: TimeInterval = 0.1
            button.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                button.isHighlighted = false
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    button.isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
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
        let desktopID = Int(space.desktopID) ?? 99
        
        let mask = shortcutHelper.getModifiersAsFlags()
        var shortcutKey = ""
        if desktopID < 10 {
            shortcutKey = space.desktopID
        } else if desktopID == 10 {
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
        if space.isCurrentSpace || shortcutKey == "" {
            item.isEnabled = false
            // item.state = NSControl.StateValue.on // tick mark
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
        spaceSwitcher.switchToSpace(spaceNumber: spaceNumber, onError: flashStatusBar)
    }
}
