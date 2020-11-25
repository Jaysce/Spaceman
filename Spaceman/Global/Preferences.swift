//
//  Preferences.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 24/11/20.
//

import Foundation

class Preferences {
    static let shared = Preferences(displayType: .both)
    private var displayType: DisplayType
    
    private init(displayType: DisplayType) {
        self.displayType = displayType
    }
    
    func changeDisplayType(to displayType: DisplayType) {
        self.displayType = displayType
    }
    
    func getDisplayType() -> DisplayType {
        return displayType
    }
}

enum DisplayType {
    case numbers, text, none, both
}
