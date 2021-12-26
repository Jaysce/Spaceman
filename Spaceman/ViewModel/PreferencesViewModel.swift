//
//  PreferencesViewModel.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 6/12/20.
//

import Foundation
import SwiftUI

class PreferencesViewModel: ObservableObject {
    @AppStorage("autoRefreshSpaces") private var autoRefreshSpaces = false
    @Published var selectedSpace = 0
    @Published var spaceName = ""
    var spaceNamesDict: [String: SpaceNameInfo]!
    var sortedSpaceNamesDict: [Dictionary<String, SpaceNameInfo>.Element]!
    var timer: Timer!
    
    init() {
        selectedSpace = 0
        spaceName = ""
        spaceNamesDict = [String: SpaceNameInfo]()
        sortedSpaceNamesDict = [Dictionary<String, SpaceNameInfo>.Element]()
        timer = Timer()
        if autoRefreshSpaces { startTimer() }
    }
    
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
        spaceNamesDict[key] = SpaceNameInfo(spaceNum: spaceNum, spaceName: spaceName.isEmpty ? "N/A" : spaceName)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refreshSpaces), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        timer.invalidate()
    }
    
    @objc func refreshSpaces() {
        print("Updating spaces")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
    }
}
