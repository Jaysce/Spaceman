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
    private var dict: [String: DictVal]
    
    private init(displayType: SpacemanStyle) {
        self.displayType = displayType
        
        if let data = UserDefaults.standard.value(forKey:"spaceNames") as? Data {
            let dict = try! PropertyListDecoder().decode(Dictionary<String, DictVal>.self, from: data)
            self.dict = dict
        } else {
            self.dict = [String: DictVal]()
        }
    }
    
    func changeDisplayType(to displayType: SpacemanStyle) {
        self.displayType = displayType
    }
    
    func getDisplayType() -> SpacemanStyle {
        return displayType
    }
    
    func updateValue(for key: String, withSpaceNumber num: Int, withSpaceName name: String) {
        dict[key] = DictVal(spaceNum: num, spaceName: name)
    }
    
    func updateDictionary(with dict: [String: DictVal]) {
        self.dict = dict
    }
    
    func getDict() -> [String: DictVal] {
        return dict
    }
    
    func getSortedDict() -> [Dictionary<String, DictVal>.Element] {
        let sorted = dict.sorted { (first, second) -> Bool in
            return first.value.spaceNum < second.value.spaceNum
        }
        
        return sorted
    }
}

enum SpacemanStyle: Int {
    case none, numbers, both, text
}

struct DictVal: Hashable, Codable {
    let spaceNum: Int
    let spaceName: String
}
