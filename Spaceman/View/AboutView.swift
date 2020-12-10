//
//  AboutView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 9/12/20.
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        HStack {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text("Spaceman").font(.title).fontWeight(.bold)
                Text("Version: \(appVersion ?? "?")")
            }
            Spacer()
        }
        .padding(.leading, 10)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
