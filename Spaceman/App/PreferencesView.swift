//
//  ContentView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import LaunchAtLogin

struct PreferencesView: View {
    let defaults = UserDefaults.standard
    let prefs = Preferences.shared
    let sortedDict = Preferences.shared.getSortedDict()
    @State private var selectedStyle = UserDefaults.standard.integer(forKey: "displayStyle")
    @State private var selectedSpace = 0
    @State private var text = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20, content: {
            
            Picker(selection: $selectedStyle, label: Text("Style: ").font(.headline), content: {
                Text("Rectangles").tag(0)
                Text("Numbers").tag(1)
                Text("Rectangles with numbers").tag(2)
                Text("Named spaces").tag(3)
            })
            .onReceive([self.selectedStyle].publisher.first()) { value in
                var displayType = prefs.getDisplayType()
                
                switch value {
                case 0:
                    defaults.set(SpacemanStyle.none.rawValue, forKey: "displayStyle")
                    displayType = .none
                case 1:
                    defaults.set(SpacemanStyle.numbers.rawValue, forKey: "displayStyle")
                    displayType = .numbers
                case 3:
                    defaults.set(SpacemanStyle.text.rawValue, forKey: "displayStyle")
                    displayType = .text
                default:
                    defaults.set(SpacemanStyle.both.rawValue, forKey: "displayStyle")
                    displayType = .both
                }
                
                prefs.changeDisplayType(to: displayType)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
            }
            
            HStack {
                Picker(selection: $selectedSpace, label: Text("Space: ").font(.headline), content: {
                    ForEach(0..<sortedDict.count) {
                        Text(String(sortedDict[$0].value.spaceNum))
                    }
                })
                TextField("Enter name...", text: $text)
                
                Button(action: {
                    let key = sortedDict[selectedSpace].key
                    let spaceNum = sortedDict[selectedSpace].value.spaceNum
                    
                    prefs.updateValue(for: key, withSpaceNumber: spaceNum, withSpaceName: text)
                    defaults.set(try? PropertyListEncoder().encode(prefs.getDict()), forKey: "spaceNames")
                    
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
