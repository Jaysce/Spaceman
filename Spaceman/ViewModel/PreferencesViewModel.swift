//
//  PreferencesViewModel.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 6/12/20.
//

import Foundation
import SwiftUI

class PreferencesViewModel: ObservableObject {
    @Published var selectedSpace = 0
    @Published var spaceName = ""
    var spaceNamesDict = [String: SpaceNameInfo]()
    var sortedSpaceNamesDict = [Dictionary<String, SpaceNameInfo>.Element]()
    
    func loadData() {
        guard let data = UserDefaults.standard.value(forKey:"spaceNames") as? Data else {
            return
        }
        
        self.selectedSpace = 0
        let decoded = try! PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data)
        self.spaceNamesDict = decoded
        
        let sorted = spaceNamesDict.sorted { (first, second) -> Bool in
            return first.value.spaceNum < second.value.spaceNum
        }
        
        sortedSpaceNamesDict = sorted
    }
    
    func updateSpace() {
        let key = sortedSpaceNamesDict[selectedSpace].key
        let spaceNum = sortedSpaceNamesDict[selectedSpace].value.spaceNum
        spaceNamesDict[key] = SpaceNameInfo(spaceNum: spaceNum, spaceName: spaceName)
    }
}
