//
//  Config.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 28/08/2024.
//
//  See https://apple.stackexchange.com/questions/36943/how-do-i-automate-a-key-press-in-applescript

import Foundation
import SwiftUI

class Config {
    
    private let defaults = UserDefaults.standard

    /**
     * Uses the number keys on the top row of the keyboard
     */
    private func getKeyCodeTopRow(spaceNumber: Int) -> Int {
        let keyCode: Int
        switch (spaceNumber) {
        case 1:
            keyCode = 18 // kVK_ANSI_1
        case 2:
            keyCode = 19 // kVK_ANSI_2
        case 3:
            keyCode = 20 // kVK_ANSI_3
        case 4:
            keyCode = 21 // kVK_ANSI_4
        case 5:
            keyCode = 23 // kVK_ANSI_5 (!)
        case 6:
            keyCode = 22 // kVK_ANSI_6
        case 7:
            keyCode = 26 // kVK_ANSI_7
        case 8:
            keyCode = 28 // kVK_ANSI_8
        case 9:
            keyCode = 25 // kVK_ANSI_9
        case 10:
            keyCode = 29 // kVK_ANSI_0
        default:
            keyCode = -1
        }
        return keyCode
    }

    /**
     * Uses the number keys on the numeric keypad
     */
    private func getKeyCodeNumPad(spaceNumber: Int) -> Int {
        let keyCode: Int
        switch (spaceNumber) {
        case 1:
            keyCode = 83 // kVK_ANSI_Keypad1
        case 2:
            keyCode = 84 // kVK_ANSI_Keypad2
        case 3:
            keyCode = 85 // kVK_ANSI_Keypad3
        case 4:
            keyCode = 86 // kVK_ANSI_Keypad4
        case 5:
            keyCode = 87 // kVK_ANSI_Keypad5
        case 6:
            keyCode = 88 // kVK_ANSI_Keypad6
        case 7:
            keyCode = 89 // kVK_ANSI_Keypad7
        case 8:
            keyCode = 91 // kVK_ANSI_Keypad8 (!)
        case 9:
            keyCode = 92 // kVK_ANSI_Keypad9
        case 10:
            keyCode = 82 // kVK_ANSI_Keypad0
        default:
            keyCode = -1
        }
        return keyCode
    }
    
    func getKeyCode(spaceNumber: Int) -> Int {
        let schema = defaults.string(forKey: "schema")
        switch (schema) {
        case "toprow":
            return getKeyCodeTopRow(spaceNumber: spaceNumber)
        case "numpad":
            return getKeyCodeNumPad(spaceNumber: spaceNumber)
        default:
            return getKeyCodeTopRow(spaceNumber: spaceNumber)
        }
    }
    
    func getModifiers() -> String {
        var modifiers: [String] = []
        if defaults.bool(forKey: "withShift") {
            modifiers.append("shift down")
        }
        if defaults.bool(forKey: "withControl") {
            modifiers.append("control down")
        }
        if defaults.bool(forKey: "withOption") {
            modifiers.append("option down")
        }
        if defaults.bool(forKey: "withCommand") {
            modifiers.append("command down")
        }
        return modifiers.joined(separator: ",")
    }

    func getModifiersAsFlags() -> NSEvent.ModifierFlags {
        var mask = NSEvent.ModifierFlags()
        if defaults.bool(forKey: "withShift") {
            mask = mask.union(NSEvent.ModifierFlags.shift)
        }
        if defaults.bool(forKey: "withControl") {
            mask = mask.union(NSEvent.ModifierFlags.control)
        }
        if defaults.bool(forKey: "withOption") {
            mask = mask.union(NSEvent.ModifierFlags.option)
        }
        if defaults.bool(forKey: "withCommand") {
            mask = mask.union(NSEvent.ModifierFlags.command)
        }
        return mask
    }
}
