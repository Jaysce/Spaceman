//
//  AppDelegate.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import KeyboardShortcuts

final class SpacemanCore: NSObject {

    private var iconCreator: IconCreator!
    private var statusBar: StatusBar!
    private var spaceObserver: SpaceObserver!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        iconCreator = IconCreator()

        statusBar = StatusBar()
        statusBar.iconCreator = iconCreator
        
        spaceObserver = SpaceObserver()
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

extension SpacemanCore: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        let icon = iconCreator.getIcon(for: spaces)
        statusBar.updateStatusBar(withIcon: icon, withSpaces: spaces)
    }
}

@main
final class SpacemanApp: NSObject, NSApplicationDelegate {
    
    private var spacemanCore: SpacemanCore!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        spacemanCore = SpacemanCore()
        spacemanCore.applicationDidFinishLaunching(notification)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        spacemanCore?.applicationWillTerminate(notification)
    }
    
    static func main() {
        let app = NSApplication.shared
        let delegate = SpacemanApp()
        app.delegate = delegate
        app.run()
    }
}
