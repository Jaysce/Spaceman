//
//  StatusBar.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import Foundation
import SwiftUI
import Sparkle

final class StatusBar: NSObject, SPUStandardUserDriverDelegate {
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var prefsWindow: PreferencesWindow!
    private var updatesMenuItem: NSMenuItem!
    private lazy var updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: self)
    private var hasPendingScheduledUpdate = false
    
    override init() {
        super.init()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenu = NSMenu()
        
        prefsWindow = PreferencesWindow()
        let hostedPrefsView = NSHostingView(rootView: PreferencesView(parentWindow: prefsWindow))
        prefsWindow.contentView = hostedPrefsView
        
        let about = NSMenuItem()
        let aboutView = AboutView()
        let view = NSHostingView(rootView: aboutView)
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 70)
        about.view = view
        
        updatesMenuItem = NSMenuItem(
            title: "Check for updates...",
            action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)),
            keyEquivalent: "")
        updatesMenuItem.target = updaterController
        
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
        statusBarMenu.addItem(updatesMenuItem)
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
        
        if prefsWindow == nil {
            prefsWindow = PreferencesWindow()
            let hostedPrefsView = NSHostingView(rootView: PreferencesView(parentWindow: prefsWindow))
            prefsWindow.contentView = hostedPrefsView
        }
        
        prefsWindow.center()
        prefsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        immediateFocus
    }

    func standardUserDriverWillHandleShowingUpdate(_ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        guard !state.userInitiated else {
            return
        }

        if handleShowingUpdate {
            clearGentleReminderState()
        } else {
            hasPendingScheduledUpdate = true
            updatesMenuItem.title = "Update available..."
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        clearGentleReminderState()
    }

    func standardUserDriverWillFinishUpdateSession() {
        clearGentleReminderState()
    }

    private func clearGentleReminderState() {
        guard hasPendingScheduledUpdate else {
            return
        }

        hasPendingScheduledUpdate = false
        updatesMenuItem.title = "Check for updates..."
    }
}
