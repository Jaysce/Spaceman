//
//  Preferences.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 24/11/20.
//

import Foundation

class Preferences {
    static let shared = Preferences(displayType: SpacemanStyle(rawValue: UserDefaults.standard.integer(forKey: "displayStyle"))!)
    private var displayType: SpacemanStyle
    
    private init(displayType: SpacemanStyle) {
        self.displayType = displayType
    }
    
    func changeDisplayType(to displayType: SpacemanStyle) {
        self.displayType = displayType
    }
    
    func getDisplayType() -> SpacemanStyle {
        return displayType
    }
}

enum SpacemanStyle: Int {
    case none, numbers, both, text
}
