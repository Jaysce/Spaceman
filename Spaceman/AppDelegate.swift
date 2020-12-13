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
    private let observer = SpaceObserver()
    private let iconBuilder = IconCreator()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        observer.delegate = self
        observer.updateSpaceInformation()
        NSApp.activate(ignoringOtherApps: true)
        KeyboardShortcuts.onKeyUp(for: .refresh) { [] in
            self.observer.updateSpaceInformation()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        let icon = iconBuilder.getIcon(for: spaces)
        statusBar.updateStatusBar(withIcon: icon)
    }
}
