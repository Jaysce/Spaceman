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
    @ObservedObject private var prefsVM = PreferencesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20, content: {
            Picker(selection: $selectedStyle, label: Text("Style: ").font(.headline), content: {
                Text("Rectangles").tag(0)
                Text("Numbers").tag(1)
                Text("Rectangles with numbers").tag(2)
                Text("Named spaces").tag(3)
            })
            .onChange(of: selectedStyle) { val in
                selectedStyle = val
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
            }
            HStack {
                Picker(selection: $prefsVM.selectedSpace, label: Text("Space: ").font(.headline), content: {
                    ForEach(0..<prefsVM.sortedSpaceNamesDict.count, id: \.self) {
                        Text(String(prefsVM.sortedSpaceNamesDict[$0].value.spaceNum))
                    }
                })
                TextField("Enter name...", text: $prefsVM.spaceName)
                
                Button(action: {
                    prefsVM.updateSpace()
                    self.data = try! PropertyListEncoder().encode(prefsVM.spaceNamesDict)
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
        .onAppear(perform: prefsVM.loadData)
        .onChange(of: data) { _ in
            prefsVM.loadData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
