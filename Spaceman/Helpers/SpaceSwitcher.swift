//
//  SpaceSwitcher.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 28/08/2024.
//

import Foundation
import SwiftUI

class SpaceSwitcher {
    private var shortcutHelper: ShortcutHelper!

    init() {
        shortcutHelper = ShortcutHelper()
    }

    func switchToSpace(spaceNumber: Int, onError: () -> Void) {
        let keyCode = shortcutHelper.getKeyCode(spaceNumber: spaceNumber)
        if keyCode < 0 {
            return onError()
        }
        let modifiers = shortcutHelper.getModifiers()

        let pipe = Pipe()
        let file = pipe.fileHandleForReading
        
        let script = "tell application \"System Events\" to key code \(keyCode) using {\(modifiers)}"
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        task.standardError = pipe

        do {
            // Launch the task.
            try task.run()
            task.waitUntilExit()
            let exitCode = task.terminationStatus
            let data = file.readDataToEndOfFile()
            file.closeFile()

            // We may run into an execution error:
            // "System Events got an error: osascript is not allowed to send keystrokes"
            if exitCode > 0 {
                let errorString = String(data: data, encoding: .utf8)
                if errorString == nil {
                    alert(msg: "Error: osascript exited with code \(exitCode)")
                } else {
                    alert(msg: "Error: \(errorString!)")

                }
            }
        } catch {
            alert(msg: "Error launching task: \(error)")
        }
    }
    
    func switchUsingLocation(widths: [CGFloat], horizontal: CGFloat, onError: () -> Void) {
        var index = 0
        while index < widths.count && horizontal > widths[index] {
            index += 1
        }
        switchToSpace(spaceNumber: index, onError: onError)
    }
    
    func alert(msg: String) {
        var settingsTitle: String
        if #available(macOS 13.0, *) {
            settingsTitle = "Settings"
        } else {
            settingsTitle = "Preferences"
        }
        let alert = NSAlert.init()
        alert.messageText = "Spaceman"
        alert.informativeText = msg
        alert.addButton(withTitle: "Dismiss")
        alert.addButton(withTitle: "System \(settingsTitle)...")
        let response = alert.runModal()
        if (response == .alertSecondButtonReturn) {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["/System/Library/PreferencePanes/Security.prefPane"]
            try? task.run()
        }
    }
}
