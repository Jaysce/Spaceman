//
//  ContentView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import LaunchAtLogin

struct PreferencesView: View {
    @AppStorage("displayStyle") private var selectedStyle = 0
    @AppStorage("spaceNames") private var data = Data()
    @State private var selectedSpace = 0
    @State private var spaceNamesDict = [String: SpaceNameInfo]()
    @State private var sortedSpaceNamesDict = [Dictionary<String, SpaceNameInfo>.Element]()
    @State private var spaceName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20, content: {
            
            Picker(selection: $selectedStyle, label: Text("Style: ").font(.headline), content: {
                Text("Rectangles").tag(0)
                Text("Numbers").tag(1)
                Text("Rectangles with numbers").tag(2)
                Text("Named spaces").tag(3)
            })
            .onChange(of: selectedStyle) { newValue in
                self.selectedStyle = newValue
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
            }
            
            HStack {
                Picker(selection: $selectedSpace, label: Text("Space: ").font(.headline), content: {
                    ForEach(0..<sortedSpaceNamesDict.count, id: \.self) {
                        Text(String(sortedSpaceNamesDict[$0].value.spaceNum))
                    }
                })
                TextField("Enter name...", text: $spaceName)
                
                Button(action: {
                    let key = sortedSpaceNamesDict[selectedSpace].key
                    let spaceNum = sortedSpaceNamesDict[selectedSpace].value.spaceNum
                    
                    spaceNamesDict[key] = SpaceNameInfo(spaceNum: spaceNum, spaceName: spaceName)
                    self.data = try! PropertyListEncoder().encode(spaceNamesDict)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
                    
                }, label: {
                    Text("Update name")
                })
            }
            
            LaunchAtLogin.Toggle() {
                Text("Launch Spaceman at login").font(.headline)
            }
        })
        .padding()
        .onAppear(perform: loadData)
        .onChange(of: data) { newValue in
            loadData()
        }
    }
    
    func loadData() {
        guard let data = UserDefaults.standard.value(forKey:"spaceNames") as? Data else {
            print("Failed to retrive data from UserDefaults (view)")
            return
        }
        
        print("Loading data from UserDefaults")
        self.selectedSpace = 0
        let decoded = try! PropertyListDecoder().decode(Dictionary<String, SpaceNameInfo>.self, from: data)
        self.spaceNamesDict = decoded
        let sorted = decoded.sorted { (first, second) -> Bool in
            return first.value.spaceNum < second.value.spaceNum
        }
        
        self.sortedSpaceNamesDict = sorted
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
