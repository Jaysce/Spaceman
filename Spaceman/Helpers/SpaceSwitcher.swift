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
                    let errorBriefMessage: String = error?[NSAppleScript.errorBriefMessage] as! String
                    let settingsName = self.systemSettingsName()
                    self.alert(
                        msg: "Error: \(errorBriefMessage)\n\nPlease grant Accessibility permissions to Spaceman in \(settingsName) → Privacy and Security.",
                        withSettingsButton: true)
                }
            }
        }
    }
    
    public func switchUsingLocation(iconWidths: [IconWidth], horizontal: CGFloat, onError: () -> Void) {
        var index: Int = -1
        for i in 0 ..< iconWidths.count {
            if horizontal >= iconWidths[i].left && horizontal < iconWidths[i].right {
                index = i + 1
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
    
    private func alert(msg: String, withSettingsButton: Bool) {
        DispatchQueue.main.async {
            let alert = NSAlert.init()
            alert.messageText = "Spaceman"
            alert.informativeText = "\(msg)"
            alert.addButton(withTitle: "Dismiss")
            if withSettingsButton {
                let settingsName = self.systemSettingsName()
                alert.addButton(withTitle: "\(settingsName)...")
            }
            let response = alert.runModal()
            if (response == .alertSecondButtonReturn) {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]
                try? task.run()
            }
        }
    }
}
