//
//  AboutView.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 9/12/20.
//

import SwiftUI

struct AboutView: View {

    var body: some View {
        HStack {
            Link(destination: Constants.AppInfo.repo) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                Text("Spaceman").font(.title).fontWeight(.bold)
                Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                    .foregroundColor(.secondary)
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
