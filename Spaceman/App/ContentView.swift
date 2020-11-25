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
    @State private var selectedStyle = UserDefaults.standard.integer(forKey: "displayStyle")
    
    var body: some View {
        HStack {
            VStack {
                Picker(selection: $selectedStyle, label: Text("Style:"), content: {
                    Text("Block").tag(0)
                    Text("Numbers").tag(1)
                    Text("Both").tag(2)
                })
                .pickerStyle(RadioGroupPickerStyle())
                
                Button(action: {
                    switch selectedStyle {
                    case 0:
                        defaults.set(SpacemanStyle.none.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .none)
                    case 1:
                        defaults.set(SpacemanStyle.numbers.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .numbers)
                    default:
                        defaults.set(SpacemanStyle.both.rawValue, forKey: "displayStyle")
                        prefs.changeDisplayType(to: .both)
                    }
                }, label: {
                    Text("Update")
                })
                .pickerStyle(RadioGroupPickerStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
