//
//  AppDelegate.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import KeyboardShortcuts

final class AppDelegate: NSObject, NSApplicationDelegate {

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

extension AppDelegate: SpaceObserverDelegate {
    func didUpdateSpaces(spaces: [Space]) {
        let icon = iconCreator.getIcon(for: spaces)
        statusBar.updateStatusBar(withIcon: icon, withSpaces: spaces)
    }
}

@main
struct SpacemanApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
    }
}
