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
        // Check if the process has Accessibility permission, and make sure it has been added to the list
        AXIsProcessTrusted()
    }

    public func switchToSpace(spaceNumber: Int, onError: () -> Void) {
        let keyCode = shortcutHelper.getKeyCode(spaceNumber: spaceNumber)
        if keyCode < 0 {
            return onError()
        }
        let modifiers = shortcutHelper.getModifiers()
        let appleScript = "tell application \"System Events\" to key code \(keyCode) using {\(modifiers)}"
        var error: NSDictionary?
        DispatchQueue.global(qos: .background).async {
            if let scriptObject = NSAppleScript(source: appleScript) {
                scriptObject.executeAndReturnError(&error)
                if error != nil {
                    let errorNumber: Int = error?[NSAppleScript.errorNumber] as! Int
                    let errorBriefMessage: String = error?[NSAppleScript.errorBriefMessage] as! String
                    let settingsName = self.systemSettingsName()
                    // -1002: Error: Spaceman is not allowed to send keystrokes. (needs Accessibility permission)
                    // -1743: Error: Not authorized to send Apple events to System Events. (needs Automation permission)
                    let permissionType = errorNumber == 1002 ? "Accessibility" : "Automation"
                    self.alert(
                        msg: "Error: \(errorBriefMessage)\n\nPlease grant \(permissionType) permissions to Spaceman in \(settingsName) → Privacy and Security.",
                        permissionTypeName: permissionType)
                }
            }
        }
    }
    
    public func switchUsingLocation(iconWidths: [IconWidth], horizontal: CGFloat, onError: () -> Void) {
        var index: Int = 0
        for i in 0 ..< iconWidths.count {
            if horizontal >= iconWidths[i].left && horizontal < iconWidths[i].right {
                index = iconWidths[i].index
                break
            }
        }
        switchToSpace(spaceNumber: index, onError: onError)
    }
    
    private func systemSettingsName() -> String {
        if #available(macOS 13.0, *) {
            return "System Settings"
        } else {
            return "System Preferences"
        }
    }
    
    private func alert(msg: String, permissionTypeName: String) {
        DispatchQueue.main.async {
            let alert = NSAlert.init()
            alert.messageText = "Spaceman"
            alert.informativeText = "\(msg)"
            alert.addButton(withTitle: "Dismiss")
            if permissionTypeName != "" {
                let settingsName = self.systemSettingsName()
                alert.addButton(withTitle: "\(settingsName)...")
            }
            let response = alert.runModal()
            if (response == .alertSecondButtonReturn) {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["x-apple.systempreferences:com.apple.preference.security?Privacy_\(permissionTypeName)"]
                try? task.run()
            }
        }
    }
}
