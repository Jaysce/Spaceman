//
//  SpaceSwitcher.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 28/08/2024.
//

import Foundation
import SwiftUI

class SpaceSwitcher {
    private var config: Config!
    
    func switchToSpace(spaceNumber: Int) {
        config = Config()
        
        let keyCode = config.getKeyCode(spaceNumber: spaceNumber)
        if keyCode < 0 {
            return
        }
        let modifiers = config.getModifiers()

        print("Called switchToSpace \(spaceNumber), sending keycode \(keyCode)")
        
        let script = "tell application \"System Events\" to key code \(keyCode) using {\(modifiers)}"
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]

        do {
            // Launch the task. We may run into an execution error:
            // "System Events got an error: osascript is not allowed to send keystrokes"
            try task.run()
            task.waitUntilExit()
            if (task.terminationStatus > 0) {
                alert(msg: "Error: osascript exited with code \(task.terminationStatus)")
            }
        } catch {
            alert(msg: "Error launching osascript: \(error)")
        }
    }
    
    func alert(msg: String) {
        let alert = NSAlert.init()
        alert.messageText = "Spaceman"
        alert.informativeText = msg
        alert.addButton(withTitle: "Dismiss")
        alert.runModal()
    }
}
