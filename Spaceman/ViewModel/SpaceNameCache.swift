//
//  SpaceNameCache.swift
//  Spaceman
//
//  Created by René Uittenbogaard on 02/09/2024.
//

import Foundation
import SwiftUI

class SpaceNameCache {
    @AppStorage("spaceNameCache")  private var spaceNameCacheString: String = ""
    private let empty = Array.init(repeating: "-", count: 5)
    
    var cache: [String] {
        get {
            if let data = spaceNameCacheString.data(using: .utf8) {
                let decoded = try? JSONDecoder().decode([String].self, from: data)
                if (decoded != nil) {
                    return decoded!
                }
            }
            return empty
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                spaceNameCacheString = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    func extend() {
        cache.append(contentsOf: empty)
    }
}
