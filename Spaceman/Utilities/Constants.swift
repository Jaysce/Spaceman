//
//  Constants.swift
//  Spaceman
//
//  Created by Sasindu Jayasinghe on 7/11/21.
//

import Foundation

enum Constants {
    
    enum AppInfo {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let repo = URL(string: "https://github.com/Jaysce/Spaceman")!
        static let website = URL(string: "https://jaysce.dev/projects/spaceman")!
    }
    
}
