//
//  ShortcutHelper.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 28/08/2024.
//
//  See https://apple.stackexchange.com/questions/36943/how-do-i-automate-a-key-press-in-applescript

import Foundation
import SwiftUI

class ShortcutHelper {
    
    @AppStorage("schema") private var keySet = KeySet.toprow
    @AppStorage("withShift") private var withShift = false
    @AppStorage("withControl") private var withControl = false
    @AppStorage("withOption") private var withOption = false
    @AppStorage("withCommand") private var withCommand = false

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
        switch (keySet) {
        case .toprow:
            return getKeyCodeTopRow(spaceNumber: spaceNumber)
        case .numpad:
            return getKeyCodeNumPad(spaceNumber: spaceNumber)
        }
    }
    
    func getModifiers() -> String {
        var modifiers: [String] = []
        if withShift {
            modifiers.append("shift down")
        }
        if withControl {
            modifiers.append("control down")
        }
        if withOption {
            modifiers.append("option down")
        }
        if withCommand {
            modifiers.append("command down")
        }
        return modifiers.joined(separator: ",")
    }

    func getModifiersAsFlags() -> NSEvent.ModifierFlags {
        var mask = NSEvent.ModifierFlags()
        if withShift {
            mask = mask.union(NSEvent.ModifierFlags.shift)
        }
        if withControl {
            mask = mask.union(NSEvent.ModifierFlags.control)
        }
        if withOption {
            mask = mask.union(NSEvent.ModifierFlags.option)
        }
        if withCommand {
            mask = mask.union(NSEvent.ModifierFlags.command)
        }
        return mask
    }
}
