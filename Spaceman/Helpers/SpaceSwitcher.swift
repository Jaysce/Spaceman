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

    init() {
        config = Config()
    }
    
    func switchToSpace(spaceNumber: Int) {
        let keyCode = config.getKeyCode(spaceNumber: spaceNumber)
        if keyCode < 0 {
            return
        }
        let modifiers = config.getModifiers()

        print("Called switchToSpace \(spaceNumber), sending keycode \(keyCode)")

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
    
    func alert(msg: String) {
        let alert = NSAlert.init()
        alert.messageText = "Spaceman"
        alert.informativeText = msg
        alert.addButton(withTitle: "Dismiss")
        alert.runModal()
    }
}
