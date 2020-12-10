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
            StylePicker
            SpaceNameEditor
            LaunchAtLogin.Toggle(){Text("Launch Spaceman at login").font(.headline)}
        })
        .padding()
        .onAppear(perform: prefsVM.loadData)
        .onChange(of: data) { _ in
            prefsVM.loadData()
        }
    }
    
    private var StylePicker: some View {
        Picker(selection: $selectedStyle, label: Text("Style: ").font(.headline)) {
            Text("Rectangles").tag(0)
            Text("Numbers").tag(1)
            Text("Rectangles with numbers").tag(2)
            Text("Named spaces").tag(3)
        }
        .onChange(of: selectedStyle) { val in
            selectedStyle = val
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
        }
    }
    
    private var SpaceNameEditor: some View {
        HStack {
            Picker(selection: $prefsVM.selectedSpace, label: Text("Space: ").font(.headline)) {
                ForEach(0..<prefsVM.sortedSpaceNamesDict.count, id: \.self) {
                    Text(String(prefsVM.sortedSpaceNamesDict[$0].value.spaceNum))
                }
            }
            TextField("Name (3 char.)", text: Binding(get: {prefsVM.spaceName}, set: {prefsVM.spaceName = $0.prefix(3).trimmingCharacters(in: .whitespacesAndNewlines)}), onCommit: updateName)
            
            Button("Update name") {
                updateName()
            }
        }
    }
    
    func updateName() {
        prefsVM.updateSpace()
        self.data = try! PropertyListEncoder().encode(prefsVM.spaceNamesDict)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
