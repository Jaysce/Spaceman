//
//  Preferences.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 24/11/20.
//

import Foundation

enum SpacemanStyle: Int {
    case none, numbers, both, text
}

struct SpaceNameInfo: Hashable, Codable {
    let spaceNum: Int
    let spaceName: String
}
