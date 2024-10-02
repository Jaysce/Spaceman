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
        let appleScript = "tell application \"System Events\" to key code \(keyCode) using {\(modifiers)}"
        var error: NSDictionary?
        DispatchQueue.global(qos: .background).async {
            if let scriptObject = NSAppleScript(source: appleScript) {
                scriptObject.executeAndReturnError(&error)
                if error != nil {
                    var errorBriefMessage: String = error?[NSAppleScript.errorBriefMessage] as! String
                    self.alert(msg: "Error launching task: \(errorBriefMessage)\n")
                }
            }
        }
    }
    
    func switchUsingLocation(iconWidths: [IconWidth], horizontal: CGFloat, onError: () -> Void) {
        var index: Int = -1
        for i in 0 ..< iconWidths.count {
            if horizontal >= iconWidths[i].left && horizontal < iconWidths[i].right {
                index = i + 1
                break
            }
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
        DispatchQueue.main.async {
            let alert = NSAlert.init()
            var friendlyMsg: String
            if let regex = try? NSRegularExpression(pattern: #"\d+:\d+: execution error: "#) {
                let range = NSRange(msg.startIndex..., in: msg)
                friendlyMsg = regex.stringByReplacingMatches(in: msg, options: [], range: range, withTemplate: "")
            } else {
                friendlyMsg = msg
            }
            alert.messageText = "Spaceman"
            alert.informativeText = "\(friendlyMsg)\nPlease grant Accessibility permissions to Spaceman in System \(settingsTitle) → Privacy and Security."
            alert.addButton(withTitle: "Dismiss")
            alert.addButton(withTitle: "System \(settingsTitle)...")
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
