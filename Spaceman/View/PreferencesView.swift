//
//  ContentView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 23/11/20.
//

import SwiftUI
import LaunchAtLogin
import KeyboardShortcuts

struct PreferencesView: View {
    
    weak var parentWindow: PreferencesWindow!
    
    @AppStorage("displayStyle") private var selectedStyle = 0
    @AppStorage("spaceNames") private var data = Data()
    @ObservedObject private var prefsVM = PreferencesViewModel()
    
    var body: some View {
        
        VStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                CloseButton(parentWindow: parentWindow)
                AppInfo()
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            
            Divider()
            
            GeometryReader { geo in
                AnyView(
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // General
                        VStack(alignment: .leading) {
                            Text("General")
                                .font(.title2)
                                .fontWeight(.semibold)
                            LaunchAtLogin.Toggle(){Text("Launch Spaceman at login")}
                            ShortcutRecorder
                        }
                        .padding()
                        .frame(width: geo.size.width, height: geo.size.height / 2, alignment: .topLeading)
                        
                        Divider()
                        
                        // Spaces
                        VStack(alignment: .leading) {
                            Text("Spaces")
                                .font(.title2)
                                .fontWeight(.semibold)
                            StylePicker
                            SpaceNameEditor.disabled(selectedStyle != 3 ? true : false)
                        }
                        .padding()
                        .frame(width: geo.size.width, height: geo.size.height / 2, alignment: .topLeading)
                        
                    }
                )
            }
            
        }
        .ignoresSafeArea()
        .onAppear(perform: prefsVM.loadData)
        .onChange(of: data) { _ in
            prefsVM.loadData()
        }
        
    }
    
    struct CloseButton: View {
        
        weak var parentWindow: PreferencesWindow!
        
        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Button {
                        parentWindow.close()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading, 12)
                    Spacer()
                }
                Spacer()
            }
        }
        
    }
    
    struct AppInfo: View {
        
        var body: some View {
            HStack(spacing: 8) {
                HStack {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Spaceman").font(.headline)
                        Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                HStack {
                    Button {
                        NSWorkspace.shared.open(Constants.AppInfo.repo)
                    } label: {
                        Text("GitHub").font(.system(size: 12))
                    }
                    .buttonStyle(LinkButtonStyle())
                    
                    Button {
                        NSWorkspace.shared.open(Constants.AppInfo.website)
                    } label: {
                        Text("Website").font(.system(size: 12))
                    }
                    .buttonStyle(LinkButtonStyle())
                    .disabled(true)
                }
            }
            .padding(.horizontal, 18)
        }
        
    }
    
    private var StylePicker: some View {
        Picker(selection: $selectedStyle, label: Text("Style")) {
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
            Picker(selection: $prefsVM.selectedSpace, label: Text("Space")) {
                ForEach(0..<prefsVM.sortedSpaceNamesDict.count, id: \.self) {
                    Text(String(prefsVM.sortedSpaceNamesDict[$0].value.spaceNum))
                }
            }
            TextField(
                "Name (max 3 char.)",
                text: Binding(
                    get: {prefsVM.spaceName},
                    set: {prefsVM.spaceName = $0.prefix(3).trimmingCharacters(in: .whitespacesAndNewlines)}),
                onCommit: updateName)
            
            Button("Update name") {
                updateName()
            }
        }
    }
    
    private var ShortcutRecorder: some View {
        HStack {
            Text("Force icon refresh shortcut")
            Spacer()
            KeyboardShortcuts.Recorder(for: .refresh)
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
