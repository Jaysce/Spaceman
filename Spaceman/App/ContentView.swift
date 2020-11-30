//
//  ContentView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI

struct ContentView: View {
    let defaults = UserDefaults.standard
    let prefs = Preferences.shared
    let sortedDict = Preferences.shared.getSortedDict()
    @State private var selectedStyle = UserDefaults.standard.integer(forKey: "displayStyle")
    @State private var selectedSpace = 0
    @State private var text = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Picker(selection: $selectedStyle, label: Text("Style:"), content: {
                    Text("Block").tag(0)
                    Text("Numbers").tag(1)
                    Text("Both").tag(2)
                    Text("Text").tag(3)
                })
                .pickerStyle(RadioGroupPickerStyle())
                
                HStack {
                    Picker(selection: $selectedSpace, label: Text("Space Text:"), content: {
                        ForEach(0..<sortedDict.count) { num in
                            Text(String(sortedDict[num].value.spaceNum))
                        }
                    })
                    TextField("Enter space name up to 3 letters", text: $text)
                }
                
                Button(action: {
                    switch selectedStyle {
                    case 0:
                        defaults.set(SpacemanStyle.none.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .none)
                    case 1:
                        defaults.set(SpacemanStyle.numbers.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .numbers)
                    case 3:
                        defaults.set(SpacemanStyle.text.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .text)
                        prefs.updateValue(for: sortedDict[selectedSpace].key, withSpaceNumber: sortedDict[selectedSpace].value.spaceNum, withSpaceName: text)
                        defaults.set(try? PropertyListEncoder().encode(prefs.getDict()), forKey: "spaceNames")
                    default:
                        defaults.set(SpacemanStyle.both.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .both)
                    }

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
                }, label: {
                    Text("Update")
                })
                .pickerStyle(RadioGroupPickerStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
