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
    @AppStorage("autoRefreshSpaces") private var autoRefreshSpaces = false
    @StateObject private var prefsVM = PreferencesViewModel()
    
    // MARK: - Main Body
    var body: some View {
        
        VStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                closeButton
                appInfo
            }
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .center)
            .offset(y: 1) // Looked like it was off center
            
            Divider()
                        
            preferencePanes
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear(perform: prefsVM.loadData)
        .onChange(of: data) { _ in
            prefsVM.loadData()
        }
        
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
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
    
    // MARK: - App Info
    private var appInfo: some View {
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
            }
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - Preference Panes
    private var preferencePanes: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // General Pane
            VStack(alignment: .leading) {
                Text("General")
                    .font(.title2)
                    .fontWeight(.semibold)
                LaunchAtLogin.Toggle(){Text("Launch Spaceman at login")}
                Toggle("Refresh spaces in background", isOn: $autoRefreshSpaces)
                shortcutRecorder.disabled(autoRefreshSpaces ? true : false)
            }
            .padding()
            .onChange(of: autoRefreshSpaces) { enabled in
                if enabled {
                    prefsVM.startTimer()
                    KeyboardShortcuts.disable(.refresh)
                }
                else {
                    prefsVM.pauseTimer()
                    KeyboardShortcuts.enable(.refresh)
                }
            }
            
            Divider()
            
            // Spaces Pane
            VStack(alignment: .leading) {
                Text("Spaces")
                    .font(.title2)
                    .fontWeight(.semibold)
//                Toggle("Use single icon indicator", isOn: .constant(false)) // TODO: Implement this
                spacesStylePicker
                spaceNameEditor.disabled(selectedStyle != SpacemanStyle.text.rawValue ? true : false)
            }
            .padding()
            
        }
    }
    
    // MARK: - Shortcut Recorder
    private var shortcutRecorder: some View {
        HStack {
            Text("Force icon refresh shortcut")
            Spacer()
            KeyboardShortcuts.Recorder(for: .refresh)
        }
    }
    
    // MARK: - Style Picker
    private var spacesStylePicker: some View {
        Picker(selection: $selectedStyle, label: Text("Style")) {
            Text("Rectangles").tag(SpacemanStyle.none.rawValue)
            Text("Numbers").tag(SpacemanStyle.numbers.rawValue)
            Text("Rectangles with numbers").tag(SpacemanStyle.numbersAndRects.rawValue)
            Text("Rectangles with desktop numbers").tag(SpacemanStyle.desktopNumbersAndRects.rawValue)
            Text("Named spaces").tag(SpacemanStyle.text.rawValue)
        }
        .onChange(of: selectedStyle) { val in
            selectedStyle = val
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonPressed"), object: nil)
        }
    }
    
    // MARK: - Space Name Editor
    private var spaceNameEditor: some View {
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
    
    // MARK: - Update Name Method
    private func updateName() {
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
