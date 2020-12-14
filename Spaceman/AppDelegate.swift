//
//  AppDelegate.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import KeyboardShortcuts

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusBar = StatusBar()
    private let spaceObserver = SpaceObserver()
    private let iconCreator = IconCreator()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        spaceObserver.delegate = self
        spaceObserver.updateSpaceInformation()
        NSApp.activate(ignoringOtherApps: true)
        KeyboardShortcuts.onKeyUp(for: .refresh) { [] in
            self.spaceObserver.updateSpaceInformation()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        let icon = iconCreator.getIcon(for: spaces)
        statusBar.updateStatusBar(withIcon: icon)
    }
}
