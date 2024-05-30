//
//  ScriptableCommand.swift
//  Spaceman
//
//  Created by Michael Lehenauer on 30.05.24.
//

import Foundation
import Cocoa

class RefreshCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
        return nil
    }
}

