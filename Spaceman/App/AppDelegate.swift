//
//  AppDelegate.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusBar = StatusBar()
    private let observer = SpaceObserver()
    private let iconBuilder = IconBuilder()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        observer.delegate = self
        observer.updateSpaceInformation() // initial update on launch
        NSApp.activate(ignoringOtherApps: true)
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
